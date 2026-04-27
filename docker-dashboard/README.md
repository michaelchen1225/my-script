# docker-dashboard

An interactive, color-coded Docker dashboard for the terminal. Launches directly into the running containers view and provides clean, trimmed output with container actions and prune support.

## Installation

```bash
curl -O https://raw.githubusercontent.com/michaelchen1225/my-script/refs/heads/master/docker-dashboard/docker-dashboard.sh

chmod +x docker-dashboard.sh

cp docker-dashboard.sh /usr/local/bin/docker-dashboard.sh
```

## Features

- Launches with running containers view on startup
- Interactive menu — pick a view, get formatted output, return to menu
- ANSI color-coded container status (green = running, yellow = paused, red = exited)
- Summary line on each view (counts of running, exited, dangling, etc.)
- Trimmed columns with `…` truncation — output stays within terminal width
- Numbered rows — select a container by number to open its action sub-menu
- Container actions — tail logs, follow logs, exec shell, live stats, inspect, stop, restart, remove
- Prune support — shows preview of what will be removed before confirming
- Auto-refresh — press a digit to loop the view every N seconds, any key to stop
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

## Container Actions

Select a container by number in view `[1]` or `[2]` to open its action sub-menu.

**Running container:**

| Key | Action |
|-----|--------|
| `l` | Tail logs (last 100 lines) |
| `f` | Follow logs |
| `s` | Live stats |
| `i` | Inspect (full JSON) |
| `e` | Exec shell (bash → sh fallback) |
| `t` | Stop (with confirmation) |
| `r` | Restart (with confirmation) |
| `b` | Back |

**Stopped container:**

| Key | Action |
|-----|--------|
| `l` | Tail logs |
| `i` | Inspect |
| `s` | Start |
| `d` | Remove (with confirmation) |
| `b` | Back |

## Auto-refresh

After any view loads, the bottom bar shows:

```
  [ENTER] back   [r] refresh   [1-9] auto-refresh every N seconds
```

Press a digit (e.g. `5`) to refresh every 5 seconds. Press any key to stop watch mode.

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

## Requirements

- Bash 4+
- Docker CLI
- `docker compose` plugin (for view 4)
- `python3` (for parsing compose JSON output)
