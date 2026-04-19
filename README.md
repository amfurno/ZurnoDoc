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

**Run tests** 
```sh
docker compose -f docker-compose.dev.yml up --build
```

**Teardown containers and volumes:**
```sh
docker compose -f docker-compose.dev.yml down -v
```

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
