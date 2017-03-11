#!/usr/bin/env bash

ElementIn () {
	local e
	#for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
	for e in "${@:2}"; do [[ "$e" =~ "$1" ]] && return 0; done
	return 1
}

getIndex () {
	
	array=(${@:2})

	for e in "${!array[@]}"; do
		if [[ "${array[$e]}" =~ "$1" ]]; then
			echo "${e}"
			return 0
			break;
		fi
	done

	return -1;
}

pkg=$(which pkg)
portsnap=$(which portsnap)
portmaster=$(which portmaster)

$pkg update -f 
$pkg upgrade -y
$portsnap fetch update

IFS=$'\n'
pnu=($($portmaster -L --index-only | grep "New version available" | awk '{print $5}'))


pnu_full=("${pnu[@]}")

echo
echo "--------------->>"
echo "Port Master Packages Needing Upgrading:"
printf '%s\n' "${pnu_full[@]}"
echo


for (( i=0; i<${#pnu[@]}; i=$i+1 )); do pnu[${i}]="${pnu[${i}]%-*}"; done

IFS=$'\n'
if $pkg lock --has-locked-packages; then
	packages=( $($pkg lock --show-locked) )
	
	#Shift array not to include the "Currently locked packages first element"
	packages=("${packages[@]:1}")

	#Remove the version and release numbers from the packages
	for (( i=0; i<${#packages[@]}; i=$i+1 )); do packages[${i}]="${packages[${i}]%-*}"; done
	
	echo "--------------->>"
	echo "Locked ports"
	printf '%s\n' "${packages[@]}";
	echo

	#Compare the locked package list with the ports-needing-upgrade from portmaster
	#unique-packages=( `echo ${pnu[@]} ${packages[@]} ` )
  	#This will give the intersection between the locked package list and the portmaster upgrade list

	locked_packages_needing_upgrading=( $(echo ${pnu[@]} ${packages[@]} | tr ' ' '\n' | sort | uniq -d ) )

	
	echo "--------------->>"
	echo "Locked packages needing upgrading"
	printf '%s\n' "${locked_packages_needing_upgrading[@]}"
	echo

	if [ "${#locked_packages_needing_upgrading[@]}" -gt 0 ]; then
		for e in "${locked_packages_needing_upgrading[@]}"; do $pkg unlock -y "${e}"; done
		for e in "${locked_packages_needing_upgrading[@]}"; do $portmaster -yGd --no-confirm "${e}"; done
		for e in "${locked_packages_needing_upgrading[@]}"; do $pkg lock -y "${e}"; done	
	fi	

fi

$portmaster -dGya --no-confirm


#	if ElementIn "vim" "${pnu_full[@]}"; then
#		c=$(getIndex "vim" "${pnu_full[@]}")
#		echo "cat: $c"
#		echo "return: $?"
#		echo		
#	fi

########### End Upgrade Script
