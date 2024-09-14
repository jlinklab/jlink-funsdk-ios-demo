//
//  JFNewAlarmSliderValueCell.h
//   iCSee
//
//  Created by kevin on 2023/9/25.
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JFNewCustomSliderValueView.h"
NS_ASSUME_NONNULL_BEGIN

@interface JFNewAlarmSliderValueCell : UITableViewCell
@property (nonatomic,strong) UILabel *titleLabel;

//标题偏移左边距
@property (nonatomic,assign) CGFloat titleLeftBorder;
@property (nonatomic,strong) UIView *bottomLine;          // 底部分割线
@property (nonatomic,assign) BOOL ifFilletMode;           // 是否圆角模式
@property (nonatomic, assign) CGFloat minValue;
@property (nonatomic, assign) CGFloat maxValue;
@property (nonatomic, assign) CGFloat currentValue;
@property (nonatomic,copy) NSString *strLeftValue;
@property (nonatomic,copy) NSString *strRightValue;
@property (nonatomic, strong) JFNewCustomSliderValueView *valueSlider;

- (void)updateSliderValue;
//MARK: 进入圆角模式
- (void)enterFilletMode;
 
@property (nonatomic, copy) void (^valueChangedBlock)(CGFloat value);
//- (void)setSliderPointLevel:(SliderAction)action;
@end

NS_ASSUME_NONNULL_END
