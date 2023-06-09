#!/usr/bin/env bash
echo "*******************************************************"
echo "* 3                                                   *"
echo "*                   System-Install                    *"
echo "*                                                     *"
echo "*******************************************************"

# Skip Pacstrap (Base Install), if Done Earlier:
    if [[ "$Part" -ne 2  &&  $Pa -eq 2 ]]; then
            PS5='Skip Pacstrap (Base Install), If Done Earlier? '
            echo "Skip Pacstrap (Base Install), If Done Earlier?"
                options=("Yes, Skip Pacstrap (Base Install)" "No, Do Pacstrap (Base Install) Now")
                select opt in "${options[@]}"
                do
                    case $opt in
                        "Yes, Skip Pacstrap (Base Install)")
                            BsInst=0
                            break
                            ;;
                        "No, Do Pacstrap (Base Install) Now")
                            BsInst=1
                            break
                            ;;
                        *) echo "invalid option $REPLY";;
                    esac
                done
    fi