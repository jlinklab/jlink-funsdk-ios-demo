//
//  JFNewCustomSliderValueView.h
//   iCSee
//
//  Created by kevin on 2023/9/25.
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>

/// slider的样式
/// normal：普通无级样式
/// segmentation：分段样式 需要设置每一段对应的数组
typedef NS_ENUM(NSInteger,JFSliderStyle){
    JFSliderStyle_Normal,
    JFSliderStyle_Segmentation,
};

NS_ASSUME_NONNULL_BEGIN

/// 自定义Slider
@interface JFNewCustomSliderValueView : UIView
/// 底部背景视图
@property (nonatomic, strong) UIView *sliderBackgroundView;
/// 拖动的按钮
@property (nonatomic, strong) UIButton *sliderButton;
/// 最小值
@property (nonatomic, assign) CGFloat minValue;
/// 最大值
@property (nonatomic, assign) CGFloat maxValue;
/// 当前值
@property (nonatomic, assign) CGFloat currentValue;
/// 当前值变化回调
@property (nonatomic, copy) void (^valueChangedBlock)(CGFloat value);
/// 左侧标题
@property (nonatomic, strong) UILabel *lblLeft;
/// 右侧标题
@property (nonatomic, strong) UILabel *lblRight;
/// 悬浮气泡 拖动是显示当前值
@property (nonatomic, strong) UIButton *btnBubbble;
/// 悬浮泡沫的单位 默认是空 一旦设置之后 注意其他服用到的地方要先清空
@property (nonatomic, copy) NSString *bubbleUnit;
/// 当前的样式
@property (nonatomic, assign) JFSliderStyle style;
/// 分段显示每一段的值的实际数字 比如要显示设置： 30 40 60 就设置成@[@30,@50,@80]
@property (nonatomic, strong,nullable) NSArray *arraySegmentValue;
// 分段显示对应上面每一段数字的显示：@[@"30秒"，@"40秒",@"1分钟"]
@property (nonatomic, strong,nullable) NSArray *arraySegmentName;
/// 分段显示的当前的实际数字
@property (nonatomic, assign) int realValue;
/// 是否需要转化显示样式  分秒    10’30”
@property (nonatomic, assign) BOOL isNeedChangeShowType;

- (void)updateSliderValue;

@end

NS_ASSUME_NONNULL_END
