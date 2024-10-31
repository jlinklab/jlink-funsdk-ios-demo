//
//  ZoomControlView.m
//
//
//  Created by Tony Stark on 2021/11/8.
//  Copyright © 2021 xiongmaitech. All rights reserved.
//

#import "ZoomControlView.h"
#import <Masonry/Masonry.h>

#define GET_COLOR(r,g,b,a) [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:a]

@interface ZoomControlView ()

@property (nonatomic,strong) NSMutableArray <UIView *>*arrayLargeScaleViews;
@property (nonatomic,strong) NSMutableArray <NSMutableArray <UIView *>*>*arraySmalScaleViews;

@property (nonatomic,strong) UIView *scaleBG;
@property (nonatomic,strong) UIView *scaleContainer;

//触摸开始时的倍数
@property (nonatomic,assign) float touchMultiple;
//最近一次的位置
@property (nonatomic,assign) float lastPointX;
//倍数视图宽高
@property (nonatomic,assign) CGFloat multipleViewWidth;
@property (nonatomic,assign) CGFloat multipleViewHeight;
//倍数标题的宽度
@property (nonatomic,assign) float multipleLabelWidth;
//常显标题宽度
@property (nonatomic,assign) float lbCirleWidth;
//分割大小圆直径
@property (nonatomic,assign) CGFloat bigCircleDiameter;
@property (nonatomic,assign) CGFloat smallCircleDiameter;
//分割线的段数
@property (nonatomic,assign) int littleInterval;
//分割大小圆的颜色
@property (nonatomic,strong) UIColor *bigCDColor;
@property (nonatomic,strong) UIColor *smallCDColor;

@end
@implementation ZoomControlView

- (instancetype)initWithFrame:(CGRect)frame totalMultiple:(int)multiple {
    self = [super initWithFrame:frame];
    if (self) {
        self.multipleViewWidth = 40;
        self.multipleViewHeight = 80;
        self.lbCirleWidth = 23;
        self.bigCircleDiameter = 5;
        self.smallCircleDiameter = 2;
        self.littleInterval = 5;
        self.multipleLabelWidth = 40;
        self.bigCDColor = [UIColor whiteColor];//GET_COLOR(175, 175, 175, 0.47);
        self.smallCDColor = [UIColor whiteColor];//GET_COLOR(175, 175, 175, 0.47);
        self.totalMultiple = multiple;
        if (self.totalMultiple < 8) {
            self.littleInterval = 10;
        }
        
        [self addSubview:self.scaleBG];
        [self.scaleBG mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).mas_offset(30 - self.lbCirleWidth * 0.5);
            make.right.equalTo(self).mas_offset(-30 + self.lbCirleWidth * 0.5);
            make.centerY.equalTo(self);
            make.height.equalTo(@15);
        }];
        
        [self addSubview:self.scaleContainer];
        [self.scaleContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).mas_offset(30);
            make.right.equalTo(self).mas_offset(-30);
            make.centerY.equalTo(self);
            make.height.equalTo(@20);
        }];
        
        [self refreshZoomView];
        self.curMultiple = 1;
    }
    
    return self;
}

- (void)setCurMultiple:(float)curMultiple {
    _curMultiple = curMultiple;
    self.lbMultipleCircle.text = [NSString stringWithFormat:@"%.1fX",_curMultiple];
    self.lbMultipleCircle.frame = CGRectMake(-self.lbCirleWidth * 0.5 + CGRectGetWidth(self.scaleContainer.frame) * ((_curMultiple - 1) / (self.totalMultiple - 1)), (20 - self.lbCirleWidth) * 0.5, self.lbCirleWidth, self.lbCirleWidth);
    
    float percent = 0;
    if (self.curMultiple > 1) {
        percent = (self.curMultiple - 1) / ((self.totalMultiple - 1) * 0.5);
        if (percent > 2) {
            percent = 2;
        }
    }
    
    self.lbCirleWidth = 23;
    self.lbMultipleCircle.font = [UIFont systemFontOfSize:9];
    
    if(self.curMultiple >= 10.0){
        self.lbCirleWidth = 24;
        self.lbMultipleCircle.font = [UIFont systemFontOfSize:8];
    }
    
    [self.scaleContainer addSubview:self.lbMultipleCircle];
    [self.lbMultipleCircle mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.scaleContainer);
        if (self.curMultiple <= 1) {
            make.centerX.equalTo(self.scaleContainer.mas_left);
        }else{
            make.centerX.equalTo(self.scaleContainer).multipliedBy(percent);
        }
        make.width.mas_equalTo(self.lbCirleWidth);
        make.height.mas_equalTo(self.lbCirleWidth);
    }];
}

- (void)setTotalMultiple:(int)totalMultiple {
    BOOL needRefreshZoomView = NO;
    if (_totalMultiple != totalMultiple) {
        needRefreshZoomView = YES;
    }
    
    _totalMultiple = totalMultiple;
    
    if (needRefreshZoomView) {
        if (totalMultiple < 8) {
            self.littleInterval = 10;
        }
        
        [self refreshZoomView];
    }
    
    if (self.curMultiple >  totalMultiple){
        self.curMultiple = totalMultiple;
    }
}

- (void)refreshZoomView {
    for (UIView *view in self.arrayLargeScaleViews) {
        [view removeFromSuperview];
    }
    
    for (NSMutableArray <UIView *>*array in self.arraySmalScaleViews) {
        for (UIView *view in array) {
            [view removeFromSuperview];
        }
    }
    
    [self.arrayLargeScaleViews removeAllObjects];
    [self.arraySmalScaleViews removeAllObjects];
    
    for (int i = 0; i < self.totalMultiple; i++) {
        UIView *largeCircle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bigCircleDiameter, self.bigCircleDiameter)];
        largeCircle.backgroundColor = self.bigCDColor;
        largeCircle.layer.cornerRadius = self.bigCircleDiameter * 0.5;
        largeCircle.layer.masksToBounds = YES;
        largeCircle.userInteractionEnabled = NO;
        [self.arrayLargeScaleViews addObject:largeCircle];
        
        [self.scaleContainer addSubview:largeCircle];
    }
    
    for (int i = 1; i < self.arrayLargeScaleViews.count; i ++) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
        for (int i = 1; i < self.littleInterval; i++) {
            UIView *smalCircle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.smallCircleDiameter, self.smallCircleDiameter)];
            smalCircle.backgroundColor = self.smallCDColor;
            smalCircle.layer.cornerRadius = self.smallCircleDiameter * 0.5;
            smalCircle.layer.masksToBounds = YES;
            smalCircle.userInteractionEnabled = NO;
            [array addObject:smalCircle];
            
            [self.scaleContainer addSubview:smalCircle];
        }
        [self.arraySmalScaleViews addObject:array];
    }
    
    for (int i = 0; i < self.arrayLargeScaleViews.count; i++) {
        [[self.arrayLargeScaleViews objectAtIndex:i] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.bigCircleDiameter);
            make.height.mas_equalTo(self.bigCircleDiameter);
            make.centerY.equalTo(self.scaleContainer);
            if (i == 0) {
                make.centerX.equalTo(self.scaleContainer.mas_left);
            }else{
                make.centerX.equalTo(self.scaleContainer).multipliedBy(2.0 * i / (self.totalMultiple - 1));
            }
        }];
        
        if (self.arraySmalScaleViews.count > i) {
            NSArray <UIView *>*array = [self.arraySmalScaleViews objectAtIndex:i];
            for (int y = 0; y < array.count; y++) {
                [[array objectAtIndex:y] mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(self.smallCircleDiameter);
                    make.height.mas_equalTo(self.smallCircleDiameter);
                    make.centerY.equalTo(self.scaleContainer);
                    make.centerX.equalTo(self.scaleContainer).multipliedBy(2.0 * (i * self.littleInterval + y + 1) / ((self.totalMultiple - 1) * self.littleInterval));
                }];
            }
        }
        
    }
    
    [self.scaleContainer addSubview:self.lbMultipleCircle];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UIView *touchView = [touches anyObject].view;
    if ([touchView isEqual:self.scaleContainer] ||
        [touchView isEqual:self.scaleBG]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kZoomControlViewTouchBegin object:nil];
        self.touchMultiple = self.curMultiple;
        [self feedbackGenerator];
        CGPoint point = [[touches anyObject] locationInView:self.scaleContainer];
        if (point.x < 0) {
            point.x = 0;
        }else if (point.x > CGRectGetWidth(self.scaleContainer.frame)){
            point.x = CGRectGetWidth(self.scaleContainer.frame);
        }
        
        self.curMultiple = 1 + point.x / (CGRectGetWidth(self.scaleContainer.frame) / (self.totalMultiple - 1));
        //和android统一 强制处理成2的倍数 如果是返回的倍数是设备给的且小于8 精确到0.1
        NSString *strMultiple = [NSString stringWithFormat:@"%.1f",self.curMultiple];
        float value = [strMultiple floatValue];
        int judge = (int)(value * 10);
        if (judge % 2 != 0 && self.totalMultiple >= 8) {
            judge = judge + 1;
        }
        self.curMultiple = judge / 10.0;
        self.lastPointX = point.x;
        self.lbMultiple.text = [NSString stringWithFormat:@"%.1fX",self.curMultiple];
        self.lbMultipleCircle.text = [NSString stringWithFormat:@"%.1fX",self.curMultiple];
        [self.scaleContainer addSubview:self.curMultipleView];
        [self.scaleContainer addSubview:self.lbMultipleCircle];
        self.curMultipleView.hidden = NO;
        self.curMultipleView.frame = CGRectMake(-self.multipleViewWidth * 0.5 + self.lbMultipleCircle.center.x, 30 - self.multipleViewHeight, self.multipleViewWidth, self.multipleViewHeight);
        return;
    }
    
    //[super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UIView *touchView = [touches anyObject].view;
    if ([touchView isEqual:self.scaleContainer] ||
        [touchView isEqual:self.scaleBG]) {
        CGPoint point = [[touches anyObject] locationInView:self.scaleContainer];
        if (point.x < 0) {
            point.x = 0;
        }else if (point.x > CGRectGetWidth(self.scaleContainer.frame)){
            point.x = CGRectGetWidth(self.scaleContainer.frame);
        }
        
        NSLog(@"haha== %f %f %f",point.x,CGRectGetWidth(self.scaleContainer.frame),(CGRectGetWidth(self.scaleContainer.frame) / (self.totalMultiple - 1)));
        self.curMultiple = 1 + point.x / (CGRectGetWidth(self.scaleContainer.frame) / (self.totalMultiple - 1));
        int passPoint1 = 0;
        int passPoint2 = 0;
        passPoint1 = 1 + point.x / (CGRectGetWidth(self.scaleContainer.frame) / ((self.totalMultiple - 1) * self.littleInterval));
        passPoint2 = 1 + self.lastPointX / (CGRectGetWidth(self.scaleContainer.frame) / ((self.totalMultiple - 1) * self.littleInterval));
        int pass = abs(passPoint1 - passPoint2);
        if (pass > 0) {
            for (int i = 0; i < pass ; i++) {
                [self feedbackGenerator];
            }
        }
        
        //和android统一 强制处理成2的倍数 如果是返回的倍数是设备给的且小于8 精确到0.1
        NSString *strMultiple = [NSString stringWithFormat:@"%.1f",self.curMultiple];
        float value = [strMultiple floatValue];
        int judge = (int)(value * 10);
        if (judge % 2 != 0 && self.totalMultiple >= 8) {
            judge = judge + 1;
        }
        self.curMultiple = judge / 10.0;
        self.lastPointX = point.x;
        self.lbMultiple.text = [NSString stringWithFormat:@"%.1fX",self.curMultiple];
        self.lbMultipleCircle.text = [NSString stringWithFormat:@"%.1fX",self.curMultiple];
        
        self.curMultipleView.frame = CGRectMake(-self.multipleViewWidth * 0.5 + self.lbMultipleCircle.center.x, 30 - self.multipleViewHeight, self.multipleViewWidth, self.multipleViewHeight);
        return;
    }
    
    //[super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[NSNotificationCenter defaultCenter] postNotificationName:kZoomControlViewTouchEnd object:nil];
    UIView *touchView = [touches anyObject].view;
    if ([touchView isEqual:self.scaleContainer] ||
        [touchView isEqual:self.scaleBG]) {
        CGPoint point = [[touches anyObject] locationInView:self.scaleContainer];
        if (point.x < 0) {
            point.x = 0;
        }else if (point.x > CGRectGetWidth(self.scaleContainer.frame)){
            point.x = CGRectGetWidth(self.scaleContainer.frame);
        }
        
        self.curMultiple = 1 + point.x / (CGRectGetWidth(self.scaleContainer.frame) / (self.totalMultiple - 1));
        //和android统一 强制处理成2的倍数 如果是返回的倍数是设备给的且小于8 精确到0.1
        NSString *strMultiple = [NSString stringWithFormat:@"%.1f",self.curMultiple];
        float value = [strMultiple floatValue];
        int judge = (int)(value * 10);
        if (judge % 2 != 0 && self.totalMultiple >= 8) {
            judge = judge + 1;
        }
        self.curMultiple = judge / 10.0;
        self.lastPointX = point.x;
        self.lbMultiple.text = [NSString stringWithFormat:@"%.1fX",self.curMultiple];
        self.lbMultipleCircle.text = [NSString stringWithFormat:@"%.1fX",self.curMultiple];
        [self.scaleContainer addSubview:self.curMultipleView];
        [self.scaleContainer addSubview:self.lbMultipleCircle];
        self.curMultipleView.hidden = NO;
        self.curMultipleView.frame = CGRectMake(-self.multipleViewWidth * 0.5 + self.lbMultipleCircle.center.x, 30 - self.multipleViewHeight, self.multipleViewWidth, self.multipleViewHeight);

        self.curMultipleView.hidden = YES;
        if (self.multipleChangeCallBack) {
            self.multipleChangeCallBack(self.curMultiple,self.touchMultiple);
        }
        return;
    }
    
    //[super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[NSNotificationCenter defaultCenter] postNotificationName:kZoomControlViewTouchEnd object:nil];
    UIView *touchView = [touches anyObject].view;
    if ([touchView isEqual:self.scaleContainer] ||
        [touchView isEqual:self.scaleBG]) {
        self.curMultipleView.hidden = YES;
        if (self.multipleChangeCallBack) {
            self.multipleChangeCallBack(self.curMultiple,self.touchMultiple);
        }
        return;
    }
    
    //[super touchesCancelled:touches withEvent:event];
}

- (void)feedbackGenerator {
    UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    [generator prepare];
    [generator impactOccurred];
}

//MARK: - LazyLoad
- (NSMutableArray <UIView *>*)arrayLargeScaleViews {
    if (!_arrayLargeScaleViews) {
        _arrayLargeScaleViews = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _arrayLargeScaleViews;
}

- (NSMutableArray <NSMutableArray <UIView *>*>*)arraySmalScaleViews {
    if (!_arraySmalScaleViews) {
        _arraySmalScaleViews = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _arraySmalScaleViews;
}

- (UIView *)scaleContainer {
    if (!_scaleContainer) {
        _scaleContainer = [[UIView alloc] init];
    }
    
    return _scaleContainer;
}

- (UIView *)scaleBG {
    if (!_scaleBG) {
        _scaleBG = [[UIView alloc] init];
        _scaleBG.backgroundColor = GET_COLOR(30, 30, 30, 0.5);
        _scaleBG.layer.cornerRadius = 7.5;
        _scaleBG.layer.masksToBounds = YES;
    }
    
    return _scaleBG;
}

- (UIView *)curMultipleView {
    if (!_curMultipleView) {
        _curMultipleView = [[UIView alloc] initWithFrame:CGRectZero];
        
        self.lbMultiple = [[UILabel alloc] init];
        self.lbMultiple.backgroundColor = GET_COLOR(151, 151, 151, 0.3);
        self.lbMultiple.font = [UIFont systemFontOfSize:12];
        self.lbMultiple.textColor = UIColor.whiteColor;
        self.lbMultiple.layer.cornerRadius = self.multipleLabelWidth * 0.5;
        self.lbMultiple.layer.masksToBounds = YES;
        self.lbMultiple.layer.borderColor = [UIColor whiteColor].CGColor;
        self.lbMultiple.layer.borderWidth = 1;
        self.lbMultiple.textAlignment = NSTextAlignmentCenter;
        _curMultipleView.userInteractionEnabled = NO;
        
        [_curMultipleView addSubview:self.lbMultiple];
        [self.lbMultiple mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.multipleLabelWidth);
            make.height.mas_equalTo(self.multipleLabelWidth);
            make.top.equalTo(_curMultipleView).mas_offset(5);
            make.centerX.equalTo(_curMultipleView);
        }];
        
        _curMultipleView.hidden = YES;
    }
    
    return _curMultipleView;
}

- (UILabel *)lbMultipleCircle {
    if (!_lbMultipleCircle) {
        _lbMultipleCircle = [[UILabel alloc] init];
        _lbMultipleCircle.backgroundColor = GET_COLOR(73, 73, 73, 0.8);
        _lbMultipleCircle.font = [UIFont systemFontOfSize:9];
        _lbMultipleCircle.textColor = UIColor.whiteColor;
        _lbMultipleCircle.layer.cornerRadius = self.lbCirleWidth * 0.5;
        _lbMultipleCircle.layer.masksToBounds = YES;
        _lbMultipleCircle.textAlignment = NSTextAlignmentCenter;
        _lbMultipleCircle.text = @"1.0X";
    }
    
    return _lbMultipleCircle;
}

- (void)dealloc {
}

@end
