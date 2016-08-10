DEBUG = 0
TARGET = iphone:latest:7.0
PACKAGE_VERSION = 0.0.2

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = DNDSO
DNDSO_FILES = Switch.xm
DNDSO_PRIVATE_FRAMEWORKS = Preferences
DNDSO_LIBRARIES = flipswitch
DNDSO_INSTALL_PATH = /Library/Switches

include $(THEOS_MAKE_PATH)/bundle.mk