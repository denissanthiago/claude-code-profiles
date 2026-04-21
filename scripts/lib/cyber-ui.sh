#!/usr/bin/env bash
#
# cyber-ui.sh — primitivas de UI con estética cyberpunk + animaciones.
#
# Uso (desde un script en scripts/):
#   source "$(dirname "${BASH_SOURCE[0]}")/lib/cyber-ui.sh"
#
# Exports:
#   - Paleta base:       C_BOLD, C_DIM, C_ITALIC, C_UNDER, C_RESET
#   - Paleta semantic:   C_OK, C_WARN, C_ERR, C_INFO
#   - Paleta cyber:      C_NEON, C_ELEC, C_ACID, C_GOLD, C_GRAY, C_DARK
#   - Paleta gradient:   C_CYAN1..3, C_MAG1..3, C_PINK, C_TEAL, C_BLUE1, C_PURPLE
#   - TERM_WIDTH:        clamp 60–100
#   - hr <char> <color>           línea horizontal simple
#   - grad_hr                     línea horizontal con gradient cyan→magenta
#   - banner <title> [meta]       header con logo + gradient
#   - banner_simple <t> [meta]    header sin logo (para subsecciones repetidas)
#   - subhead <label> [meta]      subsección con ⬢
#   - item <name> [desc]          item con ▸
#   - wrap_desc <txt> <prefix>    wrap a ancho de terminal
#   - typewriter <text> [delay]   imprime letra-por-letra
#   - spinner_start <msg>         lanza spinner braille en background
#   - spinner_stop [final_msg]    detiene el spinner
#   - log_info/ok/warn/err        logs semánticos
#   - die <msg>                   log_err + exit 1
#
# Env vars que controlan el comportamiento:
#   CCP_NO_ANIM=1  → desactiva typewriter/spinner/sleeps (para CI/scripts)
#   CCP_NO_LOGO=1  → banner sin logo ASCII (más compacto)
#   CY_INDENT="  " → indent base de los log_*

# Guard
if [[ -n "${_CYBER_UI_LOADED:-}" ]]; then
  return 0 2>/dev/null
fi
_CYBER_UI_LOADED=1

# ---------- Paleta ----------
if [[ -t 1 ]]; then
  # Formato
  C_BOLD=$'\e[1m'
  C_DIM=$'\e[2m'
  C_ITALIC=$'\e[3m'
  C_UNDER=$'\e[4m'
  C_RESET=$'\e[0m'

  # Semantic
  C_OK=$'\e[92m'            # neon green
  C_WARN=$'\e[93m'          # neon amber
  C_ERR=$'\e[91m'           # neon red
  C_INFO=$'\e[96m'          # cyan

  # Cyber base
  C_NEON=$'\e[95m'          # magenta / hot pink
  C_ELEC=$'\e[94m'          # electric blue
  C_ACID=$'\e[38;5;154m'    # acid green
  C_GOLD=$'\e[38;5;220m'    # neon gold
  C_GRAY=$'\e[38;5;245m'    # steel
  C_DARK=$'\e[38;5;238m'    # dark line

  # Gradient palette (cyan → pink → magenta → purple)
  C_CYAN1=$'\e[38;5;51m'    # bright cyan
  C_CYAN2=$'\e[38;5;87m'    # soft cyan
  C_CYAN3=$'\e[38;5;45m'    # teal-cyan
  C_TEAL=$'\e[38;5;44m'
  C_PINK=$'\e[38;5;213m'
  C_MAG1=$'\e[38;5;201m'    # hot pink
  C_MAG2=$'\e[38;5;165m'    # medium magenta
  C_MAG3=$'\e[38;5;129m'    # deep magenta
  C_BLUE1=$'\e[38;5;33m'
  C_PURPLE=$'\e[38;5;99m'
else
  C_BOLD="" C_DIM="" C_ITALIC="" C_UNDER="" C_RESET=""
  C_OK="" C_WARN="" C_ERR="" C_INFO=""
  C_NEON="" C_ELEC="" C_ACID="" C_GOLD="" C_GRAY="" C_DARK=""
  C_CYAN1="" C_CYAN2="" C_CYAN3="" C_TEAL="" C_PINK=""
  C_MAG1="" C_MAG2="" C_MAG3="" C_BLUE1="" C_PURPLE=""
fi

TERM_WIDTH="${COLUMNS:-$(tput cols 2>/dev/null || echo 80)}"
(( TERM_WIDTH > 100 )) && TERM_WIDTH=100
(( TERM_WIDTH < 60 ))  && TERM_WIDTH=60

# ---------- Animation primitives ----------
# sleep en segundos (acepta decimales). No-op si CCP_NO_ANIM=1 o stdout no es tty.
_anim_sleep() {
  [[ "${CCP_NO_ANIM:-0}" == "1" ]] && return 0
  [[ -t 1 ]] || return 0
  sleep "${1:-0.02}" 2>/dev/null || true
}

# Escribe texto con delay entre caracteres. Fallback a printf normal si no hay anim.
# $1: texto  $2: delay entre chars (default 0.004s = ~250 chars/seg — imperceptible pero vivo)
typewriter() {
  local text="$1" delay="${2:-0.004}"
  if [[ "${CCP_NO_ANIM:-0}" == "1" ]] || [[ ! -t 1 ]]; then
    printf "%s" "$text"
    return 0
  fi
  local i
  for ((i=0; i<${#text}; i++)); do
    printf "%s" "${text:$i:1}"
    sleep "$delay" 2>/dev/null || true
  done
}

# ---------- Separadores ----------
# Horizontal bar con char y color uniforme (default ━ en cyan).
hr() {
  local char="${1:-━}" color="${2:-$C_INFO}"
  local i
  printf "%b" "$color"
  for ((i=0; i<TERM_WIDTH; i++)); do printf "%s" "$char"; done
  printf "%b\n" "$C_RESET"
}

# Horizontal bar con gradient: cyan → pink → magenta. Usa 4 segmentos.
grad_hr() {
  local char="${1:-━}"
  local w=$TERM_WIDTH
  local seg=$((w / 4))
  local rest=$((w - seg * 4))
  local i
  local colors=("$C_CYAN1" "$C_CYAN2" "$C_PINK" "$C_MAG2")

  for ((i=0; i<4; i++)); do
    printf "%b" "${colors[$i]}"
    local cnt=$seg
    (( i == 3 )) && cnt=$((seg + rest))
    local j
    for ((j=0; j<cnt; j++)); do printf "%s" "$char"; done
  done
  printf "%b\n" "$C_RESET"
}

# ---------- Logo ----------
# Logo ASCII del nombre "ccp" con gradient vertical (cyan → pink → magenta).
# 6 líneas. Animado: cada línea aparece con un pequeño delay.
_logo_ccp() {
  local -a colors=("$C_CYAN1" "$C_CYAN3" "$C_TEAL" "$C_PINK" "$C_MAG2" "$C_MAG3")
  local -a lines=(
    "   ██████╗ ██████╗ ██████╗ "
    "  ██╔════╝██╔════╝ ██╔══██╗"
    "  ██║     ██║      ██████╔╝"
    "  ██║     ██║      ██╔═══╝ "
    "  ╚██████╗╚██████╗ ██║     "
    "   ╚═════╝ ╚═════╝ ╚═╝     "
  )
  local i
  for i in "${!lines[@]}"; do
    printf "%b%s%b\n" "${colors[$i]}" "${lines[$i]}" "$C_RESET"
    _anim_sleep 0.015
  done
}

# ---------- Banners ----------
# Banner principal: logo + gradient hr + título en typewriter + meta en gris.
# Uso:  banner "<título>" ["<meta>"]
banner() {
  local title="$1" meta="${2:-}"
  echo

  if [[ "${CCP_NO_LOGO:-0}" != "1" && -t 1 ]]; then
    _logo_ccp
    echo
  fi

  grad_hr "━"
  # Título con ícono pulsante visual (⚡ gold, resto bold con gradient subtil)
  printf " %b⚡%b  " "$C_GOLD" "$C_RESET"
  printf "%b" "$C_BOLD"
  typewriter "$title" 0.003
  printf "%b" "$C_RESET"
  if [[ -n "$meta" ]]; then
    printf "  %b%s%b" "$C_GRAY" "$meta" "$C_RESET"
  fi
  echo
  grad_hr "━"
  echo
}

# Banner compacto: sin logo (para sub-operaciones dentro de un flow).
# Uso:  banner_simple "<título>" ["<meta>"]
banner_simple() {
  local title="$1" meta="${2:-}"
  echo
  hr "━" "$C_INFO"
  printf " %b⚡%b  %b%s%b" "$C_GOLD" "$C_RESET" "$C_BOLD" "$title" "$C_RESET"
  if [[ -n "$meta" ]]; then
    printf "  %b%s%b" "$C_GRAY" "$meta" "$C_RESET"
  fi
  echo
  hr "━" "$C_INFO"
  echo
}

# Subhead: subsección con ícono ⬢ + label + meta opcional.
subhead() {
  local label="$1" meta="${2:-}"
  printf "  %b⬢%b  %b%s%b" "$C_NEON" "$C_RESET" "$C_BOLD" "$label" "$C_RESET"
  if [[ -n "$meta" ]]; then
    printf "  %b%s%b" "$C_GRAY" "$meta" "$C_RESET"
  fi
  echo
  echo
}

# ---------- Text helpers ----------
# Wrap text al ancho de terminal preservando un prefix de indentación.
wrap_desc() {
  local text="$1" prefix="$2"
  local width=$((TERM_WIDTH - ${#prefix}))
  (( width < 30 )) && width=30
  echo "$text" | fold -s -w "$width" | while IFS= read -r line; do
    printf "%s%b%s%b\n" "$prefix" "$C_GRAY" "$line" "$C_RESET"
  done
}

# Item listable con nombre destacado + descripción wrapped opcional.
item() {
  local name="$1" desc="${2:-}"
  printf "    %b▸%b %b%s%b\n" "$C_ACID" "$C_RESET" "$C_BOLD" "$name" "$C_RESET"
  if [[ -n "$desc" ]]; then
    wrap_desc "$desc" "      "
  fi
  return 0
}

# ---------- Spinner ----------
# Braille spinner para operaciones largas. Corre en background.
# Uso:
#   spinner_start "generando con Claude"
#   do_long_task
#   spinner_stop "listo"
_SPINNER_PID=""
_SPINNER_MSG=""
spinner_start() {
  _SPINNER_MSG="$1"
  [[ "${CCP_NO_ANIM:-0}" == "1" || ! -t 2 ]] && {
    printf "  %b▸%b %s\n" "$C_INFO" "$C_RESET" "$_SPINNER_MSG" >&2
    return 0
  }

  # braille frames (dots rotating pattern)
  local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
  (
    # hide cursor
    printf '\e[?25l' >&2
    local i=0
    while true; do
      local f="${frames[$((i % 10))]}"
      # overwrite line
      printf "\r  %b%s%b  %s" "$C_CYAN1" "$f" "$C_RESET" "$_SPINNER_MSG" >&2
      i=$((i + 1))
      sleep 0.08 2>/dev/null || break
    done
  ) &
  _SPINNER_PID=$!
  disown "$_SPINNER_PID" 2>/dev/null || true
}

spinner_stop() {
  local final="${1:-}"
  if [[ -n "$_SPINNER_PID" ]]; then
    kill "$_SPINNER_PID" 2>/dev/null || true
    wait "$_SPINNER_PID" 2>/dev/null || true
    _SPINNER_PID=""
    # restore cursor + clear line
    printf '\r\e[2K\e[?25h' >&2
  fi
  if [[ -n "$final" ]]; then
    printf "  %b◉%b %s\n" "$C_OK" "$C_RESET" "$final" >&2
  fi
}

# ---------- Logs ----------
# Todos los logs van a stderr (diagnóstico, no data).
# Stdout queda limpio para captures vía $(funcion).
log_info() { printf "%s%b▸%b %s\n" "${CY_INDENT:-  }" "$C_INFO" "$C_RESET" "$*" >&2; }
log_ok()   { printf "%s%b◉%b %s\n" "${CY_INDENT:-  }" "$C_OK"   "$C_RESET" "$*" >&2; }
log_warn() { printf "%s%b◈%b %s\n" "${CY_INDENT:-  }" "$C_WARN" "$C_RESET" "$*" >&2; }
log_err()  { printf "%s%b⊘%b %s\n" "${CY_INDENT:-  }" "$C_ERR"  "$C_RESET" "$*" >&2; }

# Muere con error (reemplaza log_err+exit)
die() { log_err "$*"; exit 1; }

# Compatibilidad: log_step = banner compacto (sin logo)
log_step() { banner_simple "$*"; }

# Cleanup automático: si algún script muere con spinner activo, lo paramos.
_spinner_cleanup() { [[ -n "$_SPINNER_PID" ]] && spinner_stop; }
trap '_spinner_cleanup' EXIT
