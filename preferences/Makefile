TARGET = iphone:clang:9.2

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = AutoDismissSiriPrefs
AutoDismissSiriPrefs_FILES = ADSRootListController.m
AutoDismissSiriPrefs_CFLAGS = -fobjc-arc
AutoDismissSiriPrefs_INSTALL_PATH = /Library/PreferenceBundles
AutoDismissSiriPrefs_FRAMEWORKS = UIKit
AutoDismissSiriPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/AutoDismissSiriPrefs.plist$(ECHO_END)
