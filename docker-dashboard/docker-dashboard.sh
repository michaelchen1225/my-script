#!/usr/bin/env bash

# ─── Colors ───────────────────────────────────────────────────────────────────
RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
CYAN="\033[36m"
WHITE="\033[37m"
BG_HEADER="\033[44m"   # blue background for section headers

# ─── Helpers ──────────────────────────────────────────────────────────────────
header() {
  local title="$1"
  local width=60
  printf "\n${BG_HEADER}${BOLD}${WHITE}  %-${width}s${RESET}\n" "$title"
}

tip() {
  printf "${DIM}  Tip: %s${RESET}\n" "$1"
}

summary() {
  printf "${CYAN}${BOLD}  → %s${RESET}\n" "$1"
}

divider() {
  printf "${DIM}%s${RESET}\n" "  $(printf '─%.0s' {1..62})"
}

press_any_key() {
  printf "\n${DIM}  Press any key to return to menu...${RESET}"
  read -rsn1
  echo
}

ask_refresh() {
  local interval=5
  printf "\n${YELLOW}  Auto-refresh? (y/N): ${RESET}"
  read -r ans
  if [[ "$ans" =~ ^[Yy]$ ]]; then
    printf "${YELLOW}  Interval in seconds [5]: ${RESET}"
    read -r input
    [[ "$input" =~ ^[0-9]+$ ]] && interval="$input"
    echo "$interval"
  else
    echo "0"
  fi
}

color_status() {
  local status="$1" width="${2:-0}"
  local padded
  padded=$(printf "%-${width}s" "$status")
  case "${status,,}" in
    *up*)      printf "${GREEN}%s${RESET}" "$padded" ;;
    *paused*)  printf "${YELLOW}%s${RESET}" "$padded" ;;
    *exited*|*dead*|*removing*) printf "${RED}%s${RESET}" "$padded" ;;
    *)         printf "${WHITE}%s${RESET}" "$padded" ;;
  esac
}

# Truncate to max chars, pad with spaces so columns stay aligned
trunc() {
  local str="$1" max="$2"
  if (( ${#str} > max )); then
    printf "%s" "${str:0:$((max-1))}…"
  else
    printf "%-${max}s" "$str"
  fi
}

# Keep only host->container port pairs, drop IPv6 duplicates and bare exposed ports
shorten_ports() {
  local ports="$1"
  [[ -z "$ports" ]] && { printf "-"; return; }
  local result
  result=$(printf "%s" "$ports" \
    | grep -oP '0\.0\.0\.0:\K\d+->\d+' \
    | sort -u \
    | paste -sd ',' -)
  [[ -z "$result" ]] && printf "-" || printf "%s" "$result"
}

# ─── Views ────────────────────────────────────────────────────────────────────

view_running_containers() {
  header "Running Containers  (docker ps)"
  divider

  local data
  data=$(docker ps --format '{{.Names}}\t{{.Status}}\t{{.Ports}}' 2>&1)

  if [[ -z "$data" ]]; then
    printf "${YELLOW}  No running containers.${RESET}\n"
  else
    local count
    count=$(echo "$data" | wc -l)
    summary "$count running container(s)"
    divider
    printf "${BOLD}  %-28s %-26s %s${RESET}\n" "NAME" "STATUS" "PORTS"
    divider
    while IFS=$'\t' read -r name status ports; do
      printf "  %s " "$(trunc "$name" 28)"
      color_status "$status" 26
      printf " %s\n" "$(shorten_ports "$ports")"
    done <<< "$data"
  fi
}

view_all_containers() {
  header "All Containers  (docker ps -a)"
  divider

  local data
  data=$(docker ps -a --format '{{.Names}}\t{{.Image}}\t{{.Status}}' 2>&1)

  if [[ -z "$data" ]]; then
    printf "${YELLOW}  No containers found.${RESET}\n"
  else
    local running exited other total
    running=$(docker ps -q | wc -l)
    exited=$(docker ps -a --filter status=exited -q | wc -l)
    total=$(docker ps -aq | wc -l)
    other=$(( total - running - exited ))

    summary "Total: $total  |  Running: $running  |  Exited: $exited  |  Other: $other"
    divider
    printf "${BOLD}  %-22s %-28s %s${RESET}\n" "NAME" "IMAGE" "STATUS"
    divider
    while IFS=$'\t' read -r name image status; do
      printf "  %s %s " "$(trunc "$name" 22)" "$(trunc "$image" 28)"
      color_status "$status"
      echo
    done <<< "$data"
  fi

  echo
  tip "docker start <name>          — start a stopped container"
  tip "docker rm \$(docker ps -aq --filter status=exited)  — remove all exited containers"
}

view_images() {
  header "Images  (docker image ls)"
  divider

  local data
  data=$(docker image ls --format '{{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedSince}}' 2>&1)

  if [[ -z "$data" ]]; then
    printf "${YELLOW}  No images found.${RESET}\n"
  else
    local total dangling
    total=$(docker image ls -q | wc -l)
    dangling=$(docker image ls -f dangling=true -q | wc -l)
    summary "Total: $total image(s)  |  Dangling: $dangling"
    divider
    printf "${BOLD}  %-35s %-20s %-10s %s${RESET}\n" "REPOSITORY" "TAG" "SIZE" "CREATED"
    divider
    while IFS=$'\t' read -r repo tag size created; do
      printf "  %s %s %-10s %s\n" "$(trunc "$repo" 35)" "$(trunc "$tag" 20)" "$size" "$created"
    done <<< "$data"
  fi

  echo
  tip "docker image prune -f        — remove dangling images"
  tip "docker image prune -a        — remove all unused images"
}

view_compose() {
  header "Compose Projects  (docker compose ls)"
  divider

  if ! docker compose version &>/dev/null; then
    printf "${RED}  docker compose not available.${RESET}\n"
    return
  fi

  local data
  data=$(docker compose ls --format json 2>/dev/null \
    | python3 -c "
import sys, json
rows = json.load(sys.stdin)
for r in rows:
    print(r.get('Name',''), r.get('Status',''), r.get('ConfigFiles',''), sep='\t')
" 2>/dev/null)

  if [[ -z "$data" ]]; then
    printf "${YELLOW}  No Compose projects found.${RESET}\n"
  else
    local count
    count=$(echo "$data" | wc -l)
    summary "$count compose project(s)"
    divider
    printf "${BOLD}  %-25s %-20s %s${RESET}\n" "NAME" "STATUS" "CONFIG FILE"
    divider
    while IFS=$'\t' read -r name status config; do
      printf "  %-25s " "$name"
      color_status "$status"
      printf " %s\n" "$config"
    done <<< "$data"
  fi

  echo
  tip "docker compose -p <name> ps  — list containers in a project"
  tip "docker compose -p <name> logs --tail=50  — view recent logs"
}

view_volumes() {
  header "Volumes  (docker volume ls)"
  divider

  local data
  data=$(docker volume ls --format '{{.Driver}}\t{{.Name}}' 2>&1)

  if [[ -z "$data" ]]; then
    printf "${YELLOW}  No volumes found.${RESET}\n"
  else
    local total
    total=$(docker volume ls -q | wc -l)
    summary "$total volume(s)"
    divider
    printf "${BOLD}  %-15s %s${RESET}\n" "DRIVER" "NAME"
    divider
    while IFS=$'\t' read -r driver name; do
      printf "  %-15s %s\n" "$driver" "$name"
    done <<< "$data"
  fi

  echo
  tip "docker volume rm <name>      — remove a volume"
  tip "docker volume prune          — remove all unused volumes"
}

view_networks() {
  header "Networks  (docker network ls)"
  divider

  local data
  data=$(docker network ls --format '{{.Name}}\t{{.Driver}}\t{{.Scope}}' 2>&1)

  if [[ -z "$data" ]]; then
    printf "${YELLOW}  No networks found.${RESET}\n"
  else
    local total
    total=$(docker network ls -q | wc -l)
    summary "$total network(s)"
    divider
    printf "${BOLD}  %-30s %-15s %s${RESET}\n" "NAME" "DRIVER" "SCOPE"
    divider
    while IFS=$'\t' read -r name driver scope; do
      printf "  %-30s %-15s %s\n" "$name" "$driver" "$scope"
    done <<< "$data"
  fi

  echo
  tip "docker network inspect <name>  — inspect a network"
  tip "docker network prune           — remove all unused networks"
}

view_system_df() {
  header "System Disk Usage  (docker system df)"
  divider
  echo
  docker system df
  echo
  tip "docker system prune          — remove all unused data"
  tip "docker system prune -a       — remove all unused data including unused images"
}

# ─── Run a view with optional auto-refresh ────────────────────────────────────
run_view() {
  local fn="$1"
  clear
  $fn

  local interval
  interval=$(ask_refresh)

  if [[ "$interval" -gt 0 ]]; then
    while true; do
      sleep "$interval"
      clear
      $fn
      printf "\n${DIM}  Auto-refreshing every ${interval}s — Ctrl+C to stop${RESET}\n"
    done
  else
    press_any_key
  fi
}

# ─── Menu ─────────────────────────────────────────────────────────────────────
show_menu() {
  clear
  printf "${BOLD}${CYAN}"
  printf "  ╔══════════════════════════════════════════╗\n"
  printf "  ║         Docker Dashboard                 ║\n"
  printf "  ╚══════════════════════════════════════════╝\n"
  printf "${RESET}"
  printf "\n"
  printf "  ${BOLD}[1]${RESET}  Running containers\n"
  printf "  ${BOLD}[2]${RESET}  All containers\n"
  printf "  ${BOLD}[3]${RESET}  Images\n"
  printf "  ${BOLD}[4]${RESET}  Compose projects\n"
  printf "  ${BOLD}[5]${RESET}  Volumes\n"
  printf "  ${BOLD}[6]${RESET}  Networks\n"
  printf "  ${BOLD}[7]${RESET}  System disk usage\n"
  printf "\n"
  printf "  ${BOLD}[q]${RESET}  Quit\n"
  printf "\n"
  printf "  Choose: "
}

# ─── Direct invocation support ────────────────────────────────────────────────
if [[ -n "$1" ]]; then
  case "$1" in
    ps)      run_view view_running_containers ;;
    ps-a)    run_view view_all_containers ;;
    images)  run_view view_images ;;
    compose) run_view view_compose ;;
    volumes) run_view view_volumes ;;
    networks)run_view view_networks ;;
    df)      run_view view_system_df ;;
    *)
      printf "Usage: %s [ps|ps-a|images|compose|volumes|networks|df]\n" "$(basename "$0")"
      exit 1
      ;;
  esac
  exit 0
fi

# ─── Main loop ────────────────────────────────────────────────────────────────
while true; do
  show_menu
  read -rsn1 choice
  echo
  case "$choice" in
    1) run_view view_running_containers ;;
    2) run_view view_all_containers ;;
    3) run_view view_images ;;
    4) run_view view_compose ;;
    5) run_view view_volumes ;;
    6) run_view view_networks ;;
    7) run_view view_system_df ;;
    q|Q) clear; echo "  Bye."; exit 0 ;;
    *) ;;
  esac
done
