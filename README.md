# Alertmanager issue 2659

## Issue

https://github.com/prometheus/alertmanager/issues/2659

## Requirements

This test environment requires docker

Notice that `get_mem.sh` requires group or cgroup2 metrics. If the paths are not working for you, feel free to adapt the script.

## How to reproduce

Edit the first lines of `run.sh`. Change `DATARETENTION` to the value you wish.

```
./build_env.sh
./run.sh
```

## Traces with go tool pprof

```
./trace.sh
```

## Traces with Prometheus

http://localhost:9090/graph

Check these metrics :

```
go_memstats_heap_objects{instance="localhost:9093"}
go_memstats_heap_inuse_bytes{instance="localhost:9093"}
alertmanager_memory_working_set{instance="localhost:9273"}
```
