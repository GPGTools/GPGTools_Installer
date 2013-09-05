PROJECT = GPGTools_Installer
TARGET = GPGTools_Installer
PRODUCT = GPGTools_Installer
MAKE_DEFAULT = Dependencies/GPGTools_Core/newBuildSystem/Makefile.default


-include $(MAKE_DEFAULT)

.PRECIOUS: $(MAKE_DEFAULT)
$(MAKE_DEFAULT):
	@bash -c "$$(curl -fsSL https://raw.github.com/GPGTools/GPGTools_Core/master/newBuildSystem/prepare-core.sh)"

init: $(MAKE_DEFAULT)

$(PRODUCT):
ifeq ("$(CORE_PKG_DIR)","")
	@./prepare-packages.sh build
endif
	@./prepare-packages.sh $(CORE_PKG_DIR)
