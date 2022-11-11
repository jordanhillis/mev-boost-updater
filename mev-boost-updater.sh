#!/bin/bash
: '
________________________________________________________________________
                        MEV-Boost Updater
                        By Jordan Hillis
                        jordan@hillis.email
                        https://jordanhillis.com
________________________________________________________________________
  MEV-Boost Updater
  Copyright (C) 2022, Jordan Hillis

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
________________________________________________________________________
'

VERSION="1.0"

echo -e "
  __  __ _______     __    ____                  _   
 |  \/  | ____\ \   / /   | __ )  ___   ___  ___| |_ 
 | |\/| |  _|  \ \ / /____|  _ \ / _ \ / _ \/ __| __|
 | |  | | |___  \ V /_____| |_) | (_) | (_) \__ \ |_ 
 |_|  |_|_____|  \_/      |____/ \___/ \___/|___/\__|
  _   _           _       _                          
 | | | |_ __   __| | __ _| |_ ___ _ __               
 | | | | '_ \ / _\` |/ _\` | __/ _ \ '__|              
 | |_| | |_) | (_| | (_| | ||  __/ |                 
  \___/| .__/ \__,_|\__,_|\__\___|_|       ⎦˚◡˚⎣ v$VERSION             
       |_|                                           
_______________________________________________________

"

# Ensure Sudo works
SUDO_WORKS=$(sudo whoami)
if [ "$SUDO_WORKS" != "root" ]; then
        echo "[!] Sudo is required for the process to continue...$SUDO_WORKS"
        exit 0
fi

# Required programs needed
required_programs="wget golang git"
# List of programs that will be asked to install
list_to_install=""
# Check if each is installed
for i in $required_programs
do
        # Check if it is install via dpkg
        if [ $(dpkg-query -W -f='${Status}' $i 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
                printf "[!] Required program \"$i\" was not found on your system\n"
                # Add to the list
                list_to_install+="$i "
        fi
done
# Check if the list isn't empty
if [ "$list_to_install" != "" ]; then
        # Ask the user if they want to install the listed program above
        read -p "[*] Would you like to install these [y/N] " -n 1 -r
        printf "\n"
        if [[ $REPLY =~ ^[Yy]$ ]]; then
                # Install via apt, assume yes for install
                echo -n "[+] Installing programs..."
                sudo apt install -y $list_to_install > /dev/null 2>&1
                echo -e "Done!\n"
        else
                exit 0
        fi
fi

# Set MEV-Boost location, version, service name, and owner
MEV_LOC=$(ps -fe | grep -v "[m]ev-boost-updater" | grep "/[m]ev" | head -1|  awk '$1=$1' | awk -F ' ' '{print $8}')
# Ensure MEV-Boost location is found
if [ "$MEV_LOC" == "" ]; then
        echo "[!] Can't find MEV-Boost file location..."
        exit 0
fi
MEV_VERSION=$($MEV_LOC --version | sed "s/mev-boost//g" | sed "s/ //g")
MEV_SERVICE=$(systemctl --type=service | sed 's/|/ /' | awk '{print $1}' | grep "^mev" | head -1|  awk '$1=$1' | awk -F ' ' '{print $1}')
# Ensure MEV-Boost service is found
if [ "$MEV_SERVICE" == "" ]; then
        echo "[!] Can't find MEV-Boost service..."
        exit 0
fi
MEV_OWNER=$(stat -c '%U' $MEV_LOC)

# Show information on MEV-Boost
echo "[-] Current MEV-Boost Info:"
echo "      - Location: $MEV_LOC"
echo "      - Version:  $MEV_VERSION"
echo "      - Service:  $MEV_SERVICE"
echo "      - Owner:    $MEV_OWNER"
echo -e "\n[-] Press ENTER to continue or CTRL+C to quit"
read

# Build MEV-Boost
rm -rf /tmp/mev-boost > /dev/null 2>&1
cd /tmp
echo "[-] Grabbing latest MEV-Boost source code..."
git clone https://github.com/flashbots/mev-boost.git > /dev/null 2>&1
cd mev-boost
echo -e "[-] Building MEV-Boost...\n"
make build > /dev/null 2>&1
MEV_VERSION_NEW=$(/tmp/mev-boost/mev-boost --version | sed "s/mev-boost//g" | sed "s/ //g")
sleep 3

# Compare current and build versions
echo "-------------------------------------------------"       
echo "[-] Current version:    $MEV_VERSION"
echo "[-] New build version:  $MEV_VERSION_NEW"
echo -e "-------------------------------------------------\n"
sleep 3

# Current version doesn't need to be updated
if [ "$MEV_VERSION" = "$MEV_VERSION_NEW" ]; then
        echo "[!] Versions are the same. No need to update."
# Update MEV-Boost process
else
        echo "[-] Updating MEV-Boost to version $MEV_VERSION_NEW..."
        sudo systemctl stop $MEV_SERVICE
        sudo rm $MEV_LOC
        sudo cp /tmp/mev-boost/mev-boost $MEV_LOC
        sudo chmod +x $MEV_LOC
        sudo chown $MEV_OWNER:$MEV_OWNER $MEV_LOC
        sudo systemctl start $MEV_SERVICE
        echo "[+] MEV-Boost updated: "$($MEV_LOC --version | sed "s/mev-boost//g" | sed "s/ //g")
        echo "[-] Press CTRL+C to exit or ENTER to view the MEV-Boost logs"
        read
        sudo journalctl -fu $MEV_SERVICE
fi
