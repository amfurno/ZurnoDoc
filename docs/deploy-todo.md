# Pre-Deploy Checklist

## Infrastructure

- [x] Register a domain name via Cloudflare (cloudflare.com → Domain Registration)
- [x] Provision a Linux VM (Ubuntu 24.04 LTS recommended, min 1 vCPU / 1 GB RAM)
  - In DigitalOcean: Create → Droplets → copy the public IPv4 address once provisioned
- [x] Point the domain's A and AAAA records at the VM's public IP
  - In Cloudflare: DNS → Records → Add record
  - Add `A` record: Name `@`, IPv4 = Droplet IP, **Proxy status: DNS only** (grey cloud) — required for Thruster/Let's Encrypt SSL challenges
  - Add `A` record: Name `www`, same IPv4, DNS only
  - Add `AAAA` record: Name `@`, IPv6 = Droplet IPv6 address, DNS only (find it in DigitalOcean: Droplet → Networking → IPv6)
  - Add `AAAA` record: Name `www`, same IPv6, DNS only
  - Verify propagation: `dig +short yourdomain.com` and `dig +short AAAA yourdomain.com` should return the Droplet addresses
- [x] Open ports 22 (SSH), 80 (HTTP), and 443 (HTTPS) in the VM firewall
- [x] Add your local SSH public key to `~/.ssh/authorized_keys` on the VM (Kamal SSHes as root by default)

## Docker Hub

- [x] Create a public (or private) repository named `zurno_doc`
- [x] Generate a Docker Hub access token: Account Settings → Security → New Access Token (**Read & Write** scope is sufficient)

## Local Configuration

- [x] In `config/deploy.yml`, replace both occurrences of `YOURNAME` with your Docker Hub username (`image` and `registry.username`)
- [x] In `config/deploy.yml`, replace both occurrences of `YOUR_SERVER_IP` with the VM's public IP address (`servers.web` and `accessories.db.host`)
- [x] Confirm `config/master.key` exists locally and is **not** committed to git
- [x] Copy `.env.example` to `.env` and fill in:
  - [x] `KAMAL_REGISTRY_PASSWORD` — Docker Hub access token from above
  - [x] `POSTGRES_USER` — username for the production Postgres database (e.g. `zurno`)
  - [x] `POSTGRES_PASSWORD` — generate with `openssl rand -hex 32`, store it securely

## HTTPS / SSL

Thruster obtains and renews Let's Encrypt certificates automatically — no Certbot or separate proxy needed. It requires the domain's A record to be live and both ports 80 and 443 reachable before the first deploy with SSL enabled.

- [x] Confirm the domain A record has propagated (`dig +short yourdomain.com` returns the VM IP)
- [x] Confirm port 443 is open in the VM firewall (in addition to 80 and 22)
- [x] In `config/deploy.yml`, uncomment and fill in the `proxy` block:
  ```yaml
  proxy:
    ssl: true
    host: your-domain.com
  ```
- [x] In `config/environments/production.rb`, uncomment:
  ```ruby
  config.assume_ssl = true
  config.force_ssl  = true
  ```

> **Note:** If the certificate request fails on first deploy (e.g. DNS hasn't propagated yet), Thruster will retry on the next request. You can also deploy HTTP-only first, then add the `proxy` block and redeploy once DNS is confirmed.

## Rails Production Config

- [x] Update `config.action_mailer.default_url_options` in `config/environments/production.rb` with your domain
- [x] Uncomment and populate `config.hosts` in `config/environments/production.rb` with your domain

## First Deploy

- [ ] Run `source .env && bin/kamal setup`
- [ ] Verify the app is reachable at the VM's IP (HTTP) or domain (HTTPS)
- [ ] Create the first admin/user account via the sign-up page
