#Installing ClamAV using Homebrew on MacOS

## Requirements
1. Homebrew
2. MacOS

## Step by step directions for installing and configuring
1. Open terminal
1. If you previously installed clamav then run the following commands
   ```BASH
   sudo killall clamd
   brew uninstall clamav
   sudo rm -rf /usr/local/var/lib/clamav
   sudo rm -rf /usr/local/var/clamav
   cd /Library/LaunchDaemons/ && sudo launchctl unload clamav.freshclam.plist clamav.clamd.plist clamav.clamdscan.plist
   ```
1. Remove old config files
   ```BASH
   sudo rm /usr/local/etc/clamav/freshclam.conf
   sudo rm /usr/local/etc/clamav/clamd.conf
   ```
1. Navigate to a directory where you want to store this script (If no preference then run `cd ~` to navigate home)
1. Clone install script package `git clone https://github.com/daniellmorris/clamav-tools.git`
1. Navigate into cloned directory `cd clamav-tools`
1. Set executable permission on install script `chmod +x install-on-macos.sh`
1. Run install script `./install-on-macos.sh`
1. Go to System Preferences -> Security & Privacy -> Privacy -> Full Disk Access.
1. Check clamav to enable full disk access
1. To test that it works `sudo clamdscan -m /User`. This could take hours to finish
