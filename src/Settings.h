#pragma once

#include <atomic>
#include <string>

namespace Settings {

extern std::atomic<bool> bIsAppActive;
extern std::atomic<bool> bShowMenu;
extern std::atomic<bool> Cheatoff;

// ESP
extern std::atomic<bool> bEnableESP;
extern std::atomic<bool> bBoxESP;
extern std::atomic<bool> bLineESP;
extern std::atomic<bool> bDistanceESP;
extern std::atomic<bool> bSkeletonESP;
extern std::atomic<bool> bCountESP;
extern std::atomic<bool> bMiniMapEsp;
extern std::atomic<bool> bTurnEspRadius;
extern std::atomic<float> espRadiusValue;
extern std::atomic<int> lineOrigin;
extern std::atomic<int> lineTarget;
extern std::atomic<float> lineThickness;

// Aimbot
extern std::atomic<bool> bAimEnable;
extern std::atomic<int> AimPart;
extern std::atomic<bool> bAimLine;
extern std::atomic<bool> bAimIndicator;
extern std::atomic<bool> bAimDrawFov;
extern std::atomic<bool> bVisibilityCheck;
extern std::atomic<float> AimFov;
extern std::atomic<float> AimSmooth;
extern std::atomic<bool> bCrosshair;
extern std::atomic<bool> FovEnable;
extern std::atomic<float> FovVal;

// Movement
extern std::atomic<bool> bSpeedHack;
extern std::atomic<bool> bFlyEnable;
extern std::atomic<float> FlySpeed;
extern std::atomic<float> FlyJoySpeed;
extern std::atomic<bool> bShowJoystick;
extern std::atomic<bool> bCarhack;
extern std::atomic<float> Carspeed;
extern std::atomic<bool> bCarFly;
extern std::atomic<float> carFlySpeed;

// Player scale
extern std::atomic<bool> ScaleEnable;
extern std::atomic<bool> BigHead;
extern std::atomic<bool> BigChest;
extern std::atomic<bool> BigBody;
extern std::atomic<float> ScaleVal;

// Weapon
extern std::atomic<bool> bInstantReload;
extern std::atomic<bool> bFastShoot;

// Misc
extern std::atomic<bool> bStreamerMode;
extern std::atomic<bool> bEnableNotifications;
extern std::atomic<int> MenuTheme;
extern std::atomic<float> uiScale;
extern std::atomic<int> selectedTab;
extern std::atomic<int> targetFPS;

// Teleport
extern std::atomic<bool> bAutoTeleport;
extern std::atomic<int> selectedTeleport;

void Load();
void Save();

} // namespace Settings
