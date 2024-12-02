#!/bin/bash

subscription="$1"

ss_re='ss://([^#]+)#(.+)'
ss_conf_re='([^:]+):([^@]+)@([^:]+):(\w+)'
vmess_re='vmess://([^/]+)'

proxies=()

services=$(curl -s "$subscription" | base64 -d)

for service in $services; do
    if [[ $service =~ $ss_re ]]; then
        conf=$(echo "${BASH_REMATCH[1]}" | base64 -d)
	servername=${BASH_REMATCH[2]}
	if [[ $conf =~ $ss_conf_re ]]; then
		cipher=${BASH_REMATCH[1]}
		pwd=${BASH_REMATCH[2]}
		server=${BASH_REMATCH[3]}
		port=${BASH_REMATCH[4]}
		json=$(jq -n -c --arg name "$servername" --arg server "$server" --arg port "$port" --arg cipher "$cipher" --arg pwd "$pwd" '{"type": "ss","name": $name, "server": $server, "port": $port, "cipher": $cipher, "password": $pwd}')
		proxies+=("$json")
	fi
    elif [[ $service =~ $vmess_re ]]; then
        vmess_json=$(echo "${BASH_REMATCH[1]}" | base64 -d)
        key_value_pairs=$(jq -r 'to_entries[] | "\(.key)=\(.value)"' <<< "$vmess_json")
        declare -A key_value_map

        for pair in $key_value_pairs; do
		IFS='=' read -r key value <<< "$pair"
		key_value_map[$key]=$value
        done
	ps=${key_value_map['ps']}
	add=${key_value_map['add']}
	id=${key_value_map['id']}
	port=${key_value_map['port']}
	json=$(jq -n -c --arg ps "$ps" --arg add "$add" --arg port "$port" --arg id "$id" '{"type": "vmess", "name": $ps, "server": $add, "port": $port, "uuid": $id, "alterId": 0, "cipher": "auto", "network":"tcp"}')
	proxies+=("$json")
    else
        echo "Invalid service: $service"
    fi
done
echo -n "" > clash.yaml
echo "proxies:" >> clash.yaml
for proxy in "${proxies[@]}"; do
    echo "  - $proxy" >> clash.yaml
done
echo "clash.yaml generated"
cat "clash.yaml"

