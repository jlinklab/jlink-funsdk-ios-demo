//
//  JFBottomSliderCell.h
//   iCSee
//
//  Created by Megatron on 2024/3/16.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JFNewCustomSliderValueView.h"

NS_ASSUME_NONNULL_BEGIN

@interface JFBottomSliderCell : UITableViewCell

/// 滑动条
@property (nonatomic, strong) JFNewCustomSliderValueView *slider;
/// 底部分割线
@property (nonatomic,strong) UIView *underLine;
/// 分割线的左边距
@property (nonatomic,assign) CGFloat underLineLeftBorder;
/// 分割线右边距
@property (nonatomic,assign) CGFloat underLineRightBorder;

/// 更新左侧标题
- (void)updateLeftTitle:(NSString *)title;
/// 更新底部分割线的边距
- (void)updateUnderLineBorderLeft:(CGFloat)leftBorder right:(CGFloat)rightBorder;
/// 必须设置 当前控件的宽度 标题的左右边距
- (void)resetSubViewsWithContentWidth:(CGFloat)width titleLeftBorder:(CGFloat)titleLeftBorder titleRightBorder:(CGFloat)titleRightBorder;

@end

NS_ASSUME_NONNULL_END
