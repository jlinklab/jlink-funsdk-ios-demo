//
//  PirAlarmManager.m
//   
//
//  Created by Tony Stark on 2021/7/30.
//  Copyright © 2021 xiongmaitech. All rights reserved.
//

#import "PirAlarmManager.h"
#import <FunSDK/FunSDK.h>

@interface PirAlarmManager ()

@property (nonatomic,strong) NSMutableArray *arrayCfg;

@end
@implementation PirAlarmManager

//MARK: 获取体感应报警配置
- (void)getPirAlarm:(NSString *)devID channel:(int)channel completed:(GetPirAlarmResult)completion{
    self.devID = devID;
    self.channelNumber = channel;
    self.getPirAlarmResult = completion;
    
    FUN_DevGetConfig_Json(self.msgHandle, self.devID.UTF8String, "Alarm.PIR", 1024,self.channelNumber);
}

//MARK: 保存体感应报警配置
- (void)setPirAlarmCompleted:(SetPirAlarmResult)completion{
    self.setPirAlarmResult = completion;
    
    if (!self.arrayCfg || !self.cfgName) {
        [self sendSetResult:-1];
        return;
    }
    
    NSDictionary* jsonDic = @{@"Name":self.cfgName,self.cfgName:self.arrayCfg};
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *pCfgBufString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    FUN_DevSetConfig_Json(self.msgHandle, self.devID.UTF8String, self.cfgName.UTF8String,[pCfgBufString UTF8String], (int)(strlen([pCfgBufString UTF8String]) + 1), self.channelNumber);
}





//MARK: - EventAction
//MARK: 获取人体感应报警开关
- (BOOL)getEnable{
    NSDictionary *dicAlarm = [self.arrayCfg objectAtIndex:0];
    if (dicAlarm && [dicAlarm isKindOfClass:[NSDictionary class]]) {
        return [[dicAlarm objectForKey:@"Enable"] boolValue];
    }
    
    return NO;
}
//MARK: 设置灵敏度报警开关
- (void)setEnable:(BOOL)enable{
    NSMutableDictionary *dicAlarm = [[self.arrayCfg objectAtIndex:0] mutableCopy];
    if (dicAlarm && [dicAlarm isKindOfClass:[NSDictionary class]]) {
        [dicAlarm setObject:[NSNumber numberWithBool:enable] forKey:@"Enable"];
        [self.arrayCfg replaceObjectAtIndex:0 withObject:dicAlarm];
    }
}







//MARK: 获取灵敏度报警开关
- (int)getPirSensitive{
    NSDictionary *dicAlarm = [self.arrayCfg objectAtIndex:0];
    if (dicAlarm && [dicAlarm isKindOfClass:[NSDictionary class]]) {
        return [[dicAlarm objectForKey:@"PirSensitive"] intValue];
    }
    
    return -1;
}

//MARK: 设置人体感应报警开关
- (void)setPirSensitive:(int)sensitive{
    NSMutableDictionary *dicAlarm = [[self.arrayCfg objectAtIndex:0] mutableCopy];
    if (dicAlarm && [dicAlarm isKindOfClass:[NSDictionary class]]) {
        [dicAlarm setObject:[NSNumber numberWithInt:sensitive] forKey:@"PirSensitive"];
        [self.arrayCfg replaceObjectAtIndex:0 withObject:dicAlarm];
    }
}


//MARK: 获取徘徊检测时间
- (CGFloat)getPIRCheckTime{
    NSDictionary *dicAlarm = [self.arrayCfg objectAtIndex:0];
    if (dicAlarm && [dicAlarm isKindOfClass:[NSDictionary class]]) {
        return [[dicAlarm objectForKey:@"PIRCheckTime"] floatValue];
    }
    
    return -1;
}

//MARK: 设置徘徊检测时间
- (void)setPIRCheckTime:(CGFloat)PIRCheckTime{
    NSMutableDictionary *dicAlarm = [[self.arrayCfg objectAtIndex:0] mutableCopy];
    if (dicAlarm && [dicAlarm isKindOfClass:[NSDictionary class]]) {
        [dicAlarm setObject:[NSNumber numberWithFloat:PIRCheckTime] forKey:@"PIRCheckTime"];
        [self.arrayCfg replaceObjectAtIndex:0 withObject:dicAlarm];
    }
}

//MARK:获取报警类型：1.PIR报警 2.微波报警 3.灵敏度触发 4.精准触发
- (int)getPIRAlarmType{
    int alarmType = 0;
    NSDictionary *dicAlarm = [self.arrayCfg objectAtIndex:0];
    if (dicAlarm && [dicAlarm isKindOfClass:[NSDictionary class]]) {
        alarmType = [[dicAlarm objectForKey:@"AlarmType"] intValue];
    }
    return alarmType;
}

//MARK:设置报警类型
- (void)setPIRAlarmType:(int)type{
    NSMutableDictionary *dicAlarm = [[self.arrayCfg objectAtIndex:0] mutableCopy];;
    if (dicAlarm && [dicAlarm isKindOfClass:[NSDictionary class]]) {
        [dicAlarm setObject:[NSNumber numberWithInt:type] forKey:@"AlarmType"];
    }
    
    if (dicAlarm) {
        [self.arrayCfg replaceObjectAtIndex:0 withObject:dicAlarm];
    }
}

#pragma mark -- 徘徊检测录像时长
-(int)getRecordLatch{
    int RecordLatchValue = 0;
    NSDictionary *dicAlarm = [self.arrayCfg objectAtIndex:0];
    if (dicAlarm && [dicAlarm isKindOfClass:[NSDictionary class]]) {
        NSDictionary *eventDic = [dicAlarm objectForKey:@"EventHandler"];
        RecordLatchValue = [[eventDic objectForKey:@"RecordLatch"] intValue];
    }
    return RecordLatchValue;
}

-(void)setRecordLatch:(int)latch{
    NSMutableDictionary *dicAlarm = [[self.arrayCfg objectAtIndex:0] mutableCopy];
    if (dicAlarm && [dicAlarm isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *eventDic = [[dicAlarm objectForKey:@"EventHandler"] mutableCopy];
        [eventDic setObject:[NSNumber numberWithInt:latch] forKey:@"RecordLatch"];
        [dicAlarm setObject:eventDic forKey:@"EventHandler"];
        [self.arrayCfg replaceObjectAtIndex:0 withObject:dicAlarm];
    }
}



#pragma mark -- 侦测时间段信息
//是否打开报警时间段
-(BOOL)getPirTimeSection:(NSInteger)sectionNum {
    if (sectionNum == 0) {
        BOOL pirTimeSection = NO;
        NSDictionary *dicAlarm = [self.arrayCfg objectAtIndex:0];
        if (dicAlarm && [dicAlarm isKindOfClass:[NSDictionary class]]) {
            NSDictionary *eventDic = [dicAlarm objectForKey:@"PirTimeSection"];
            NSDictionary *dicPirTimeSectionOne = [eventDic objectForKey:@"PirTimeSectionOne"];
            pirTimeSection = [[dicPirTimeSectionOne objectForKey:@"Enable"] boolValue];
            
        }
        return pirTimeSection;
    } else if (sectionNum == 1) {
        BOOL pirTimeSection = NO;
        NSDictionary *dicAlarm = [self.arrayCfg objectAtIndex:0];
        if (dicAlarm && [dicAlarm isKindOfClass:[NSDictionary class]]) {
            NSDictionary *eventDic = [dicAlarm objectForKey:@"PirTimeSection"];
            NSDictionary *dicPirTimeSectionTwo = [eventDic objectForKey:@"PirTimeSectionTwo"];
            pirTimeSection = [[dicPirTimeSectionTwo objectForKey:@"Enable"] boolValue];
            
        }
        return pirTimeSection;
    }
    return NO;
}

-(void)setPirTimeSection:(BOOL)open sectionNum:(NSInteger)sectionNum {
    if (sectionNum == 0) {
        NSMutableDictionary *dicAlarm = [[self.arrayCfg objectAtIndex:0] mutableCopy];
        if (dicAlarm && [dicAlarm isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *eventDic = [[dicAlarm objectForKey:@"PirTimeSection"] mutableCopy];
            NSMutableDictionary *dicPirTimeSectionOne = [[eventDic objectForKey:@"PirTimeSectionOne"] mutableCopy];
            [dicPirTimeSectionOne setObject:[NSNumber numberWithBool:open] forKey:@"Enable"];
            [eventDic setObject:dicPirTimeSectionOne forKey:@"PirTimeSectionOne"];
            [dicAlarm setObject:eventDic forKey:@"PirTimeSection"];
            [self.arrayCfg replaceObjectAtIndex:0 withObject:dicAlarm];
        }
    } else if (sectionNum == 1) {
        NSMutableDictionary *dicAlarm = [[self.arrayCfg objectAtIndex:0] mutableCopy];
        if (dicAlarm && [dicAlarm isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *eventDic = [[dicAlarm objectForKey:@"PirTimeSection"] mutableCopy];
            NSMutableDictionary *dicPirTimeSectionTwo = [[eventDic objectForKey:@"PirTimeSectionTwo"] mutableCopy];
            [dicPirTimeSectionTwo setObject:[NSNumber numberWithBool:open] forKey:@"Enable"];
            [eventDic setObject:dicPirTimeSectionTwo forKey:@"PirTimeSectionTwo"];
            [dicAlarm setObject:eventDic forKey:@"PirTimeSection"];
            [self.arrayCfg replaceObjectAtIndex:0 withObject:dicAlarm];
        }
    }
    
}

//报警结束时间和开始时间
-(NSString *)getPirTimeSectionStartTime:(NSInteger)sectionNum {
    if (sectionNum == 0) {
        NSString *startTime = @"";
        
            NSDictionary *dicAlarm = [self.arrayCfg objectAtIndex:0];
            if (dicAlarm && [dicAlarm isKindOfClass:[NSDictionary class]]) {
                NSDictionary *eventDic = [dicAlarm objectForKey:@"PirTimeSection"];
                NSDictionary *dicPirTimeSectionOne = [eventDic objectForKey:@"PirTimeSectionOne"];
                startTime = [dicPirTimeSectionOne objectForKey:@"StartTime"];
            }
         
        return startTime;
    } else if (sectionNum == 1) {
        NSString *startTime = @"";
         
            NSDictionary *dicAlarm = [self.arrayCfg objectAtIndex:0];
            if (dicAlarm && [dicAlarm isKindOfClass:[NSDictionary class]]) {
                NSDictionary *eventDic = [dicAlarm objectForKey:@"PirTimeSection"];
                NSDictionary *dicPirTimeSectionTwo = [eventDic objectForKey:@"PirTimeSectionTwo"];
                startTime = [dicPirTimeSectionTwo objectForKey:@"StartTime"];
            }
         
        return startTime;
    }
    return @"";
}

-(void)setPirTimeSectionStartTime:(NSString *)startTime sectionNum:(NSInteger)sectionNum {
    if (sectionNum == 0) {
        NSMutableDictionary *dicAlarm = [[self.arrayCfg objectAtIndex:0] mutableCopy];
        if (dicAlarm && [dicAlarm isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *eventDic = [[dicAlarm objectForKey:@"PirTimeSection"] mutableCopy];
            NSMutableDictionary *dicPirTimeSectionOne = [[eventDic objectForKey:@"PirTimeSectionOne"] mutableCopy];
            [dicPirTimeSectionOne setObject:startTime forKey:@"StartTime"];
            [eventDic setObject:dicPirTimeSectionOne forKey:@"PirTimeSectionOne"];
            [dicAlarm setObject:eventDic forKey:@"PirTimeSection"];
            [self.arrayCfg replaceObjectAtIndex:0 withObject:dicAlarm];
            
        }
    } else if (sectionNum == 1) {
        NSMutableDictionary *dicAlarm = [[self.arrayCfg objectAtIndex:0] mutableCopy];
        if (dicAlarm && [dicAlarm isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *eventDic = [[dicAlarm objectForKey:@"PirTimeSection"] mutableCopy];
            NSMutableDictionary *dicPirTimeSectionTwo = [[eventDic objectForKey:@"PirTimeSectionTwo"] mutableCopy];
            [dicPirTimeSectionTwo setObject:startTime forKey:@"StartTime"];
            [eventDic setObject:dicPirTimeSectionTwo forKey:@"PirTimeSectionTwo"];
            [dicAlarm setObject:eventDic forKey:@"PirTimeSection"];
            [self.arrayCfg replaceObjectAtIndex:0 withObject:dicAlarm];
            
        }
    }
}
-(NSString *)getPirTimeSectionEndTime:(NSInteger)sectionNum {
    if (sectionNum == 0) {
        NSString *endTime = @"";
         
            NSDictionary *dicAlarm = [self.arrayCfg objectAtIndex:0];
            if (dicAlarm && [dicAlarm isKindOfClass:[NSDictionary class]]) {
                NSDictionary *eventDic = [dicAlarm objectForKey:@"PirTimeSection"];
                NSDictionary *dicPirTimeSectionOne = [eventDic objectForKey:@"PirTimeSectionOne"];
                endTime = [dicPirTimeSectionOne objectForKey:@"EndTime"];
            }
        
        return endTime;
    } else if (sectionNum == 1) {
        NSString *endTime = @"";
        
            NSDictionary *dicAlarm = [self.arrayCfg objectAtIndex:0];
            if (dicAlarm && [dicAlarm isKindOfClass:[NSDictionary class]]) {
                NSDictionary *eventDic = [dicAlarm objectForKey:@"PirTimeSection"];
                NSDictionary *dicPirTimeSectionTwo = [eventDic objectForKey:@"PirTimeSectionTwo"];
                endTime = [dicPirTimeSectionTwo objectForKey:@"EndTime"];
            }
       
        return endTime;
    }
    return @"";
}

-(void)setPirTimeSectionEndTime:(NSString *)endTime sectionNum:(NSInteger)sectionNum {
    if (sectionNum == 0) {
        NSMutableDictionary *dicAlarm = [[self.arrayCfg objectAtIndex:0] mutableCopy];
        if (dicAlarm && [dicAlarm isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *eventDic = [[dicAlarm objectForKey:@"PirTimeSection"] mutableCopy];
            NSMutableDictionary *dicPirTimeSectionOne = [[eventDic objectForKey:@"PirTimeSectionOne"] mutableCopy];
            [dicPirTimeSectionOne setObject:endTime forKey:@"EndTime"];
            [eventDic setObject:dicPirTimeSectionOne forKey:@"PirTimeSectionOne"];
            [dicAlarm setObject:eventDic forKey:@"PirTimeSection"];
            [self.arrayCfg replaceObjectAtIndex:0 withObject:dicAlarm];
            
        }
    } else if (sectionNum == 1) {
        NSMutableDictionary *dicAlarm = [[self.arrayCfg objectAtIndex:0] mutableCopy];
        if (dicAlarm && [dicAlarm isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *eventDic = [[dicAlarm objectForKey:@"PirTimeSection"] mutableCopy];
            NSMutableDictionary *dicPirTimeSectionTwo = [[eventDic objectForKey:@"PirTimeSectionTwo"] mutableCopy];
            [dicPirTimeSectionTwo setObject:endTime forKey:@"EndTime"];
            [eventDic setObject:dicPirTimeSectionTwo forKey:@"PirTimeSectionTwo"];
            [dicAlarm setObject:eventDic forKey:@"PirTimeSection"];
            [self.arrayCfg replaceObjectAtIndex:0 withObject:dicAlarm];
            
        }
    }
}

//报警周期(按星期算)
-(int)getPirTimeSectionWeekMask:(NSInteger)sectionNum {
    if (sectionNum == 0) {
        int weekMask = -1;
        
            NSDictionary *dicAlarm = [self.arrayCfg objectAtIndex:0];
            if (dicAlarm && [dicAlarm isKindOfClass:[NSDictionary class]]) {
                NSDictionary *eventDic = [dicAlarm objectForKey:@"PirTimeSection"];
                NSDictionary *dicPirTimeSectionOne = [eventDic objectForKey:@"PirTimeSectionOne"];
                weekMask = [[dicPirTimeSectionOne objectForKey:@"WeekMask"] intValue];
            }
        
        return weekMask;
    } else if (sectionNum == 1) {
        int weekMask = -1;
         
            NSDictionary *dicAlarm = [self.arrayCfg objectAtIndex:0];
            if (dicAlarm && [dicAlarm isKindOfClass:[NSDictionary class]]) {
                NSDictionary *eventDic = [dicAlarm objectForKey:@"PirTimeSection"];
                NSDictionary *dicPirTimeSectionTwo = [eventDic objectForKey:@"PirTimeSectionTwo"];
                weekMask = [[dicPirTimeSectionTwo objectForKey:@"WeekMask"] intValue];
            }
        
        return weekMask;
    }
    return -1;
}

-(void)setPirTimeSectionWeekMask:(int)weekMask sectionNum:(NSInteger)sectionNum {
    if (sectionNum == 0) {
        NSMutableDictionary *dicAlarm = [[self.arrayCfg objectAtIndex:0] mutableCopy];
        if (dicAlarm && [dicAlarm isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *eventDic = [[dicAlarm objectForKey:@"PirTimeSection"] mutableCopy];
            NSMutableDictionary *dicPirTimeSectionOne = [[eventDic objectForKey:@"PirTimeSectionOne"] mutableCopy];
            [dicPirTimeSectionOne setObject:[NSNumber numberWithInt:weekMask] forKey:@"WeekMask"];
            [eventDic setObject:dicPirTimeSectionOne forKey:@"PirTimeSectionOne"];
            [dicAlarm setObject:eventDic forKey:@"PirTimeSection"];
            [self.arrayCfg replaceObjectAtIndex:0 withObject:dicAlarm];
        }
    } else if (sectionNum == 1) {
        NSMutableDictionary *dicAlarm = [[self.arrayCfg objectAtIndex:0] mutableCopy];
        if (dicAlarm && [dicAlarm isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *eventDic = [[dicAlarm objectForKey:@"PirTimeSection"] mutableCopy];
            NSMutableDictionary *dicPirTimeSectionTwo = [[eventDic objectForKey:@"PirTimeSectionTwo"] mutableCopy];
            [dicPirTimeSectionTwo setObject:[NSNumber numberWithInt:weekMask] forKey:@"WeekMask"];
            [eventDic setObject:dicPirTimeSectionTwo forKey:@"PirTimeSectionTwo"];
            [dicAlarm setObject:eventDic forKey:@"PirTimeSection"];
            [self.arrayCfg replaceObjectAtIndex:0 withObject:dicAlarm];
        }
    }
}


#pragma mark -- 获取数据源和保存数据源回调
- (void)sendGetResult:(int)result{
    if (self.getPirAlarmResult) {
        self.getPirAlarmResult(result,self.channelNumber);
    }
}

- (void)sendSetResult:(int)result{
    if (self.setPirAlarmResult) {
        self.setPirAlarmResult(result,self.channelNumber);
    }
}

//MARK: SDKCallBack
- (void)baseOnFunSDKResult:(MsgContent *)msg{
    switch (msg->id) {
        case EMSG_DEV_GET_CONFIG_JSON:
        {
            if (msg->param1 >= 0) {
                if (msg->pObject == NULL) {
                    [self sendGetResult:-1];
                    return;
                }
                NSData *jsonData = [NSData dataWithBytes:msg->pObject length:strlen(msg->pObject)];
                NSError *error;
                NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
                if(error){
                    [self sendGetResult:-1];
                    return;
                }
                
                self.cfgName = OCSTR(msg->szStr);
                if (self.channelNumber >= 0) {
                    self.cfgName = [NSString stringWithFormat:@"%@.[%i]",self.cfgName,self.channelNumber];
                }
                NSArray *arrayCfg = [jsonDic objectForKey:self.cfgName];
                if (arrayCfg && ![arrayCfg isKindOfClass:[NSNull class]]) {
                    self.arrayCfg = [arrayCfg mutableCopy];
                    [self sendGetResult:msg->param1];
                }else{
                    [self sendGetResult:-1];
                }
            }else{
                [self sendGetResult:msg->param1];
            }
        }
            break;
        case EMSG_DEV_SET_CONFIG_JSON:
        {
            [self sendSetResult:msg->param1];
        }
            break;
        default:
            break;
    }
}

@end
