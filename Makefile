PROJECT = GPGTools
TARGET = GPGTools
PRODUCT = GPGTools
ifndef PACKAGE_DEPS
PACKAGE_DEPS = GPGMail:GPGMail:GPGMail_10.7 GPGKeychainAccess GPGPreferences GPGMailSnowLeopard:GPGMail:GPGMail_10.6 Libmacgpg Libmacgpg:LibmacgpgXPC MacGPG2 GPGServices
endif
NO_CORE_PKG = 1

include Dependencies/GPGTools_Core/newBuildSystem/Makefile.default

$(PRODUCT):
	@./prepare-packages.sh $(PACKAGE_DEPS)
