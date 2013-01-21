PROJECT = GPGTools
TARGET = GPGTools
PRODUCT = GPGTools

include Dependencies/GPGTools_Core/newBuildSystem/Makefile.default

$(PRODUCT):
	@./prepare-packages.sh $(CORE_PKG_DIR)
