# Deployment Guide

ZurnoDoc is deployed using [Kamal](https://kamal-deploy.org/), the deployment tool that ships with Rails 8. Kamal SSHes into the VM from your local machine, builds a Docker image, pushes it to Docker Hub, and manages the running containers on the server.

## Architecture

```
Your machine
    │
    │  bin/kamal deploy
    │
    ▼
Docker Hub  ──────────────────────────────────────────────────────┐
(YOURNAME/zurno_doc)                                              │
                                                                   │ docker pull
                                                              VM (Linux)
                                                      ┌────────────────────────┐
                                                      │                        │
                                                      │  [web container]       │
                                                      │  Thruster → Puma       │
                                                      │  Rails app             │
                                                      │  Solid Queue (in Puma) │
                                                      │  port 80               │
                                                      │                        │
                                                      │  [db accessory]        │
                                                      │  postgres:16           │
                                                      │  localhost:5432 only   │
                                                      │                        │
                                                      │  [volumes]             │
                                                      │  zurno_doc_storage     │
                                                      │  (Active Storage)      │
                                                      │  zurno_doc-db-data     │
                                                      │  (Postgres data)       │
                                                      └────────────────────────┘
```

**Key points:**

- **Thruster** is the HTTP proxy in front of Puma. It handles HTTP/2, static asset serving, and X-Sendfile. No Nginx needed.
- **Solid Queue** runs inside the Puma process (`SOLID_QUEUE_IN_PUMA=true`), suitable for a single-server deployment.
- **Solid Cache** and **Solid Cable** use separate Postgres databases (`zurno_doc_cache`, `zurno_doc_cable`) on the same container, keeping their write load isolated from the main app database.
- **Postgres** is bound to `127.0.0.1:5432` on the VM — it is not exposed to the internet.
- **Active Storage** files are persisted in a Docker named volume (`zurno_doc_storage`) so they survive container restarts and deploys.
- On every start the entrypoint runs `db:prepare`, which creates all four databases and loads their schemas if they don't already exist.

## Prerequisites

### On your local machine

- Docker (to build the image)
- SSH key with root access to the VM (or configure `ssh.user` in `config/deploy.yml`)
- Docker Hub account with a read/write access token

### On the VM

- A fresh Linux VM (Kamal installs Docker automatically via `kamal setup`)
- Ports 80 and 22 open in the firewall

## Configuration

Two placeholder values in [config/deploy.yml](../config/deploy.yml) must be set before first deploy:

| Placeholder | Replace with |
|---|---|
| `YOURNAME` | Your Docker Hub username (appears twice — `image` and `registry.username`) |
| `YOUR_SERVER_IP` | The VM's public IP address (appears twice — `servers.web` and `accessories.db.host`) |

## Secrets

Secrets are never committed to git. They are read from your shell environment by [.kamal/secrets](../.kamal/secrets) at deploy time.

Set up your local environment using the provided template:

```sh
cp .env.example .env
# Edit .env and fill in the values, then:
source .env
```

| Variable | Where to get it |
|---|---|
| `KAMAL_REGISTRY_PASSWORD` | Docker Hub → Account Settings → Security → New Access Token (read/write/delete scope) |
| `POSTGRES_PASSWORD` | Generate with `openssl rand -hex 32` — store it somewhere safe |

`RAILS_MASTER_KEY` is read directly from `config/master.key` by `.kamal/secrets`. Never commit `config/master.key` to git.

## First Deploy

Run once to provision the server and do the initial deploy:

```sh
source .env
bin/kamal setup
```

`kamal setup` will:
1. SSH into the VM and install Docker
2. Start the Postgres accessory container
3. Build the Rails image locally, push it to Docker Hub, pull it on the VM
4. Start the web container
5. The entrypoint runs `db:prepare` — creates all four databases and loads their schemas

## Subsequent Deploys

After any code change:

```sh
source .env
bin/kamal deploy
```

Kamal performs a zero-downtime deploy: it starts the new container, waits for the `/up` health check to pass, then switches traffic and stops the old container.

## Useful Commands

All commands are run from your local machine (they SSH into the VM):

```sh
# Tail application logs
bin/kamal logs

# Open a Rails console on the server
bin/kamal console

# Open a shell inside the web container
bin/kamal shell

# Open a database console (psql)
bin/kamal dbc

# Roll back to the previous image
bin/kamal rollback

# Restart the web container without a new deploy
bin/kamal app restart

# Check container status
bin/kamal app details

# Redeploy just the Postgres accessory (e.g. after changing its config)
bin/kamal accessory reboot db
```

## Adding SSL

When you have a domain name pointed at the VM:

1. Uncomment and configure the `proxy` block in [config/deploy.yml](../config/deploy.yml):

    ```yaml
    proxy:
      ssl: true
      host: your-domain.com
    ```

2. Uncomment in [config/environments/production.rb](../config/environments/production.rb):

    ```ruby
    config.assume_ssl = true
    config.force_ssl  = true
    ```

3. Update the mailer host:

    ```ruby
    config.action_mailer.default_url_options = { host: 'your-domain.com' }
    ```

4. Run `bin/kamal deploy`. Thruster will obtain a Let's Encrypt certificate automatically.
