SHELL := /bin/bash
CROMWELL=/Users/solomon/Documents/dev/enterprise/ariel_workflows/cromwell/cromwell-*.jar
WOMTOOL=/Users/solomon/Documents/dev/enterprise/ariel_workflows/cromwell/womtool*.jar

clean:clean-build

clean-build:
	rm -rf build/

all: clean workflow test

workflow: clean-build
	mkdir -p build/
	cat artic.wdl > build/artic.wdl
	cat tasks/*.wdl >> build/artic.wdl

test:
	echo testing build...
	java -jar $(WOMTOOL) validate build/artic.wdl