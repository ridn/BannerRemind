include theos/makefiles/common.mk

TWEAK_NAME = BannerRemind
BannerRemind_FILES = Tweak.xm
BannerRemind_FRAMEWORKS = UIKit EventKit
BannerRemind_PRIVATE_FRAMEWORKS = BulletinBoard
include $(THEOS_MAKE_PATH)/tweak.mk
