all: dmg

update:
	@git submodule foreach git pull origin master
	@git pull

compile: dmg

dmg:
	@./build-script.sh
	@./Dependencies/GPGTools_Core/scripts/create_dmg.sh

test:
	@./build-script.sh
	@./Dependencies/GPGTools_Core/scripts/create_dmg.sh auto

clean:
	rm -rf build

