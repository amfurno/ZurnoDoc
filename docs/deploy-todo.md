# Pre-Deploy Checklist

## Infrastructure

- [ ] Register a domain name
- [ ] Provision a Linux VM (Ubuntu 24.04 LTS recommended, min 1 vCPU / 1 GB RAM)
- [ ] Point the domain's A record at the VM's public IP
- [ ] Open ports 22 (SSH), 80 (HTTP), and 443 (HTTPS) in the VM firewall
- [ ] Add your local SSH public key to `~/.ssh/authorized_keys` on the VM (Kamal SSHes as root by default)

## Docker Hub

- [ ] Create a public (or private) repository named `zurno_doc`
- [ ] Generate a Docker Hub access token: Account Settings → Security → New Access Token (read/write/delete scope)

## Local Configuration

- [ ] In `config/deploy.yml`, replace both occurrences of `YOURNAME` with your Docker Hub username (`image` and `registry.username`)
- [ ] In `config/deploy.yml`, replace both occurrences of `YOUR_SERVER_IP` with the VM's public IP address (`servers.web` and `accessories.db.host`)
- [ ] Confirm `config/master.key` exists locally and is **not** committed to git
- [ ] Copy `.env.example` to `.env` and fill in:
  - [ ] `KAMAL_REGISTRY_PASSWORD` — Docker Hub access token from above
  - [ ] `POSTGRES_PASSWORD` — generate with `openssl rand -hex 32`, store it securely

## HTTPS / SSL

Thruster obtains and renews Let's Encrypt certificates automatically — no Certbot or separate proxy needed. It requires the domain's A record to be live and both ports 80 and 443 reachable before the first deploy with SSL enabled.

- [ ] Confirm the domain A record has propagated (`dig +short yourdomain.com` returns the VM IP)
- [ ] Confirm port 443 is open in the VM firewall (in addition to 80 and 22)
- [ ] In `config/deploy.yml`, uncomment and fill in the `proxy` block:
  ```yaml
  proxy:
    ssl: true
    host: your-domain.com
  ```
- [ ] In `config/environments/production.rb`, uncomment:
  ```ruby
  config.assume_ssl = true
  config.force_ssl  = true
  ```

> **Note:** If the certificate request fails on first deploy (e.g. DNS hasn't propagated yet), Thruster will retry on the next request. You can also deploy HTTP-only first, then add the `proxy` block and redeploy once DNS is confirmed.

## Rails Production Config

- [ ] Update `config.action_mailer.default_url_options` in `config/environments/production.rb` with your domain
- [ ] Uncomment and populate `config.hosts` in `config/environments/production.rb` with your domain

## First Deploy

- [ ] Run `source .env && bin/kamal setup`
- [ ] Verify the app is reachable at the VM's IP (HTTP) or domain (HTTPS)
- [ ] Create the first admin/user account via the sign-up page
