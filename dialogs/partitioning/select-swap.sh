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
  unset SWAP_TYPE
  unset HIBERNATE_TYPE

  sed -i '/^SWAP_TYPE=/d' "$PARTITION_DIR/../../install.conf" &>/dev/null
  options=()
  options+=("none" "")
  options+=("Swap File" "(recommended)")
  options+=("Swap Partition" "")
  result=$(whiptail --backtitle "${TITLE}" --title "Select Swap Option" --menu "" --default-item "Swap File" 0 0 0 "${options[@]}" 3>&1 1>&2 2>&3)
  if [ ! "$?" = "0" ]; then
    return 1
  fi
  case "$result" in
    "none")
      unset SWAP_TYPE
      unset HIBERNATE_TYPE
      return 2
      ;;
    "Swap Partition")
      SWAP_TYPE="partition"
      ;;
    "Swap File")
      SWAP_TYPE="file"
      ;;
  esac
}

selectHibernateOption() {
  unset HIBERNATE_TYPE
  sed -i '/^HIBERNATE_TYPE=/d' "$PARTITION_DIR/../../install.conf" &>/dev/null
  options=()
  options+=("without Hibernate" "")
  options+=("with Hibernate" "")
  result=$(whiptail --backtitle "${TITLE}" --title "Select Hibernate Option" --cancel-button "Back" --menu "" 0 0 0 "${options[@]}" 3>&1 1>&2 2>&3)
  if [ ! "$?" = "0" ]; then
    return 1
  fi
  case "$result" in
    "without Hibernate")
      ;;
    "with Hibernate")
      HIBERNATE_TYPE="hibernate"
      ;;
  esac
}

# returning the swap size in MiB
getSwapSpace() {
  local disk="$ROOT_PARTITION"
  [ -z "$disk" ] && disk="$DISK"
  availableSpace=$(lsblk -dnb -o SIZE "$disk")
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

  swapSize=$(echo $swapSize | awk '{print int($1*1.1+0.5)}')
  swapSize=$(printf "%.0f\n" "$swapSize")

  if [ "$HIBERNATE_TYPE" != "hibernate" ]; then
    swapSize=$(( $swapSize > $spaceThreshold ? $spaceThreshold : $swapSize ))
  fi

  swapSize=$(echo $swapSize | awk '{print int($1/1024/1024+0.5)}')

  swapSize=$(printf "%.0f\n" "$swapSize")
  echo $swapSize
}
