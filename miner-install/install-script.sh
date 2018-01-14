#!/bin/sh
# Sigil Miner Install Script (Actually, should work for https://github.com/pooler/cpuminer too)
DIR_HERE="$(cd "$(dirname "$0")" && pwd)"
. "$DIR_HERE/os-detect.sh"

# User inputs (should accept these as command line options)
MINER_TYPE="$1" # CCMiner, NSGMiner, or CPUMiner
USERNAME="$2" # Username of your sigilmining.com account
WORKERNAME="$3" # Workername that you created on sigilmining.com
WORKERPASS="$4" # Corresponding worker password you created

# Get operating system family
os_detect
OS_SPECIFIC="$OS"
UNAME=$(uname)
if [ "$UNAME" = "Linux" ]; then
	OS_CATEGORY="lin"
	DEP_LISTER="ldd"
	DEP_OPTION=""
elif [ "$UNAME" = "FreeBSD" ]; then
	OS_CATEGORY="lin"
	DEP_LISTER="ldd"
	DEP_OPTION=""
elif [ "$UNAME" = "Darwin" ]; then
	OS_CATEGORY="osx"
	DEP_LISTER="otool"
	DEP_OPTION="-L"
fi
if [ "$OS_SPECIFIC" = "Ubuntu" ]; then
	PKG="apt"
	DIR_DEPS_LIN="/usr/lib/x86_64-linux-gnu" # (but sometimes without the "/usr")
elif [ "$OS_SPECIFIC" = "Debian" ]; then
	PKG="apt"
	DIR_DEPS_LIN="/usr/lib/x86_64-linux-gnu"
elif [ "$OS_SPECIFIC" = "CentOS Linux" ]; then
	PKG="yum"
	DIR_DEPS_LIN="/lib64"
elif [ "$OS_SPECIFIC" = "Fedora" ]; then # Maybe Fedora Linux??
	PKG="yum"
	DIR_DEPS_LIN="/lib64"
elif [ "$OS_SPECIFIC" = "RHEL" ]; then # Maybe RHEL Linux??
	PKG="yum"
	DIR_DEPS_LIN="/lib64"
elif [ "$OS_SPECIFIC" = "FreeBSD" ]; then
	PKG="pkg"
	DIR_DEPS_LIN="/compat/linux/lib64"
elif [ "$OS_SPECIFIC" = "Darwin" ]; then
	PKG="brew"
fi

DIR_DEPS_SOURCE="$DIR_HERE/deps"
FILENAME_DOWNLOAD="sigil-cpuminer-$OS_CATEGORY-1.0.0.zip"
FILE_DOWNLOAD="$DIR_HERE/$FILENAME_DOWNLOAD"
DIRNAME_MINER="cpuminer-$OS_CATEGORY"
DIR_MINER="$DIR_HERE/$DIRNAME_MINER"
URL_MINER="stratum+tcp://www.sigilmining.com:3333"

install_dep_via_PKG() {
	printf 'Checking for dependency "%s"...' "$1"
	path_dep=$(which "$1")
	if [ "x`printf '%s' "$path_dep" | tr -d "$IFS"`" = x ]; then
		printf 'Not found...Attempting to install...'
		"$PKG" install "$1"
	else
		printf 'Found.\n'
	fi
}

install_dep_via_PKG wget
wget "https://github.com/Sigil-Developer/CPUMiner-Sigil/releases/download/1.0.0/$FILENAME_DOWNLOAD"

install_dep_via_PKG unzip
unzip "$FILE_DOWNLOAD" && rm "$FILE_DOWNLOAD"

# It might be better if we only copied that dependencies it asked for:
# deps_raw=$("$DEP_LISTER" "$DEP_OPTION" "$DIR_MINER/minerd")

# copy deps into place
if [ "$OS_CATEGORY" = "lin" ]; then
	cp -n "$DIR_DEPS_SOURCE"/* "$DIR_DEPS_LIN"
fi

# should we spawn a 'screen' and execute this in there?
if [ "$MINER_TYPE" = "CCMiner" ]; then
	"$DIR_MINER/ccminer" -a "neoscrypt" -o "$URL_MINER" -u "$USERNAME.$WORKERNAME" -p "$WORKERPASS"
elif [ "$MINER_TYPE" = "NSGMiner" ]; then
	"$DIR_MINER/nsgminer" --neoscrypt -o "$URL_MINER" -u "$USERNAME.$WORKERNAME" -p "$WORKERPASS"
elif [ "$MINER_TYPE" = "CPUMiner" ]; then
	"$DIR_MINER/minerd" -a "neoscrypt" -o "$URL_MINER" -O "$USERNAME.$WORKERNAME:$WORKERPASS"
fi

