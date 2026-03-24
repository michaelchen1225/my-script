# clean disk space

### quick install

```bash
curl -k --tlsv1.2 -O https://raw.githubusercontent.com/michaelchen1225/my-script/refs/heads/master/clean-disk/clean.sh

chmod +x clean.sh

cp clean.sh /usr/local/bin/clean.sh
```

### Key features

> support Debian-based and Red Hat-based Linux distributions 
* Find largest files and directories
* Clean package cache and unused dependencies
* Clear temporary directories safely
* Vacuum systemd journal logs
* Remove old Snap versions (Debian-based systems)
* Docker system cleanup (docker system prune)
* Dry-run mode (simulate actions without making changes)
* Disk usage analysis with threshold alerts

### Option

`d`  → Disk usage analysis

`f`  → Find largest files

`1`  → Clean package cache & orphans

`2`  → Clean systemd journal logs

`3`  → Clear /tmp and /var/tmp

`4`  → Docker system prune

`5`  → Remove old Snap versions (Debian only)

`a`  → Run all cleanup tasks (1–4)

`q`  → Quit (interactive mode)

### Usage

```bash
# Run interactive mode
clean.sh

# Run in dry-run mode (no actual changes)
clean.sh --dry-run

# Execute specific tasks directly
clean.sh 1 3 4
```

### NOTES

* Root privileges are recommended for full cleanup functionality

* Always use `--dry-run` first if you're unsure

* Some operations (like /tmp cleanup) are safety-checked to avoid breaking running processes