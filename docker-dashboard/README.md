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
- Trimmed columns — only the most useful fields shown
- Auto-refresh mode — set an interval and the view reloads automatically
- Tip block — relevant `docker` commands suggested at the bottom of each view
- Direct invocation — skip the menu by passing a subcommand

## Menu Options

| Key | View | Command |
|-----|------|---------|
| 1 | Running containers | `docker ps` |
| 2 | All containers | `docker ps -a` |
| 3 | Images | `docker image ls` |
| 4 | Compose projects | `docker compose ls` |
| 5 | Volumes | `docker volume ls` |
| 6 | Networks | `docker network ls` |
| 7 | System disk usage | `docker system df` |
| q | Quit | — |

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
