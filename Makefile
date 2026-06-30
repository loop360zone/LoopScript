TARGET := iphone:clang:16.5:14.0
ARCHS = arm64
INSTALL_TARGET_PROCESSES = oneState

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = StateScript

StateScript_FILES = Tweak.xm \
	src/Settings.mm \
	src/Unity/UnityAPI.mm \
	src/Features/ESP.mm \
	src/Features/Aimbot.mm \
	src/Features/Movement.mm \
	src/Features/PlayerScale.mm \
	src/Features/Teleport.mm \
	src/Features/Weapon.mm \
	src/Menu/Localization.mm \
	src/Menu/Themes.mm \
	src/Menu/MenuRenderer.mm \
	src/Overlay/Overlay.mm \
	vendor/imgui/imgui.cpp \
	vendor/imgui/imgui_draw.cpp \
	vendor/imgui/imgui_tables.cpp \
	vendor/imgui/imgui_widgets.cpp \
	vendor/imgui/backends/imgui_impl_metal.mm

StateScript_CFLAGS = -std=c++17 -Wno-module-import-in-extern-c \
	-Isrc -Ivendor/imgui -Ivendor/imgui/backends
StateScript_OBJCFLAGS = -fobjc-arc
StateScript_CXXFLAGS = -std=c++17 \
	-Isrc -Ivendor/imgui -Ivendor/imgui/backends
StateScript_LDFLAGS = -lc++
StateScript_LIBRARIES = substrate
StateScript_FRAMEWORKS = UIKit Foundation QuartzCore Metal MetalKit CoreGraphics

include $(THEOS)/makefiles/tweak.mk

internal-stage::
	@DYLIB="$(THEOS_STAGING_DIR)/Library/MobileSubstrate/DynamicLibraries/StateScript.dylib"; \
	if [ -f "$$DYLIB" ]; then \
	  install_name_tool -change /Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate @executable_path/libsubstrate.dylib "$$DYLIB" 2>/dev/null || true; \
	  install_name_tool -change /usr/lib/libsubstrate.dylib @executable_path/libsubstrate.dylib "$$DYLIB" 2>/dev/null || true; \
	fi

before-all::
	@test -f vendor/imgui/imgui.h || (echo "Run: bash scripts/setup_imgui.sh" && exit 1)
