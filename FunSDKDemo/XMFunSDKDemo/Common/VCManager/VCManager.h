//
//  VCManager.h
//   
//
//  Created by Tony Stark on 2021/9/11.
//  Copyright © 2021 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VCManager : NSObject

//MARK: - 获取当前屏幕显示的viewcontroller
+ (UIViewController *)getCurrentVC;
//MARK: 获取view所在的viewcontroller
+ (UIViewController *)viewControllerForView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
