#pragma once

#import <UIKit/UIKit.h>

@interface StateScriptOverlay : NSObject
+ (instancetype)shared;
- (void)install;
- (void)ensureOnTop;
- (void)toggleMenu;
@end

BOOL StateScriptIsOverlayWindow(UIWindow *window);
