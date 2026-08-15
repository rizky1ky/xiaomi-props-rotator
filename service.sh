#!/system/bin/sh

MODDIR="${0%/*}"
MODPATH_SYSTEM_PROP="$MODDIR/system.prop"

# Dummy ui_print for boot execution
ui_print() {
  echo "$1"
}

# Function to get a property
get_property() {
  PROP="$1"
  FILE="$2"
  if [ -n "$FILE" ] && [ -f "$FILE" ]; then
    grep -m1 "^$PROP=" "$FILE" 2>/dev/null | cut -d= -f2- | head -n 1
  else
    getprop "$PROP" 2>/dev/null
  fi
}

# Function to check and update a property
check_and_update_prop() {
  sys_prop_key="$1"
  mod_prop_key="$2"
  prop_name="$3"
  comparison="$4"

  sys_prop=$(get_property "$sys_prop_key")
  mod_prop=$(get_property "$mod_prop_key" "$MODPATH_SYSTEM_PROP")

  [ -z "$sys_prop" ] || [ -z "$mod_prop" ] && return

  case "$comparison" in
  "eq") [ "$sys_prop" -eq "$mod_prop" 2>/dev/null ] && update_prop "$prop_name" "$sys_prop" "$mod_prop_key" || ignore_prop "$prop_name" "$sys_prop" "$mod_prop_key" ;;
  "ne") [ "$sys_prop" != "$mod_prop" ] && update_prop "$prop_name" "$sys_prop" "$mod_prop_key" || ignore_prop "$prop_name" "$sys_prop" "$mod_prop_key" ;;
  "lt") [ "$sys_prop" -lt "$mod_prop" 2>/dev/null ] && update_prop "$prop_name" "$sys_prop" "$mod_prop_key" || ignore_prop "$prop_name" "$sys_prop" "$mod_prop_key" ;;
  "le") [ "$sys_prop" -le "$mod_prop" 2>/dev/null ] && update_prop "$prop_name" "$sys_prop" "$mod_prop_key" || ignore_prop "$prop_name" "$sys_prop" "$mod_prop_key" ;;
  "gt") [ "$sys_prop" -gt "$mod_prop" 2>/dev/null ] && update_prop "$prop_name" "$sys_prop" "$mod_prop_key" || ignore_prop "$prop_name" "$sys_prop" "$mod_prop_key" ;;
  "ge") [ "$sys_prop" -ge "$mod_prop" 2>/dev/null ] && update_prop "$prop_name" "$sys_prop" "$mod_prop_key" || ignore_prop "$prop_name" "$sys_prop" "$mod_prop_key" ;;
  esac
}

update_prop() {
  ui_print " - $1=$2, running unsafe mode"
}

ignore_prop() {
  ui_print " - $1=$2, running safe mode"
}

# Check and update properties safely
if [ -f "$MODPATH_SYSTEM_PROP" ]; then
  check_and_update_prop "ro.product.manufacturer" "ro.product.product.brand" "MANUFACTURER" "ne"
  check_and_update_prop "ro.product.model" "ro.product.model" "MODEL" "ne"
  check_and_update_prop "ro.product.device" "ro.product.device" "DEVICE" "ne"
fi
