all: dmg

update:
	@git submodule foreach git pull origin master
	@git pull

dmg:
	@./build-script.sh
	@./Dependencies/GPGTools_Core/scripts/create_dmg.sh

clean:
	rm -rf build

