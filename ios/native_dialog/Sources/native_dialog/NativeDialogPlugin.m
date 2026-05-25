#import <UIKit/UIKit.h>
#import "NativeDialogPlugin.h"
@import MBProgressHUD;
#import "FanweDeviceMacro.h"
#import "FWColorMacro.h"
#import "UILabel+UILabel_ChangeLineSpaceAndWordSpace_m.h"

typedef void(^floatButtonClickDelegate)(void);

@implementation NativeDialogPlugin{
    FlutterMethodChannel *_methodChannel;
    MBProgressHUD *_hud;
    UIWindow *_overlayWindow;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
        methodChannelWithName:@"native_dialog"
              binaryMessenger:[registrar messenger]];
    NativeDialogPlugin* instance = [[NativeDialogPlugin alloc] initWithChannel:channel];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel {
    self = [super init];
    if (self) {
        _methodChannel = channel;
    }
    return self;
}

#pragma mark - Window/Scene helpers

// iOS 13+ scene-aware: returns the foreground-active UIWindowScene, or any connected one.
- (UIWindowScene *)activeWindowScene API_AVAILABLE(ios(13.0)) {
    UIWindowScene *fallback = nil;
    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
        if (![scene isKindOfClass:[UIWindowScene class]]) continue;
        UIWindowScene *ws = (UIWindowScene *)scene;
        if (ws.activationState == UISceneActivationStateForegroundActive) return ws;
        if (fallback == nil) fallback = ws;
    }
    return fallback;
}

// Dedicated overlay UIWindow that floats above the app's main window.
// Survives Flutter's window swap; returns nil if no UIScene is ready yet.
- (UIWindow *)overlayWindow {
    if (_overlayWindow != nil) return _overlayWindow;

    if (@available(iOS 13.0, *)) {
        UIWindowScene *scene = [self activeWindowScene];
        if (scene == nil) return nil;
        _overlayWindow = [[UIWindow alloc] initWithWindowScene:scene];
        _overlayWindow.frame = scene.coordinateSpace.bounds;
    } else {
        _overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    _overlayWindow.backgroundColor = [UIColor clearColor];
    _overlayWindow.windowLevel = UIWindowLevelAlert - 1;
    _overlayWindow.rootViewController = [[UIViewController alloc] init];
    _overlayWindow.hidden = YES;
    return _overlayWindow;
}

// Best-effort top view controller for presenting modals.
- (UIViewController *)topPresentingViewController {
    UIWindow *win = nil;
    id<UIApplicationDelegate> delegate = UIApplication.sharedApplication.delegate;
    if ([delegate respondsToSelector:@selector(window)]) {
        win = delegate.window;
    }
    if (win == nil && @available(iOS 13.0, *)) {
        UIWindowScene *scene = [self activeWindowScene];
        for (UIWindow *w in scene.windows) {
            if (w.isKeyWindow) { win = w; break; }
        }
        if (win == nil) win = scene.windows.firstObject;
    }
    if (win == nil) {
        win = UIApplication.sharedApplication.keyWindow;
    }
    UIViewController *vc = win.rootViewController;
    if (vc == nil) {
        vc = [self overlayWindow].rootViewController;
    }
    while (vc.presentedViewController) vc = vc.presentedViewController;
    return vc;
}

- (void)doCallback:(id)callback args:(id)args {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setValue:callback forKey:@"callback"];
    [dict setValue:args forKey:@"args"];
    [_methodChannel invokeMethod:@"doCallback" arguments:dict];
}

#pragma 确认框UI

- (void)showConfirmDialog:(NSString*)title text:(NSString*)text cancleText:(NSString*)cancleText confirmText:(NSString*)confirmText callbackIndex:(id)callbackIndex cancleValue:(id)cancleValue otherValue:(id)otherValue{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:text preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:confirmText style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf && otherValue) {
            [strongSelf doCallback:callbackIndex args:otherValue];
        }
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:cancleText style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf && cancleValue) {
            [strongSelf doCallback:callbackIndex args:cancleValue];
        }
    }]];

    UIViewController *top = [self topPresentingViewController];
    if (top == nil) {
        __weak typeof(self) weakSelf2 = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf2 showConfirmDialog:title text:text cancleText:cancleText confirmText:confirmText callbackIndex:callbackIndex cancleValue:cancleValue otherValue:otherValue];
        });
        return;
    }
    [top presentViewController:alert animated:YES completion:nil];
}

#pragma flutter接口定义

// 警告框
- (void)handleShowAlert:(FlutterMethodCall*)call result:(FlutterResult)result {
    id callbackIndex = call.arguments[@"callback"];
    NSString *title = call.arguments[@"title"];
    NSString *text = call.arguments[@"text"];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:text preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf doCallback:callbackIndex args:@"1"];
        }
    }]];

    UIViewController *top = [self topPresentingViewController];
    if (top == nil) {
        __weak typeof(self) weakSelf2 = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf2 handleShowAlert:call result:result];
        });
        return;
    }
    [top presentViewController:alert animated:YES completion:nil];

    result(nil);
}

- (void)handleShowToast:(FlutterMethodCall*)call result:(FlutterResult)result {
    id callbackIndex = call.arguments[@"callback"];
    NSString *title = call.arguments[@"title"];

    UIWindow *overlay = [self overlayWindow];
    if (overlay == nil) {
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf handleShowToast:call result:result];
        });
        return;
    }
    overlay.hidden = NO;
    UIView *parent = overlay.rootViewController.view;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:parent animated:NO];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = title;

    __weak typeof(self) weakSelf = self;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf doCallback:callbackIndex args:@"1"];
        }
        [hud hideAnimated:YES];
        [hud removeFromSuperview];
        if (strongSelf->_hud == nil) {
            strongSelf->_overlayWindow.hidden = YES;
        }
    });


    result(nil);
}


-(void)loadAnim1:(FlutterMethodCall*)call {
    NSString *version = call.arguments[@"version"];
    NSString *content = call.arguments[@"content"];
    NSString *status = call.arguments[@"status"];

    UIWindow *overlay = [self overlayWindow];
    if (overlay == nil) {
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf loadAnim1:call];
        });
        return;
    }
    UIView *parent = overlay.rootViewController.view;

    if (_hud == nil || _hud.superview != parent) {
        if (_hud) {
            [_hud removeFromSuperview];
            _hud = nil;
        }
        _hud = [MBProgressHUD showHUDAddedTo:parent animated:NO];
        _hud.contentColor = [UIColor whiteColor];
        _hud.userInteractionEnabled = YES;
        _hud.removeFromSuperViewOnHide = NO;
    }

    if ([status isEqualToString:@"1"]) {
        _hud.hidden = YES;
        overlay.hidden = YES;
    } else {
        overlay.hidden = NO;
        _hud.hidden = NO;
        _hud.mode = MBProgressHUDModeIndeterminate;
        _hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
        if (@available(iOS 13.0, *)) {
            _hud.bezelView.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
        }
        _hud.bezelView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        _hud.bezelView.layer.cornerRadius = 10;

        _hud.label.font = [UIFont systemFontOfSize:16];
        _hud.label.textColor = [UIColor whiteColor];
        NSString * str;
        if([version isEqualToString:@""]){
            str = [NSString stringWithFormat:@"%@%@",version,content];
        }else{
            str = [NSString stringWithFormat:@"%@\n%@",version,content];
        }

        _hud.label.text = str;
        [UILabel changeLineSpaceForLabel:_hud.label WithSpace:3.0];
        _hud.label.textAlignment = NSTextAlignmentCenter;
        _hud.label.numberOfLines = 0;
        _hud.margin = 7;
        [_hud showAnimated:YES];
    }
}




// 确认框
- (void)handleShowConfirm:(FlutterMethodCall*)call result:(FlutterResult)result {
    id callbackIndex = call.arguments[@"callback"];
    NSString *title = call.arguments[@"title"];
    NSString *text = call.arguments[@"text"];
    NSString *confirmText = call.arguments[@"confirmText"];
    NSString *cancleText = call.arguments[@"cancleText"];

    [self showConfirmDialog:title text:text cancleText:cancleText confirmText:confirmText callbackIndex:callbackIndex cancleValue:@"0" otherValue:@"1"];

    result(nil);
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if ([@"alertDialog" isEqualToString:call.method]) {
    [self handleShowAlert:call result:result];
  } else if ([@"confirmDialog" isEqualToString:call.method]) {
    [self handleShowConfirm:call result:result];
  } else if ([@"toastDialog" isEqualToString:call.method]) {
    [self handleShowToast:call result:result];
  } else if ([@"loadingDialog" isEqualToString:call.method]) {
    [self loadAnim1:call];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
