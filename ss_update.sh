#!/bin/bash

validate_input() {
    if [ "$ARCH_NUMBER" -ge 1 ] && [ "$ARCH_NUMBER" -le 5 ]; then
        return 0
    else
        return 1
    fi
}

ARCH_PATH="/var/subspace_arch.txt"

if [ -f "$ARCH_PATH" ]; then
    ARCH=$(cat $ARCH_PATH)
else
   echo -e "Enter NUMBER for CPU architecture"
   echo -e "1) ubuntu-x86_64-skylake - for Intel Skylake/AMD Ryzen processors and newer"
   echo -e "2) ubuntu-x86_64-v2 - for older processors since ~2009 and some old VMs"
   echo -e "3) ubuntu-aarch64 - for ARM 64 processors"
   echo -e "4) macos-aarch64 for Mac on Apple M1/M2/M3 processors"
   echo -e "5) macos-x86_64 for Mac on Intel processors"
   read ARCH_NUMBER

   while ! validate_input; do
   	echo "Incorrect input, please select from 1 to 5:"
   	read ARCH_NUMBER
   done

   case "$ARCH_NUMBER" in
        1) ARCH="ubuntu-x86_64-skylake" ;;
        2) ARCH="ubuntu-x86_64-v2" ;;
        3) ARCH="ubuntu-aarch64";;
        4) ARCH="macos-aarch64";;
        5) ARCH="macos-x86_64" ;;
   esac

   echo $ARCH >/var/subspace_arch.txt

fi

ACTUAL=$(curl -s https://api.github.com/repos/subspace/subspace/releases/latest | jq -r '.name')
VERSION_PATH="/var/subspace_version.txt"
if [ -f "$VERSION_PATH" ]; then
    INSTALLED=$(cat $VERSION_PATH)
else
    INSTALLED="Unknown"
fi

echo -e "Installed version: $INSTALLED"
echo -e "Actual version:    $ACTUAL"

if [[ "$ACTUAL" == "$INSTALLED" ]]; then
	echo "No updates"
else
	echo -e "Start update"
        echo -e "\033[0;0mStart update"
        wget -O subspace-farmer $(wget -qO-  https://api.github.com/repos/subspace/subspace/releases/latest | grep browser_download_url | grep "farmer-$ARCH" | awk '{print $2}' | sed 's/"//g')
        wget -O subspace-node $(wget -qO-  https://api.github.com/repos/subspace/subspace/releases/latest | grep browser_download_url | grep "node-ubuntu-$ARCH" | awk '{print $2}' | sed 's/"//g')
        chmod +x subspace-*
        echo -e "Stop subspace-farmer.service"
        sudo systemctl stop subspace-farmer.service
        echo -e "Stop subspace-node.service"
        sudo systemctl stop subspace-node.service
        echo -e "Move binary"
        mv subspace-* /usr/bin/
        echo -e "Start subspace-farmer.service"
        sudo systemctl start subspace-node.service
        echo -e "Start subspace-node.service"
        sudo systemctl start subspace-farmer.service
	echo $ACTUAL > $VERSION_PATH
	echo -e "Done"
	echo -e "Check logs for node and farmer:"
	echo -e "journalctl -u subspace-node.service -o cat -f"
        echo -e "journalctl -u subspace-farmer.service -o cat -f"
fi
