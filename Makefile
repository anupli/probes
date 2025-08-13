.PHONY: all clean test

JAVA8_HOME=/usr/lib/jvm/temurin-8-jdk-amd64
JAVA6_HOME=/opt/jdk1.6.0_45
JAVAC=$(JAVA8_HOME)/bin/javac
JAR=$(JAVA8_HOME)/bin/jar
CC=gcc
CFLAGS=-O2 -g -Wall -Werror -D_GNU_SOURCE -fPIC
BENCHMARKS=/usr/share/benchmarks
DACAPO2006JAR=$(BENCHMARKS)/dacapo/dacapo-2006-10-MR2.jar
DACAPOBACHJAR=$(BENCHMARKS)/dacapo/dacapo-9.12-bach.jar
DACAPOCHOPINJAR=$(BENCHMARKS)/dacapo/dacapo-23.11-chopin.jar
UNAME_M=$(shell uname -m)

all: out/probes-java6.jar out/probes.jar out/librust_mmtk_probe.so $(if $(findstring $(UNAME_M),x86_64),out/librust_mmtk_probe_32.so) out/libusdt_probe.so

out/probes.jar: out/java8/probe/RustMMTkProbe.class out/java8/probe/MMTkProbe.class out/java8/probe/HelloWorldProbe.class out/java8/probe/USDTProbe.class out/java8/probe/Dacapo2006Callback.class out/java8/probe/DacapoBachCallback.class out/java8/probe/DacapoChopinCallback.class
	$(JAR) -cf out/probes.jar -C out/java8/ .

out/probes-java6.jar: out/java6/probe/RustMMTkProbe.class out/java6/probe/RustMMTk32Probe.class out/java6/probe/MMTkProbe.class out/java6/probe/HelloWorldProbe.class out/java6/probe/USDTProbe.class out/java6/probe/Dacapo2006Callback.class out/java6/probe/DacapoBachCallback.class
	$(JAR) -cf out/probes-java6.jar -C out/java6/ .

out/java6/probe/RustMMTkProbe.class: src/probe/RustMMTkProbe.java
	mkdir -p out/java6 && $(JAVAC) -target 1.6 -source 1.6 -cp src -d out/java6 $<

out/java6/probe/RustMMTk32Probe.class: src/probe/RustMMTk32Probe.java
	mkdir -p out/java6 && $(JAVAC) -target 1.6 -source 1.6 -cp src -d out/java6 $<

out/java6/probe/HelloWorldProbe.class: src/probe/HelloWorldProbe.java
	mkdir -p out/java6 && $(JAVAC) -target 1.6 -source 1.6 -cp src -d out/java6 $<

out/java6/probe/MMTkProbe.class: src/probe/MMTkProbe.java
	mkdir -p out/java6 && $(JAVAC) -target 1.6 -source 1.6 -cp src -d out/java6 $<

out/java6/probe/USDTProbe.class: src/probe/USDTProbe.java
	mkdir -p out/java6 && $(JAVAC) -target 1.6 -source 1.6 -cp src -d out/java6 $<

out/java6/probe/Dacapo2006Callback.class: src/probe/Dacapo2006Callback.java
	mkdir -p out/java6 && $(JAVAC) -target 1.6 -source 1.6 -cp src:$(DACAPO2006JAR) -d out/java6 $<

out/java6/probe/DacapoBachCallback.class: src/probe/DacapoBachCallback.java
	mkdir -p out/java6 && $(JAVAC) -target 1.6 -source 1.6 -cp src:$(DACAPOBACHJAR) -d out/java6 $<

out/java8/probe/RustMMTkProbe.class: src/probe/RustMMTkProbe.java
	mkdir -p out/java8 && $(JAVAC) -cp src -d out/java8 $<

out/java8/probe/HelloWorldProbe.class: src/probe/HelloWorldProbe.java
	mkdir -p out/java8 && $(JAVAC) -cp src -d out/java8 $<

out/java8/probe/MMTkProbe.class: src/probe/MMTkProbe.java
	mkdir -p out/java8 && $(JAVAC) -cp src -d out/java8 $<

out/java8/probe/USDTProbe.class: src/probe/USDTProbe.java
	mkdir -p out/java8 && $(JAVAC) -cp src -d out/java8 $<

out/java8/probe/Dacapo2006Callback.class: src/probe/Dacapo2006Callback.java
	mkdir -p out/java8 && $(JAVAC) -cp src:$(DACAPO2006JAR) -d out/java8 $<

out/java8/probe/DacapoBachCallback.class: src/probe/DacapoBachCallback.java
	mkdir -p out/java8 && $(JAVAC) -cp src:$(DACAPOBACHJAR) -d out/java8 $<

out/java8/probe/DacapoChopinCallback.class: src/probe/DacapoChopinCallback.java
	mkdir -p out/java8 && $(JAVAC) -cp src:$(DACAPOCHOPINJAR) -d out/java8 $<

out/librust_mmtk_probe.so: out/native/rust_mmtk_probe.o
	$(CC) $(CFLAGS) -pthread -shared -o $@ $< -lc

out/native/rust_mmtk_probe.o: src/native/rust_mmtk_probe.c
	mkdir -p out/native && $(CC) $(CFLAGS) -pthread -c $< -o $@ -I$(JAVA6_HOME)/include -I$(JAVA6_HOME)/include/linux/

out/libusdt_probe.so: out/native/usdt_probe.o
	$(CC) $(CFLAGS) -pthread -shared -o $@ $< -lc

out/native/usdt_probe.o: src/native/usdt_probe.c
	mkdir -p out/native && $(CC) $(CFLAGS) -pthread -c $< -o $@ -I$(JAVA6_HOME)/include -I$(JAVA6_HOME)/include/linux/

out/librust_mmtk_probe_32.so: out/native/rust_mmtk_probe_32.o
	$(CC) $(CFLAGS) -m32 -pthread -shared -o $@ $< -lc

out/native/rust_mmtk_probe_32.o: src/native/rust_mmtk_probe.c
	mkdir -p out/native && $(CC) $(CFLAGS) -m32 -pthread -c $< -o $@ -I$(JAVA6_HOME)/include -I$(JAVA6_HOME)/include/linux/

test:
	$(JAVA6_HOME)/bin/java -Dprobes=HelloWorld -cp $(DACAPO2006JAR):./out/probes-java6.jar Harness -c probe.Dacapo2006Callback fop
	$(JAVA6_HOME)/bin/java -Dprobes=HelloWorld -cp $(DACAPOBACHJAR):./out/probes-java6.jar Harness -c probe.DacapoBachCallback fop
	$(JAVA8_HOME)/bin/java -Dprobes=HelloWorld -cp $(DACAPO2006JAR):./out/probes.jar Harness -c probe.Dacapo2006Callback fop
	$(JAVA8_HOME)/bin/java -Dprobes=HelloWorld -cp $(DACAPOBACHJAR):./out/probes.jar Harness -c probe.DacapoBachCallback fop
	$(JAVA8_HOME)/bin/java -Dprobes=HelloWorld -cp $(DACAPOCHOPINJAR):./out/probes.jar Harness -c probe.DacapoChopinCallback fop

test_usdt:
# Need sudo to write to /root/.debug
	sudo perf buildid-cache -u ./out/libusdt_probe.so
# Explict probe is not needed if only root needs to record, https://groups.google.com/g/linux.kernel/c/vSz0q7mDSHs
	sudo perf probe -f --add sdt_DaCapo:begin sdt_DaCapo:end
# remount with 755 is not enough before this fix
# https://patchew.org/linux/20240502151547.973653253@goodmis.org/20240502151620.874018137@goodmis.org/
# Should be fixed in Linux 6.10, or Ubuntu LTS HWE >= 24.04.2
	sudo umount /sys/kernel/tracing
	sudo mount -o mode=755 -t tracefs nodev /sys/kernel/tracing
# Still need sudo here because the file permissions under /sys/kernel/tracing/events/sdt_DaCapo/begin are still wrong
	sudo LD_LIBRARY_PATH=$(PWD)/out perf record -e sdt_DaCapo:begin -e sdt_DaCapo:end -- $(JAVA8_HOME)/bin/java -Dprobes=USDT -cp $(DACAPOCHOPINJAR):./out/probes.jar Harness -c probe.DacapoChopinCallback fop
	sudo perf probe --del sdt_DaCapo:begin
	sudo perf probe --del sdt_DaCapo:end
	sudo perf buildid-cache -r ./out/libusdt_probe.so
	sudo perf script|grep sdt_DaCapo
	sudo rm -f perf.data perf.data.old

clean:
	rm -rf out
