#import <UIKit/UIKit.h>
#include "Settings.h"
#include "Overlay/Overlay.h"

static void SSScheduleInstall(void) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        [[StateScriptOverlay shared] install];
    });
}

static void SSOnAppActive() {
    Settings::bIsAppActive.store(true);
    SSScheduleInstall();
}

static void SSOnAppInactive() {
    Settings::bIsAppActive.store(false);
}

%hook UIApplication

- (void)applicationDidBecomeActive:(UIApplication *)application {
    %orig;
    SSOnAppActive();
}

- (void)applicationWillResignActive:(UIApplication *)application {
    %orig;
    SSOnAppInactive();
}

%end

%hook UIWindow

- (void)makeKeyAndVisible {
    %orig;
    if (!self.hidden && self.windowLevel >= UIWindowLevelNormal) {
        SSScheduleInstall();
    }
}

%end

%ctor {
    @autoreleasepool {
        Settings::Load();
        SSScheduleInstall();
    }
}
