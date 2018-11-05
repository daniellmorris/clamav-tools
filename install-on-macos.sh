#!/bin/bash

CONFIG_FOLDER=/usr/local/etc/clamav
CLAMD_CONFIG_FILE=$CONFIG_FOLDER/clamd.conf
FRESHCLAM_CONFIG_FILE=$CONFIG_FOLDER/freshclam.conf
DB_FOLDER=/usr/local/var/lib/clamav
RUN_FOLDER=/usr/local/var/run/clamav
LOG_FOLDER=/usr/local/var/log
CLAMD_LOG_FILE=$LOG_FOLDER/clamd.log
FRESHCLAM_LOG_FILE=$LOG_FOLDER/freshclam.log

( brew list --versions clamav > /dev/null ) || brew install clamav || exit

[ -e "$CLAMD_CONFIG_FILE" ] || (
  sudo cp "${CLAMD_CONFIG_FILE}.sample" "$CLAMD_CONFIG_FILE"
  sudo sed -e "s/# Example config file/# Config file/" \
           -e "s/^Example$/# Example/" \
           -e "s/^#LogFile .*/LogFile ${CLAMD_LOG_FILE//\//\\/}/" \
           -e "s/^#PidFile .*/PidFile ${RUN_FOLDER//\//\\/}\/clamd.pid/" \
           -e "s/^#DatabaseDirectory .*/DatabaseDirectory ${DB_FOLDER//\//\\/}/" \
           -e "s/^#LocalSocket .*/LocalSocket ${RUN_FOLDER//\//\\/}\/clamd.socket/" \
           -i -n "$CLAMD_CONFIG_FILE"
)
[ -e "$FRESHCLAM_CONFIG_FILE" ] || (
  sudo cp "${FRESHCLAM_CONFIG_FILE}.sample" "$FRESHCLAM_CONFIG_FILE"
  sudo sed -e "s/# Example config file/# Config file/" \
           -e "s/^Example$/# Example/" \
           -e "s/^#DatabaseDirectory .*/DatabaseDirectory ${DB_FOLDER//\//\\/}/" \
           -e "s/^#UpdateLogFile .*/UpdateLogFile ${FRESHCLAM_LOG_FILE//\//\\/}/" \
           -e "s/^#PidFile .*/PidFile ${RUN_FOLDER//\//\\/}\/freshclam.pid/" \
           -e "s/^#NotifyClamd .*/NotifyClamd ${CLAMD_CONFIG_FILE//\//\\/}/" \
           -i -n "$FRESHCLAM_CONFIG_FILE"
)
sudo mkdir -p "$DB_FOLDER"
sudo mkdir -p "$RUN_FOLDER"
[ -e "$CLAMD_LOG_FILE" ] || sudo touch "$CLAMD_LOG_FILE"
[ -e "$FRESHCLAM_LOG_FILE" ] || sudo touch "$FRESHCLAM_LOG_FILE"
sudo chown -R root:wheel "$CONFIG_FOLDER"
sudo chown -R clamav:clamav "$DB_FOLDER"
sudo chown -R clamav:clamav "$RUN_FOLDER"
sudo chown clamav:clamav "$CLAMD_LOG_FILE" "$FRESHCLAM_LOG_FILE"
sudo chmod 0644 "$CLAMD_CONFIG_FILE" "$FRESHCLAM_CONFIG_FILE"
sudo chmod 0644 "$CLAMD_LOG_FILE" "$FRESHCLAM_LOG_FILE"