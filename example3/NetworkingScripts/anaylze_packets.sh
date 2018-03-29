#!/bin/bash

# CMPT 471 Assignment 2
# Parts 1, 2, and 3
# Kevin Grant / 301192898

# Tested from november.
# eth1 must be down on october.
# Must be run as root.

# Hosts
_OCTOBER="172.19.1.10"
_FEBRUARY="172.17.1.2"
_SEPTEMBER="172.16.1.9"
_MAY="2002:ac10:10c:118:250:56ff:fe85:d1d8"

# Formatting
_NC='\033[0m'
_BOLD='\033[1m'

# ICMP Codes
_ICMP_CODE_UNREACHABLE=3
_ICMP_CODE_REDIRECT=5

# Temporary file for displaying routing path
_RR_FILE="./temp_rr.txt"

# Ensure the eth0 interface of October is down.
# Exit if it is up.
_ensureOctoberEth1Down()
{
  ping -c 1 -w 1 "$_OCTOBER" > /dev/null 2>&1
  if [[ $? -eq 0 ]]; then
    echo "Error: Please shut down eth1 on October"
    exit 1
  fi
}

# Ensure script is being run as root.
# Exit if not.
_ensureRoot()
{
  if [ "$EUID" -ne 0 ]
    then echo "Error: Please run script as root"
    exit 1
  fi
}

# Print a bold message.
_printBold()
{
  echo -e "${_BOLD}"$1"${_NC}"
}

_printHeader()
{
  local divider="======================================================"
  _printBold $divider
  _printBold "$1"
  _printBold $divider
}

#### PART 1 ############

# Send a ping request to october multiple times.
# A 'Destination Unreachable' response is expected.
_makePings()
{ 
  sleep 1
  for i in {0..2}; do
    ping -c 1 -w 1 "$_OCTOBER" > /dev/null 2>&1
  done
}

# Capture an ICMP Destination Unreachable message by sending pings
# to a down interface, and listening for ICMP unreachable messages
# via tcpdump.
_captureDestUnreachable()
{
  _printHeader "Part 1"
  _printBold "ICMP Destination Unreachable Message:"
  echo ""
  _makePings &
  tcpdump -vvnni eth1 -c 1 -e icmp[icmptype] == $_ICMP_CODE_UNREACHABLE
  echo ""
}

#### PART 2 ############

# Send a ping to september.
# A redirect should occur. Write the output of ping to a temporary file.
_sendPingForRedirect()
{
  sleep 2
  _RR=$(ping -c 1 -w 1 -R "$_SEPTEMBER")
  echo -n "$_RR" > $_RR_FILE
}

# Display the changes of the routing cache.
# $1 = the old routing cache
_displayRoutingCaches()
{
  _printBold "Routing Cache:"
  echo ""
  echo "Before Redirect:"
  echo ""
  echo -n "$1"
  echo ""
  echo ""
  echo "After Redirect:"
  echo ""
  route -C
  echo ""
}

# Display the routing path from the redirected ping.
# Delete the temporary file after it is read.
_displayRoutingPath()
{
  _printBold "Routing Path:"
  echo ""
  cat $_RR_FILE | grep -A 10 RR | egrep -v "statistics|packets"
  rm $_RR_FILE
  echo ""
}

# Flush the route cache and set up the routing table for redirects.
_setupRoute() 
{
  ip route flush cache
  route del default gw "$_FEBRUARY" > /dev/null 2>&1
  route add default gw "$_FEBRUARY"
}

# Capture an ICMP Redirect Message, show the changes to the routing
# cache, and show the routing table.
# Add February as the default gateway and ping September. February
# will issue a redirect message to this host (November) notifying 
# us that the packet is forwarded to January.
_captureRedirect()
{
  _setupRoute
  local oldCache=$(route -C)
  
  _printHeader "Part 2"
  _printBold "ICMP Redirect Message:"
  echo ""
  _sendPingForRedirect &
  tcpdump -vvnni eth1 -c 1 -e icmp[icmptype] == $_ICMP_CODE_REDIRECT  
  echo ""

  _displayRoutingCaches "$oldCache"
  _displayRoutingPath "$_RR"

  route del default gw "$_FEBRUARY"
}

#### PART 3 ############

# Execute a tracepath6 command with May as the host.
_sendTracepath6()
{
  sleep 1
  tracepath6 "$_MAY" > /dev/null 2>&1
}

# Capture an IPv6 Datagram encapsulated within an IPv4 datagram.
# ip[9] references the protocol field in the IPv4 header, and 41
# is the IPv6 code.
_captureEncapsulatedDatagram()
{
  _printBold "Encapsulated IPv6 Datagram:"
  echo ""

  _sendTracepath6 &
  tcpdump -vvni eth1 -c 1 ip[9]==41
}

# Capture an IPv6 Datagram, sent from network 17 to 18.
_captureV6Datagram()
{
  _printHeader "Part 3"
  _printBold "IPv6 Datagram:"
  echo ""

  _sendTracepath6 &
  tcpdump -vvni eth1 -c 1 ip6
  echo ""
}

_main()
{
  _ensureRoot
  _ensureOctoberEth1Down
  _captureDestUnreachable
  _captureRedirect
  _captureV6Datagram
  _captureEncapsulatedDatagram
}

_main