PROJECT = GPGTools_Installer
TARGET = GPGTools_Installer
PRODUCT = GPGTools_Installer

include Dependencies/GPGTools_Core/newBuildSystem/Makefile.default

$(PRODUCT):
	@./prepare-packages.sh $(CORE_PKG_DIR)
