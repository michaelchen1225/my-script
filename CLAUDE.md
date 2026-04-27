# CLAUDE.md — Project Guidelines

## Project Overview

A collection of standalone Bash utility scripts for Linux system administration. Each script lives in its own subdirectory with its own `README.md` and is designed to be installed system-wide at `/usr/local/bin/`.

**GitHub repo:** `https://github.com/michaelchen1225/my-script`

---

## Repository Structure

```
my-script/
├── README.md              ← Root index: one entry per script with quick-install commands
├── clean-disk/
│   ├── clean.sh           ← Disk cleanup & analysis (interactive menu or direct args)
│   └── README.md
├── docker-dashboard/
│   ├── docker-dashboard.sh ← Interactive Docker dashboard (containers, images, prune, actions)
│   └── README.md
├── docker-info/
│   ├── docker-info.sh     ← Read-only Docker inspection (containers, images, disk usage)
│   └── README.md
├── install-krew/
│   ├── krew-plug.sh       ← Batch Kubernetes krew plugin installer
│   └── README.md
├── let-encrypt/
│   ├── renew_cert.sh      ← Automated Let's Encrypt cert renewal via Dockerized certbot
│   └── README.md
└── quick-sed/
    ├── quick-sed.sh       ← Interactive sed wrapper with backup/diff/search modes
    ├── README.md
    └── test.txt
```

---

## Scripts Reference

| Script | File | Install name |
|---|---|---|
| quick-sed | `quick-sed/quick-sed.sh` | `quick-sed.sh` |
| clean-disk | `clean-disk/clean.sh` | `clean.sh` |
| install-krew | `install-krew/krew-plug.sh` | `krew-plug.sh` |
| let's encrypt | `let-encrypt/renew_cert.sh` | `renew_cert.sh` |
| docker-info | `docker-info/docker-info.sh` | `docker-info.sh` |
| docker-dashboard | `docker-dashboard/docker-dashboard.sh` | `docker-dashboard.sh` |

---

## Conventions

- Every script is a self-contained Bash file with no external dependencies beyond standard Linux tools.
- Scripts are designed to run on Debian/Ubuntu or RHEL-based distros; multi-distro support is handled inside the script itself.
- Destructive operations (disk cleanup, docker prune, cert renewal) require root or appropriate permissions.
- All scripts are chmod +x and copied to `/usr/local/bin/` for system-wide access.

---

## Rules

### ALWAYS update README.md — for new scripts AND every change to existing scripts

**Rule 1 — Script changed (new feature, new option, behavior change, bug fix):**
Update `<folder>/README.md` to reflect the change before the task is done. No exceptions.

**Rule 2 — New script added:**
- Update the root `README.md` with a new section in this format:

```markdown
### [<display name>](./<folder-name>/)

```bash
curl -O https://raw.githubusercontent.com/michaelchen1225/my-script/refs/heads/master/<folder>/<script-file>

chmod +x <script-file>

cp <script-file> /usr/local/bin/<script-file>
```
```

- Create `<folder>/README.md` documenting: installation, features, options, usage examples, prerequisites.

**Do not consider any task complete until the relevant README.md files are updated.**
