//
//  MyDatePickerView.m
//  datapicker
//
//  Created by admin on 2017/3/22.
//  Copyright © 2017年 lalagu. All rights reserved.
//

#import "MyDatePickerView.h"
#import <Masonry/Masonry.h>

@interface MyDatePickerView()<CAAnimationDelegate>
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UIButton *btnConfirm;
@property (nonatomic, strong) UIView *weekView;
@property (nonatomic, strong) NSArray *weekArr;
@property (nonatomic, strong) UIView *blackView;
@property (nonatomic, strong) UIView *line1;
@property (nonatomic, strong) UIView *line2;
@property (nonatomic, strong) UILabel *lbTitle;
@property (nonatomic, strong) UILabel *lbWarning;
@property (nonatomic, strong) UIButton *btnCancel;
@property (nonatomic, strong) UIView *circleMask;

@end
@implementation MyDatePickerView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.frame = [UIScreen mainScreen].bounds;

        self.blackView = [[UIView alloc]initWithFrame:self.frame];
        self.blackView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        self.blackView.alpha = 0;
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc]init];
        [tapGR setNumberOfTapsRequired:1];
        [tapGR setNumberOfTouchesRequired:1];
        [tapGR addTarget:self action:@selector(myDismiss)];
        [self addGestureRecognizer:tapGR];
        [self addSubview:self.circleMask];
        [self addSubview:self.datePicker];
        [self addSubview:self.weekView];
        [self addSubview:self.btnConfirm];
        [self addSubview:self.btnCancel];
        [self addSubview:self.lbTitle];
        [self addSubview:self.line1];
        [self addSubview:self.line2];
        [self addSubview:self.lbWarning];
    }
    return self;
}
-(void)setCurStyle:(DatePickerStyle)curStyle {
    _curStyle = curStyle;
    if (self.uiStyle == DatePickerUIStyleTopCircle){
        self.lbTitle.text = self.title;
        [self.btnConfirm setTitleColor: [UIColor orangeColor] forState:UIControlStateNormal];
        self.btnCancel.hidden = NO;
        self.line1.hidden = NO;
        self.line2.hidden = NO;
        self.lbWarning.hidden = YES;
        self.lbTitle.hidden = NO;
        self.circleMask.hidden = NO;
        if (curStyle == DatePickerStyleTime) {
            self.datePicker.hidden = NO;
            self.weekView.hidden = YES;
            [self.datePicker mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.height.equalTo(@230);
                make.bottom.equalTo(self.mas_bottom).offset(-34);
                make.width.equalTo(self);
            }];
            
            [self.btnCancel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self).mas_offset(cTableViewFilletLFBorder);
                make.bottom.equalTo(self.datePicker.mas_top);
                make.width.equalTo(@70);
                make.height.equalTo(@40);
            }];
            
            [self.btnConfirm mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self).mas_offset(-cTableViewFilletLFBorder);
                make.bottom.equalTo(self.datePicker.mas_top);
                make.width.equalTo(@70);
                make.height.equalTo(@40);
            }];
            
            [self.lbTitle mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.btnCancel.mas_right);
                make.right.equalTo(self.btnConfirm.mas_left);
                make.height.equalTo(@40);
                make.bottom.equalTo(self.datePicker.mas_top);
            }];
            
            [self.line1 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self).mas_offset(cTableViewFilletLFBorder + 10);
                make.right.equalTo(self).mas_offset(-cTableViewFilletLFBorder - 10);
                make.height.equalTo(@1);
                make.bottom.equalTo(self.datePicker.mas_top);
            }];
            
            [self.line2 mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self);
                make.right.equalTo(self);
                make.height.equalTo(@1);
                make.bottom.equalTo(self.datePicker.mas_bottom);
            }];
            
            [self.lbWarning mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.line1).mas_offset(3);
                make.left.equalTo(self);
                make.right.equalTo(self);
//                make.height.equalTo(@40);
            }];
            
            [self.circleMask mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self);
                make.left.equalTo(self);
                make.right.equalTo(self);
                make.top.equalTo(self.btnConfirm.mas_top);
            }];
            
            [self setNeedsLayout];
            [self layoutIfNeeded];
            
            // 创建左上角和右下角圆角的 UIBezierPath 路径
            UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.circleMask.bounds
                                                           byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                                 cornerRadii:CGSizeMake(15.f, 15.f)];
            // 创建 CAShapeLayer
            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
            maskLayer.frame = self.circleMask.bounds;
            maskLayer.path = maskPath.CGPath;
            self.circleMask.layer.mask = maskLayer;
        }
    }else{
        [self.btnConfirm setTitleColor:kDefaultTitleColor forState:UIControlStateNormal];
        self.btnCancel.hidden = YES;
        self.line1.hidden = YES;
        self.line2.hidden = YES;
        self.lbWarning.hidden = YES;
        self.lbTitle.hidden = YES;
        self.circleMask.hidden = YES;
        if (curStyle == DatePickerStyleTime) {
            self.datePicker.hidden = NO;
            self.weekView.hidden = YES;
            [self.datePicker mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.mas_right).multipliedBy(0.05);
                make.height.equalTo(@190);
                make.bottom.equalTo(self.mas_bottom).offset(-cTableViewCellHeight - 20-34);
                make.width.equalTo(self).multipliedBy(0.9);
            }];
        }
        
        if (curStyle == DatePickerStyleWeek || curStyle == DatePickerStyleWeekSundayFirst) {
            self.datePicker.hidden = YES;
            self.weekView.hidden = NO;
            [self createWeekBtn];
            [self.weekView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.mas_right).multipliedBy(0.05);
                make.height.mas_equalTo(cTableViewCellHeight * 7 );
                make.bottom.equalTo(self.mas_bottom).offset(-cTableViewCellHeight - 20-34);
                make.width.equalTo(self).multipliedBy(0.9);
            }];
        }
        
        [self.btnConfirm mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_right).multipliedBy(0.05);
            make.height.mas_equalTo(cTableViewCellHeight);
            make.bottom.equalTo(self.mas_bottom).offset(-10-34);
            make.width.equalTo(self).multipliedBy(0.9);
        }];
    }
}

-(void)createWeekBtn {
    for (UIView *subView in self.weekView.subviews) {
        [subView removeFromSuperview];
    }
    
    for (int i = 0; i < 7; i++) {
        float y = 0;
        if (self.curStyle == DatePickerStyleWeekSundayFirst) {
            if (i == 6) {
                y = 0;
            }else{
                y = (i + 1) * cTableViewCellHeight;
            }
        }else{
            y = i * cTableViewCellHeight;
        }
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(20, y, CGRectGetWidth(self.frame)*0.9 - 20, cTableViewCellHeight)];
        [btn setTitle:[NSString stringWithFormat:@" %@",self.weekArr[i]] forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:cTableViewFilletTitleFont]];
        [btn setTitleColor:cTableViewFilletTitleColor forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"AlarmModeView-correct-nor"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"AlarmModeView-correct-sel"] forState:UIControlStateSelected];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [btn addTarget:self action:@selector(onWeekBtn:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 100 + i;
        if (_weekBit & (1<<i)) {
            btn.selected = !btn.selected;
        }
        [self.weekView addSubview:btn];
        
        if (self.curStyle != DatePickerStyleWeekSundayFirst) {
            if (i < 6) {
                UIView *line = [[UIView alloc] init];
                line.backgroundColor = [UIColor lightGrayColor];
                
                [btn addSubview:line];
                [line mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(self.weekView);
                    make.right.equalTo(self.weekView);
                    make.height.equalTo(@0.5);
                    make.bottom.equalTo(btn);
                }];
            }
        }else{
            if (i != 5) {
                UIView *line = [[UIView alloc] init];
                line.backgroundColor = [UIColor lightGrayColor];
                
                [btn addSubview:line];
                [line mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(self.weekView);
                    make.right.equalTo(self.weekView);
                    make.height.equalTo(@0.5);
                    make.bottom.equalTo(btn);
                }];
            }
        }
    }
}

#pragma mark - UIButtonEvent
-(void)onWeekBtn:(UIButton *)sender {
    for (int i = 0; i < 7; i++) {
        if (sender.tag == 100 + i) {
            if ((_weekBit & (1<<i))>0) {
                _weekBit = ~((~_weekBit) | (1<<i));
            } else {
                _weekBit = _weekBit | (1<<i);
            }
            sender.selected = !sender.selected;
        }
    }
}

#pragma mark 确定时间选择按钮
-(void)btnConfirmClicked:(UIButton *)sender
{
    if (self.uiStyle == DatePickerUIStyleTopCircle){
        NSString *choseDateStr = [NSDate timeStringWithDate:self.datePicker.date];
        if (!self.ifChoseStart && [choseDateStr isEqual:@"00:00:00"]){
            choseDateStr = @"23:59:59";
        }
        NSDate *choseDate = [NSDate dateWithTimeString:choseDateStr];
        if (self.ifChoseStart) {
            if ([self.compareDate timeIntervalSince1970] < [choseDate timeIntervalSince1970]){
                self.lbWarning.hidden = NO;
                self.lbWarning.text = TS("TR_Alarm_Period_Start_Time_Can_Not_Great_Than_Or_Equal_To_End_Time");
                return;
            } else if ([self.compareDate timeIntervalSince1970] == [choseDate timeIntervalSince1970]) {
                self.lbWarning.hidden = NO;
                self.lbWarning.text = TS("TR_Alarm_Period_Repeat_Time");
                return;
            }
        }else{
            if ([self.compareDate timeIntervalSince1970] > [choseDate timeIntervalSince1970]){
                self.lbWarning.hidden = NO;
                self.lbWarning.text = TS("TR_Alarm_Period_End_Time_Can_Not_Less_Than_Or_Equal_To_Start_Time");
                return;
            }else if ([self.compareDate timeIntervalSince1970] == [choseDate timeIntervalSince1970]) {
                self.lbWarning.hidden = NO;
                self.lbWarning.text = TS("TR_Alarm_Period_Repeat_Time");
                return;
            }
        }
    }
    
    self.lbWarning.hidden = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(onSelectDate:sender:)]) {
        [self.delegate onSelectDate:self.datePicker.date sender:self];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(onSelectWeek:sender:)]) {
        [self.delegate onSelectWeek:_weekBit sender:self];
    }
    [self myDismiss];
}

#pragma mark 取消时间选择按钮
-(void)btnCancelClicked:(UIButton *)sender
{
    [self myDismiss];
}

#pragma mark 显示方法
-(void)myShowInView:(UIView *)view dismiss:(MyDatePickerDismiss)dismiss
{
    self.myDatePickerDismiss = dismiss;
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self.frame = CGRectMake(0, 300, screenSize.width, screenSize.height);
    
    [view addSubview:self];
    [view insertSubview:self.blackView belowSubview:self];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.blackView.alpha = 1;
        self.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    }];
}

- (void)myShowInView:(UIView *)view showDate:(NSDate *)date dismiss:(MyDatePickerDismiss)dismiss{
    self.myDatePickerDismiss = dismiss;
    
    if (date) {
        [self.datePicker setDate:date animated:NO];
    }
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self.frame = CGRectMake(0, 300, screenSize.width, screenSize.height);
    
    [view addSubview:self];
    [view insertSubview:self.blackView belowSubview:self];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.blackView.alpha = 1;
        self.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    }];
}

#pragma mark 消失方法
-(void)myDismiss
{
    [UIView animateWithDuration:0.1 animations:^{
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        self.blackView.alpha = 0;
        self.frame = CGRectMake(0, 300, screenSize.width, screenSize.height);
    } completion:^(BOOL finished) {
        [self.blackView removeFromSuperview];
        [self removeFromSuperview];
        if (self.myDatePickerDismiss) {
            self.myDatePickerDismiss();
        }
    }];
}

-(UIButton *)btnConfirm {
    if (!_btnConfirm) {
        _btnConfirm = [UIButton buttonWithType:UIButtonTypeSystem];
        _btnConfirm.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
        _btnConfirm.layer.cornerRadius = 8;
        [_btnConfirm setTitleColor:kDefaultTitleColor forState:UIControlStateNormal];
        [_btnConfirm setTitle:TS("confirm") forState:UIControlStateNormal];
        [_btnConfirm addTarget:self action:@selector(btnConfirmClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnConfirm;
}

-(UIDatePicker *)datePicker
{
    if (!_datePicker) {
        _datePicker = [[UIDatePicker alloc] init];
        _datePicker.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
        _datePicker.layer.cornerRadius = 8;
        _datePicker.layer.masksToBounds = YES;
        _datePicker.hidden = YES;
        if (@available(iOS 13.4, *)) {
            _datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
            _datePicker.backgroundColor = [UIColor whiteColor];
        }
        _datePicker.datePickerMode = UIDatePickerModeTime;
    }
    return _datePicker;
}

-(NSArray *)weekArr {
    if (!_weekArr) {
        _weekArr = @[TS("Monday"), TS("Tuesday"), TS("Wednesday"), TS("Thursday"), TS("Friday"), TS("Saturday"), TS("Sunday")];
    }
    return _weekArr;
}

-(UIView *)weekView {
    if (!_weekView) {
        _weekView = [[UIView alloc] init];
        _weekView.layer.masksToBounds = YES;
        _weekView.hidden = YES;
        _weekView.layer.cornerRadius = 8;
        _weekView.layer.masksToBounds = YES;
        _weekView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
    }
    return _weekView;
}

- (UIView *)line1{
    if (!_line1){
        _line1 = [[UIView alloc] init];
        _line1.backgroundColor = cTableViewFilletUnderLineColor;
    }
    
    return _line1;
}

- (UIView *)line2{
    if (!_line2){
        _line2 = [[UIView alloc] init];
        _line2.backgroundColor = cTableViewFilletUnderLineColor;
    }
    
    return _line2;
}

- (UILabel *)lbTitle{
    if (!_lbTitle){
        _lbTitle = [[UILabel alloc] init];
        _lbTitle.textAlignment = NSTextAlignmentCenter;
        _lbTitle.font = [UIFont boldSystemFontOfSize:cTableViewFilletTitleFont + 1];
        _lbTitle.text = TS("TR_Alarm_Period_Repeat_Time");
        _lbTitle.numberOfLines = 2;
    }
    
    return _lbTitle;
}

- (UILabel *)lbWarning{
    if (!_lbWarning){
        _lbWarning = [[UILabel alloc] init];
        _lbWarning.textAlignment = NSTextAlignmentCenter;
        _lbWarning.font = [UIFont systemFontOfSize:cTableViewFilletTitleFont - 2];
        _lbWarning.textColor = [UIColor colorWithHexStr:@"#EE1818"];
        _lbWarning.numberOfLines = 2;
    }
    
    return _lbWarning;
}

-(UIButton *)btnCancel {
    if (!_btnCancel) {
        _btnCancel = [UIButton buttonWithType:UIButtonTypeSystem];
        _btnCancel.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
        _btnCancel.layer.cornerRadius = 8;
        [_btnCancel setTitleColor:kDefaultTitleColor forState:UIControlStateNormal];
        [_btnCancel setTitle:TS("cancel") forState:UIControlStateNormal];
        [_btnCancel addTarget:self action:@selector(btnCancelClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnCancel;
}

- (UIView *)circleMask{
    if (!_circleMask){
        _circleMask = [[UIView alloc] init];
        _circleMask.backgroundColor = [UIColor whiteColor];
    }
    
    return _circleMask;
}

@end

