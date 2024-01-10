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

all: out/probes-java6.jar out/probes.jar out/librust_mmtk_probe.so $(if $(findstring $(UNAME_M),x86_64),out/librust_mmtk_probe_32.so)

out/probes.jar: out/java8/probe/RustMMTkProbe.class out/java8/probe/MMTkProbe.class out/java8/probe/HelloWorldProbe.class out/java8/probe/Dacapo2006Callback.class out/java8/probe/DacapoBachCallback.class out/java8/probe/DacapoChopinCallback.class
	$(JAR) -cf out/probes.jar -C out/java8/ .

out/probes-java6.jar: out/java6/probe/RustMMTkProbe.class out/java6/probe/RustMMTk32Probe.class out/java6/probe/MMTkProbe.class out/java6/probe/HelloWorldProbe.class out/java6/probe/Dacapo2006Callback.class out/java6/probe/DacapoBachCallback.class
	$(JAR) -cf out/probes-java6.jar -C out/java6/ .

out/java6/probe/RustMMTkProbe.class: src/probe/RustMMTkProbe.java
	mkdir -p out/java6 && $(JAVAC) -target 1.6 -source 1.6 -cp src -d out/java6 $<

out/java6/probe/RustMMTk32Probe.class: src/probe/RustMMTk32Probe.java
	mkdir -p out/java6 && $(JAVAC) -target 1.6 -source 1.6 -cp src -d out/java6 $<

out/java6/probe/HelloWorldProbe.class: src/probe/HelloWorldProbe.java
	mkdir -p out/java6 && $(JAVAC) -target 1.6 -source 1.6 -cp src -d out/java6 $<

out/java6/probe/MMTkProbe.class: src/probe/MMTkProbe.java
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

clean:
	rm -rf out
