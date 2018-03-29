#!/bin/bash

# CMPT 471 Assignment 1
# Kevin Grant / 301192898

_CLIENT_HOSTNAMES="summer fall equinox april june september may july winter \
                   october solstice year november august spring autumn \
                   december january february march" 

_CLIENT_V4_ADDRESSES="172.16.1.13 172.16.1.14 172.16.1.6 172.16.1.4 172.16.1.6 172.16.1.9 \
                      172.18.1.5 172.18.1.7 172.18.1.15 172.19.1.10 172.19.1.17 172.19.1.18 \
                      172.17.1.11 172.17.1.8 172.17.1.19 172.17.1.20 172.17.1.1 172.17.1.2 \
                      172.18.1.2 172.18.1.3 172.20.0.10"

_CLIENT_V6_ADDRESS="fdd0:8184:d967:118:250:56ff:fe85:d1d8"

_NETWORKS="admin net16 net17 net18 net19"

# ping response codes
_CODE_OK=0 
_CODE_NO_RESPONSE=1
_CODE_UNKNOWN_HOST=2

# ping options
_PING_COUNT=1
_PING_DEADLINE=1

# formatting strings
_ARROW="  -->"
_NC='\033[0m'
_BOLD='\033[1m'
_BARRIER="${_BOLD}===========================================================${_NC}"
_FAIL='\033[0;33m'
_GREEN='\033[0;32m'


# Get the IP address of the current host.
# If retrieval of IP fails, just use hostname as a failsafe
_setup()
{
  _IP=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo -m 1 '172\.([0-9]*\.){2}[0-9]*' | grep -v '127.0.0.1')
  if [[ -z "$_IP" ]]; then _IP=$(hostname); fi
}

# Retrieves the host string from the specified server and network
# If no network is provided, the host string is just the server.
# $1 - the host (hostname or IP address)
# $2 - the network (optional)
_getHostString()
{
  local server="$1"
  local network="$2"
  
  if [[ -z "$network" ]]; then echo "$server"; else echo "$server.$network"; fi
}

# Send a ping to the specified server (network optional)
# $1 - the host (hostname or IP address)
# $2 - the network (optional)
_pingHost()
{
  local host=$(_getHostString "$1" "$2")

  ping -c $_PING_COUNT -w $_PING_DEADLINE -R "$host" 2>/dev/null
}

# Retrieves the routing path from ping output.
# $1 - the ping response
# $2 - the host string
_getRoutingPathFromResponse()
{
  local response="$1"
  local host="$2"
  local path=$(echo "$response" | grep -A 100 RR | grep -m 1 -B 100 "$host")

  # do some extra formatting
  path=$(echo "$path" | sed -r "s/RR:\s*//g" | sed -r "s/^\s*/\t/g")

  echo -e "$_ARROW Routing Path:"
  echo "$path"
}

# Provide the ethernet address of the connection if the host
# is on the same network.
# $1 - the host string
_maybeShowEthernetAddress()
{
  local host="$1"
  local ethernet=$(arp | grep "$host")

  if [[ -n "$ethernet" ]]; then
    ethernet=$(echo "$ethernet" | grep -Eo '([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}')
    echo -e "$_ARROW Ethernet:"
    echo -e "\t$ethernet"
  fi
}

# Generate output appropriate for the ping OK response.
# $1 - the ping response
# $2 - the host (hostname of IP address)
# $3 - the network (optional)
_handlePingOkResponse()
{
  local response="$1"
  local host=$(_getHostString "$2" "$3")

  
  echo -e "\t${_GREEN}Reachable${_NC}"

  _getRoutingPathFromResponse "$response" "$host"
  _maybeShowEthernetAddress "$host"
}

# Generate output apporpriate for when ping gets no response.
# $1 - the host (hostname or IP address)
# $2 - the network
_handlePingNoResponse()
{
  local host=$(_getHostString "$1" "$2")
 
  echo -e "\t${_FAIL}No Response${_NC}"
}

# Generate output for when ping unknown host response.
# $1 - the host (hostname or IP address)
# $2 - the network
_handlePingUnknownHost()
{
  local host=$(_getHostString "$1" "$2")

  echo -e "\t${_FAIL}Unreachable${_NC}"
}

# Launch the apporpriate action given the response code.
# $1 - return value of the ping command
# $2 - the ping response
# $3 - the host (hostname or IP)
# $4 - the network
_handlePingReturnValue()
{
  local code="$1"
  local response="$2"
  local host="$3"
  local network="$4"

  echo -e "$_ARROW Status:"
  case "$code" in
    $_CODE_OK)
      _handlePingOkResponse "$response" "$host" "$network"
      ;;
    $_CODE_NO_RESPONSE)
      _handlePingNoResponse "$host" "$network"
      ;;
    $_CODE_UNKNOWN_HOST)
      _handlePingUnknownHost "$host" "$network"
      ;;
    *)
      echo "Unknown ping response code: $code"
      ;;
  esac
  echo ""
}

# print a header for the host.
# $1 - the host (hostname or IP address)
_printHostname()
{
  echo -e "$_BARRIER"
  echo -e "${_BOLD}$host${_NC}"
  echo -e "$_BARRIER"
  echo "Testing from $_IP"
  echo ""
}

# Test connectivity to each server and network using hostnames.
# Get the response for every client with every network (using ping)
# and parse the output.
_testHostnames()
{
  for host in $_CLIENT_HOSTNAMES; do
  _printHostname "$host"
    for network in $_NETWORKS; do
      echo -e "${_BOLD}$host.$network${_NC}"
      response=$(_pingHost "$host" "$network")
      _handlePingReturnValue "$?" "$response" "$host" "$network"
    done
  done
}

# Test connectivity to each IPv4 address using ping, and parse the
# output.
_testV4Addresses()
{
  for host in $_CLIENT_V4_ADDRESSES; do
    _printHostname "$host"
    response=$(_pingHost "$host")
    _handlePingReturnValue "$?" "$response" "$host"
  done
}

# Test connectivity to the IPv6 address.
# Use tracepath6 instead of ping6, because ping6 provides no option to retrieve
# the routing path.
_testV6Address()
{
  local host="$_CLIENT_V6_ADDRESS"

  _printHostname "$host"
  response=$(tracepath6 $host)

  # If tracepathCode is 1, then tracepath failed.
  # If noReplyCode is 0, then tracepath did not receive a reply.
  local tracepathCode="$?"
  echo "$response" | grep "no reply" &>/dev/null
  local noReplyCode="$?"

  echo -e "$_ARROW Status:"
  if [ $tracepathCode -eq 1 ] || [ $noReplyCode -eq 0 ]; then
    _handlePingNoResponse "$host"
  else
    echo -e "\t${_GREEN}Reachable${_NC}"
    echo -e "$_ARROW Routing Path:"
    echo "$response" | grep -v "Resume" | sed -r "s/^\s*/\t/g"
  fi

  echo ""
}

_main()
{
  _testHostnames
  _testV4Addresses
  _testV6Address
}

_setup
_main
