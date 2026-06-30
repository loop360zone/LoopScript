#pragma once

@import UIKit;

@interface StateScriptOverlay : NSObject
+ (instancetype)shared;
- (void)install;
- (void)toggleMenu;
@end
