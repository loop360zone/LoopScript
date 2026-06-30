#import <UIKit/UIKit.h>
#include "Settings.h"
#include "Overlay/Overlay.h"

static void SSOnAppActive() {
    Settings::bIsAppActive.store(true);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        [[StateScriptOverlay shared] install];
    });
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
    }
}
