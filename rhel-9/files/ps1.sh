#!/bin/bash

GIT_URL=$(git config --get remote.origin.url)
[ -z "${GIT_URL}" ] && GIT_URL=null
PUBLIC_IP=$(curl -s -f ifconfig.me)
if [ -z "${PUBLIC_IP}" ]; then
  PUBLIC_IP=null
fi
PRIVATE_IP=$(curl -s -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance?api-version=2021-02-01" | jq .network.interface[0].ipv4.ipAddress[0].privateIpAddress 2>/dev/null| xargs)
INSTANCE_TYPE=$(curl -s -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance?api-version=2021-02-01" | jq .compute.vmSize 2>/dev/null |xargs)
export PS1="
\e[1;32m${PUBLIC_IP} | ${PRIVATE_IP} | ${INSTANCE_TYPE} | \$(git config --get remote.origin.url || echo null)
[ \[\e[1;31m\]\u\[\e[m\]@\[\e[1;33m\]\h\[\e[m\] \[\e[1;36m\]\w\[\e[m\] ]\\$ "
