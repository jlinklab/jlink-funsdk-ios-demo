//
//  WhiteLightManager.m
//  XWorld_General
//
//  Created by Megatron on 2019/7/1.
//  Copyright © 2019 xiongmaitech. All rights reserved.
//

#import "WhiteLightManager.h"
#import "Camera_WhiteLight.h"
#import "DeviceConfig.h"

@interface WhiteLightManager () <DeviceConfigDelegate>
{
    Camera_WhiteLight pWhiteLight;   // 白光灯控制
}

@end

@implementation WhiteLightManager

//MARK: 请求配置
- (void)getWhiteLight:(NSString *)devID channel:(int)channel completed:(WhiteLightManagerRequestBlock)completion{
    self.devID = devID;
    self.channelNumber = channel;
    self.requestAction = completion;
    
    DeviceConfig* devCfg = [[DeviceConfig alloc] initWithJObject:&pWhiteLight];
    devCfg.devId = self.devID;
    devCfg.channel = self.channelNumber;
    devCfg.isSet = NO;
    devCfg.delegate = self;
    [self requestGetConfig:devCfg];
}

//MARK: 保存配置
- (void)setWhiteLight:(WhiteLightManagerRequestBlock)action{
    self.requestAction = action;
    
    DeviceConfig *cfg = [DeviceConfig initWith:self.devID Channel:self.channelNumber GetSet:2 Resutl:&pWhiteLight Delegate:self];
    [self requestSetConfig:cfg];
}

//MARK: 设置工作模式
- (void)setWorkMode:(NSString *)wordMode{
    pWhiteLight.WorkMode.SetValue([wordMode UTF8String]);
}

//MARK: 设置移动触发开灯灵敏度
- (void)setMoveTrigLightLevel:(int)level{
    pWhiteLight.mMoveTrigLight.Level = level;
}
//MARK: 设置灯光亮度
- (void)setBrightness:(int)value {
    pWhiteLight.Brightness = value;
}
//MARK: 设置移动触发持续亮灯时间
- (void)setMoveTrigLightDuration:(int)duration{
    pWhiteLight.mMoveTrigLight.Duration = duration;
}

//MARK: 设置定时开灯时间
- (void)setLightOpenTime:(NSString *)time{
    NSArray *array = [time componentsSeparatedByString:@":"];
    if (array.count == 2) {
        int hour = [[array objectAtIndex:0] intValue];
        int minute = [[array objectAtIndex:1] intValue];
        
        pWhiteLight.mWorkPeriod.SHour = hour;
        pWhiteLight.mWorkPeriod.SMinute = minute;
    }
}

//MARK: 设置定时关灯时间
- (void)setLightCloseTime:(NSString *)time{
    NSArray *array = [time componentsSeparatedByString:@":"];
    if (array.count == 2) {
        int hour = [[array objectAtIndex:0] intValue];
        int minute = [[array objectAtIndex:1] intValue];
        
        pWhiteLight.mWorkPeriod.EHour = hour;
        pWhiteLight.mWorkPeriod.EMinute = minute;
    }
}


//MARK: 获取工作模式
- (NSString *)getWordMode{
    return [NSString stringWithUTF8String:pWhiteLight.WorkMode.Value()];
}

//MARK: 获取移动触发开灯灵敏度
- (int)getMoveTrigLightLevel{
    return pWhiteLight.mMoveTrigLight.Level.Value();
}

//MARK: 获取移动触发持续亮灯时间
- (int)getMoveTrigLightDuration{
    return pWhiteLight.mMoveTrigLight.Duration.Value();
}
//MARK: 获取灯光亮度
- (int)getBrightness {
    return pWhiteLight.Brightness.Value();
}
//MARK: 获取定时灯开关
- (BOOL)getLightOpenEnable {
    BOOL isON = pWhiteLight.mWorkPeriod.Enable.ToBool();
    return isON;
}
//MARK: 设置定时灯开关
- (void)setLightOpenEnable:(BOOL)isON {
    pWhiteLight.mWorkPeriod.Enable = isON;
    
}
//MARK: 获取定时开灯时间
- (NSString *)getLightOpenTime{
    int hour = pWhiteLight.mWorkPeriod.SHour.Value();
    int minute = pWhiteLight.mWorkPeriod.SMinute.Value();
    
    return [NSString stringWithFormat:@"%02d:%02d", hour, minute];
}

//MARK: 获取定时关灯时间
- (NSString *)getLightCloseTime{
    int hour = pWhiteLight.mWorkPeriod.EHour.Value();
    int minute = pWhiteLight.mWorkPeriod.EMinute.Value();
    
    return [NSString stringWithFormat:@"%02d:%02d", hour, minute];
}

//MARK: 回调
- (void)getConfig:(DeviceConfig *)config result:(int)result{
    if (self.requestAction) {
        self.requestAction(WhiteLightManagerRequestTypeGet, result,self.channelNumber);
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(getWhiteLightConfigResult:)]) {
        [self.delegate getWhiteLightConfigResult:result];
    }
}

- (void)setConfig:(DeviceConfig *)config result:(int)result{
    if (self.requestAction) {
        self.requestAction(WhiteLightManagerRequestTypeSet, result,self.channelNumber);
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(setWhiteLightConfigResult:)]) {
        [self.delegate setWhiteLightConfigResult:result];
    }
}

@end
