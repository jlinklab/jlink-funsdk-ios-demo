//
//  MyDatePickerView.h
//  datapicker
//
//  Created by admin on 2017/3/22.
//  Copyright © 2017年 lalagu. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, DatePickerStyle) {
    DatePickerStyleTime,                // 时间选择器
    DatePickerStyleWeek,                // 星期选择器
    DatePickerStyleWeekSundayFirst,     // 星期选择器礼拜天第一位
};

typedef NS_ENUM(NSInteger, DatePickerUIStyle) {
    DatePickerUIStyleCircle,                // 圆角模式
    DatePickerUIStyleTopCircle,             // 半圆角模式
};

typedef void (^MyDatePickerDismiss)();

@protocol MyDatePickerViewDelegate <NSObject>

-(void)onSelectDate:(NSDate *)date sender:(id)sender;
-(void)onSelectWeek:(NSInteger)weekBit sender:(id)sender;

@end

@interface MyDatePickerView : UIView

@property (nonatomic, weak) id<MyDatePickerViewDelegate> delegate;
@property (nonatomic, assign) DatePickerStyle curStyle;
@property (nonatomic, assign) DatePickerUIStyle uiStyle;
@property (nonatomic, assign) NSInteger weekBit;
@property (nonatomic, copy) MyDatePickerDismiss myDatePickerDismiss;

//显示的标题
@property (nonatomic, copy) NSString *title;
//是否是选择开始时间
@property (nonatomic, assign) BOOL ifChoseStart;
//选择时间对比的时间
@property (nonatomic, strong) NSDate *compareDate;

@property (nonatomic,copy) NSString *action;

- (void)myShowInView:(UIView *)view dismiss:(MyDatePickerDismiss)dismiss;         // 显示方法
- (void)myShowInView:(UIView *)view showDate:(NSDate *)date dismiss:(MyDatePickerDismiss)dismiss;
- (void)myDismiss;                           // 消失方法
@end
