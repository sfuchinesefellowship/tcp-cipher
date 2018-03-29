#!/bin/bash

_OCTOBER="172.19.1.10"

# Script for testing the firewall script. Run this script on 
# January, and run the firewall script on November. Run this script 
# first and follow instructions.

_ensureJanuary()
{
  if [[ `hostname -f` != january ]]; then
      echo "Please run this script on January"
      exit -1
  fi
}

_waitForInput()
{
  echo "Hit any key when the firewall script is running on October"
  read ready
}

_sendPings()
{
  ping $_OCTOBER -c 4
}

_sendBlockedPings()
{
  for i in {1..7}; do
    ping $_OCTOBER -w 1
  done
}

_main()
{
  _ensureJanuary
  _waitForInput
  _sendPings
  sleep 3 
  _sendBlockedPings
}

_main

