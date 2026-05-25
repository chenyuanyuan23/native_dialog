#import <UIKit/UIKit.h>
#import "NativeDialogPlugin.h"
@import MBProgressHUD;
#import "FanweDeviceMacro.h"
#import "FWColorMacro.h"

#import "UILabel+UILabel_ChangeLineSpaceAndWordSpace_m.h"

//#import <Foundation/NSBundle.h>

typedef void(^floatButtonClickDelegate)(void);

@implementation NativeDialogPlugin{
    FlutterMethodChannel *_methodChannel;
    MBProgressHUD *_hud;
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

- (void)doCallback:(id)callback args:(id)args {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setValue:callback forKey:@"callback"];
    [dict setValue:args forKey:@"args"];
    [_methodChannel invokeMethod:@"doCallback" arguments:dict];
}

#pragma 确认框UI

- (void)showConfirmDialog:(NSString*)title text:(NSString*)text cancleText:(NSString*)cancleText confirmText:(NSString*)confirmText callbackIndex:(id)callbackIndex cancleValue:(id)cancleValue otherValue:(id)otherValue{
    // 初始化对话框
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:text preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:confirmText style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf && otherValue) {
            [strongSelf doCallback:callbackIndex args:otherValue];
            // [strongSelf->_viewPot removeFromSuperview];
        }
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:cancleText style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf && cancleValue) {
            [strongSelf doCallback:callbackIndex args:cancleValue];
            // [strongSelf->_viewPot removeFromSuperview];
        }
    }]];

    // 弹出对话框
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    UIViewController *topViewController = [window rootViewController];
    [topViewController presentViewController:alert animated:true completion:nil];
}

#pragma flutter接口定义

// 警告框
- (void)handleShowAlert:(FlutterMethodCall*)call result:(FlutterResult)result {
    id callbackIndex = call.arguments[@"callback"];
    NSString *title = call.arguments[@"title"];
    NSString *text = call.arguments[@"text"];
    NSLog(@"alert title:%@", title);
   
    // 初始化对话框
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:text preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf doCallback:callbackIndex args:@"1"];
            // [strongSelf->_viewPot removeFromSuperview];
        }
    }]];
    
    // 弹出对话框
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    UIViewController *topViewController = [window rootViewController];
    [topViewController presentViewController:alert animated:true completion:nil];
    
    result(nil);
}

- (void)handleShowToast:(FlutterMethodCall*)call result:(FlutterResult)result {
    id callbackIndex = call.arguments[@"callback"];
    NSString *title = call.arguments[@"title"];
    NSLog(@"toast title:%@", title);
    
    UIView *parent = UIApplication.sharedApplication.keyWindow;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:parent animated:NO];
    hud.mode = MBProgressHUDModeText;
    UILabel *label = [[UILabel alloc]init];
    hud.label.text = title;
    [hud addSubview:label];

    __weak typeof(self) weakSelf = self;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf doCallback:callbackIndex args:@"1"];
        }
        [hud removeFromSuperview];
        [hud hideAnimated:true];
    });
    

    result(nil);
}


-(void)loadAnim1:(FlutterMethodCall*)call {
    NSString *version = call.arguments[@"version"];
    NSString *content = call.arguments[@"content"];
    NSString *status = call.arguments[@"status"];
    UIView *parent = UIApplication.sharedApplication.keyWindow;
    if(_hud == NULL){
        _hud = [MBProgressHUD showHUDAddedTo:parent animated:NO];
//        [_hud userInteractionEnabled:NO];
        _hud.contentColor = [UIColor whiteColor];
        [_hud setUserInteractionEnabled:YES];
    }
    if([status isEqualToString:@"1"]){
//        [_hud removeFromSuperview];
//        [_hud hideAnimated:true];
        [_hud setHidden:YES];
    }else{
        [_hud setHidden:NO];
        _hud.mode = MBProgressHUDModeIndeterminate;
        _hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
        if (@available(iOS 13.0, *)) {
            _hud.bezelView.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
        }
        _hud.bezelView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7]; // 设置背景为黑色透明度为70%
        _hud.bezelView.layer.cornerRadius = 10;
        // 设置菊花颜色为白色
//        [[UIActivityIndicatorView appearanceWhenContainedInInstancesOfClasses:@[[MBProgressHUD class]]] setColor:[UIColor whiteColor]];
        
        _hud.label.font = [UIFont systemFontOfSize:16];
        _hud.label.textColor = [UIColor whiteColor]; // 设置文字颜色为白色
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
        _hud.margin = 7;//修改该值，可以修改加载框大小
        _hud.removeFromSuperViewOnHide = YES;
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
    NSLog(@"Confirm title:%@ text:%@", title, text);
    
    //弹出确认框
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
