GPGTools Installer
==================
The all-in-one installer for the tools part of the GPGTools project.

Requirements
------------
Before you can build the GPGTools Installer you need to build all tools that are
part of GPGTools first. These are:
* GPG Keychain Access
* GPGMail (10.6, 10.7, 10.8)
* GPGServices
* GPGPreferences
* MacGPG2
* Libmacgpg

How to build the GPGTools Installer
-----------------------------------
The GPGTools Installer requires all other packages of GPGTools to be already
available as packages. So build them first and follow these steps afterwards:

1. Run `make pkg` to build the intaller package.
2. Run `make dmg` to create a disk image including the installer package.

