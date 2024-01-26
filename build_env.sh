#! /bin/sh


ALERTMANAGER_VERSION="0.26.0"
PROMETHEUS_VERSION="2.49.1"
TELEGRAF_VERSION="1.29.2"


VARDIR=var

ALERTMANAGER_ARCHIVE="alertmanager-${ALERTMANAGER_VERSION}.linux-amd64.tar.gz"
ALERTMANAGER_URL="https://github.com/prometheus/alertmanager/releases/download/v${ALERTMANAGER_VERSION}/${ALERTMANAGER_ARCHIVE}"
PROMETHEUS_ARCHIVE="prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz"
PROMETHEUS_URL="https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/${PROMETHEUS_ARCHIVE}"
TELEGRAF_ARCHIVE="telegraf-${TELEGRAF_VERSION}_linux_amd64.tar.gz"
TELEGRAF_URL="https://dl.influxdata.com/telegraf/releases/${TELEGRAF_ARCHIVE}"

# Download
mkdir -p "${VARDIR}"
[ -e "${VARDIR}/${ALERTMANAGER_ARCHIVE}" ] || curl -sL "${ALERTMANAGER_URL}" -o "${VARDIR}/${ALERTMANAGER_ARCHIVE}"
[ -f "alertmanager" ] || (p=$(pwd); cd ${VARDIR}; tar xzf "${ALERTMANAGER_ARCHIVE}" ; mv "alertmanager-${ALERTMANAGER_VERSION}.linux-amd64/alertmanager" "${p}/alertmanager")
[ -f "amtool" ] || (p=$(pwd); cd ${VARDIR}; tar xzf "${ALERTMANAGER_ARCHIVE}" ; mv "alertmanager-${ALERTMANAGER_VERSION}.linux-amd64/amtool" "${p}/amtool")
[ -e "${VARDIR}/${PROMETHEUS_ARCHIVE}" ] || curl -sL "${PROMETHEUS_URL}" -o "${VARDIR}/${PROMETHEUS_ARCHIVE}"
[ -f "prometheus" ] || (p=$(pwd); cd ${VARDIR}; tar xzf "${PROMETHEUS_ARCHIVE}" ; mv "prometheus-${PROMETHEUS_VERSION}.linux-amd64/prometheus" "${p}/prometheus")
[ -e "${VARDIR}/${TELEGRAF_ARCHIVE}" ] || curl -sL "${TELEGRAF_URL}" -o "${VARDIR}/${TELEGRAF_ARCHIVE}"
[ -f "telegraf" ] || (p=$(pwd); cd ${VARDIR}; tar xzf "${TELEGRAF_ARCHIVE}" ; mv "telegraf-${TELEGRAF_VERSION}/usr/bin/telegraf" "${p}/telegraf")

echo "${ALERTMANAGER_VERSION}" > alertmanager_version

cat <<EOF > alertmanager.yml 
route:
  group_by: ['alertname']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 1h
  receiver: 'mytest'
receivers:
  - name: 'mytest'
EOF

./alertmanager --version > alertmanager_version.txt

cat <<EOF > prometheus.yml
global:
  scrape_interval:     15s # By default, scrape targets every 15 seconds.

scrape_configs:
  - job_name: 'alertmanager'

    static_configs:
      - targets: ['localhost:9093']
      - targets: ['localhost:9273']
EOF

cat <<EOF > telegraf.conf
[[outputs.prometheus_client]]
  listen = ":9273"
[[inputs.exec]]
  commands = ["$(pwd)/get_mem.sh" ]
  timeout = "5s"
  data_format = "prometheus"
  name_override = "alertmanager"
  [inputs.exec.tags]
    host = "localhost"
