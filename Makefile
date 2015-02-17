PROJECT = GPGTools_Installer
TARGET = GPGTools_Installer
PRODUCT = GPGTools_Installer
MAKE_DEFAULT = Dependencies/GPGTools_Core/newBuildSystem/Makefile.default


-include $(MAKE_DEFAULT)

.PRECIOUS: $(MAKE_DEFAULT)
$(MAKE_DEFAULT):
	@echo "Dependencies/GPGTools_Core is missing.\nPlease clone it manually from https://github.com/GPGTools/GPGTools_Core\n"
	@exit 1

init: $(MAKE_DEFAULT)

$(PRODUCT):
ifeq ("$(CORE_PKG_DIR)","")
	@./prepare-packages.sh build
else
	@./prepare-packages.sh $(CORE_PKG_DIR)
endif
