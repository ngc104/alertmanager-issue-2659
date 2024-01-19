#! /bin/bash

[ -e var/prometheus.pid ] && kill $(cat var/prometheus.pid)
[ -e var/alertmanager.pid ] && kill $(cat var/alertmanager.pid)

rm -f var/prometheus.pid var/alertmanager.pid
