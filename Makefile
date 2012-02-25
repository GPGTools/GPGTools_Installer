include Dependencies/GPGTools_Core/make/default

all: dmg

update:
	@git submodule foreach git pull origin master
	@git pull

compile:
	@./build-script.sh

test: deploy

clean:
	@chmod -R +w build
	@rm -rf build

nightly:
	@cp build-script.sh.nightly.config build-script.sh.config
	@cp Makefile.nightly.config Makefile.config
