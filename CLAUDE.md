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

---

## Conventions

- Every script is a self-contained Bash file with no external dependencies beyond standard Linux tools.
- Scripts are designed to run on Debian/Ubuntu or RHEL-based distros; multi-distro support is handled inside the script itself.
- Destructive operations (disk cleanup, docker prune, cert renewal) require root or appropriate permissions.
- All scripts are chmod +x and copied to `/usr/local/bin/` for system-wide access.

---

## Rules

### README.md must be updated for every new script

**update the README.md of the script, if the script has chnaged (e.g new features, new options, etc)**


**Whenever a new script is added to this repository, you MUST update the root `README.md`** to include a new section for it. The section must follow this format:

```markdown
### [<display name>](./<folder-name>/)

```bash
curl -O https://raw.githubusercontent.com/michaelchen1225/my-script/refs/heads/master/<folder>/<script-file>

chmod +x <script-file>

cp <script-file> /usr/local/bin/<script-file>
```
```

Each new script also needs its own `README.md` inside its subdirectory documenting: installation, features, options, usage examples, and any prerequisites.

Do not mark a new-script task as complete until both the root `README.md` and the subdirectory `README.md` have been written or updated.
