# ZurnoDoc

ZurnoDoc is a Rails 8 app for tracking patient records, doctors, and medications in a simple mobile-friendly interface.

## What the app does

- lets users sign up, sign in, and manage their own records
- tracks patients owned by the signed-in user
- stores doctor contact and practice information per patient
- tracks medications, including active vs past status
- supports sorting medication lists by key fields
- protects records with authentication plus Pundit authorization

## Tech stack

- Ruby 4.0.1
- Rails 8.1.3
- PostgreSQL
- Hotwire + Importmap
- Bulma via `cssbundling-rails`
- RSpec, Capybara, RuboCop, Brakeman, Bundler Audit
- Kamal for deployment

## Data model at a glance

Ownership flows from the signed-in user down to each medical record:

`User -> Patients -> Doctors / Medications`

Key models:

- `User` has many patients and sessions
- `Patient` belongs to a user
- `Doctor` belongs to a patient
- `Medication` belongs to a patient and can optionally belong to a doctor

## Main routes

- `/` -> patients index
- `/login` -> sign in
- `/users/new` -> sign up
- `/patients`
- `/patients/:patient_id/doctors`
- `/patients/:patient_id/medications`

## Local development

### Prerequisites

- Ruby 4.0.1
- Node.js and Yarn
- PostgreSQL

The development and test configs expect a PostgreSQL server reachable at:

- host: `db`
- username: `postgres`
- password: `postgres`

### Initial setup

```sh
bundle install
yarn install
bin/setup
```

`bin/setup` installs gems, prepares the database, clears logs/tmp files, and starts the development server unless you pass `--skip-server`.

### Start the app

```sh
bin/dev
```

This runs:

- the Rails server
- the Bulma/Sass watcher for CSS changes

Open http://localhost:3000 when both processes are up.

## Database

Prepare the database manually when needed:

```sh
bin/rails db:prepare
```

Production also uses separate PostgreSQL databases for:

- Solid Queue
- Solid Cache
- Solid Cable

Do not edit these schema files manually:

- `db/cable_schema.rb`
- `db/cache_schema.rb`
- `db/queue_schema.rb`

## Testing and quality checks

### RSpec

```sh
bin/rails db:test:prepare
bundle exec rspec
```

Run a single spec file:

```sh
bundle exec rspec spec/path/to/file_spec.rb
```

### Linting

```sh
bin/rubocop
```

### CSS build

```sh
yarn build:css
```

### Security checks

```sh
bin/brakeman --no-pager
bin/bundler-audit
bin/importmap audit
```

## Docker-based test workflow

If you want to run the test suite in Docker instead of a local Ruby/PostgreSQL setup:

```sh
docker compose -f docker-compose.dev.yml build
docker compose -f docker-compose.dev.yml up --build
```

Tear everything down with:

```sh
docker compose -f docker-compose.dev.yml down -v
```

## Deployment

Production deploys use Kamal and Docker.

- app image: `amfurno/zurnodoc`
- host: `zurnodoc.com`
- proxy: Thruster in front of Puma
- database: PostgreSQL 16 accessory container

See [`docs/deploy.md`](docs/deploy.md) for the full deployment guide.

## Repository highlights

- `app/controllers/concerns/authentication.rb` handles session-based auth
- `app/policies/` contains the Pundit authorization rules
- `app/models/` contains the core medical record models
- `spec/` contains the RSpec suite
- `docker-compose.dev.yml` provides an isolated test stack

## Current focus

The current codebase is centered on:

- patient management
- doctor management
- medication tracking
- secure session-based authentication
- mobile-aware UI foundations
