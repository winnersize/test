#!/bin/bash

HOSTS_FILE="/etc/hosts"
CONF_DIR="/etc/default/"
BRIDGE_CONFIG_FILE="tektelic-bridge.toml"
OAM_CONFIG_FILE="tektelic-bridge.oam.toml"
NS_CONFIG_FILE="tektelic-bridge.ns.toml"
GEO_CONFIG_FILE="tektelic-bridge.geo.toml"
MQTT_SERVICE_NAME="mqtt-bridge"
MQTT_SERVICE_CMD="/etc/init.d/${MQTT_SERVICE_NAME} restart"
NEW_LINE='url = "ssl://tek-iot.kyivcity.gov.ua"'

# Find the MAC	
MAC=$(grep 'gw_mac' "${CONF_DIR}${BRIDGE_CONFIG_FILE}" | awk -F'"' '{print $2}')

LOG_FILE="/var/log/log_$MAC.log"
exec &>> "${LOG_FILE}"
echo "$(date +'%Y-%m-%d %H:%M:%S'): GW_MAC= $MAC"

##HOSTS file
HOSTS_ENTRY="185.185.253.220[[:space:]]+tek-iot.kyivcity.gov.ua"
if grep -Eq "${HOSTS_ENTRY}" "${HOSTS_FILE}"; then
    echo "$(date +'%Y-%m-%d %H:%M:%S'): Line exist in ${HOSTS_FILE}"
else
    echo "$(date +'%Y-%m-%d %H:%M:%S'):Add line to ${HOSTS_FILE}"
    echo "185.185.253.220    tek-iot.kyivcity.gov.ua" >> "${HOSTS_FILE}"
fi
## OAM_Conf file
if grep -q '^url = "ssl://tek-iot.kyivcity.gov.ua"$' "${CONF_DIR}${OAM_CONFIG_FILE}"; then
	echo "$(date +'%Y-%m-%d %H:%M:%S'): Url with ssl exist in ${OAM_CONFIG_FILE}"
else	
	if grep '^url = "*"' "${CONF_DIR}${OAM_CONFIG_FILE}"; then		
		sed -i '/^url =/ s/^/#/' "${CONF_DIR}${OAM_CONFIG_FILE}"		
		sed -i "/^#url =/i ${NEW_LINE}" "${CONF_DIR}${OAM_CONFIG_FILE}"
		echo "$(date +'%Y-%m-%d %H:%M:%S'): Add url 'url = \"ssl://tek-iot.kyivcity.gov.ua\"' in ${OAM_CONFIG_FILE}"
	else
		echo "$(date +'%Y-%m-%d %H:%M:%S') - Url not found in ${OAM_CONFIG_FILE}"
	fi
fi
## NS_Conf file:
if grep -q '^url = ".*://[^/].*"$' "${CONF_DIR}${NS_CONFIG_FILE}"; then
    # String is not commented
    sed -i '/^url =/ s/^/#/' "${CONF_DIR}${NS_CONFIG_FILE}"
    echo "$(date +'%Y-%m-%d %H:%M:%S'): STRING in ${NS_CONFIG_FILE} was commented" 
else
    # String is already commented
    echo "$(date +'%Y-%m-%d %H:%M:%S'): STRING in ${NS_CONFIG_FILE} was already commented" 
fi

## GEO_Conf file
if grep -q '^url = ".*://[^/].*"$' "${CONF_DIR}${GEO_CONFIG_FILE}"; then
    # String is not commented
    sed -i '/^url =/ s/^/#/' "${CONF_DIR}${GEO_CONFIG_FILE}"
    echo "$(date +'%Y-%m-%d %H:%M:%S'): STRING in ${GEO_CONFIG_FILE} was commented" 
else
    # String is already commented
    echo "$(date +'%Y-%m-%d %H:%M:%S'): STRING in ${GEO_CONFIG_FILE} was already commented" 
fi	
### restart MQTT service
echo "$(date +'%Y-%m-%d %H:%M:%S'): Restart service ${MQTT_SERVICE_NAME}"
${MQTT_SERVICE_CMD}

###
echo "$(date +'%Y-%m-%d %H:%M:%S'): script executed successfully" 