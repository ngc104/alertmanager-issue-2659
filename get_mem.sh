#! /bin/bash

ID=$(docker inspect alertmanager | jq -r '.[0].Id')
CGROUP2=$(cat /proc/mounts|grep cgroup2 | awk '{print $2}')

if [ -d "${CGROUP2}/system.slice/docker-${ID}.scope" ]; then
    memory_usage_in_bytes=$(cat "${CGROUP2}/system.slice/docker-${ID}.scope/memory.current")
    memory_total_inactive_file=$(cat "${CGROUP2}/system.slice/docker-${ID}.scope/memory.stat" | grep inactive_file | awk '{print $2}')
elif [ -d "/sys/fs/cgroup/memory/docker/${ID}" ]; then
    memory_usage_in_bytes=$(cat "/sys/fs/cgroup/memory/docker/${ID}/memory.usage_in_bytes")
    memory_total_inactive_file=$(cat "/sys/fs/cgroup/memory/docker/${ID}/memory.stat" | grep total_inactive_file | awk '{print $2}')
else
    memory_usage_in_bytes=0
    memory_total_inactive_file=0
fi

memory_working_set=${memory_usage_in_bytes}
if [ "$memory_working_set" -lt "$memory_total_inactive_file" ];
then
    memory_working_set=0
else
    memory_working_set=$((memory_usage_in_bytes - memory_total_inactive_file))
fi

echo "memory_working_set $memory_working_set"
