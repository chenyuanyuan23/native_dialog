//
//  XHPhotoViewController.m
//  native_dialog
//
//  Created by liuxing on 25/9/2020.
//

#import <Foundation/Foundation.h>

#import "UIViewController+XHPhoto.h"

#import "XHPhotoViewController.h"

@implementation XHPhotoViewController{
    UIWindow* newWindow;
    UIWindow *originWindow;
}

+ (void)showWindow {
    UIWindow* tmpWindow = nil;
    if (@available(iOS 13.0, *))
    {
        for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes)
        {
            if (windowScene.activationState == UISceneActivationStateForegroundActive)
            {
//                tmpWindow = windowScene.windows.firstObject;
                tmpWindow = [[UIWindow alloc]initWithWindowScene:windowScene];
                break;
            }
        }
    }else{
        tmpWindow = [[UIWindow alloc]init];
    }
    UIViewController * vv = [[UIViewController alloc] init];
    [tmpWindow setRootViewController:vv];
    
    XHPhotoViewController *vc = [[XHPhotoViewController alloc]init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    vc->newWindow = tmpWindow;
    vc->originWindow = [UIApplication sharedApplication].keyWindow;
    
    tmpWindow.backgroundColor = [UIColor redColor];
    tmpWindow.hidden = NO;
    UIWindowLevel baseWindowLevel = [UIApplication sharedApplication].keyWindow.windowLevel;
    tmpWindow.windowLevel = baseWindowLevel + 1;
    [tmpWindow makeKeyAndVisible];
    [tmpWindow.rootViewController presentViewController:vc animated:YES completion:nil];
}

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor blackColor];
    UIButton *cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cameraBtn.frame = CGRectMake(0, 0, 200, 50);
    cameraBtn.center = self.view.center;
    cameraBtn.backgroundColor = [UIColor redColor];
    cameraBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [cameraBtn setTitle:@"打开" forState:UIControlStateNormal];
    [cameraBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cameraBtn addTarget:self action:@selector(oldButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cameraBtn];
}

- (void)oldButtonClick{
    //edit:照片需要裁剪:传YES,不需要裁剪传NO(默认NO)
    __weak typeof(self) weakSelf = self;
    [self showCanEdit:YES photo:^(UIImage *photo) {
        NSLog(@"+++++++++++");
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf close];
        }
    }];
}

-(void) close {
    if ([self respondsToSelector:@selector(presentingViewController)]) {
        [[self presentingViewController]dismissViewControllerAnimated:YES completion:nil];
    } else {
        [[self parentViewController]dismissViewControllerAnimated:YES completion:nil];
    }
    self->newWindow.windowLevel = 0;
    [self->newWindow setHidden:YES];
    [self->originWindow makeKeyAndVisible];
}

@end
