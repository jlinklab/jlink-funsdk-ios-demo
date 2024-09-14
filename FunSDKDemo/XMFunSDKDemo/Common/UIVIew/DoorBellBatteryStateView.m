//
//  DoorBellBatteryStateView.m
//  XWorld_General
//
//  Created by SaturdayNight on 26/10/2017.
//  Copyright © 2017 xiongmaitech. All rights reserved.
//

#import "DoorBellBatteryStateView.h"
#import <Masonry/Masonry.h>

@interface DoorBellBatteryStateView ()
{
    
}

@property (nonatomic,strong) NSTimer *timerAnimation;
@property (nonatomic,assign) float electricityAnimation;

@property (nonatomic,assign) float lastPercentage;

@end

@implementation DoorBellBatteryStateView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.electricityAnimation = -1;
        [self addSubview:self.imgViewBatteryOutline];
        [self.imgViewBatteryOutline addSubview:self.electricQuantityView];
        [self.imgViewBatteryOutline addSubview:self.imgViewLightingIcon];
        [self.imgViewBatteryOutline addSubview:self.lbElectricQuantity];
        [SVProgressHUD show];
        [self myLayout];
    }
    
    return self;
}

//MARK: 设置电量百分比（float：0-1）
- (void)setBateryPercentage:(float)percentage{
    //如果是非法数字 不执行
    if (isnan(percentage)){
        return;
    }
    self.lastPercentage = percentage;
    [self updateBatteryDescriptionWithPercentage:percentage];
    [self updateBackGroundColorWithPercentage:percentage];
    [self endLoadingState];
    [self updateBatteryIconWithPercentage:percentage];
    [self updateBackGroundLenghtWithPercentage:percentage];
}

//MARK: 报警消息界面低电量
- (void)setAlarmMessageLowBateryPercentage:(float)percentage{
    //如果是非法数字 不执行
    if (isnan(percentage)){
        return;
    }
    self.lastPercentage = percentage;
    [self updateBatteryDescriptionWithPercentage:percentage];
    [self updateBackGroundColorWithPercentage:percentage];
    [self endLoadingState];
    [self updateBatteryIconWithPercentage:percentage];
    [self updateBackGroundLenghtWithPercentage:percentage];
    //消息低电量强制修改背景色和图片
    self.electricQuantityView.backgroundColor = [UIColor redColor];
    self.imgViewBatteryOutline.image = [UIImage imageNamed:@"electricity.png"];
}

//MARK: 是否显示电量数值
- (void)showLabel:(BOOL)show{
    show = NO;
    self.lbElectricQuantity.hidden = !show;
    if (show) {
        
    }else{
        if (!self.imgViewLightingIcon.hidden) {
            [self.imgViewLightingIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@7.5);
                make.height.equalTo(@10);
                make.centerX.equalTo(self.imgViewBatteryOutline);
                make.centerY.equalTo(self);
            }];
        }
    }
}

- (void)setBateryPercentage:(float)percentage animated:(BOOL)animated{
    //如果是非法数字 不执行
    if (isnan(percentage)){
        return;
    }
    [self endLoadingState];
    [self updateBackGroundLenghtWithPercentage:percentage];
}

//MARK: 根据电池电量 修改背景色 小于等于20 红色 其他绿色
- (void)updateBackGroundColorWithPercentage:(float)percentage{
    //浮点数计算在末尾会有误差，简单处理，这里只需要精确到小数点后第二位即可：用0.204替换正常思路下的0.2
    self.electricQuantityView.backgroundColor = percentage > 0.204 ? [UIColor colorWithHexStr:@"#00AF43"] : [UIColor redColor];
}

//MARK: 根据电池电量修改文字颜色和内容
- (void)updateBatteryDescriptionWithPercentage:(float)percentage{
    if (percentage <= 0) {
        self.lbElectricQuantity.text = @"!";
        self.lbElectricQuantity.textColor = [UIColor redColor];
    }else{
        self.lbElectricQuantity.text = [NSString stringWithFormat:@"%i",(int)(percentage * 100)];
        self.lbElectricQuantity.textColor = [UIColor whiteColor];
    }
}

//MARK: 根据电池电量修改背景色长度
- (void)updateBackGroundLenghtWithPercentage:(float)percentage{
    CGFloat width = 35 - 4 - 2;
    width = width * (1 - percentage);
    [self.electricQuantityView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imgViewBatteryOutline).offset(2);
        make.right.equalTo(self.imgViewBatteryOutline.mas_right).offset(-4 - width);
        make.bottom.equalTo(self.imgViewBatteryOutline).offset(-2);
        make.top.equalTo(self.imgViewBatteryOutline).offset(2);
    }];
}

//MARK: 根据电池电量更新电池的图标
- (void)updateBatteryIconWithPercentage:(float)percentage{
    if (percentage == 0 && self.timerAnimation == nil) {
        self.imgViewBatteryOutline.image = [UIImage imageNamed:@"electricity_red.png"];
    }else{
        self.imgViewBatteryOutline.image = [UIImage imageNamed:@"electricity.png"];
    }
}

//MARK: 结束加载状态
- (void)endLoadingState{
    [SVProgressHUD dismiss];
    self.electricQuantityView.hidden = NO;
}

//MARK: 正在充电
- (void)beginChargeAnimation{
    [SVProgressHUD dismiss];
    self.imgViewLightingIcon.hidden = NO;
    [self.imgViewLightingIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@7.5);
        make.height.equalTo(@10);
        make.right.equalTo(self.imgViewBatteryOutline).offset(-4);
        make.centerY.equalTo(self);
    }];
    [self.lbElectricQuantity mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imgViewBatteryOutline).offset(2);
        make.right.equalTo(self.imgViewLightingIcon.mas_left).mas_offset(4);
        make.bottom.equalTo(self.imgViewBatteryOutline).offset(-2);
        make.top.equalTo(self.imgViewBatteryOutline).offset(2);
    }];
    //动画不再使用 只显示充电图标
//    if (!self.timerAnimation) {
//        self.timerAnimation = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timeGone) userInfo:nil repeats:YES];
//    }
}

- (void)timeGone{
    int beginENum = 0;
    int endENum = 10;
    if (self.lastPercentage >= 1) {
        beginENum = 9;
    }else if (self.lastPercentage <= 0){
        beginENum = 0;
    }else{
        beginENum = 10 * self.lastPercentage;
    }
    
    if (self.electricityAnimation >= endENum) {
        self.electricityAnimation = beginENum;
    }else if (self.electricityAnimation < beginENum){
        self.electricityAnimation = beginENum;
    }
    else{
        self.electricityAnimation++;
    }

    [UIView animateWithDuration:1 animations:^{
        [self setBateryPercentage:self.electricityAnimation * 0.1 animated:YES];
    } completion:^(BOOL finished) {
        
    }];
}

//MARK: 停止充电
- (void)endChargeAnimation{
    self.imgViewLightingIcon.hidden = YES;
    [self.imgViewLightingIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@0);
        make.height.equalTo(self);
        make.right.equalTo(self.imgViewBatteryOutline).offset(-4);
        make.centerY.equalTo(self);
    }];
    [self.lbElectricQuantity mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imgViewBatteryOutline).offset(2);
        make.right.equalTo(self.imgViewLightingIcon.mas_left);
        make.bottom.equalTo(self.imgViewBatteryOutline).offset(-2);
        make.top.equalTo(self.imgViewBatteryOutline).offset(2);
    }];
    if (self.timerAnimation) {
        [self.timerAnimation invalidate];
        self.timerAnimation = nil;
    }
}

//MARK: Layout
- (void)myLayout{
    [self.imgViewBatteryOutline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.top.equalTo(self);
        make.bottom.equalTo(self);
    }];

    [self.electricQuantityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imgViewBatteryOutline).offset(2);
        make.right.equalTo(self.imgViewBatteryOutline).offset(-4);
        make.bottom.equalTo(self.imgViewBatteryOutline).offset(-2);
        make.top.equalTo(self.imgViewBatteryOutline).offset(2);
    }];

    [self.imgViewLightingIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@0);
        make.height.equalTo(self);
        make.right.equalTo(self.imgViewBatteryOutline).offset(-4);
        make.centerY.equalTo(self);
    }];
    
    [self.lbElectricQuantity mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imgViewBatteryOutline).offset(2);
        make.right.equalTo(self.imgViewLightingIcon.mas_left);
        make.bottom.equalTo(self.imgViewBatteryOutline).offset(-2);
        make.top.equalTo(self.imgViewBatteryOutline).offset(2);
    }];
}

//MARK: - LazyLoad
- (UIImageView *)imgViewBatteryOutline{
    if (!_imgViewBatteryOutline) {
        _imgViewBatteryOutline = [[UIImageView alloc] init];
        [_imgViewBatteryOutline setImage:[UIImage imageNamed:@"electricity.png"]];
    }
    
    return _imgViewBatteryOutline;
}

- (UIImageView *)imgViewLightingIcon{
    if (!_imgViewLightingIcon) {
        _imgViewLightingIcon = [[UIImageView alloc] init];
        _imgViewLightingIcon.image = [UIImage imageNamed:@"battery_lighting.png"];
        _imgViewLightingIcon.hidden = YES;
    }
    
    return _imgViewLightingIcon;
}

- (UIView *)electricQuantityView{
    if (!_electricQuantityView) {
        _electricQuantityView = [[UIView alloc] init];
        _electricQuantityView.backgroundColor = [UIColor colorWithHexStr:@"#00AF43"];
        _electricQuantityView.hidden = YES;
    }
    
    return _electricQuantityView;
}

- (UILabel *)lbElectricQuantity{
    if (!_lbElectricQuantity) {
        _lbElectricQuantity = [[UILabel alloc] init];
        _lbElectricQuantity.textColor = [UIColor whiteColor];
        _lbElectricQuantity.textAlignment = NSTextAlignmentCenter;
        _lbElectricQuantity.font = [UIFont systemFontOfSize:10 weight:0.2];
        _lbElectricQuantity.hidden = YES;
    }
    
    return _lbElectricQuantity;
}

@end
