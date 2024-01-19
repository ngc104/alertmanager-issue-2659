#! /bin/bash

mkdir -p var
./process-exporter -config.path process-exporter.yml > var/process-exporter.log 2>&1 &
echo $! > var/process-exporter.pid
./prometheus --storage.tsdb.path=var/data > var/prometheus.log 2>&1 &
echo $! > var/prometheus.pid
./alertmanager > var/alertmanager.log 2>&1 &
echo $! > var/alertmanager.pid

echo "Process-exporter : http://localhost:9256"
echo "Prometheus : http://localhost:9090"
echo "Alertmanager : http://localhost:9093"

sleep 5
echo "Now harassing Alertmanager ($(date +"%Y-%m-%d %H:%M:%S"))"
while true; do
  date;
  ./amtool --alertmanager.url=http://localhost:9093/ alert add alertname=foo node=bar
  ./amtool --alertmanager.url=http://localhost:9093/ silence add -a "awesome user" -d 1m -c "awesome comment" alertname=foo
  sleep 60
done

exit 0
