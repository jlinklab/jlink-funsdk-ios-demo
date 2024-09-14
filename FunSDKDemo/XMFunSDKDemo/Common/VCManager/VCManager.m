//
//  VCManager.m
//   
//
//  Created by Tony Stark on 2021/9/11.
//  Copyright © 2021 xiongmaitech. All rights reserved.
//

#import "VCManager.h"
#import "AppDelegate.h"

@implementation VCManager

//MARK: - 获取当前屏幕显示的viewcontroller
+ (UIViewController *)getCurrentVC
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (!rootViewController){
        rootViewController = ((AppDelegate *)([UIApplication sharedApplication].delegate)).window.rootViewController;
    }
    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
    return currentVC;
}

+ (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC
{
    UIViewController *currentVC;
    if ([rootVC presentedViewController]) {
        // 视图是被presented出来的
        rootVC = [rootVC presentedViewController];
    }
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
    } else {
        // 根视图为非导航类
        currentVC = rootVC;
    }
    return currentVC;
}

//MARK: 获取view所在的viewcontroller
+ (UIViewController *)viewControllerForView:(UIView *)view {
    if (![view isKindOfClass:[UIView class]]) {
        NSLog(@"传入的参数不是UIView类型");
        return nil;
    }

    UIResponder *responder = view;
    while (responder) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
        responder = responder.nextResponder;
    }
    return nil;
}


@end
