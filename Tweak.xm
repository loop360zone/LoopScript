@import UIKit;
#include "Settings.h"
#include "Overlay/Overlay.h"

static void SSOnAppActive() {
    Settings::bIsAppActive.store(true);
    [[StateScriptOverlay shared] install];
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

%ctor {
    @autoreleasepool {
        Settings::Load();
        dispatch_async(dispatch_get_main_queue(), ^{
            SSOnAppActive();
        });
    }
}
