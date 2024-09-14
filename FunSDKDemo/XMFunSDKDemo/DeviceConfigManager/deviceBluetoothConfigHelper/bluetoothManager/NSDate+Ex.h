//
//  NSDate+Ex.h
//  XWorld
//
//  Created by liuguifang on 16/6/25.
//  Copyright © 2016年 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Ex)

- (NSString *)xm_string;

-(NSString*)dateString;

-(NSString*)timeString;

-(NSString*)dateTimeString;

-(NSDateComponents*)currentCompent;

+(NSDate*)dateWithDateString:(NSString*)dateStr;

+(NSDate*)dateWithTimeString:(NSString*)timeStr;

+(NSDate*)dateWithDateTimeString:(NSString*)dateTimeStr;
+ (NSString *)dateTimeStringWithDate:(NSDate *)date;
+ (NSString *)timeStringWithDate:(NSDate *)date;

///@brief 获取距离今天x天的开始时间和结束时间 精确到毫秒
///@param 如果days传1，返回 @[@"2024-05-08 00:00:00.000",@"2024-05-08 23:59:59.999"]; 注意days要大于0
+ (NSArray<NSString *> *)getRecentDaysStartAndEndDateTime:(NSInteger)days;
///@brief 获取距离今天x天的开始时间和结束时间 精确到秒
///@param 如果days传1，返回 @[@"2024-05-08 00:00:00",@"2024-05-08 23:59:59"]; 注意days要大于0
+ (NSArray<NSString *> *)getRecentDaysStartAndEndDateTimeAccurateToSecond:(NSInteger)days;
//以当前时间作为起始时间，获取近七天时间
+ (NSArray *)getPastSevenDays;
@end
