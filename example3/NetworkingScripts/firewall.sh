#!/bin/bash

_PACKET_COUNT=5
_LOG_PREFIX="kcgrant_firewall_dropped: "

# Remove any existing iptables rules.
_cleanRules()
{
  echo ""
  echo "Cleaning all iptables rules..."
  sudo iptables -F INPUT
  sudo iptables -P INPUT ACCEPT
  sudo iptables -F FORWARD
  sudo iptables -P FORWARD ACCEPT
  sudo iptables -F OUTPUT
  sudo iptables -P OUTPUT ACCEPT
  sudo iptables -F LOG_AND_DROP > /dev/null 2>&1
  sudo iptables -X LOG_AND_DROP > /dev/null 2>&1
  echo ""
}

# Restricts all packets except for ICMP packets on eth1.
_startRestrictiveFirewall()
{
  echo "RESTRICTIVE"
  echo "Restricting all packets on eth1 except ICMP"
  sudo iptables -A INPUT -i eth1 -p icmp -j ACCEPT
  sudo iptables -A OUTPUT -o eth1 -p icmp -j ACCEPT
  sudo iptables -A INPUT -i eth1 -j DROP
  echo ""
}

# Log packets allowed by the restrictive firewall on eth1.
_logAllowedPackets()
{
  echo "Allowed packets:"
  echo ""
  sudo tcpdump -vvvi eth1 -c $_PACKET_COUNT
  echo ""
}

# Create an iptables chain that logs blocked packets to /var/log/messages
# before dropping them.
_createLogAndDropChain()
{
  sudo iptables -N LOG_AND_DROP
  sudo iptables -A LOG_AND_DROP -j LOG --log-prefix "$_LOG_PREFIX"
  sudo iptables -A LOG_AND_DROP -j DROP
}

# Log 5 packets blocked by the connectivitiy-based firewall.
_logDroppedPackets()
{
  echo "Dropped packets:"
  echo ""
  sudo tail -F /var/log/messages | grep -m $_PACKET_COUNT "$_LOG_PREFIX"
  echo ""
}

# Start the connectivity-based firewall.
# Allows all packets on eth1 except for ICMP packets.
_startConnectiveFirewall()
{
  echo "CONNECTIVITY-BASED"
  echo "Allowing all packets on eth1 except ICMP"
  echo ""

  _createLogAndDropChain
  sudo iptables -A INPUT -i eth1 -p icmp -j LOG_AND_DROP
  sudo iptables -A OUTPUT -o eth1 -p icmp -j LOG_AND_DROP
  sudo iptables -A INPUT -i eth1 -j ACCEPT
}

_main()
{
  _cleanRules
  _startRestrictiveFirewall
  _logAllowedPackets
  _cleanRules
  _startConnectiveFirewall
  _logDroppedPackets
  _cleanRules
}

_main

