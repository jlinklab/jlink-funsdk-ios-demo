//
//  UIViewController+JFForbiddenSwipeRight.m
//   iCSee
//
//  Created by Megatron on 2023/3/30.
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import "UIViewController+JFForbiddenSwipeRight.h"

@implementation UIViewController (JFForbiddenSwipeRight)

/**
 禁用侧滑返回手势
 @param VC 需要禁用手势的视图控制器
 */
- (void)forbiddenSwipeRightGesture:(UIViewController *)VC{
    // 禁用侧滑返回手势
    if ([VC.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        // 这里对添加到右滑视图上的所有手势禁用
        for (UIGestureRecognizer *popGesture in VC.navigationController.interactivePopGestureRecognizer.view.gestureRecognizers) {
            popGesture.enabled = NO;
        }
    }
}
/**
 启用侧滑返回手势
 @param VC 需要启用手势的视图控制器
 */
- (void)openSwipeRightGesture:(UIViewController *)VC{
    // 启用侧滑返回手势
    if ([VC.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        // 这里对添加到右滑视图上的所有手势启用
        for (UIGestureRecognizer *popGesture in VC.navigationController.interactivePopGestureRecognizer.view.gestureRecognizers) {
            popGesture.enabled = YES;
        }
    }
}


@end
