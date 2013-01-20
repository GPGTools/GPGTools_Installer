include Dependencies/GPGTools_Core/make/default

all: dmg

update:
	@git submodule foreach git pull origin master
	@git pull

compile:
	@#./build-script.sh

test: deploy

clean:
	@chmod -R +w build
	@rm -rf build

nightly:
	@cat build-script.sh.config.nightlyDiff >> build-script.sh.config
