# DaCapo Callbacks and probes
## Build
```bash
make
```

## Test
```bash
make test
```

## UDST Probe
### perf
```
sudo perf buildid-cache -u ./out/libusdt_probe.so
sudo perf probe -f --add sdt_DaCapo:begin sdt_DaCapo:end
sudo LD_LIBRARY_PATH=$(PWD)/out perf record -e sdt_DaCapo:begin -e sdt_DaCapo:end -- java ...
```

To use this without sudo, various permissions under /sys/kernel/tracing need to be correct, which might require >= 6.10 kernel with a correct remount setting.

### bpftrace
```
sudo bpftrace -l "usdt:./out/libusdt_probe.so:*"
```
