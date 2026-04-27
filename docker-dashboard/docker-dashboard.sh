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
BG_HEADER="\033[44m"

# ─── Helpers ──────────────────────────────────────────────────────────────────
header() {
  printf "\n${BG_HEADER}${BOLD}${WHITE}  %-60s${RESET}\n" "$1"
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

bottom_bar() {
  printf "\n${DIM}  [ENTER] back   [r] refresh   [1-9] auto-refresh every N seconds${RESET}  "
}

color_status() {
  local status="$1" width="${2:-0}"
  local padded
  padded=$(printf "%-${width}s" "$status")
  case "${status,,}" in
    *up*)                       printf "${GREEN}%s${RESET}"  "$padded" ;;
    *paused*)                   printf "${YELLOW}%s${RESET}" "$padded" ;;
    *exited*|*dead*|*removing*) printf "${RED}%s${RESET}"    "$padded" ;;
    *)                          printf "${WHITE}%s${RESET}"  "$padded" ;;
  esac
}

trunc() {
  local str="$1" max="$2"
  if (( ${#str} > max )); then
    printf "%s" "${str:0:$((max-1))}…"
  else
    printf "%-${max}s" "$str"
  fi
}

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

# Show what will be removed, then ask for confirmation before running a prune
prune_confirm() {
  local label="$1"; shift
  printf "${YELLOW}  Run: ${BOLD}docker %s${RESET}${YELLOW} ? (y/N): ${RESET}" "$label"
  read -r confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo
    "$@" 2>&1
    printf "\n${GREEN}  Done.${RESET}\n"
    sleep 1
    return 0
  fi
  return 1
}

prune_section() {
  divider
  printf "\n  ${BOLD}Prune:${RESET}  "
  printf "%b  " "$1"
}

# ─── Container action sub-menu ────────────────────────────────────────────────
container_actions() {
  local name="$1" image="$2" status="$3" ports="$4"
  local is_running=false
  [[ "${status,,}" == *"up"* ]] && is_running=true

  while true; do
    printf "\n"
    printf "${CYAN}${BOLD}  ┌─ %s ${RESET}\n" "$name"
    printf "${CYAN}  │${RESET}  Image:  %s\n" "$image"
    printf "${CYAN}  │${RESET}  Status: "
    color_status "$status"
    printf "\n"
    if $is_running; then
      printf "${CYAN}  │${RESET}  Ports:  %s\n" "$(shorten_ports "$ports")"
    fi
    printf "${CYAN}${BOLD}  └──────────────────────────────────────────${RESET}\n"
    printf "\n"

    if $is_running; then
      printf "  ${BOLD}[l]${RESET}  Tail logs (last 100)   ${BOLD}[f]${RESET}  Follow logs\n"
      printf "  ${BOLD}[s]${RESET}  Live stats             ${BOLD}[i]${RESET}  Inspect\n"
      printf "  ${BOLD}[e]${RESET}  Exec shell\n"
      printf "\n"
      printf "  ${BOLD}[t]${RESET}  Stop                   ${BOLD}[r]${RESET}  Restart\n"
    else
      printf "  ${BOLD}[l]${RESET}  Tail logs (last 100)   ${BOLD}[i]${RESET}  Inspect\n"
      printf "\n"
      printf "  ${BOLD}[s]${RESET}  Start                  ${BOLD}[d]${RESET}  Remove\n"
    fi

    printf "\n  ${BOLD}[b]${RESET}  Back\n"
    printf "\n  Choose: "
    read -rsn1 action
    echo

    case "$action" in
      l) docker logs --tail=100 "$name" 2>&1 | less -R ;;
      f) $is_running && docker logs -f --tail=20 "$name" ;;
      s)
        if $is_running; then
          docker stats "$name"
        else
          printf "${YELLOW}  Start '${name}'? (y/N): ${RESET}"
          read -r c; [[ "$c" =~ ^[Yy]$ ]] && docker start "$name" && return
        fi
        ;;
      i) docker inspect "$name" 2>&1 | less -R ;;
      e)
        if $is_running; then
          docker exec -it "$name" bash 2>/dev/null || docker exec -it "$name" sh
        fi
        ;;
      t)
        if $is_running; then
          printf "${YELLOW}  Stop '${name}'? (y/N): ${RESET}"
          read -r c
          [[ "$c" =~ ^[Yy]$ ]] && docker stop "$name" \
            && printf "${GREEN}  Stopped.${RESET}\n" && sleep 1 && return
        fi
        ;;
      r)
        if $is_running; then
          printf "${YELLOW}  Restart '${name}'? (y/N): ${RESET}"
          read -r c
          [[ "$c" =~ ^[Yy]$ ]] && docker restart "$name" \
            && printf "${GREEN}  Restarted.${RESET}\n" && sleep 1 && return
        fi
        ;;
      d)
        if ! $is_running; then
          printf "${RED}  Remove '${name}'? Cannot be undone. (y/N): ${RESET}"
          read -r c
          [[ "$c" =~ ^[Yy]$ ]] && docker rm "$name" \
            && printf "${GREEN}  Removed.${RESET}\n" && sleep 1 && return
        fi
        ;;
      b|'') return ;;
    esac
  done
}

# ─── Views ────────────────────────────────────────────────────────────────────

view_running_containers() {
  local selecting=true
  while $selecting; do
    selecting=false
    header "Running Containers  (docker ps)"
    divider

    local data
    data=$(docker ps --format '{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}' 2>&1)

    if [[ -z "$data" ]]; then
      printf "${YELLOW}  No running containers.${RESET}\n"
      return
    fi

    local count
    count=$(echo "$data" | wc -l)
    summary "$count running container(s)"
    divider
    printf "${BOLD}  %-4s %-20s %-22s %-22s %s${RESET}\n" "#" "NAME" "IMAGE" "STATUS" "PORTS"
    divider

    local i=1
    local -a _names _images _statuses _ports
    while IFS=$'\t' read -r name image status ports; do
      printf "  ${CYAN}${BOLD}[%-2s]${RESET} %s %s " "$i" "$(trunc "$name" 20)" "$(trunc "$image" 22)"
      color_status "$status" 22
      printf " %s\n" "$(shorten_ports "$ports")"
      _names+=("$name"); _images+=("$image"); _statuses+=("$status"); _ports+=("$ports")
      (( i++ ))
    done <<< "$data"

    printf "\n${YELLOW}  Select container [1-${count}] or ENTER to skip: ${RESET}"
    read -r sel
    if [[ "$sel" =~ ^[0-9]+$ ]] && (( sel >= 1 && sel <= count )); then
      local idx=$(( sel - 1 ))
      clear
      container_actions "${_names[$idx]}" "${_images[$idx]}" "${_statuses[$idx]}" "${_ports[$idx]}"
      clear
      selecting=true
    fi
  done
}

view_all_containers() {
  local selecting=true
  while $selecting; do
    selecting=false
    header "All Containers  (docker ps -a)"
    divider

    local data
    data=$(docker ps -a --format '{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}' 2>&1)

    if [[ -z "$data" ]]; then
      printf "${YELLOW}  No containers found.${RESET}\n"
      return
    fi

    local running exited total other
    running=$(docker ps -q | wc -l)
    exited=$(docker ps -a --filter status=exited -q | wc -l)
    total=$(docker ps -aq | wc -l)
    other=$(( total - running - exited ))

    summary "Total: $total  |  Running: $running  |  Exited: $exited  |  Other: $other"
    divider
    printf "${BOLD}  %-4s %-20s %-22s %s${RESET}\n" "#" "NAME" "IMAGE" "STATUS"
    divider

    local i=1
    local -a _names _images _statuses _ports
    while IFS=$'\t' read -r name image status ports; do
      printf "  ${CYAN}${BOLD}[%-2s]${RESET} %s %s " "$i" "$(trunc "$name" 20)" "$(trunc "$image" 22)"
      color_status "$status"
      echo
      _names+=("$name"); _images+=("$image"); _statuses+=("$status"); _ports+=("$ports")
      (( i++ ))
    done <<< "$data"

    # ── Prune stopped containers ──────────────────────────────────────────────
    prune_section "${BOLD}[p]${RESET} remove all stopped containers   ENTER to skip"
    read -rsn1 pk
    echo
    if [[ "$pk" == "p" || "$pk" == "P" ]]; then
      local stopped
      stopped=$(docker ps -a --filter status=exited --filter status=dead \
        --filter status=created --format "    {{.Names}}  ({{.Status}})" 2>/dev/null)
      if [[ -z "$stopped" ]]; then
        printf "\n${DIM}  No stopped containers.${RESET}\n"; sleep 1
      else
        printf "\n${BOLD}  Stopped containers that will be removed:${RESET}\n"
        echo "$stopped"
        echo
        prune_confirm "container prune -f" docker container prune -f
      fi
      selecting=true
    elif [[ "$pk" =~ ^[0-9]+$ ]] && (( pk >= 1 && pk <= total )); then
      local idx=$(( pk - 1 ))
      clear
      container_actions "${_names[$idx]}" "${_images[$idx]}" "${_statuses[$idx]}" "${_ports[$idx]}"
      clear
      selecting=true
    fi
  done
}

view_images() {
  local redisplay=true
  while $redisplay; do
    redisplay=false
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

    # ── Prune ─────────────────────────────────────────────────────────────────
    prune_section "${BOLD}[d]${RESET} dangling only   ${BOLD}[a]${RESET} all unused   ENTER to skip"
    read -rsn1 pk
    echo
    case "$pk" in
      d)
        local dlist
        dlist=$(docker images -f dangling=true \
          --format "    <none>:<none>  {{.Size}}  ({{.CreatedSince}})" 2>/dev/null)
        if [[ -z "$dlist" ]]; then
          printf "\n${DIM}  No dangling images.${RESET}\n"; sleep 1
        else
          printf "\n${BOLD}  Dangling images that will be removed:${RESET}\n"
          echo "$dlist"
          echo
          prune_confirm "image prune -f" docker image prune -f
        fi
        redisplay=true
        ;;
      a)
        printf "\n${BOLD}  All images present (only those unused by any container will be removed):${RESET}\n"
        docker images --format "    {{.Repository}}:{{.Tag}}  {{.Size}}" 2>/dev/null
        echo
        prune_confirm "image prune -a -f" docker image prune -a -f
        redisplay=true
        ;;
    esac
  done
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
  tip "docker compose -p <name> ps            — list containers in a project"
  tip "docker compose -p <name> logs --tail=50 — view recent logs"
}

view_volumes() {
  local redisplay=true
  while $redisplay; do
    redisplay=false
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

    # ── Prune ─────────────────────────────────────────────────────────────────
    prune_section "${BOLD}[p]${RESET} all unused volumes   ENTER to skip"
    read -rsn1 pk
    echo
    if [[ "$pk" == "p" || "$pk" == "P" ]]; then
      local vlist
      vlist=$(docker volume ls -f dangling=true --format "    {{.Name}}" 2>/dev/null)
      if [[ -z "$vlist" ]]; then
        printf "\n${DIM}  No unused volumes.${RESET}\n"; sleep 1
      else
        printf "\n${BOLD}  Unused volumes that will be removed:${RESET}\n"
        echo "$vlist"
        echo
        prune_confirm "volume prune -f" docker volume prune -f
      fi
      redisplay=true
    fi
  done
}

view_networks() {
  local redisplay=true
  while $redisplay; do
    redisplay=false
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

    # ── Prune ─────────────────────────────────────────────────────────────────
    prune_section "${BOLD}[p]${RESET} unused custom networks   ENTER to skip"
    read -rsn1 pk
    echo
    if [[ "$pk" == "p" || "$pk" == "P" ]]; then
      local nlist
      nlist=$(docker network ls --filter type=custom \
        --format "    {{.Name}}  ({{.Driver}})" 2>/dev/null)
      if [[ -z "$nlist" ]]; then
        printf "\n${DIM}  No custom networks to prune.${RESET}\n"; sleep 1
      else
        printf "\n${BOLD}  Custom networks not used by any container (will be removed):${RESET}\n"
        echo "$nlist"
        echo
        prune_confirm "network prune -f" docker network prune -f
      fi
      redisplay=true
    fi
  done
}

view_system_df() {
  local redisplay=true
  while $redisplay; do
    redisplay=false
    header "System Disk Usage  (docker system df)"
    divider
    echo
    docker system df
    echo

    # ── Prune ─────────────────────────────────────────────────────────────────
    prune_section "${BOLD}[p]${RESET} system prune   ${BOLD}[a]${RESET} + all unused images   ENTER to skip"
    read -rsn1 pk
    echo
    case "$pk" in
      p)
        printf "\n${BOLD}  docker system prune will remove:${RESET}\n"
        printf "    • Stopped containers\n"
        printf "    • Unused networks\n"
        printf "    • Dangling images\n"
        printf "    • Dangling build cache\n"
        echo
        prune_confirm "system prune -f" docker system prune -f
        redisplay=true
        ;;
      a)
        printf "\n${BOLD}  docker system prune -a will remove:${RESET}\n"
        printf "    • Stopped containers\n"
        printf "    • Unused networks\n"
        printf "    • ${RED}ALL unused images${RESET} (not just dangling)\n"
        printf "    • Build cache\n"
        echo
        prune_confirm "system prune -a -f" docker system prune -a -f
        redisplay=true
        ;;
    esac
  done
}

# ─── Run a view with bottom-bar controls ─────────────────────────────────────
run_view() {
  local fn="$1"
  clear
  $fn

  while true; do
    bottom_bar
    read -rsn1 key
    case "$key" in
      r|R)
        clear; $fn
        ;;
      [1-9])
        while true; do
          printf "\n${DIM}  Watching every ${key}s — press any key to stop${RESET}  "
          read -rsn1 -t "$key" && break
          clear; $fn
        done
        clear; $fn
        ;;
      '') return ;;
      *)  return ;;
    esac
  done
}

# ─── Menu ─────────────────────────────────────────────────────────────────────
show_menu() {
  clear
  printf "${BOLD}${CYAN}"
  printf "  ╔══════════════════════════════════════════╗\n"
  printf "  ║         Docker Dashboard                 ║\n"
  printf "  ╚══════════════════════════════════════════╝\n"
  printf "${RESET}\n"
  printf "  ${BOLD}[1]${RESET}  Running containers\n"
  printf "  ${BOLD}[2]${RESET}  All containers\n"
  printf "  ${BOLD}[3]${RESET}  Images\n"
  printf "  ${BOLD}[4]${RESET}  Compose projects\n"
  printf "  ${BOLD}[5]${RESET}  Volumes\n"
  printf "  ${BOLD}[6]${RESET}  Networks\n"
  printf "  ${BOLD}[7]${RESET}  System disk usage\n"
  printf "\n"
  printf "  ${BOLD}[q]${RESET}  Quit\n"
  printf "\n  Choose: "
}

# ─── Direct invocation ────────────────────────────────────────────────────────
if [[ -n "$1" ]]; then
  case "$1" in
    ps)       run_view view_running_containers ;;
    ps-a)     run_view view_all_containers ;;
    images)   run_view view_images ;;
    compose)  run_view view_compose ;;
    volumes)  run_view view_volumes ;;
    networks) run_view view_networks ;;
    df)       run_view view_system_df ;;
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
