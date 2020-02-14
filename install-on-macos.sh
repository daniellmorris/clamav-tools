#!/bin/bash

CONFIG_FOLDER=/usr/local/etc/clamav
CLAMD_CONFIG_FILE=$CONFIG_FOLDER/clamd.conf
FRESHCLAM_CONFIG_FILE=$CONFIG_FOLDER/freshclam.conf
BASE_FOLDER=/usr/local/var/clamav
DB_FOLDER=$BASE_FOLDER/db
RUN_FOLDER=$BASE_FOLDER/run
LOG_FOLDER=$BASE_FOLDER/log
CLAMD_LOG_FILE=$LOG_FOLDER/clamd.log
CLAMD_ERROR_LOG_FILE=$LOG_FOLDER/clamd.error.log
FRESHCLAM_LOG_FILE=$LOG_FOLDER/freshclam.log
FRESHCLAM_ERROR_LOG_FILE=$LOG_FOLDER/freshclam.error.log
CLAMDSCAN_LOG_FILE=$LOG_FOLDER/clamdscan.log
CLAMDSCAN_ERROR_LOG_FILE=$LOG_FOLDER/clamdscan.error.log

( brew list --versions clamav > /dev/null ) || brew install clamav || exit

# Setup config
#echo "DatabaseMirror database.clamav.net" > $FRESHCLAM_CONFIG_FILE
#echo "LocalSocket /usr/local/var/run/clamav/clamd.sock" > $CLAMD_CONFIG_FILE
#echo "LogFile /usr/local/var/run/clamav/clamd.log" >> $CLAMD_CONFIG_FILE
#[ -e "$CLAMD_CONFIG_FILE" ] || (
  cp "${CLAMD_CONFIG_FILE}.sample" "$CLAMD_CONFIG_FILE"
  sed -e "s/# Example config file/# Config file/" \
           -e "s/^Example$/# Example/" \
           -e "s/^#MaxDirectoryRecursion 20$/MaxDirectoryRecursion 25/" \
           -e "s/^#LogFile .*/LogFile ${CLAMD_LOG_FILE//\//\\/}/" \
           -e "s/^#PidFile .*/PidFile ${RUN_FOLDER//\//\\/}\/clamd.pid/" \
           -e "s/^#DatabaseDirectory .*/DatabaseDirectory ${DB_FOLDER//\//\\/}/" \
           -e "s/^#LocalSocket .*/LocalSocket ${RUN_FOLDER//\//\\/}\/clamd.socket/" \
           -i -n "$CLAMD_CONFIG_FILE"
#)
#[ -e "$FRESHCLAM_CONFIG_FILE" ] || (
  cp "${FRESHCLAM_CONFIG_FILE}.sample" "$FRESHCLAM_CONFIG_FILE"
  sed -e "s/# Example config file/# Config file/" \
           -e "s/^Example$/# Example/" \
           -e "s/^#DatabaseDirectory .*/DatabaseDirectory ${DB_FOLDER//\//\\/}/" \
           -e "s/^#UpdateLogFile .*/UpdateLogFile ${FRESHCLAM_LOG_FILE//\//\\/}/" \
           -e "s/^#PidFile .*/PidFile ${RUN_FOLDER//\//\\/}\/freshclam.pid/" \
           -e "s/^#NotifyClamd .*/NotifyClamd ${CLAMD_CONFIG_FILE//\//\\/}/" \
           -i -n "$FRESHCLAM_CONFIG_FILE"
#)

sudo dscl . create /Groups/clamav
sudo dscl . create /Groups/clamav RealName "Clam Antivirus Group"
sudo dscl . create /Groups/clamav gid 799           # Ensure this is unique!
sudo dscl . create /Users/clamav
sudo dscl . create /Users/clamav RealName "Clam Antivirus User"
sudo dscl . create /Users/clamav UserShell /bin/false
sudo dscl . create /Users/clamav UniqueID 599       # Ensure this is unique!
sudo dscl . create /Users/clamav PrimaryGroupID 799 # Must match the above gid!

sudo mkdir -p $BASE_FOLDER
sudo mkdir -p $RUN_FOLDER
sudo mkdir -p $LOG_FOLDER
sudo mkdir -p $DB_FOLDER
sudo chown clamav:clamav $BASE_FOLDER
sudo chown clamav:clamav $RUN_FOLDER
sudo chown clamav:clamav $LOG_FOLDER
sudo chown clamav:clamav $DB_FOLDER
#[ -e "$CLAMD_LOG_FILE" ] || sudo touch "$CLAMD_LOG_FILE"
#[ -e "$CLAMD_ERROR_LOG_FILE" ] || sudo touch "$CLAMD_ERROR_LOG_FILE"
#[ -e "$FRESHCLAM_LOG_FILE" ] || sudo touch "$FRESHCLAM_LOG_FILE"
#[ -e "$FRESHCLAM_ERROR_LOG_FILE" ] || sudo touch "$FRESHCLAM_ERROR_LOG_FILE"
#sudo chown clamav:clamav "$CLAMD_LOG_FILE" "$CLAMD_ERROR_LOG_FILE" "$FRESHCLAM_LOG_FILE" "$FRESHCLAM_ERROR_LOG_FILE"
#sudo chmod 0644 "$CLAMD_LOG_FILE" "$CLAMD_ERROR_LOG_FILE" "$FRESHCLAM_LOG_FILE" "$FRESHCLAM_ERROR_LOG_FILE"

DAEMON_FOLDER=/Library/LaunchDaemons
CLAMD_DAEMON_NAME=clamav.clamd
CLAMD_DAEMON_FILE=$DAEMON_FOLDER/$CLAMD_DAEMON_NAME.plist
FRESHCLAM_DAEMON_NAME=clamav.freshclam
FRESHCLAM_DAEMON_FILE=$DAEMON_FOLDER/$FRESHCLAM_DAEMON_NAME.plist
CLAMDSCAN_DAEMON_NAME=clamav.clamdscan
CLAMDSCAN_DAEMON_FILE=$DAEMON_FOLDER/$CLAMDSCAN_DAEMON_NAME.plist
[ -d "$DAEMON_FOLDER" ] || sudo mkdir "$DAEMON_FOLDER"
sudo tee "$CLAMD_DAEMON_FILE" << EOF > /dev/null
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${CLAMD_DAEMON_NAME}</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/sbin/clamd</string>
        <string>--foreground</string>
    </array>
    <key>KeepAlive</key>
    <true/>
    <key>StandardErrorPath</key>
    <string>${CLAMD_ERROR_LOG_FILE}</string>
</dict>
</plist>
EOF
sudo tee "$FRESHCLAM_DAEMON_FILE" << EOF > /dev/null
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${FRESHCLAM_DAEMON_NAME}</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/freshclam</string>
        <string>--daemon</string>
        <string>--foreground</string>
    </array>
    <key>KeepAlive</key>
    <true/>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardErrorPath</key>
    <string>${FRESHCLAM_ERROR_LOG_FILE}</string>
    <key>StartInterval</key>
    <integer>86400</integer>
</dict>
</plist>
EOF
sudo tee "$CLAMDSCAN_DAEMON_FILE" << EOF > /dev/null
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${CLAMDSCAN_DAEMON_NAME}</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/clamdscan</string>
        <string>--log=${CLAMDSCAN_LOG_FILE}</string>
        <string>-m</string>
        <string>/</string>
    </array>
    <key>KeepAlive</key>
    <false/>
    <key>RunAtLoad</key>
    <false/>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>1</integer>
        <key>Minute</key>
        <integer>45</integer>
    </dict>
    <key>StandardErrorPath</key>
    <string>${CLAMDSCAN_ERROR_LOG_FILE}</string>
</dict>
</plist>
EOF
sudo chown root:wheel "$CLAMD_DAEMON_FILE" "$FRESHCLAM_DAEMON_FILE" "$CLAMDSCAN_DAEMON_FILE"
sudo chmod 0644 "$CLAMD_DAEMON_FILE" "$FRESHCLAM_DAEMON_FILE" "$CLAMDSCAN_DAEMON_FILE"
#sudo launchctl unload "$CLAMD_DAEMON_FILE" "$FRESHCLAM_DAEMON_FILE" "$CLAMDSCAN_DAEMON_FILE"
sudo launchctl load "$CLAMD_DAEMON_FILE" "$FRESHCLAM_DAEMON_FILE" "$CLAMDSCAN_DAEMON_FILE"
