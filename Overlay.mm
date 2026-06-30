#include "Overlay.h"
#include "../Settings.h"
#include "../Menu/MenuRenderer.h"
#include "../Features/ESP.h"
#include "../Features/Aimbot.h"
#include "../Features/Movement.h"
#include "../Features/PlayerScale.h"
#include "../Features/Weapon.h"
#include "../Features/Teleport.h"
#include "../Unity/UnityAPI.h"

#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <QuartzCore/QuartzCore.h>

#include "imgui.h"
#include "imgui_impl_metal.h"

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

        Settings::Load();
        UnityAPI::Initialize();

        self.device = MTLCreateSystemDefaultDevice();
        self.commandQueue = [self.device newCommandQueue];

        CGRect bounds = UIScreen.mainScreen.bounds;
        self.overlayWindow = [[UIWindow alloc] initWithFrame:bounds];
        self.overlayWindow.windowLevel = UIWindowLevelAlert + 1;
        self.overlayWindow.backgroundColor = UIColor.clearColor;
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
        [self.overlayWindow makeKeyAndVisible];

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
    if (Settings::bEnableNotifications.load()) {
        NSString *msg = show ? @"StateScript Menu Opened" : @"StateScript Menu Closed";
        if (!Settings::bStreamerMode.load()) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"StateScript"
                                                                           message:msg
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            UIViewController *root = self.overlayWindow.rootViewController;
            if (root) [root presentViewController:alert animated:YES completion:nil];
        }
    }
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

    ESPFeature::Update(w, h);
    AimbotFeature::Update(w, h);
    MovementFeature::Update(dt);
    PlayerScaleFeature::Update();
    WeaponFeature::Update();
    TeleportFeature::UpdateAuto();

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
