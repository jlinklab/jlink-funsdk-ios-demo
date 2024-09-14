//
//  JFTopTitleBottomSliderCell.h
//   iCSee
//
//  Created by Megatron on 2024/4/26.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JFNewCustomSliderValueView.h"

NS_ASSUME_NONNULL_BEGIN

@interface JFTopTitleBottomSliderCell : UITableViewCell

@property (nonatomic,strong) UILabel *lbTitle;
@property (nonatomic,strong) UILabel *lbSubTitle;
/// 滑动条
@property (nonatomic, strong) JFNewCustomSliderValueView *slider;

- (void)resetSubViewsWithContentWidth:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END
