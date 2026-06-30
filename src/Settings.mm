#include "Settings.h"
#import <Foundation/Foundation.h>

#define SS_BOOL(name, def) \
    std::atomic<bool> name{def}; \
    static const char *k##name = #name

#define SS_INT(name, def) \
    std::atomic<int> name{def}; \
    static const char *k##name = #name

#define SS_FLOAT(name, def) \
    std::atomic<float> name{def}; \
    static const char *k##name = #name

namespace Settings {

SS_BOOL(bIsAppActive, true);
SS_BOOL(bShowMenu, false);
SS_BOOL(Cheatoff, false);

SS_BOOL(bEnableESP, false);
SS_BOOL(bBoxESP, true);
SS_BOOL(bLineESP, true);
SS_BOOL(bDistanceESP, true);
SS_BOOL(bSkeletonESP, false);
SS_BOOL(bCountESP, true);
SS_BOOL(bMiniMapEsp, false);
SS_BOOL(bTurnEspRadius, false);
SS_FLOAT(espRadiusValue, 150.f);
SS_INT(lineOrigin, 0);
SS_INT(lineTarget, 0);
SS_FLOAT(lineThickness, 1.5f);

SS_BOOL(bAimEnable, false);
SS_INT(AimPart, 0);
SS_BOOL(bAimLine, true);
SS_BOOL(bAimIndicator, true);
SS_BOOL(bAimDrawFov, true);
SS_BOOL(bVisibilityCheck, true);
SS_FLOAT(AimFov, 90.f);
SS_FLOAT(AimSmooth, 5.f);
SS_BOOL(bCrosshair, false);
SS_BOOL(FovEnable, false);
SS_FLOAT(FovVal, 90.f);

SS_BOOL(bSpeedHack, false);
SS_BOOL(bFlyEnable, false);
SS_FLOAT(FlySpeed, 8.f);
SS_FLOAT(FlyJoySpeed, 5.f);
SS_BOOL(bShowJoystick, true);
SS_BOOL(bCarhack, false);
SS_FLOAT(Carspeed, 1.5f);
SS_BOOL(bCarFly, false);
SS_FLOAT(carFlySpeed, 10.f);

SS_BOOL(ScaleEnable, false);
SS_BOOL(BigHead, false);
SS_BOOL(BigChest, false);
SS_BOOL(BigBody, false);
SS_FLOAT(ScaleVal, 1.5f);

SS_BOOL(bInstantReload, false);
SS_BOOL(bFastShoot, false);

SS_BOOL(bStreamerMode, false);
SS_BOOL(bEnableNotifications, true);
SS_INT(MenuTheme, 0);
SS_FLOAT(uiScale, 1.f);
SS_INT(selectedTab, 0);
SS_INT(targetFPS, 60);

SS_BOOL(bAutoTeleport, false);
SS_INT(selectedTeleport, 0);

static NSUserDefaults *Defaults() {
    return [[NSUserDefaults alloc] initWithSuiteName:@"com.statescript.hack"];
}

static void LoadBool(const char *key, std::atomic<bool> &out, bool def) {
    id v = [Defaults() objectForKey:[NSString stringWithUTF8String:key]];
    out.store(v ? [v boolValue] : def);
}

static void LoadInt(const char *key, std::atomic<int> &out, int def) {
    id v = [Defaults() objectForKey:[NSString stringWithUTF8String:key]];
    out.store(v ? [v intValue] : def);
}

static void LoadFloat(const char *key, std::atomic<float> &out, float def) {
    id v = [Defaults() objectForKey:[NSString stringWithUTF8String:key]];
    out.store(v ? [v floatValue] : def);
}

void Load() {
    LoadBool("bEnableESP", bEnableESP, false);
    LoadBool("bBoxESP", bBoxESP, true);
    LoadBool("bLineESP", bLineESP, true);
    LoadBool("bDistanceESP", bDistanceESP, true);
    LoadBool("bSkeletonESP", bSkeletonESP, false);
    LoadBool("bCountESP", bCountESP, true);
    LoadBool("bMiniMapEsp", bMiniMapEsp, false);
    LoadBool("bTurnEspRadius", bTurnEspRadius, false);
    LoadFloat("espRadiusValue", espRadiusValue, 150.f);
    LoadInt("lineOrigin", lineOrigin, 0);
    LoadInt("lineTarget", lineTarget, 0);
    LoadFloat("lineThickness", lineThickness, 1.5f);

    LoadBool("AimEnable", bAimEnable, false);
    LoadInt("AimPart", AimPart, 0);
    LoadBool("AimLine", bAimLine, true);
    LoadBool("AimInd", bAimIndicator, true);
    LoadBool("AimDrawFov", bAimDrawFov, true);
    LoadBool("VisCheck", bVisibilityCheck, true);
    LoadFloat("AimFov", AimFov, 90.f);
    LoadFloat("AimSmooth", AimSmooth, 5.f);
    LoadBool("Crosshair", bCrosshair, false);
    LoadBool("FovEnable", FovEnable, false);
    LoadFloat("FovVal", FovVal, 90.f);

    LoadBool("SpeedHack", bSpeedHack, false);
    LoadBool("FlyEnable", bFlyEnable, false);
    LoadFloat("FlySpeed", FlySpeed, 8.f);
    LoadFloat("FlyJoySpeed", FlyJoySpeed, 5.f);
    LoadBool("bShowJoystick", bShowJoystick, true);
    LoadBool("bCarhack", bCarhack, false);
    LoadFloat("Carspeed", Carspeed, 1.5f);
    LoadBool("bCarFly", bCarFly, false);
    LoadFloat("carFlySpeed", carFlySpeed, 10.f);

    LoadBool("ScaleEnable", ScaleEnable, false);
    LoadBool("BigHead", BigHead, false);
    LoadBool("BigChest", BigChest, false);
    LoadBool("BigBody", BigBody, false);
    LoadFloat("ScaleVal", ScaleVal, 1.5f);

    LoadBool("InstReload", bInstantReload, false);
    LoadBool("FastShoot", bFastShoot, false);

    LoadBool("StreamerMode", bStreamerMode, false);
    LoadBool("NotifEnable", bEnableNotifications, true);
    LoadInt("MenuTheme", MenuTheme, 0);
    LoadFloat("uiScale", uiScale, 1.f);
    LoadInt("selectedTab", selectedTab, 0);
    LoadInt("targetFPS", targetFPS, 60);
    LoadBool("bAutoTeleport", bAutoTeleport, false);
    LoadInt("selectedTeleport", selectedTeleport, 0);
}

static void SaveBool(const char *key, std::atomic<bool> &v) {
    [Defaults() setBool:v.load() forKey:[NSString stringWithUTF8String:key]];
}

static void SaveInt(const char *key, std::atomic<int> &v) {
    [Defaults() setInteger:v.load() forKey:[NSString stringWithUTF8String:key]];
}

static void SaveFloat(const char *key, std::atomic<float> &v) {
    [Defaults() setFloat:v.load() forKey:[NSString stringWithUTF8String:key]];
}

void Save() {
    SaveBool("bEnableESP", bEnableESP);
    SaveBool("bBoxESP", bBoxESP);
    SaveBool("bLineESP", bLineESP);
    SaveBool("bDistanceESP", bDistanceESP);
    SaveBool("bSkeletonESP", bSkeletonESP);
    SaveBool("bCountESP", bCountESP);
    SaveBool("bMiniMapEsp", bMiniMapEsp);
    SaveBool("bTurnEspRadius", bTurnEspRadius);
    SaveFloat("espRadiusValue", espRadiusValue);
    SaveInt("lineOrigin", lineOrigin);
    SaveInt("lineTarget", lineTarget);
    SaveFloat("lineThickness", lineThickness);

    SaveBool("AimEnable", bAimEnable);
    SaveInt("AimPart", AimPart);
    SaveBool("AimLine", bAimLine);
    SaveBool("AimInd", bAimIndicator);
    SaveBool("AimDrawFov", bAimDrawFov);
    SaveBool("VisCheck", bVisibilityCheck);
    SaveFloat("AimFov", AimFov);
    SaveFloat("AimSmooth", AimSmooth);
    SaveBool("Crosshair", bCrosshair);
    SaveBool("FovEnable", FovEnable);
    SaveFloat("FovVal", FovVal);

    SaveBool("SpeedHack", bSpeedHack);
    SaveBool("FlyEnable", bFlyEnable);
    SaveFloat("FlySpeed", FlySpeed);
    SaveFloat("FlyJoySpeed", FlyJoySpeed);
    SaveBool("bShowJoystick", bShowJoystick);
    SaveBool("bCarhack", bCarhack);
    SaveFloat("Carspeed", Carspeed);
    SaveBool("bCarFly", bCarFly);
    SaveFloat("carFlySpeed", carFlySpeed);

    SaveBool("ScaleEnable", ScaleEnable);
    SaveBool("BigHead", BigHead);
    SaveBool("BigChest", BigChest);
    SaveBool("BigBody", BigBody);
    SaveFloat("ScaleVal", ScaleVal);

    SaveBool("InstReload", bInstantReload);
    SaveBool("FastShoot", bFastShoot);

    SaveBool("StreamerMode", bStreamerMode);
    SaveBool("NotifEnable", bEnableNotifications);
    SaveInt("MenuTheme", MenuTheme);
    SaveFloat("uiScale", uiScale);
    SaveInt("selectedTab", selectedTab);
    SaveInt("targetFPS", targetFPS);
    SaveBool("bAutoTeleport", bAutoTeleport);
    SaveInt("selectedTeleport", selectedTeleport);

    [Defaults() synchronize];
}

} // namespace Settings

#undef SS_BOOL
#undef SS_INT
#undef SS_FLOAT
