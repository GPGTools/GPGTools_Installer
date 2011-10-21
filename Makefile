include Dependencies/GPGTools_Core/make/default

all: dmg

update:
	@git submodule foreach git pull origin master
	@git pull

compile:
	@./build-script.sh

dmg: compile
	@./Dependencies/GPGTools_Core/scripts/create_dmg.sh

test: autobuild upload

autobuild:
	@./build-script.sh
	@./Dependencies/GPGTools_Core/scripts/create_dmg.sh auto

upload:
	@./Dependencies/GPGTools_Core/scripts/upload.sh

clean:
	rm -rf build

