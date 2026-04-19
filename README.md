# README


## CSS
bulma.io
`rails css:install:bulma`


This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

## Running Tests

Tests run via Docker — no local Ruby or PostgreSQL installation required.

**Prerequisites:** Docker and Docker Compose

**Build the test image** (once, or after changing `Gemfile`):
```sh
docker compose -f docker-compose.dev.yml build
```

**Prepare the test database** (once, or after new migrations):
```sh
docker compose -f docker-compose.dev.yml run --rm app bin/rails db:test:prepare
```

**Run the full RSpec suite:**
```sh
docker compose -f docker-compose.dev.yml run --rm app bundle exec rspec
```

**Run a single spec file:**
```sh
docker compose -f docker-compose.dev.yml run --rm app bundle exec rspec spec/path/to/file_spec.rb
```

**Teardown containers and volumes:**
```sh
docker compose -f docker-compose.dev.yml down -v
```

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
