# AGENTS.md

## Orientation

- The Rails app lives in `zurnoDoc/` — run **all** `ruby`, `rails`, `bundle`, `rubocop`, and `rspec` commands from `/workspaces/ruby-rails-postgres/zurnoDoc`, not the workspace root.
- Stack: Ruby 4.0.1, Rails 8.1.3, PostgreSQL (host `db`, user/pass `postgres/postgres`).
- Ignore any `rvm install "ruby-4.0.1"` warnings in shell output.
- App purpose: track patients, doctors, medications, doctor visits, and vitals.
- When implementing a plan, always pause between phases for confirmation.

## Dev Server

```sh
bin/dev   # starts Rails (web) + CSS watcher (css) via Foreman + Procfile.dev
```

Two processes run: `web` (`bin/rails server`) and `css` (`yarn build:css --watch`).

## Database

- PostgreSQL only — no SQLite fallback. The `db` Docker service must be running.
- Bootstrap: `bin/setup` (installs gems, runs `db:prepare`, clears logs/tmp, then launches `bin/dev`).
- Migrations only: `bin/rails db:prepare`.
- Separate schema files for Solid stack (do not edit manually): `db/cable_schema.rb`, `db/cache_schema.rb`, `db/queue_schema.rb`.

## CSS / Assets

- Bulma CSS via `cssbundling-rails` + Sass. Asset pipeline is **Propshaft** (not Sprockets).
- Build CSS once: `yarn build:css`
- Install Bulma from scratch: `rails css:install:bulma`

## Testing

- RSpec only — no Minitest. Run from `zurnoDoc/`:
  ```sh
  bin/rails db:test:prepare                #only once
  bundle exec rspec                        # full suite
  bundle exec rspec spec/path/to/file_spec.rb  # focused
  ```
- SimpleCov starts automatically via `spec/rails_helper.rb` — coverage report written after every run.
- System tests use Capybara + Selenium (`spec/system/`).
- All new code must have specs.

## Linting / Formatting

```sh
rubocop -a          # autocorrect (run first)
rubocop             # check remaining offenses (fix manually)
```

- Style base: `rubocop-rails-omakase` (inherited in `.rubocop.yml`).
- `rubocop-rspec` cop set is also active.
- TargetRubyVersion is 4.0.

## CI Pipeline

Five GitHub Actions jobs (all run from `zurnoDoc/`):

| Job | Command |
|---|---|
| `scan_ruby` | `bin/brakeman --no-pager` + `bin/bundler-audit` |
| `scan_js` | `bin/importmap audit` |
| `lint` | `bin/rubocop -f github` |
| `test` | `bin/rails db:test:prepare test` |
| `system-test` | `bin/rails db:test:prepare test:system` |

No PostgreSQL service block is configured in CI — tests that need the DB may fail in CI without it.

## Current Schema

| Table | Key columns |
|---|---|
| `patients` | `user_id` (FK, not null), `name` (not null) |
| `doctors` | `patient_id` (FK, not null), `name`, `practice`, `speciality`, `address`, `phone_number`, `fax_number`, `email` |
| `medications` | `patient_id` (FK, not null), `doctor_id` (FK, null), `name` (not null), `drug_class`, `dosage`, `date_started`, `date_stopped`, `notes`, `side_effects` |
| `users` | `email_address` (unique, normalised to lowercase+stripped), `password_digest` |
| `sessions` | `user_id` (FK), `ip_address`, `user_agent` |

Routes: `resources :patients do; resources :doctors; resources :medications; end`, `resource :session`, `resources :passwords, param: :token`, `resources :users, only: [:new, :create]`. Root → `patients#index`.

## Patient — Ownership Layer

`Patient` is the connector between `User` (authentication) and all medical records.

**Ownership chain:** `User → has_many :patients → has_many :doctors / :medications`

**Dependent destroy cascade:** destroying a `User` destroys all their `Patient` records; destroying a `Patient` destroys all their `Doctor` and `Medication` records (all medical models follow this pattern — `belongs_to :patient` with `has_many :<model>, dependent: :destroy` on `Patient`).

**Models**
- `Patient` — `belongs_to :user`, `has_many :doctors, dependent: :destroy`, `has_many :medications, dependent: :destroy`, `validates :name, presence: true`.
- `User` — `has_many :patients, dependent: :destroy`.
- `Doctor` — `belongs_to :patient`, `validates :name, presence: true`.
- `Medication` — `belongs_to :patient`, `belongs_to :doctor, optional: true`, `validates :name, presence: true`. Column `drug_class` stores the medication class (not `class` — reserved word).

**Routing** — both doctors and medications are fully nested under patients. Named helpers: `patient_doctors_path`, `patient_doctor_path`, `new_patient_doctor_path`, `edit_patient_doctor_path`; `patient_medications_path`, `patient_medication_path`, `new_patient_medication_path`, `edit_patient_medication_path`.

**Scoping** — all controllers scope queries through `Current.user.patients` so users can only access their own data. `PatientsController` uses `Current.user.patients.find(params[:id])`; `DoctorsController` and `MedicationsController` resolve the parent patient first via the same scope before querying their respective records.

## Authentication

Implemented via `bin/rails generate authentication` (Rails 8 built-in).

**Models**
- `User` — `has_secure_password`, `has_many :sessions, dependent: :destroy`, `has_many :patients, dependent: :destroy`, `normalizes :email_address`, `validates :email_address, presence: true, uniqueness: true`.
- `Session` — `belongs_to :user`, stores `ip_address` and `user_agent`.
- `Patient` — `belongs_to :user`, `has_many :doctors, dependent: :destroy`, `has_many :medications, dependent: :destroy`, `validates :name, presence: true`.
- `Doctor` — `belongs_to :patient`, `validates :name, presence: true`.
- `Medication` — `belongs_to :patient`, `belongs_to :doctor, optional: true`, `validates :name, presence: true`.
- `Current < ActiveSupport::CurrentAttributes` — exposes `Current.session` and `Current.user` per-request.

**Concern** — `app/controllers/concerns/authentication.rb` is `include`d by `ApplicationController`, which sets `before_action :require_authentication` on every action. Key helpers available in controllers and views:
- `require_authentication` — redirects unauthenticated requests to `new_session_path`, saving the visited URL in `session[:return_to_after_authenticating]`.
- `allow_unauthenticated_access` — class-level method to skip the guard (used by `SessionsController`, `PasswordsController`, `UsersController`).
- `authenticated?` — boolean view helper.
- `start_new_session_for(user)` — creates a `Session` record and writes a signed, `httponly`, `same_site: :lax` cookie.
- `terminate_session` — destroys `Current.session` and deletes the cookie.

**Controllers**
- `PatientsController` — full CRUD (`index`/`show`/`new`/`create`/`edit`/`update`/`destroy`); all queries scoped through `Current.user.patients`.
- `DoctorsController` — full CRUD; parent patient resolved via `Current.user.patients.find(params[:patient_id])` before every action; doctor queries scoped through `@patient.doctors`.
- `MedicationsController` — full CRUD; same pattern as `DoctorsController`; medication queries scoped through `@patient.medications`; `index` assigns `@active_medications` (`date_stopped: nil`) and `@past_medications` (`date_stopped` present); `set_doctors` populates `@doctors` for the form select (scoped to `@patient.doctors`).
- `SessionsController` — sign-in (`new`/`create`/`destroy`); rate-limited to 10 POSTs per 3 minutes.
- `PasswordsController` — forgot/reset password flow; reset token valid for 15 minutes.
- `UsersController` — sign-up (`new`/`create`); auto-signs-in on success via `start_new_session_for`.

**Sign-up flow** — no generator output; manually implemented. Validates presence + uniqueness of email and `has_secure_password` constraints (presence on create, ≤ 72 bytes). No custom password complexity rules.

**No authorisation layer yet** — all authenticated users have equal access.
