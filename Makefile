PROJECT = GPGTools_Installer
TARGET = GPGTools_Installer
PRODUCT = GPGTools_Installer

include Dependencies/GPGTools_Core/newBuildSystem/Makefile.default

$(PRODUCT):
ifeq ("$(CORE_PKG_DIR)","")
	@./prepare-packages.sh .
endif
	@./prepare-packages.sh $(CORE_PKG_DIR)
