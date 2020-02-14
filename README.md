#Installing ClamAV using Homebrew on MacOS

## Requirements
1. Homebrew
2. MacOS

## New Instructions - Step by step directions for installing and configuring
1. Open terminal
1. If you previously installed clamav then run the following commands
   ```BASH
   sudo killall clamd
   brew uninstall clamav
   sudo rm -rf /usr/local/var/lib/clamav
   sudo rm -rf /usr/local/var/clamav
   ```
1. Remove old config files
   ```BASH
   sudo rm /usr/local/etc/clamav/freshclam.conf
   sudo rm /usr/local/etc/clamav/clamd.conf
   ```
1. Clone install scrip packackage `git clone https://github.com/daniellmorris/clamav-tools.git`
1. Navigate into cloned directory `cd clamav-tools`
1. Set executible permission on install script `chmod +x install-on-macos.sh`
1. Run install script `./install-on-macos.sh`
1. Go to System Preferences -> Security & Privacy -> Full Disk Access.
1. Check clamav to enable full disk access
1. To download the ClamAV database run `freshclam -v`
1. To start the clamav deamon run `sudo /usr/local/sbin/clamd` now without waiting for restart
