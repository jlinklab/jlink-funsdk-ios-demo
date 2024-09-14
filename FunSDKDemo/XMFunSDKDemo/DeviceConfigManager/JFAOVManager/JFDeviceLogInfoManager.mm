//
//  JFDeviceLogInfoManager.m
//   iCSee
//
//  Created by Megatron on 2024/4/30.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import "JFDeviceLogInfoManager.h"
#import <FunSDK/FunSDK.h>
#import "NSString+Utils.h"

@interface JFDeviceLogInfoManager ()

@property (nonatomic, copy) NSString *startTime;
@property (nonatomic, copy) NSString *endTime;
///当前请求的是第几页
@property (nonatomic, assign) int page;
///当前时区偏移 分钟
@property (nonatomic, assign) int timeZoneMin;
///最终请求到的总数据
@property (nonatomic, strong) NSMutableArray *arrayFinal;

@end
@implementation JFDeviceLogInfoManager

- (void)requestDeviceLogWithDevice:(NSString *)devID startTime:(NSString *)startTime endTime:(NSString *)endTime completed:(GetBatteryInfoFromShadowServerCallBack)completion{
    [self.arrayPower removeAllObjects];
    [self.arraySignal removeAllObjects];
    [self.arrayFinal removeAllObjects];
    self.devID = devID;
    self.startTime = startTime;
    self.endTime = endTime;
    self.page = 1;
    self.getBatteryInfoFromShadowServerCallBack = completion;
    
    if (!devID || !startTime || !endTime) {
        if (self.getBatteryInfoFromShadowServerCallBack) {
            self.getBatteryInfoFromShadowServerCallBack(-1);
        }
        return;
    }
    
    //获取当前时区
    NSDate *dateNow = [NSDate date];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    BOOL isDaylightSavingTime = [timeZone isDaylightSavingTimeForDate:dateNow];
    [NSTimeZone resetSystemTimeZone]; // 重置手机系统的时区
    NSInteger offset = [NSTimeZone localTimeZone].secondsFromGMT;
    float value = offset/3600.0;
    if (isDaylightSavingTime) {
        value--;
    }
    //当前时区偏移的分钟数
    int myTime = (int)(value * 60);
    self.timeZoneMin = myTime;
    
    NSDictionary *dicReq = @{@"Url":@"/api/pub/v1/data",
                             @"ReqJson":@{@"endTime":self.endTime,
                                          @"id":self.devID,
                                          @"page":[NSNumber numberWithInt:self.page],
                                          @"size":@5000,
                                          @"startTime":self.startTime,
                                          @"subtype":[NSNull null],
                                          @"timezoneMin":[NSNumber numberWithInt:self.timeZoneMin],
                                          @"isAddLastList":@1,
                                          @"type":@"devicelog"}
                              };
    NSString *strReq = [NSString convertToJSONData:dicReq];
    
    Fun_SysGetLogs(self.msgHandle, strReq.UTF8String);
}

- (void)continueRequest{
    self.page = self.page + 1;
    NSDictionary *dicReq = @{@"Url":@"/api/pub/v1/data",
                             @"ReqJson":@{@"endTime":self.endTime,
                                          @"id":self.devID,
                                          @"page":[NSNumber numberWithInt:self.page],
                                          @"size":@5000,
                                          @"startTime":self.startTime,
                                          @"subtype":[NSNull null],
                                          @"timezoneMin":[NSNumber numberWithInt:self.timeZoneMin],
                                          @"type":@"devicelog"}
                              };
    NSString *strReq = [NSString convertToJSONData:dicReq];
    
    Fun_SysGetLogs(self.msgHandle, strReq.UTF8String);
}

///成功回调
- (void)successAction{
    NSArray *list = [[self.arrayFinal reverseObjectEnumerator] allObjects];
    
    //过滤需要的电量和信号数据
    for (int i = 0; i < list.count; i++) {
        
        NSDictionary *dic = [list objectAtIndex:i];
        NSString *logLevel = [dic objectForKey:@"logLevel"];
        NSString *serviceName = [dic objectForKey:@"serviceName"];
        NSDictionary *logInfo = [NSString dictionaryWithJsonString:[dic objectForKey:@"logInfo"]];
        if ([logLevel isEqualToString:@"INF"] && [serviceName isEqualToString:@"NSS"] && logInfo && [logInfo isKindOfClass:[NSDictionary class]]) {
            NSNumber *numberBL = [logInfo objectForKey:@"bl"];
            NSNumber *numberSS4G = [logInfo objectForKey:@"ss4g"];
            NSString *time = [dic objectForKey:@"time"];
            //不是当前时区时间的不需要转换
            if (![[dic objectForKey:@"localTime"] boolValue]) {
                time = [NSString convertUTCtoLocalTime:time];
            }
            if (numberBL) {
                NSMutableDictionary *dicFliter = [NSMutableDictionary dictionaryWithCapacity:0];
                [dicFliter setObject:numberBL forKey:@"value"];
                [dicFliter setObject:time forKey:@"time"];                
                CGFloat percentX = [self calculatePercentageBetweenStartTime:self.startTime endTime:self.endTime currentTime:time];
                [dicFliter setObject:[NSNumber numberWithFloat:percentX] forKey:@"x_percent"];
                [dicFliter setObject:[NSNumber numberWithFloat:(100-[numberBL intValue]) / 100.0] forKey:@"y_percent"];
                [self.arrayPower addObject:dicFliter];
            }
            if (numberSS4G) {
                NSMutableDictionary *dicFliter = [NSMutableDictionary dictionaryWithCapacity:0];
                [dicFliter setObject:numberSS4G forKey:@"value"];
                [dicFliter setObject:time forKey:@"time"];
                CGFloat percent = [self calculatePercentageBetweenStartTime:self.startTime endTime:self.endTime currentTime:time];
                [dicFliter setObject:[NSNumber numberWithFloat:percent] forKey:@"x_percent"];
                [dicFliter setObject:[NSNumber numberWithFloat:((3-[numberSS4G intValue]) / 3.0) > 1 ? 1 : ((3-[numberSS4G intValue]) / 3.0)] forKey:@"y_percent"];
                [self.arraySignal addObject:dicFliter];
            }
        }
    }
    
    if (self.getBatteryInfoFromShadowServerCallBack) {
        self.getBatteryInfoFromShadowServerCallBack(1);
    }
}

- (CGFloat)calculatePercentageBetweenStartTime:(NSString *)startTime endTime:(NSString *)endTime currentTime:(NSString *)currentTime {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSCalendar *calender = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:calender.locale.localeIdentifier]];
    
    NSDate *startDate = [dateFormatter dateFromString:startTime];
    NSDate *endDate = [dateFormatter dateFromString:endTime];
    NSDate *currentDate = [dateFormatter dateFromString:currentTime];
    
    // If currentTime is before startTime or after endTime, return 0 or 100 respectively
    if ([currentDate compare:startDate] == NSOrderedAscending) {
        return 0.0;
    } else if ([currentDate compare:endDate] == NSOrderedDescending) {
        return 100.0;
    }
    
    NSTimeInterval totalDuration = [endDate timeIntervalSinceDate:startDate];
    NSTimeInterval elapsedTime = [currentDate timeIntervalSinceDate:startDate];
    
    CGFloat percentage = (elapsedTime / totalDuration);
    return percentage;
}

///当前时间增加一毫秒
- (NSString *)addMillisecond:(NSString *)timeStr {
    // 创建日期格式化器
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSCalendar *calender = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:calender.locale.localeIdentifier]];
    // 将时间字符串解析为 NSDate 对象
    NSDate *date = [dateFormatter dateFromString:timeStr];
    // 创建日期组件
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    // 获取原始日期的毫秒部分
    NSInteger milliseconds = [calendar component:NSCalendarUnitNanosecond fromDate:date] / 1000000;
    // 增加 1 毫秒
    [components setNanosecond:(milliseconds - 1) * 1000000];
    // 将新的日期组件添加到日期上
    NSDate *newDate = [calendar dateByAddingComponents:components toDate:date options:0];
    // 将新的日期对象转换为时间字符串
    NSString *newTimeStr = [dateFormatter stringFromDate:newDate];
    
    return newTimeStr;
}

//MARK: - OnFunSDKResult
- (void)baseOnFunSDKResult:(MsgContent *)msg{
    switch (msg->id) {
        case EMSG_SYS_SERVICE_GET_LOGS:
        {
            if (msg->param1 < 0){
                if (self.getBatteryInfoFromShadowServerCallBack) {
                    self.getBatteryInfoFromShadowServerCallBack(msg->param1);
                }
            }else{
                if (msg->szStr == NULL) {
                    if (self.getBatteryInfoFromShadowServerCallBack) {
                        self.getBatteryInfoFromShadowServerCallBack(-1);
                    }
                    return;
                }
                NSString *jsonStr = OCSTR(msg->szStr);
                NSDictionary *dic = [NSString dictionaryWithJsonString:jsonStr];
                NSDictionary *dicData = JFSafeDictionary(dic, @"data");
                NSMutableArray *arrayList = [JFSafeDictionary(dicData, @"list") mutableCopy];
                NSMutableArray *arraylastList = [JFSafeDictionary(dicData, @"lastList") mutableCopy];

                
                if (!arrayList) {
                    if (self.getBatteryInfoFromShadowServerCallBack) {
                        self.getBatteryInfoFromShadowServerCallBack(-1);
                    }
                    return;
                }
                
                [arrayList sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
                    NSString *dateTimeString1 = [obj1 objectForKey:@"time"];
                    NSString *dateTimeString2 = [obj2 objectForKey:@"time"];
                    // 创建日期格式化对象
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
                    NSCalendar *calender = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
                    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:calender.locale.localeIdentifier]];
                    
                    // 解析日期时间字符串为 NSDate 对象
                    NSDate *date1 = [dateFormatter dateFromString:dateTimeString1];
                    NSDate *date2 = [dateFormatter dateFromString:dateTimeString2];
                    
                    // 比较两个日期时间
                    NSComparisonResult result = [date2 compare:date1];
                    
                    return  result;
                }];
                
                NSLog(@"EMSG_SYS_SERVICE_GET_LOGS page:%i %@ %@",self.page,[[arrayList firstObject] objectForKey:@"time"],[[arrayList lastObject] objectForKey:@"time"]);
                //如果获取到的数量大于等于最大限制 继续请求
                if (arrayList.count >= 5000) {
                    [self.arrayFinal addObjectsFromArray:arrayList];
                    [self continueRequest];
                }else{
                    [self.arrayFinal addObjectsFromArray:arrayList];
                    if (arraylastList.count > 0) {
                        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:[arraylastList objectAtIndex:0]];
                        NSString *beginTimeStr = @"";
                        NSString *endTimeStr = @"";
                        if (self.startTime.length > 10 && self.endTime.length > 10) {
                            beginTimeStr = [self.startTime substringToIndex:10];
                            endTimeStr = [self.endTime substringToIndex:10];
                        }
                        NSString *newTime = @"";
                        if ([beginTimeStr isEqualToString:endTimeStr]) {// 同一天的
                            NSArray *time1 = [NSDate getRecentDaysStartAndEndDateTime:1];
                            
                            newTime = [time1 objectAtIndex:0];
                        } else {
                            NSArray *time7 = [NSDate getRecentDaysStartAndEndDateTime:7];
                            newTime = [time7 objectAtIndex:0];
                        }

                        
                        [dic setObject:newTime forKey:@"time"];
                        //标记这个是当前时区的时间
                        [dic setObject:[NSNumber numberWithBool:YES] forKey:@"localTime"];
                        [self.arrayFinal addObject:dic];
    
    
                    }
                    [self successAction];
                }
            }
        }
            break;
        default:
            break;
    }
}

- (NSMutableArray *)arrayFinal{
    if (!_arrayFinal) {
        _arrayFinal = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _arrayFinal;
}

- (NSMutableArray *)arrayPower{
    if (!_arrayPower) {
        _arrayPower = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _arrayPower;
}

- (NSMutableArray *)arraySignal{
    if (!_arraySignal) {
        _arraySignal = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _arraySignal;
}

@end
