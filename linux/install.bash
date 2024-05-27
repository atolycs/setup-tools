#!/usr/bin/env bash

# https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
# Reset
Color_Off='\033[0m' # Text Reset

# Regular Colors
Black='\033[0;30m'  # Black
Red='\033[0;31m'    # Red
Green='\033[0;32m'  # Green
Yellow='\033[0;33m' # Yellow
Blue='\033[0;34m'   # Blue
Purple='\033[0;35m' # Purple
Cyan='\033[0;36m'   # Cyan
White='\033[0;37m'  # White

script_version="1.0.0"

function greeting() {
	echo "+-----------------------------------------+"
	echo "|  Atolycs Linux Setup Tools              |"
	echo "|                              ver ${script_version}  |"
	echo "|                              Atolycs    |"
	echo "+-----------------------------------------+"
}

function run_message() {
	#if [[ $(id -u atolycs) == "" ]]; then
	echo "Dont use my settings unless you know what that entails."
	echo "                        !!Use at your own risk!!       "
	#fi

}

function info() {
	local message=$1

	echo -e "[ ${Cyan}INFO${Color_Off} ]: ${message}"
}

function warn() {
	local message=$1

	echo -e "[ ${Yellow}INFO${Color_Off} ]: ${message}"
}

function error() {
	local message=$1

	echo -e "[ ${Red}ERROR${Color_Off} ]: ${message}"
}

function isRoot() {
	if [[ $(id -u) -ne 0 ]]; then
		return true
	else
		return false
	fi
}

function main() {

	greeting
	run_message

	if [[ $(id -u) -ne 0 ]]; then
		error "Please Run as root"
		exit 3
	fi

}

main $@
