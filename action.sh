#!/system/bin/sh

# Xiaomi Flagship Props Rotator
# Triggered via Root Manager Action Button
# Config saved by WebUI at device.conf

MODPATH="${0%/*}"
MODPATH_SYSTEM_PROP="$MODPATH/system.prop"
MODPATH_MODULE_PROP="$MODPATH/module.prop"
CONFIG_FILE="$MODPATH/device.conf"

###########################
# Xiaomi Flagship Database
# Format: "codename|model|device_name"
###########################

DEVICES="dada|24129PN74G|Xiaomi 15
qiaomu|25010PN83G|Xiaomi 15 Pro
xuanyuan|25021PNE4G|Xiaomi 15 Ultra
houji|23127PN0CG|Xiaomi 14
shennong|23116PN5BG|Xiaomi 14 Pro
aurora|24030PN60G|Xiaomi 14 Ultra
fuxi|2211133G|Xiaomi 13
nuwa|2210132G|Xiaomi 13 Pro
ishtar|23046PNB4G|Xiaomi 13 Ultra
zeus|2201122G|Xiaomi 12 Pro
cupid|2201123G|Xiaomi 12
thor|2209129SC|Xiaomi 12T Pro"

# Parse database line by line into indexed entries
DEVICE_COUNT=0
OLD_IFS="$IFS"
IFS='
'
for entry in $DEVICES; do
  [ -z "$entry" ] && continue
  DEVICE_COUNT=$((DEVICE_COUNT + 1))
  eval "DEVICE_ENTRY_${DEVICE_COUNT}='$entry'"
done
IFS="$OLD_IFS"

# Get current device codename from system.prop
CURRENT_CODENAME=""
if [ -f "$MODPATH_SYSTEM_PROP" ]; then
  CURRENT_CODENAME=$(grep -m1 "^ro.product.device=" "$MODPATH_SYSTEM_PROP" | cut -d= -f2)
fi

###########################
# Read config from WebUI
###########################

MODE="random"
CFG_CODENAME=""

# Read mode.txt and selected.txt
for dir in "$MODPATH" "/data/adb/modules/xiaomi_prop" "/data/adb/modules_update/xiaomi_prop"; do
  if [ -f "$dir/mode.txt" ]; then
    MODE=$(cat "$dir/mode.txt" 2>/dev/null | tr -d '\r\n ')
  fi
  if [ -f "$dir/selected.txt" ]; then
    CFG_CODENAME=$(cat "$dir/selected.txt" 2>/dev/null | tr -d '\r\n ')
  fi
  [ -n "$MODE" ] && [ -n "$CFG_CODENAME" ] && break
done

###########################
# Select device
###########################

if [ "$MODE" = "manual" ] && [ -n "$CFG_CODENAME" ]; then
  # Find device in internal DB for reliable values
  FOUND_ENTRY=""
  OLD_IFS="$IFS"
  IFS='
'
  for entry in $DEVICES; do
    [ -z "$entry" ] && continue
    cname=$(echo "$entry" | cut -d'|' -f1)
    if [ "$cname" = "$CFG_CODENAME" ]; then
      FOUND_ENTRY="$entry"
      break
    fi
  done
  IFS="$OLD_IFS"

  if [ -n "$FOUND_ENTRY" ]; then
    CODENAME=$(echo "$FOUND_ENTRY" | cut -d'|' -f1)
    MODEL=$(echo "$FOUND_ENTRY" | cut -d'|' -f2)
    DEVICE_NAME=$(echo "$FOUND_ENTRY" | cut -d'|' -f3)
  else
    CODENAME="$CFG_CODENAME"
    MODEL="Unknown"
    DEVICE_NAME="$CFG_CODENAME"
  fi
  SELECT_MODE="Manual (WebUI)"
else
  # Random mode: pick random device (avoid same)
  SELECT_MODE="Random"
  MAX_ATTEMPTS=10
  ATTEMPT=0
  while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    RANDOM_INDEX=$(( $(tr -dc '0-9' < /dev/urandom | head -c 4) % DEVICE_COUNT + 1 ))
    eval "SELECTED=\$DEVICE_ENTRY_${RANDOM_INDEX}"

    CODENAME=$(echo "$SELECTED" | cut -d'|' -f1)
    MODEL=$(echo "$SELECTED" | cut -d'|' -f2)
    DEVICE_NAME=$(echo "$SELECTED" | cut -d'|' -f3)

    [ "$CODENAME" != "$CURRENT_CODENAME" ] && break
    ATTEMPT=$((ATTEMPT + 1))
  done
fi

echo ""
echo "========================================"
echo "  Xiaomi Props Rotator"
echo "========================================"
echo ""
echo "  Mode     : $SELECT_MODE"
echo "  Previous : $CURRENT_CODENAME"
echo "  Selected : $DEVICE_NAME"
echo "  Codename : $CODENAME"
echo "  Model    : $MODEL"
echo ""

###########################
# Generate system.prop
###########################

cat > "$MODPATH_SYSTEM_PROP" << EOF
###
#-#
###

###
# begin product/etc/build.prop
###

# begin common build properties


ro.product.device=${CODENAME}
ro.product.model=${MODEL}
ro.product.name=${CODENAME}
ro.product.product.brand=Xiaomi
ro.product.product.device=${CODENAME}
ro.product.product.model=${MODEL}
ro.product.product.name=${CODENAME}
# end common build properties


ro.product.bootimage.brand=Xiaomi
ro.product.bootimage.device=${CODENAME}
ro.product.bootimage.model=${MODEL}
ro.product.bootimage.name=${CODENAME}

# end PRODUCT_BOOTIMAGE_PROPERTIES

###
# end product/etc/build.prop
###

###
#-#
###

###
# begin vendor/build.prop
###

# begin common build properties

ro.product.vendor.device=${CODENAME}
ro.product.vendor.model=${MODEL}
ro.product.vendor.name=${CODENAME}

# end PRODUCT_VENDOR_PROPERTIES

# begin ADDITIONAL_VENDOR_PROPERTIES

# begin PRODUCT_PROPERTY_OVERRIDE

###
# end vendor/build.prop
###

###
#-#
###

###
# begin vendor/odm/etc/build.prop
###

# begin common build properties
ro.product.odm.brand=Xiaomi
ro.product.odm.device=${CODENAME}
ro.product.odm.model=${MODEL}
ro.product.odm.name=${CODENAME}

###
# begin system/system/build.prop
###

# begin common build properties
ro.product.system.brand=Xiaomi
ro.product.system.device=generic
ro.product.system.model=mainline
ro.product.system.name=mainline
# end common build properties

# begin build properties


# begin PRODUCT_SYSTEM_PROPERTIES
#end PRODUCT_SYSTEM_PROPERTIES

###
# end system/system/build.prop
###

###
#-#
###

###
# begin system_ext/etc/build.prop
###

# begin common build properties
ro.product.system_ext.brand=Xiaomi
ro.product.system_ext.device=${CODENAME}
ro.product.system_ext.model=${MODEL}
ro.product.system_ext.name=${CODENAME}

###
# end system_ext/etc/build.prop
###
EOF

###########################
# Update module.prop description
###########################

if [ -f "$MODPATH_MODULE_PROP" ]; then
  sed -i "s/^description=.*/description=Spoof your device props to ${DEVICE_NAME} [${MODEL}] - Use Action to rotate/" "$MODPATH_MODULE_PROP"
fi

echo "  system.prop  -> Updated"
echo "  module.prop  -> Updated"
echo ""
echo "  Rebooting in..."
i=5
while [ $i -gt 0 ]; do
  echo "  $i..."
  sleep 1
  i=$((i - 1))
done
echo ""
echo "  Rebooting now!"
echo "========================================"
/system/bin/svc power reboot || reboot
