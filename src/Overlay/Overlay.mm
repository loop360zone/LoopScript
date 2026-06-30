#include "Overlay.h"
#include "../Settings.h"
#include "../Menu/MenuRenderer.h"
#include "../Features/ESP.h"
#include "../Features/Aimbot.h"
#include "../Features/Movement.h"
#include "../Features/PlayerScale.h"
#include "../Features/Weapon.h"
#include "../Features/Teleport.h"

#import <UIKit/UIKit.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <QuartzCore/QuartzCore.h>

#include "imgui.h"
#include "imgui_impl_metal.h"

static UIWindowScene *SSActiveWindowScene(void) {
    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
        if (scene.activationState == UISceneActivationStateForegroundActive &&
            [scene isKindOfClass:[UIWindowScene class]]) {
            return (UIWindowScene *)scene;
        }
    }
    return nil;
}

@interface StateScriptOverlayView : MTKView
@end

@implementation StateScriptOverlayView
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!Settings::bShowMenu.load()) return nil;
    return [super hitTest:point withEvent:event];
}
@end

@interface StateScriptOverlay () <MTKViewDelegate>
@property (nonatomic, strong) UIWindow *overlayWindow;
@property (nonatomic, strong) StateScriptOverlayView *mtkView;
@property (nonatomic, strong) UIButton *toggleButton;
@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, assign) CFTimeInterval lastFrameTime;
@property (nonatomic, assign) BOOL imguiReady;
@end

@implementation StateScriptOverlay

+ (instancetype)shared {
    static StateScriptOverlay *instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{ instance = [[StateScriptOverlay alloc] init]; });
    return instance;
}

- (instancetype)init {
    if ((self = [super init])) {
        _lastFrameTime = CACurrentMediaTime();
    }
    return self;
}

- (void)install {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.overlayWindow) return;

        self.device = MTLCreateSystemDefaultDevice();
        if (!self.device) return;

        self.commandQueue = [self.device newCommandQueue];
        if (!self.commandQueue) return;

        CGRect bounds = UIScreen.mainScreen.bounds;
        UIWindowScene *scene = SSActiveWindowScene();
        if (scene) {
            self.overlayWindow = [[UIWindow alloc] initWithWindowScene:scene];
            self.overlayWindow.frame = bounds;
        } else {
            self.overlayWindow = [[UIWindow alloc] initWithFrame:bounds];
        }

        self.overlayWindow.windowLevel = UIWindowLevelStatusBar + 1;
        self.overlayWindow.backgroundColor = UIColor.clearColor;
        self.overlayWindow.opaque = NO;
        self.overlayWindow.userInteractionEnabled = YES;

        self.mtkView = [[StateScriptOverlayView alloc] initWithFrame:bounds device:self.device];
        self.mtkView.delegate = self;
        self.mtkView.preferredFramesPerSecond = Settings::targetFPS.load();
        self.mtkView.clearColor = MTLClearColorMake(0, 0, 0, 0);
        self.mtkView.backgroundColor = UIColor.clearColor;
        self.mtkView.layer.opaque = NO;
        self.mtkView.userInteractionEnabled = YES;
        self.mtkView.paused = NO;
        self.mtkView.enableSetNeedsDisplay = NO;

        UIViewController *vc = [UIViewController new];
        vc.view = self.mtkView;
        self.overlayWindow.rootViewController = vc;

        self.overlayWindow.hidden = NO;

        [self setupToggleButton];
    });
}

- (void)setupToggleButton {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(20, 80, 52, 52);
    btn.backgroundColor = [[UIColor colorWithRed:0.35 green:0.15 blue:0.55 alpha:1] colorWithAlphaComponent:0.85];
    btn.layer.cornerRadius = 26;
    [btn setTitle:@"SS" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [btn addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [btn addGestureRecognizer:pan];

    [self.overlayWindow addSubview:btn];
    self.toggleButton = btn;
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    UIView *view = gesture.view;
    CGPoint t = [gesture translationInView:view.superview];
    view.center = CGPointMake(view.center.x + t.x, view.center.y + t.y);
    [gesture setTranslation:CGPointZero inView:view.superview];
}

- (void)toggleMenu {
    bool show = !Settings::bShowMenu.load();
    Settings::bShowMenu.store(show);
    self.mtkView.userInteractionEnabled = YES;
}

- (void)applyStreamerMode {
    self.toggleButton.hidden = Settings::bStreamerMode.load();
}

- (void)setupImGui {
    if (self.imguiReady) return;
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO &io = ImGui::GetIO();
    io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;
    ImGui_ImplMetal_Init(self.device);
    self.imguiReady = YES;
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    (void)view;
    (void)size;
}

- (void)drawInMTKView:(MTKView *)view {
    if (!Settings::bIsAppActive.load()) return;

    CFTimeInterval now = CACurrentMediaTime();
    float dt = (float)(now - self.lastFrameTime);
    self.lastFrameTime = now;

    [self setupImGui];
    [self applyStreamerMode];

    float w = (float)view.drawableSize.width;
    float h = (float)view.drawableSize.height;

    if (w <= 0.f || h <= 0.f) return;

    if (!Settings::Cheatoff.load()) {
        ESPFeature::Update(w, h);
        AimbotFeature::Update(w, h);
        MovementFeature::Update(dt);
        PlayerScaleFeature::Update();
        WeaponFeature::Update();
        TeleportFeature::UpdateAuto();
    }

    id<MTLCommandBuffer> cmd = [self.commandQueue commandBuffer];
    MTLRenderPassDescriptor *pass = view.currentRenderPassDescriptor;
    if (!pass) return;

    ImGui_ImplMetal_NewFrame(pass);
    ImGui::NewFrame();

    MenuRenderer::Render(w, h);
    MenuRenderer::RenderOverlay(w, h);

    ImGui::Render();
    id<MTLRenderCommandEncoder> enc = [cmd renderCommandEncoderWithDescriptor:pass];
    ImGui_ImplMetal_RenderDrawData(ImGui::GetDrawData(), cmd, enc);
    [enc endEncoding];

    [cmd presentDrawable:view.currentDrawable];
    [cmd commit];
}

@end

void StateScriptOverlayInstall() {
    [[StateScriptOverlay shared] install];
}

void StateScriptOverlayToggleMenu() {
    [[StateScriptOverlay shared] toggleMenu];
}
