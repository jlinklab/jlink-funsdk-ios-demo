//
//  NSDate+Ex.m
//  XWorld
//
//  Created by liuguifang on 16/6/25.
//  Copyright © 2016年 xiongmaitech. All rights reserved.
//

#import "NSDate+Ex.h"
#import "NSString+Utils.h"

@implementation NSDate (Ex)

- (NSString *)xm_string{
    return [self dateTimeString];
}

- (NSString*)dateString{
    // 不同地区日历 都转化为标准日历输出
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setCalendar:gregorian];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSCalendar *calender = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    [dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:calender.locale.localeIdentifier]];
    return [dateFormat stringFromDate:self];
}

-(NSString*)timeString{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateFormatter* timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setCalendar:gregorian];
    [timeFormat setDateFormat:@"HH:mm:ss"];
    NSCalendar *calender = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    [timeFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:calender.locale.localeIdentifier]];
    return [timeFormat stringFromDate:self];
}

-(NSString*)dateTimeString{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setCalendar:gregorian];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSCalendar *calender = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    [dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:calender.locale.localeIdentifier]];
    return [dateFormat stringFromDate:self];
}

-(NSDateComponents*)currentCompent{
    return [NSString toComponents:[self dateTimeString]];
}

+(NSDate*)dateWithDateString:(NSString*)dateStr{
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSCalendar *calender = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    [dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:calender.locale.localeIdentifier]];
    return [dateFormat dateFromString:dateStr];
}

+(NSDate*)dateWithTimeString:(NSString*)timeStr{
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"HH:mm:ss"];
    NSCalendar *calender = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    [formater setLocale:[[NSLocale alloc] initWithLocaleIdentifier:calender.locale.localeIdentifier]];
    return [formater dateFromString:timeStr];
}

+(NSDate*)dateWithDateTimeString:(NSString*)dateTimeStr{
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSCalendar *calender = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    [dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:calender.locale.localeIdentifier]];
    return [dateFormat dateFromString:dateTimeStr];
}

+ (NSString *)timeStringWithDate:(NSDate *)date{
    if (!date){
        return @"";
    }
    // 不同地区日历 都转化为标准日历输出
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond  fromDate:date];
    NSInteger h = [components hour];
    NSInteger m = [components minute];
    NSInteger s = [components second];
    NSString *formattedDate = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)h, (long)m, (long)s];
    return formattedDate;
}

+ (NSString *)dateTimeStringWithDate:(NSDate *)date{
    if (!date){
        return @"";
    }
    // 不同地区日历 都转化为标准日历输出
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond  fromDate:date];
    NSInteger year = [components year];
    NSInteger month = [components month];
    NSInteger day = [components day];
    NSInteger h = [components hour];
    NSInteger m = [components minute];
    NSInteger s = [components second];
    NSString *formattedDate = [NSString stringWithFormat:@"%04ld-%02ld-%02ld %02ld:%02ld:%02ld", (long)year, (long)month, (long)day, (long)h, (long)m, (long)s];
    return formattedDate;
}


///@brief 获取距离今天x天的开始时间和结束时间 精确到毫秒
///@param 如果days传1，返回 @[@"2024-05-08 00:00:00.000",@"2024-05-08 23:59:59.999"]; 注意days要大于0
+ (NSArray<NSString *> *)getRecentDaysStartAndEndDateTime:(NSInteger)days {
    // 获取当前日期
    NSDate *currentDate = [NSDate date];
    
    // 创建一个日期格式化对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSCalendar *calender = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:calender.locale.localeIdentifier]];
    
    // 格式化日期，以获取当天日期字符串
    NSString *currentDateString = [dateFormatter stringFromDate:currentDate];
    
    // 计算开始时间和结束时间的日期
    NSDate *startDate = [currentDate dateByAddingTimeInterval:-86400 * (days - 1)]; // 86400 秒 = 1 天
    NSString *startDateString = [dateFormatter stringFromDate:startDate];
    
    // 获取最近 x 天的开始时间和结束时间的字符串
    NSString *startDateTimeString = [NSString stringWithFormat:@"%@ 00:00:00.000", startDateString];
    NSString *endDateTimeString = [NSString stringWithFormat:@"%@ 23:59:59.999", currentDateString];
    
    return @[startDateTimeString, endDateTimeString];
}

///@brief 获取距离今天x天的开始时间和结束时间 精确到秒
///@param 如果days传1，返回 @[@"2024-05-08 00:00:00",@"2024-05-08 23:59:59"]; 注意days要大于0
+ (NSArray<NSString *> *)getRecentDaysStartAndEndDateTimeAccurateToSecond:(NSInteger)days{
    // 获取当前日期
    NSDate *currentDate = [NSDate date];
    
    // 创建一个日期格式化对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSCalendar *calender = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:calender.locale.localeIdentifier]];
    
    // 格式化日期，以获取当天日期字符串
    NSString *currentDateString = [dateFormatter stringFromDate:currentDate];
    
    // 计算开始时间和结束时间的日期
    NSDate *startDate = [currentDate dateByAddingTimeInterval:-86400 * (days - 1)]; // 86400 秒 = 1 天
    NSString *startDateString = [dateFormatter stringFromDate:startDate];
    
    // 获取最近 x 天的开始时间和结束时间的字符串
    NSString *startDateTimeString = [NSString stringWithFormat:@"%@ 00:00:00", startDateString];
    NSString *endDateTimeString = [NSString stringWithFormat:@"%@ 23:59:59", currentDateString];
    
    return @[startDateTimeString, endDateTimeString];
}

+ (NSArray *)getPastSevenDays {
    NSMutableArray *dateArray = [NSMutableArray array];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *currentDate = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"M.d"];
    NSCalendar *calender = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:calender.locale.localeIdentifier]];
    for (NSInteger i = 0; i < 7; i++) {
        NSDate *previousDate = [calendar dateByAddingUnit:NSCalendarUnitDay
                                                    value:-i
                                                   toDate:currentDate
                                                  options:0];
        NSString *formattedDate = [dateFormatter stringFromDate:previousDate];
        [dateArray addObject:formattedDate];
    }
    NSArray *result = [NSArray arrayWithArray: [[dateArray reverseObjectEnumerator] allObjects]];
    return result;
}


@end
