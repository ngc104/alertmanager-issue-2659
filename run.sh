#! /bin/bash

DATARETENTION=3h
ALERTMANAGERPORT=9093
ALERTMANAGERVERSION="$(cat alertmanager_version)"

mkdir -p var
./telegraf --config telegraf.conf > var/telegraf.log 2>&1 &
echo $! > var/telegraf.pid
./prometheus --storage.tsdb.path=var/data > var/prometheus.log 2>&1 &
echo $! > var/prometheus.pid
docker run -d --name alertmanager --rm -it -v $(pwd):/data -p ${ALERTMANAGERPORT}:${ALERTMANAGERPORT} "quay.io/prometheus/alertmanager:v${ALERTMANAGERVERSION}" --config.file="/data/alertmanager.yml" --data.retention=2h --web.listen-address=:${ALERTMANAGERPORT} --cluster.listen-address=""
echo $! > var/alertmanager.pid

echo "Telegraf: http://localhost:9273/metrics"
echo "Prometheus : http://localhost:9090"
echo "Alertmanager : http://localhost:${ALERTMANAGERPORT}"

echo ""
echo "Do not forget to 'docker stop alertmanager'"

sleep 5
echo "Now harassing Alertmanager ($(date +"%Y-%m-%d %H:%M:%S"))"
while true; do
  date;
  ./amtool --alertmanager.url=http://localhost:${ALERTMANAGERPORT}/ alert add alertname=foo node=bar
  ./amtool --alertmanager.url=http://localhost:${ALERTMANAGERPORT}/ silence add -a "awesome user" -d 1m -c "awesome comment" alertname=foo
  sleep 60
done

exit 0
