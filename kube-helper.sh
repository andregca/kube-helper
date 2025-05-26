#!/usr/bin/env bash
#
# kube-helper — manage Colima + Minikube together
#
# Usage: kube-helper {start|stop|status|restart}

set -euo pipefail

###############################################################################
# Colour support  (green = Running, red = Stopped, fallback = plain)
###############################################################################
if [[ -t 1 ]] && command -v tput >/dev/null && [[ $(tput colors) -ge 8 ]]; then
  GREEN=$(tput setaf 2)
  RED=$(tput setaf 1)
  RESET=$(tput sgr0)
else
  GREEN=""; RED=""; RESET=""
fi
colorize() {           # usage: colorize TEXT COLOR_CODE
  printf '%b%b%b' "${2}" "${1}" "${RESET}"
}

state_coloured() {     # usage: state_coloured Running|Stopped
  [[ $1 == "Running" ]] && colorize "$1" "$GREEN" || colorize "$1" "$RED"
}

###############################################################################
# Config
###############################################################################
PROFILE="default"                 # Colima profile name
MINIKUBE_PROFILE="minikube"       # Minikube profile name
MINIKUBE_ARGS=(--driver=docker --container-runtime=containerd --embed-certs)

###############################################################################
# Helper predicates
###############################################################################
is_colima_running() {
  colima status --profile "$PROFILE" 2>&1 | grep -q "colima is running"
}
is_minikube_running() {
  [[ $(minikube status -p "$MINIKUBE_PROFILE" --format '{{.Host}}' 2>/dev/null || echo Stopped) == Running ]]
}

###############################################################################
# Actions
###############################################################################
start() {
  printf "▶️  Colima… "
  if is_colima_running; then echo "already running."
  else echo "starting."; colima start --profile "$PROFILE" --cpu 4 --memory 4 --disk 20
  fi

  printf "▶️  Minikube… "
  if is_minikube_running; then echo "already running."
  else echo "starting."; minikube start -p "$MINIKUBE_PROFILE" "${MINIKUBE_ARGS[@]}"
  fi
}

stop() {
  printf "🛑  Minikube… "
  if is_minikube_running; then minikube stop -p "$MINIKUBE_PROFILE" >/dev/null; echo "stopped."
  else echo "already stopped."
  fi

  printf "🛑  Colima… "
  if is_colima_running; then colima stop --profile "$PROFILE" >/dev/null; echo "stopped."
  else echo "already stopped."
  fi
}

status() {
  local colima_state minikube_state
  colima_state=$(is_colima_running   && echo Running || echo Stopped)
  minikube_state=$(is_minikube_running && echo Running || echo Stopped)

  echo "ℹ️  Current status"
  printf "   Colima   : %s\n"   "$(state_coloured "$colima_state")"
  printf "   Minikube : %s\n"   "$(state_coloured "$minikube_state")"
}

restart() { stop; start; }

###############################################################################
# CLI dispatch
###############################################################################
case "${1:-}" in
  start)   start   ;;
  stop)    stop    ;;
  status)  status  ;;
  restart) restart ;;
  *) echo "Usage: $0 {start|stop|status|restart}" >&2; exit 1 ;;
esac

