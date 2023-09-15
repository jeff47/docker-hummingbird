#!/usr/bin/env bash
set -o nounset

#################################
#  Basic startup file to read the config file, set some basic firewall rules,
#    and then execute hummingbird.
#
#

# Initialize variables
config_file="/vpn/hummingbird.ini"   # Path as seen from inside the docker container
lock_file="/etc/airvpn/hummingbird.lock"
options=""

# Make sure the config file is present
if [ ! -f ${config_file} ]; then
	echo "FATAL ERROR: Config file ${config_file} is missing.  Maybe you need to make one?"
	exit 1
fi

# Make sure the config file is readable
if [ ! -r ${config_file} ]; then
	echo "FATAL ERROR: Config file ${config_file} is present but could not be read. (Check permissions)"
	exit 1
fi

echo "Reading options from ${config_file}"

# Read the config file
while IFS='=' read -r key value; do
  if [[ -n "$key" && ! "$key" =~ ^# ]]; then
    key=$(echo "$key" | awk '{$1=$1};1')			# Strip whitespace
    value=$(echo "$value" | awk -F# '{print $1'})	# cut out comments
    value=$(echo "$value" | awk '{$1=$1};1')  		# Strip whitespace
    if [[ "$key" == "ovpn-config" ]]; then			# this parameter must be last on the CLI
        ovpn_config=${value}
	else
    	options="$options --$key $value"
	fi
    options=$(echo "$options" | awk '{$1=$1};1')	# Strip whitespace again
  fi
done < "$config_file"

echo "Setting up basic firewall options..."
# Get local IPs
dockerip=$(ip route show dev eth0 | awk '/scope link src/{print $7}')
dockergw=$(ip route show default dev eth0 | awk '{print $3}')
dockernet=$(ip route show dev eth0 | awk '/scope link src/{print $1}')

# Clear existing IP6 chains
ip6tables --flush
iptables --delete-chain
ip6tables -t nat --flush
ip6tables -t nat --delete-chain

# Drop all IP6
ip6tables -P INPUT DROP
ip6tables -P FORWARD DROP
ip6tables -P OUTPUT DROP

# Allow local access
ip rule add from ${dockerip} lookup 10
iptables -A INPUT -d ${dockerip} -j ACCEPT
ip route add default via ${dockergw} table 10

# Check for stale lock file
if [ -f ${lock_file} ]; then
  pidof hummingbird || ( echo "Removing stale lockfile." && rm ${lock_file} )
fi

# Run hummingbird
echo "Executing: hummingbird ${options} ${ovpn_config}"
exec sg vpn -c "/usr/local/bin/hummingbird ${options} ${ovpn_config}"
