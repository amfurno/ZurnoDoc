# AGENTS.md

## Orientation

- The Rails app lives in `zurnoDoc/` — run **all** `ruby`, `rails`, `bundle`, `rubocop`, and `rspec` commands from `/workspaces/ruby-rails-postgres/zurnoDoc`, not the workspace root.
- Stack: Ruby 4.0.1, Rails 8.1.3, PostgreSQL (host `db`, user/pass `postgres/postgres`).
- Ignore any `rvm install "ruby-4.0.1"` warnings in shell output.
- App purpose: track patients, doctors, medications, doctor visits, and vitals. Only the `doctors` table exists so far.

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

Single table `doctors`: `name`, `practice`, `speciality`, `address`, `phone_number`, `fax_number`, `email`.

Only route beyond health check: `resources :doctors`, root → `doctors#index`.
