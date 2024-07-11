//
//  UIViewController+JFForbiddenSwipeRight.h
//   iCSee
//
//  Created by Megatron on 2023/3/30.
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (JFForbiddenSwipeRight)

/**
 禁用侧滑返回手势
 @param VC 需要禁用手势的视图控制器
 */
- (void)forbiddenSwipeRightGesture:(UIViewController *)VC;
/**
 启用侧滑返回手势
 @param VC 需要启用手势的视图控制器
 */
- (void)openSwipeRightGesture:(UIViewController *)VC;

@end

NS_ASSUME_NONNULL_END
