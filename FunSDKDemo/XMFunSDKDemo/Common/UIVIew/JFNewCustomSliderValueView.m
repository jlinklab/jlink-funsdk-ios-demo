//
//  JFNewCustomSliderValueView.m
//   iCSee
//
//  Created by kevin on 2023/9/25.
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import "JFNewCustomSliderValueView.h"
#define LEFTRIGHTDISTANCE 10 //左右的间距
@interface JFNewCustomSliderValueView ()
@property (nonatomic, strong)  UIImageView *imgBG;
@end

@implementation JFNewCustomSliderValueView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
        self.bubbleUnit = @"";
        self.minValue = 1;
        self.maxValue = 100;
        _style = JFSliderStyle_Normal;
    }
    return self;
}

- (void)setStyle:(JFSliderStyle)style{
    _style = style;
    
    if (style == JFSliderStyle_Normal) {
        self.arraySegmentValue = nil;
        self.arraySegmentName = nil;
    }else{
        self.minValue = 0;
        self.maxValue = self.arraySegmentValue.count - 1;
        self.currentValue = [self.arraySegmentValue indexOfObject:[NSNumber numberWithInt:self.realValue]];
    }
    [self updateSliderValue];
}

- (void)setupSubviews {
    self.sliderBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, self.frame.size.width, 12)];
    [self.sliderBackgroundView.layer setMasksToBounds:YES];
    [self.sliderBackgroundView.layer setCornerRadius:6];
    [self addSubview:self.sliderBackgroundView];
    self.imgBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 12)];
    [self.imgBG.layer setMasksToBounds:YES];
    [self.imgBG.layer setCornerRadius:6];
    [self.imgBG setBackgroundColor:GlobalMainColor];
    [self.sliderBackgroundView addSubview: self.imgBG];
    // 添加滑块按钮
    self.sliderButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sliderButton.frame = CGRectMake(0, 0, 38, 38);
    self.sliderButton.adjustsImageWhenHighlighted = false;
    [self.sliderButton setImage:[UIImage imageWithImageName:@"single" imageColor:GlobalMainColor] forState:UIControlStateNormal];
    
    self.sliderButton.center = CGPointMake(10, self.sliderBackgroundView.center.y);
    [self addSubview:self.sliderButton];
    // 悬浮泡沫
    self.btnBubbble = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnBubbble.frame = CGRectMake(0, 0, 35, 24);
    [self.btnBubbble setBackgroundImage:[UIImage imageNamed:@"set_img_bubble"] forState:UIControlStateNormal];
    [self.btnBubbble setTitle:@"" forState:UIControlStateNormal];
    self.btnBubbble.titleLabel.font = [UIFont systemFontOfSize:10];
    [self.btnBubbble setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.btnBubbble.center = CGPointMake(10, self.sliderBackgroundView.center.y- 27);
    [self.btnBubbble setTitleEdgeInsets:UIEdgeInsetsMake(-5, 0, 0, 0)];
    [self addSubview:self.btnBubbble];
    self.btnBubbble.hidden = YES;
    // slider左右标题
    [self addSubview:self.lblLeft];
    [self addSubview:self.lblRight];
    [self.lblLeft mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.sliderBackgroundView.mas_left).mas_offset(5);
        make.top.mas_equalTo(self.sliderBackgroundView.mas_bottom).mas_offset(10);
    }];
    [self.lblRight mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.sliderBackgroundView.mas_right).mas_offset(-5);
        make.top.mas_equalTo(self.sliderBackgroundView.mas_bottom).mas_offset(10);
    }];
    
    // 添加点击手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sliderTapped:)];
    [self addGestureRecognizer:tapGesture];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self addGestureRecognizer:panGesture];
}

- (void)updateSliderValue {
    [self layoutSubviews];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 根据当前值计算滑块的位置
    CGFloat sliderX = (self.currentValue - self.minValue) / (self.maxValue - self.minValue) * (self.bounds.size.width-20 ) + 10;
    if (sliderX < 10) {
        sliderX = 10;
    }
    if (sliderX > self.bounds.size.width-10 ) {
        sliderX = self.bounds.size.width-10 ;
    }
    
    NSLog(@"中点xlayoutSubviews:%f",sliderX);
    self.sliderButton.center = CGPointMake(sliderX, self.sliderBackgroundView.center.y);
    self.btnBubbble.center = CGPointMake(sliderX, self.sliderBackgroundView.center.y- 27);
    self.imgBG.width = self.sliderButton.left + self.sliderButton.width/2;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self];
    [self updateSliderWithLocation:translation];
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        // 实时回调当前值
        NSLog(@"husdsdsdjii:%f",self.currentValue);
        self.btnBubbble.hidden = YES;
        if (self.style == JFSliderStyle_Normal) {
            if (self.valueChangedBlock) {
                self.valueChangedBlock(self.currentValue);
            }
        }else{
            if (self.valueChangedBlock) {
                self.valueChangedBlock(self.realValue);
            }
        }
    }
    [gesture setTranslation:CGPointZero inView:self];
}

- (void)sliderTapped:(UITapGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self];
    
    CGFloat sliderX = location.x;
    if (sliderX < 10) {
        sliderX = 10;
    }
    if (sliderX > self.bounds.size.width-10) {
        sliderX = self.bounds.size.width-10 ;
    }

    self.currentValue = (sliderX -10) / (self.bounds.size.width-20 ) * (self.maxValue - self.minValue) + self.minValue;
    NSLog(@"JFNewCustomSliderValueView2 %f",self.currentValue);
    // 更新滑块的位置
    NSLog(@"中点xsliderTapped:%f",sliderX);
    self.sliderButton.center = CGPointMake(sliderX, self.sliderBackgroundView.center.y);
    self.imgBG.width = self.sliderButton.left + self.sliderButton.width/2;
    self.btnBubbble.hidden = NO;
    if ((((int)(self.currentValue * 10)) % 10) >= 5) {
        self.currentValue = self.currentValue + 1;
    }
    self.currentValue = (int)self.currentValue;
    if (self.currentValue > self.maxValue) {
        self.currentValue = self.maxValue;
    }else if (self.currentValue < self.minValue){
        self.currentValue = self.minValue;
    }
    self.currentValue = (int)self.currentValue;
    if (self.style == JFSliderStyle_Normal) {
        [self.btnBubbble setTitle:[[self convertSecondsToMinutesSeconds:[[NSString stringWithFormat:@"%.0f",self.currentValue] intValue]] stringByAppendingFormat:@"%@",self.bubbleUnit] forState:UIControlStateNormal];
    }else{
        NSString *name = [self.arraySegmentName objectAtIndex:self.currentValue];
        self.realValue = [[self.arraySegmentValue objectAtIndex:self.currentValue] intValue];
        [self.btnBubbble setTitle:name forState:UIControlStateNormal];
    }
    self.btnBubbble.center = CGPointMake(sliderX, self.sliderBackgroundView.center.y- 27);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.btnBubbble.hidden = YES;
    });
    // 实时回调当前值
    NSLog(@"husdsdsdjii:%f",self.currentValue);
    if (self.style == JFSliderStyle_Normal) {
        if (self.valueChangedBlock) {
            self.valueChangedBlock(self.currentValue);
        }
    }else{
        if (self.valueChangedBlock) {
            self.valueChangedBlock(self.realValue);
        }
    }
    [self updateSliderValue];
}

- (void)updateSliderWithLocation:(CGPoint)location {
    // 限制滑块的位置在滑杆范围内
    CGFloat sliderX = self.sliderButton.center.x + location.x;
    sliderX = MAX(sliderX, self.sliderBackgroundView.frame.origin.x+ 10);
    sliderX = MIN(sliderX, self.sliderBackgroundView.frame.origin.x + self.sliderBackgroundView.frame.size.width-10);
     
    // 根据滑块的位置计算当前值
    self.currentValue = (sliderX -10) / (self.bounds.size.width-20 ) * (self.maxValue - self.minValue) + self.minValue;
    NSLog(@"slider== currentValue = %f",self.currentValue);
    // 更新滑块的位置
    NSLog(@"JFNewCustomSliderValueView1 %f",self.currentValue);
    NSLog(@"中点xupdateSliderWithLocation:%f",sliderX);
    self.sliderButton.center = CGPointMake(sliderX, self.sliderBackgroundView.center.y);
    self.imgBG.width = self.sliderButton.left + self.sliderButton.width/2;
    self.btnBubbble.hidden = NO;
    if ((((int)(self.currentValue * 10)) % 10) >= 5) {
        self.currentValue = self.currentValue + 1;
    }
    self.currentValue = (int)self.currentValue;
    if (self.currentValue > self.maxValue) {
        self.currentValue = self.maxValue;
    }else if (self.currentValue < self.minValue){
        self.currentValue = self.minValue;
    }
    self.currentValue = (int)self.currentValue;
    if (self.style == JFSliderStyle_Normal) {
        [self.btnBubbble setTitle:[[self convertSecondsToMinutesSeconds:[[NSString stringWithFormat:@"%.0f",self.currentValue] intValue]] stringByAppendingFormat:@"%@",self.bubbleUnit] forState:UIControlStateNormal];
    }else{
        NSString *name = [self.arraySegmentName objectAtIndex:self.currentValue];
        self.realValue = [[self.arraySegmentValue objectAtIndex:self.currentValue] intValue];
        [self.btnBubbble setTitle:name forState:UIControlStateNormal];
    }
    self.btnBubbble.center = CGPointMake(sliderX, self.sliderBackgroundView.center.y- 27);
}

- (NSString *)convertSecondsToMinutesSeconds:(NSInteger)seconds {
    if (!self.isNeedChangeShowType) {
        NSString *timeString = [NSString stringWithFormat:@"%ld", seconds];
        return timeString;
    }
    NSInteger minutes = seconds / 60;
    NSInteger remainingSeconds = seconds % 60;
    if (seconds <= 60) {
        NSString *timeString = [NSString stringWithFormat:@"%ld\"",seconds];
        return timeString;
    }
    NSString *timeString = [NSString stringWithFormat:@"%ld'%ld\"", (long)minutes, (long)remainingSeconds];
    return timeString;
}

#pragma mark - **************** lazyload ****************
-(UILabel *)lblLeft {
    if (!_lblLeft) {
        _lblLeft = [[UILabel alloc] init];
        _lblLeft.textColor = cTableViewFilletSubTitleColor;
        _lblLeft.font = [UIFont systemFontOfSize:cTableViewFilletSubTitleFont];
        _lblLeft.text = TS("TR_Low");
        _lblLeft.numberOfLines = 0;
    }
    
    return _lblLeft;
}
 
-(UILabel *)lblRight {
    if (!_lblRight) {
        _lblRight = [[UILabel alloc] init];
        _lblRight.textAlignment = NSTextAlignmentRight;
        _lblRight.textColor = cTableViewFilletSubTitleColor;
        _lblRight.font = [UIFont systemFontOfSize:cTableViewFilletSubTitleFont];
        _lblRight.text = TS("TR_High");

        _lblRight.numberOfLines = 0;
    }
    return _lblRight;
}

@end
