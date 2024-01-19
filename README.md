# Alertmanager issue 2659

## Issue

https://github.com/prometheus/alertmanager/issues/2659

## How to reproduce

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
go_memstats_heap_objects
go_memstats_heap_inuse_bytes
```
