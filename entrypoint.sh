#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

export PRESTO_CFG_NODE_NODE_ID=${PRESTO_CFG_NODE_NODE_ID:-$HOSTNAME}

for var in $(env | grep PRESTO_CFG | sed 's/^PRESTO_CFG_//'); do
    
    # FIX ME - I thing there should be a smarter way of doing that...
    key_processed=$( cut -d '=' -f 1 <<< "$var" | awk '{print tolower($0)}' | sed 's/\_/./g')
    config_file_key="$(cut -d '.' -f 1 <<< "$key_processed")"
    config_key="$(cut -d '.' -f 2- <<< "$key_processed")"
    config_value="$(cut -d '=' -f 2- <<< "$var")"

    case "$config_file_key" in
        node) 
            config_file_path="$PRESTO_ETC_DIR/node.properties";;
        log)
            config_file_path="$PRESTO_ETC_DIR/log.properties";;
        config) 
            config_file_path="$PRESTO_ETC_DIR/config.properties";;
    esac
    
    if [[ ! -z $(grep "$config_key" $config_file_path) ]]; then
    
        sed -i "/$config_key/d" $config_file_path
    
    fi 
    
    echo "$config_key=$config_value" >> $config_file_path

done

exec launcher run --etc-dir=$PRESTO_ETC_DIR 
