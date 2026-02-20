#!/bin/bash

# =======================================================
#  Universal Initramfs WiFi Provisioning (Final Fixed)
#  - Fixes /var/run/rngd.pid error
#  - Crash-proof Interface Detection (Pure Shell)
#  - Universal Driver/Firmware Auto-detection
# =======================================================

set -e

if [ "$(id -u)" -ne 0 ]; then
   echo "Error: This script must be run as root."
   exit 1
fi

echo "--- Initramfs WiFi Provisioning Tool ---"

# 1. Configuration Input
# ----------------------
read -p "Enter WiFi SSID: " WIFI_SSID
read -s -p "Enter WiFi Password: " WIFI_PASS
echo ""
read -p "Enter Country Code (e.g., US, GB): " WIFI_COUNTRY

# 2. Auto-Detect Driver & Firmware Strategy (Host Side)
# -----------------------------------------
echo "[*] Scanning for wireless interface..."
# Use host tools here for setup
WIFI_IFACE=$(ls /sys/class/net/ | grep -E '^(wlan|wlp|wlx|wlo)' | head -n 1)

if [ -z "$WIFI_IFACE" ]; then
    echo "Error: No wireless interface found on host."
    exit 1
fi

DETECTED_DRIVER=$(basename $(readlink /sys/class/net/$WIFI_IFACE/device/driver/module) 2>/dev/null || echo "")
if [ -z "$DETECTED_DRIVER" ]; then
    read -p "Warning: Could not auto-detect driver. Enter module name (e.g., iwlwifi): " WIFI_DRIVER
else
    WIFI_DRIVER=$DETECTED_DRIVER
fi

echo "----------------------------------------"
echo "Interface: $WIFI_IFACE"
echo "Driver:    $WIFI_DRIVER"
echo "----------------------------------------"

# Firmware Logic
FIRMWARE_CMD=""
case "$WIFI_DRIVER" in
    iwlwifi) FIRMWARE_CMD="cp -r /lib/firmware/iwlwifi* \$DESTDIR/lib/firmware/ 2>/dev/null || true" ;;
    ath10k*) FIRMWARE_CMD="cp -r /lib/firmware/ath10k \$DESTDIR/lib/firmware/ 2>/dev/null || true" ;;
    ath9k*)  FIRMWARE_CMD="cp -r /lib/firmware/ath9k* \$DESTDIR/lib/firmware/ 2>/dev/null || true" ;;
    mt7*|mediatek) FIRMWARE_CMD="cp -r /lib/firmware/mediatek \$DESTDIR/lib/firmware/ 2>/dev/null; cp -r /lib/firmware/mt7* \$DESTDIR/lib/firmware/ 2>/dev/null" ;;
    rtw*|rtl*) FIRMWARE_CMD="cp -r /lib/firmware/rtw* \$DESTDIR/lib/firmware/ 2>/dev/null; cp -r /lib/firmware/rtl* \$DESTDIR/lib/firmware/ 2>/dev/null" ;;
    brcm*) FIRMWARE_CMD="cp -r /lib/firmware/brcm \$DESTDIR/lib/firmware/ 2>/dev/null" ;;
    *) FIRMWARE_CMD="# Unknown driver family" ;;
esac

# 3. Install Dependencies
# -----------------------
echo "[*] Installing packages..."
apt-get update -qq
apt-get install -y -qq wpasupplicant initramfs-tools curl rng-tools

# 4. Write Config
# ---------------
CONF_FILE="/etc/initramfs-tools/wpa_supplicant.conf"
cat > "$CONF_FILE" <<EOF
ctrl_interface=/tmp/wpa_supplicant
update_config=1
country=$WIFI_COUNTRY

network={
    ssid="$WIFI_SSID"
    psk="$WIFI_PASS"
    scan_ssid=1
    proto=RSN
    key_mgmt=WPA-PSK
    pairwise=CCMP
    group=CCMP
    auth_alg=OPEN
}
EOF
chmod 600 "$CONF_FILE"

# 5. Write Hook Script
# --------------------
HOOK_FILE="/etc/initramfs-tools/hooks/enable-wireless"
cat > "$HOOK_FILE" <<EOF
#!/bin/sh
set -e
PREREQ=""
prereqs()
{
    echo "\$PREREQ"
}
case \$1 in
prereqs)
    prereqs
    exit 0
    ;;
esac

. /usr/share/initramfs-tools/hook-functions

# A. Copy binaries
copy_exec /sbin/wpa_supplicant /sbin
cp /etc/initramfs-tools/wpa_supplicant.conf \$DESTDIR/etc/wpa_supplicant.conf

# B. Copy RNGD
if [ -x /usr/sbin/rngd ]; then
    copy_exec /usr/sbin/rngd /usr/sbin
elif [ -x /sbin/rngd ]; then
    copy_exec /sbin/rngd /sbin
fi

# C. Copy Firmware
mkdir -p \$DESTDIR/lib/firmware
$FIRMWARE_CMD

# D. Load Modules
manual_add_modules $WIFI_DRIVER
manual_add_modules iwlmvm 
manual_add_modules ctr
manual_add_modules ccm
manual_add_modules cmac
manual_add_modules arc4
manual_add_modules ecb
manual_add_modules jitterentropy_rng
manual_add_modules drbg
EOF
chmod +x "$HOOK_FILE"

# 6. Write Boot Script (PURE SHELL + RNGD FIX)
# ---------------------------------------
PREMOUNT_FILE="/etc/initramfs-tools/scripts/init-premount/enable-wireless"
cat > "$PREMOUNT_FILE" <<EOF
#!/bin/sh
PREREQ=""
prereqs()
{
    echo "\$PREREQ"
}
case \$1 in
prereqs)
    prereqs
    exit 0
    ;;
esac

# 1. Start Entropy (Fixes PID error by pointing to /run)
echo "Starting Entropy Daemon..."
# Create var/run just in case, though we will try to point PID to /run
mkdir -p /var/run

if [ -x /usr/sbin/rngd ]; then
    /usr/sbin/rngd -r /dev/urandom -p /run/rngd.pid
elif [ -x /sbin/rngd ]; then
    /sbin/rngd -r /dev/urandom -p /run/rngd.pid
fi
sleep 1

# 2. PURE SHELL Auto-Detection (Crash Proof)
INTERFACE=""
for path in /sys/class/net/*; do
    name=\${path##*/}
    case "\$name" in
        wlan*|wlp*|wlx*|wlo*)
            INTERFACE="\$name"
            break
            ;;
    esac
done

if [ -z "\$INTERFACE" ]; then
    INTERFACE="wlan0" # Fallback
fi

if [ ! -d "/sys/class/net/\$INTERFACE" ]; then
    echo "CRITICAL: Wireless interface \$INTERFACE not found."
    exit 0
fi

# 3. Bring Up & Start
echo "Bringing up interface \$INTERFACE..."
ip link set "\$INTERFACE" up
sleep 1

echo "Starting wpa_supplicant..."
/sbin/wpa_supplicant -B -i "\$INTERFACE" -c /etc/wpa_supplicant.conf -P /run/wpa_supplicant.pid

# 4. Wait for Link & Handshake
echo "Waiting for WiFi connection..."
MAX_RETRIES=40
COUNT=0

while [ \$COUNT -lt \$MAX_RETRIES ]; do
    # Pure Shell Carrier Check
    CARRIER_FILE="/sys/class/net/\$INTERFACE/carrier"
    if [ -f "\$CARRIER_FILE" ]; then
        read status < "\$CARRIER_FILE"
        if [ "\$status" = "1" ]; then
            echo "Link detected. Waiting 5s for Auth Handshake..."
            sleep 5
            break
        fi
    fi
    sleep 1
    COUNT=\$((COUNT+1))
done

if [ \$COUNT -eq \$MAX_RETRIES ]; then
    echo "Timeout waiting for WiFi connection."
fi

# Pause for DHCP readiness
sleep 3
EOF
chmod +x "$PREMOUNT_FILE"

# 7. Cleanup Script
# -----------------
CLEANUP_FILE="/etc/initramfs-tools/scripts/init-bottom/kill-wireless"
cat > "$CLEANUP_FILE" <<EOF
#!/bin/sh
PREREQ=""
prereqs()
{
    echo "\$PREREQ"
}
case \$1 in
prereqs)
    prereqs
    exit 0
    ;;
esac
if [ -f /run/wpa_supplicant.pid ]; then
    kill \$(cat /run/wpa_supplicant.pid)
fi
if [ -f /run/rngd.pid ]; then
    kill \$(cat /run/rngd.pid)
fi
killall rngd 2>/dev/null || true
EOF
chmod +x "$CLEANUP_FILE"

# 8. Final Config
# ---------------
if ! grep -q "^$WIFI_DRIVER" /etc/initramfs-tools/modules; then
    echo "$WIFI_DRIVER" >> /etc/initramfs-tools/modules
fi

GRUB_FILE="/etc/default/grub"
sed -i 's/quiet//g' "$GRUB_FILE"
sed -i 's/splash//g' "$GRUB_FILE"
if ! grep -q "ip=dhcp" "$GRUB_FILE"; then
    sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\([^"]*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 ip=dhcp"/' "$GRUB_FILE"
fi
sed -i 's/  / /g' "$GRUB_FILE"
update-grub

echo "[*] Rebuilding Initramfs..."
update-initramfs -u -k all

echo "Done. Reboot to test."
