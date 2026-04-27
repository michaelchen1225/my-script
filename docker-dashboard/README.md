# docker-dashboard

An interactive, color-coded Docker dashboard for the terminal. Displays clean, trimmed output from common Docker commands with auto-refresh support.

## Installation

```bash
curl -O https://raw.githubusercontent.com/michaelchen1225/my-script/refs/heads/master/docker-dashboard/docker-dashboard.sh

chmod +x docker-dashboard.sh

cp docker-dashboard.sh /usr/local/bin/docker-dashboard.sh
```

## Features

- Interactive menu — pick a view, get formatted output, return to menu
- ANSI color-coded container status (green = running, yellow = paused, red = exited)
- Summary line on each view (counts of running, exited, dangling, etc.)
- Trimmed columns with truncation — output stays within terminal width
- Numbered rows — select a container by number to open its action sub-menu
- Container actions — tail logs, follow logs, exec shell, live stats, inspect, stop, restart, remove
- Prune support — every relevant view has a prune section that previews what will be removed before confirming
- Auto-refresh mode — press a digit to loop the view every N seconds
- Direct invocation — skip the menu by passing a subcommand

## Menu Options

| Key | View | Command | Prune available |
|-----|------|---------|-----------------|
| 1 | Running containers | `docker ps` | — |
| 2 | All containers | `docker ps -a` | stopped containers |
| 3 | Images | `docker image ls` | dangling / all unused |
| 4 | Compose projects | `docker compose ls` | — |
| 5 | Volumes | `docker volume ls` | unused volumes |
| 6 | Networks | `docker network ls` | unused custom networks |
| 7 | System disk usage | `docker system df` | system prune / system prune -a |
| q | Quit | — | — |

## Prune behaviour

Each prune option shows a preview of exactly what will be removed before asking for confirmation:

- **Stopped containers** — lists each container name + status
- **Dangling images** — lists each image with size and age
- **All unused images** — lists all current images with a note that only unused ones are removed
- **Unused volumes** — lists volume names
- **Unused networks** — lists custom network names and drivers
- **System prune** — bullet list of affected resource types
- **System prune -a** — same but highlights that all unused images (not just dangling) are removed

## Direct Invocation

```bash
docker-dashboard.sh ps        # running containers
docker-dashboard.sh ps-a      # all containers
docker-dashboard.sh images    # images
docker-dashboard.sh compose   # compose projects
docker-dashboard.sh volumes   # volumes
docker-dashboard.sh networks  # networks
docker-dashboard.sh df        # system disk usage
```

## Auto-refresh

After any view loads, you are prompted:

```
Auto-refresh? (y/N):
Interval in seconds [5]:
```

Enter `y` and an interval to loop the view. Press `Ctrl+C` to stop.

## Requirements

- Bash 4+
- Docker CLI
- `docker compose` plugin (for option 4)
- `python3` (for parsing compose JSON output)
