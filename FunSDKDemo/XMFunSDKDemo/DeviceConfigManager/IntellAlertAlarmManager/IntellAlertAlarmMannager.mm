//
//  IntellAlertAlarmMannager.m
//   
//
//  Created by Tony Stark on 2021/7/22.
//  Copyright © 2021 xiongmaitech. All rights reserved.
//

#import "IntellAlertAlarmMannager.h"
#import <FunSDK/FunSDK.h>

@interface IntellAlertAlarmMannager ()

@property (nonatomic,strong) NSMutableDictionary *dicCfg;

@end
@implementation IntellAlertAlarmMannager

//MARK: 获取警戒配置
- (void)getIntellAlertAlarm:(NSString *)devID channel:(int)channel completed:(GetIntellAlertAlarmCallBack)completion{
    self.devID = devID;
    self.channelNumber = channel;
    self.getIntellAlertAlarmCallBack = completion;
    
    FUN_DevGetConfig_Json(self.msgHandle, self.devID.UTF8String, "Alarm.IntellAlertAlarm", 1024,self.channelNumber);
}

//MARK: 保存警戒配置
- (void)setIntellAlertAlarmCompleted:(SetIntellAlertAlarmCallBack)completion{
    self.setIntellAlertAlarmCallBack = completion;
    
    if (!self.dicCfg || !self.cfgName) {
        [self sendSetResult:-1];
        return;
    }
    
    NSDictionary* jsonDic = @{@"Name":self.cfgName,self.cfgName:self.dicCfg};
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *pCfgBufString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    FUN_DevSetConfig_Json(self.msgHandle, self.devID.UTF8String, self.cfgName.UTF8String,[pCfgBufString UTF8String], (int)(strlen([pCfgBufString UTF8String]) + 1), self.channelNumber);
}

//MARK: 判断是否请求到配置
- (BOOL)checkRequestedCfg{
    if (self.dicCfg) {
        return YES;
    }
    
    return NO;
}

//MARK: 获取总开关状态
- (BOOL)getEnable{
    NSNumber *enable = [self.dicCfg objectForKey:@"Enable"];
    if (enable && [enable isKindOfClass:[NSNumber class]]) {
        return [enable boolValue];
    }
    
    return NO;
}

//MARK: 设置总开关状态
- (void)setEnable:(BOOL)enable{
    [self.dicCfg setObject:[NSNumber numberWithBool:enable] forKey:@"Enable"];
}

//MARK: 获取报警持续时间
- (int)getDuration{
    NSNumber *Duration = [self.dicCfg objectForKey:@"Duration"];
    if (Duration && ![Duration isKindOfClass:[NSNull class]]) {
        return [Duration intValue];
    }
    
    return 0;
}

//MARK: 设置报警持续时间
- (void)setDuration:(int)seconds{
    [self.dicCfg setObject:[NSNumber numberWithInt:seconds] forKey:@"Duration"];
}

//MARK: 获取提示音类型
- (int)getVoiceType{
    NSDictionary *dicEventHandler = [self.dicCfg objectForKey:@"EventHandler"];
    if (dicEventHandler && [dicEventHandler isKindOfClass:[NSDictionary class]]) {
        NSNumber *EventLatch = [dicEventHandler objectForKey:@"VoiceType"];
        if (EventLatch && ![EventLatch isKindOfClass:[NSNull class]]) {
            return [EventLatch intValue];
        }
    }
    
    return 0;
}

//MARK: 设置提示音类型
- (void)setVoiceType:(int)type{
    NSMutableDictionary *dicEventHandler = [[self.dicCfg objectForKey:@"EventHandler"] mutableCopy];
    if (dicEventHandler && [dicEventHandler isKindOfClass:[NSMutableDictionary class]]) {
        [dicEventHandler setObject:[NSNumber numberWithInt:type] forKey:@"VoiceType"];
        [self.dicCfg setObject:dicEventHandler forKey:@"EventHandler"];
    }
}

//MARK: 获取通道联动报警状态
- (BOOL)getRemoteEnableChannel:(int)channel{
    NSArray *RemoteEnable = [self.dicCfg objectForKey:@"RemoteEnable"];
    if (RemoteEnable && [RemoteEnable isKindOfClass:[NSArray class]]) {
        return [[RemoteEnable objectAtIndex:channel] boolValue];
    }
    
    return NO;
}

//MARK: 设置通道联动报警状态
- (void)setRemoteEnable:(BOOL)enable channel:(int)channel{
    NSMutableArray *RemoteEnable = [[self.dicCfg objectForKey:@"RemoteEnable"] mutableCopy];
    if (RemoteEnable && [RemoteEnable isKindOfClass:[NSMutableArray class]]) {
        [RemoteEnable replaceObjectAtIndex:channel withObject:[NSNumber numberWithBool:enable]];
        [self.dicCfg setObject:RemoteEnable forKey:@"RemoteEnable"];
    }
}

//MARK: 获取报警灯开关状态
- (BOOL)getAlarmOutEnable{
    NSDictionary *dicEventHandler = [self.dicCfg objectForKey:@"EventHandler"];
    if (dicEventHandler && [dicEventHandler isKindOfClass:[NSDictionary class]]) {
        NSNumber *enable = [dicEventHandler objectForKey:@"AlarmOutEnable"];
        if (enable && ![enable isKindOfClass:[NSNull class]]) {
            return [enable boolValue];
        }
    }
    
    return NO;
}

//MARK: 设置报警灯开关状态
- (void)setAlarmOutEnable:(BOOL)enable{
    NSMutableDictionary *dicEventHandler = [[self.dicCfg objectForKey:@"EventHandler"] mutableCopy];
    if (dicEventHandler && [dicEventHandler isKindOfClass:[NSMutableDictionary class]]) {
        [dicEventHandler setObject:[NSNumber numberWithBool:enable] forKey:@"AlarmOutEnable"];
        [self.dicCfg setObject:dicEventHandler forKey:@"EventHandler"];
    }
}

- (void)sendGetResult:(int)result{
    if (self.getIntellAlertAlarmCallBack) {
        self.getIntellAlertAlarmCallBack(result,self.channelNumber);
    }
}

- (void)sendSetResult:(int)result{
    if (self.setIntellAlertAlarmCallBack) {
        self.setIntellAlertAlarmCallBack(result,self.channelNumber);
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
                NSDictionary *dicCfg = [jsonDic objectForKey:self.cfgName];
                if (dicCfg && ![dicCfg isKindOfClass:[NSNull class]]) {
                    self.dicCfg = [dicCfg mutableCopy];
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
