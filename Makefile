all: dmg

update:
	@git submodule foreach git pull origin master
	@git pull

compile: dmg

dmg:
	@./build-script.sh
	@./Dependencies/GPGTools_Core/scripts/create_dmg.sh

test: autobuild upload

autobuild:
	@./build-script.sh
	@./Dependencies/GPGTools_Core/scripts/create_dmg.sh auto

upload:
	@./Dependencies/GPGTools_Core/scripts/upload.sh

clean:
	rm -rf build

