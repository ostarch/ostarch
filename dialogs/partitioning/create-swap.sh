#!/bin/bash
#--------------------------------------------------------------------
#   █████╗ ██████╗  ██████╗██╗  ██╗██████╗  █████╗ ██╗   ██╗███████╗
#  ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗██╔══██╗██║   ██║██╔════╝
#  ███████║██████╔╝██║     ███████║██║  ██║███████║██║   ██║█████╗  
#  ██╔══██║██╔══██╗██║     ██╔══██║██║  ██║██╔══██║╚██╗ ██╔╝██╔══╝  
#  ██║  ██║██║  ██║╚██████╗██║  ██║██████╔╝██║  ██║ ╚████╔╝ ███████╗
#  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝  ╚═══╝  ╚══════╝
#--------------------------------------------------------------------
PARTITION_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"


selectSwapOption() {
  SWAP_TYPE=""
  sed -i '/^SWAP_TYPE=/d' "$PARTITION_DIR/../../install.conf"
  options=()
  options+=("none" "")
  options+=("Swap File" "")
  if [ ! "$1" = "file" ]; then
    options+=("Swap Partition" "")
  fi
  result=$(whiptail --backtitle "${TITLE}" --title "Select Swap Option" --menu "" --default-item "Swap File" 0 0 0 "${options[@]}" 3>&1 1>&2 2>&3)
  if [ ! "$?" = "0" ]; then
    return 1
  fi
  case "$result" in
    "none")
      return 1
      ;;
    "Swap Partition")
      SWAP_TYPE="partition"
      ;;
    "Swap File")
      SWAP_TYPE="file"
      ;;
  esac


  HIBERNATE_TYPE=""
  sed -i '/^HIBERNATE_TYPE=/d' "$PARTITION_DIR/../../install.conf"
  options=()
  options+=("without Hibernate" "")
  options+=("with Hibernate" "")
  result=$(whiptail --backtitle "${TITLE}" --title "Select Swap Option" --cancel-button "Back" --menu "" 0 0 0 "${options[@]}" 3>&1 1>&2 2>&3)
  if [ ! "$?" = "0" ]; then
    return 0
  fi
  case "$result" in
    "with Hibernate")
      HIBERNATE_TYPE="hibernate"
      ;;
  esac

}

getSwapSpace() {
  availableSpace=$(lsblk -dnb -o SIZE "$DISK")
  spaceThreshold=$((availableSpace * 10 / 100))
  totalMemory=$(awk '/^MemTotal/ {print $2}' /proc/meminfo)
  totalMemory=$((totalMemory * 1024))
  swapSize=0
  GiB4=$((4*1024*1024*1024))
  GiB8=$((${GiB4}*2))
  if [ "$totalMemory" -lt "${GiB4}" ]; then
    swapSize=$(($totalMemory*2))
  elif [ "$totalMemory" -lt "${GiB8}" ]; then
    swapSize=${GiB8}
  else
    swapSize=$totalMemory
  fi

  if [ "$HIBERNATE_TYPE" != "hibernate" ]; then
    swapSize=$(( $swapSize < ${GiB8} ? $swapSize : ${GiB8} ))
  fi

  swapSize=$(echo $swapSize | awk '{print int($1*1.3+0.5)}')

  if [ "$HIBERNATE_TYPE" != "hibernate" ]; then
    swapSize=$(( $swapSize > $spaceThreshold ? $spaceThreshold : $swapSize ))
  fi

  echo $swapSize
}
