SHELL := /bin/bash
CROMWELL=path/to/cromwell*.jar
WOMTOOL=path/to/womtool*.jar

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
