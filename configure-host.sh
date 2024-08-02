#!/bin/bash

verbose=0

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -verbose) verbose=1 ;;
        -name) desiredName="$2"; shift ;;
        -ip) desiredIPAddress="$2"; shift ;;
        -hostentry) desiredHostEntryName="$2"; desiredHostEntryIP="$3"; shift; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done


log() {
    if [ $verbose -eq 1 ]; then
        echo "$1"
    fi
}


update_hostname() {
    currentName=$(hostname)
    if [ "$currentName" != "$desiredName" ]; then
        log "Updating hostname from $currentName to $desiredName"
        echo "$desiredName" > /etc/hostname
        sed -i "s/$currentName/$desiredName/g" /etc/hosts
        hostnamectl set-hostname "$desiredName"
        logger "Hostname changed from $currentName to $desiredName"
    else
        log "Hostname is already set to $desiredName"
    fi
}


update_ip() {
    currentIP=$(hostname -I | awk '{print $1}')
    if [ "$currentIP" != "$desiredIPAddress" ]; then
        log "Updating IP from $currentIP to $desiredIPAddress"
        sed -i "s/$currentIP/$desiredIPAddress/g" /etc/hosts
        # Assuming netplan is used for network configuration
        netplanConfig=$(find /etc/netplan -name '*.yaml')
        sed -i "s/$currentIP/$desiredIPAddress/g" "$netplanConfig"
        netplan apply
        logger "IP address changed from $currentIP to $desiredIPAddress"
    else
        log "IP address is already set to $desiredIPAddress"
    fi
}


update_hosts_file() {
    if ! grep -q "$desiredHostEntryIP $desiredHostEntryName" /etc/hosts; then
        log "Adding $desiredHostEntryIP $desiredHostEntryName to /etc/hosts"
        echo "$desiredHostEntryIP $desiredHostEntryName" >> /etc/hosts
        logger "Added $desiredHostEntryIP $desiredHostEntryName to /etc/hosts"
    else
        log "$desiredHostEntryIP $desiredHostEntryName is already in /etc/hosts"
    }
}


if [ -n "$desiredName" ]; then
    update_hostname
fi

if [ -n "$desiredIPAddress" ]; then
    update_ip
fi

if [ -n "$desiredHostEntryName" ] && [ -n "$desiredHostEntryIP" ]; then
    update_hosts_file
fi
