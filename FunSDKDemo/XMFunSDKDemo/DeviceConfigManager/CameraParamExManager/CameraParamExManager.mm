//
//  CameraParamExManager.m
//   iCSee
//
//  Created by Megatron on 2023/4/8.
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import "CameraParamExManager.h"
#import <FunSDK/FunSDK.h>
#import "NSString+Utils.h"
#import "NSDictionary+Extension.h"

@interface CameraParamExManager ()

@property (nonatomic,assign) int msgHandle;
@property (nonatomic,copy) NSString *devID;
@property (nonatomic,assign) int channel;
@property (nonatomic,strong) NSMutableArray *arrayCfg;
@property (nonatomic,strong) NSMutableDictionary *dicCfg;
@property (nonatomic,copy) NSString *lastCfgName;

@end
@implementation CameraParamExManager

- (instancetype)init{
    self = [super init];
    if (self) {
        self.msgHandle = FUN_RegWnd((__bridge LP_WND_OBJ)self);
    }
    
    return self;
}

- (void)dealloc{
    FUN_UnRegWnd(self.msgHandle);
    self.msgHandle = -1;
}

//MARK: 获取摄像机参数配置
- (void)requestCameraParamEx:(NSString *)devID channel:(int)channel completed:(GetCameraParamExCallBack)completion{
    self.devID = devID;
    self.channel = channel;
    self.getCameraParamExCallBack = completion;
    
    NSString *cfgName = @"Camera.ParamEx";
    if (self.channel >= 0) {
        cfgName = [NSString stringWithFormat:@"Camera.ParamEx.[%i]",self.channel];
    }
    self.lastCfgName = cfgName;
    NSDictionary *dic = @{@"Name":cfgName,@"SessionID":@"0x0000000001"};
    NSString *str = [NSString convertToJSONData:dic];
    int size = [NSString getCharArraySize:str];
    char cfg[size];
    memcpy(cfg, [str cStringUsingEncoding:NSUTF8StringEncoding], 2*[str length]);
    
    FUN_DevCmdGeneral(self.msgHandle, self.devID.UTF8String, 1042, cfgName.UTF8String, -1, 15000, cfg, (int)strlen(cfg) + 1, -1, 1042);
}

- (int)autoGain{
    NSDictionary *dic = [self.arrayCfg objectAtIndex:0];
    if (!dic) {
        dic = self.dicCfg;
    }
    NSDictionary *dicBoardTrends = [dic objectForKey:@"BroadTrends"];
    if ([dicBoardTrends objectForKey:@"AutoGain"]) {
        return [[dicBoardTrends objectForKey:@"AutoGain"] intValue];
    }
    
    return 0;
}

- (void)setAutoGain:(int)state{
    NSMutableDictionary *dic = [[self.arrayCfg objectAtIndex:0] mutableCopy];
    if (!dic) {
        dic = self.dicCfg;
    }
    NSMutableDictionary *dicBoardTrends = [[dic objectForKey:@"BroadTrends"] mutableCopy];
    [dicBoardTrends setObject:[NSNumber numberWithInt:state] forKey:@"AutoGain"];
    [dic setObject:dicBoardTrends forKey:@"BroadTrends"];
    [self.arrayCfg replaceObjectAtIndex:0 withObject:dic];
}

- (NSString *)getStyle{
    NSDictionary *dic = [self.arrayCfg objectAtIndex:0];
    if (!dic) {
        dic = self.dicCfg;
    }
    NSString *type = [dic objectForKey:@"Style"];
    return type;
}

- (void)setStyle:(NSString *)type{
    NSMutableDictionary *dic = [[self.arrayCfg objectAtIndex:0] mutableCopy];
    if (!dic) {
        dic = self.dicCfg;
    }
    [dic setObject:type forKey:@"Style"];
    [self.arrayCfg replaceObjectAtIndex:0 withObject:dic];
}
///白光灯自动模式下自动开关判断阈值(软光敏)
- (int)getSoftLedThr {
    NSDictionary *dic = JFSafeArray(self.arrayCfg, 0);
    if (!dic) {
        dic = self.dicCfg;
    }
    NSNumber *SoftLedThr = JFSafeDictionary(dic, @"SoftLedThr");
    return [SoftLedThr intValue];
}
- (void)setSoftLedThr:(int)softLedThr {
    NSMutableDictionary *dic = [JFSafeArray(self.arrayCfg, 0) mutableCopy];
    if (!dic) {
        dic = self.dicCfg;
    }
    [dic setObject:[NSNumber numberWithInt:(int)softLedThr] forKey:@"SoftLedThr"];
    [self.arrayCfg replaceObjectAtIndex:0 withObject:dic];
}

///是否打开夜视增强功能
- (int)getNightEnhance {
    NSDictionary *dic = JFSafeArray(self.arrayCfg, 0);
    if (!dic) {
        dic = self.dicCfg;
    }
    NSNumber *SoftLedThr = JFSafeDictionary(dic, @"NightEnhance");
    return [SoftLedThr intValue];
}
- (void)setNightEnhance:(int)softLedThr {
    NSMutableDictionary *dic = [JFSafeArray(self.arrayCfg, 0) mutableCopy];
    if (!dic) {
        dic = self.dicCfg;
    }
    [dic setObject:[NSNumber numberWithInt:(int)softLedThr] forKey:@"NightEnhance"];
    [self.arrayCfg replaceObjectAtIndex:0 withObject:dic];
}



/// 获取当前的日夜切换方式
- (JFDayNightSwitchMode)dayNightSwitchMode{
    JFDayNightSwitchMode mode = JFDayNightNone;
    NSDictionary *dic = JFSafeArray(self.arrayCfg, 0);
    if (!dic) {
        dic = self.dicCfg;
    }
    NSDictionary *dicMode = JFSafeDictionary(dic, @"DayNightSwitch");
    NSNumber *modeNumber = JFSafeDictionary(dicMode, @"SwitchMode");
    if (modeNumber) {
        mode = (JFDayNightSwitchMode)[modeNumber intValue];
    }
    
    return mode;
}

/// 设置当前的日夜切换方式
- (void)setDayNightSwitchMode:(JFDayNightSwitchMode)mode{
    NSMutableDictionary *dic = [JFSafeArray(self.arrayCfg, 0) mutableCopy];
    if (!dic) {
        dic = self.dicCfg;
    }
    NSMutableDictionary *dicMode = [JFSafeDictionary(dic, @"DayNightSwitch") mutableCopy];
    [dicMode setObject:[NSNumber numberWithInt:(int)mode] forKey:@"SwitchMode"];
    [dic setObject:dicMode forKey:@"DayNightSwitch"];
    [self.arrayCfg replaceObjectAtIndex:0 withObject:dic];
}

///获取微光灯开关配置 0:关 1:开
- (int)microFillLight{
    NSDictionary *dic = JFSafeArray(self.arrayCfg, 0);
    if (!dic) {
        dic = self.dicCfg;
    }
    NSNumber *SoftLedThr = JFSafeDictionary(dic, @"MicroFillLight");
    return [SoftLedThr intValue];
}

///设置微光灯开关
- (void)setMicroFillLight:(int)value{
    NSMutableDictionary *dic = [JFSafeArray(self.arrayCfg, 0) mutableCopy];
    if (!dic) {
        dic = self.dicCfg;
    }
    [dic setObject:[NSNumber numberWithInt:(int)value] forKey:@"MicroFillLight"];
    [self.arrayCfg replaceObjectAtIndex:0 withObject:dic];
}

/// 获取定时切换的时间段
- (NSString *)keepDayPeriod{
    NSDictionary *dic = JFSafeArray(self.arrayCfg, 0);
    if (!dic) {
        dic = self.dicCfg;
    }
    NSDictionary *dicMode = JFSafeDictionary(dic, @"DayNightSwitch");
    NSString *period = JFSafeDictionary(dicMode, @"KeepDayPeriod");
    
    return period;
}

/// 设置定时切换的时间段
- (void)setKeepDayPeriod:(NSString *)period{
    NSMutableDictionary *dic = [JFSafeArray(self.arrayCfg, 0) mutableCopy];
    if (!dic) {
        dic = self.dicCfg;
    }
    NSMutableDictionary *dicMode = [JFSafeDictionary(dic, @"DayNightSwitch") mutableCopy];
    [dicMode setObject:period forKey:@"KeepDayPeriod"];
    [dic setObject:dicMode forKey:@"DayNightSwitch"];
    [self.arrayCfg replaceObjectAtIndex:0 withObject:dic];
}

/// 获取定时开始时间 HH:mm:ss
- (NSString *)timingStartTime{
    NSString *period = [self keepDayPeriod];
    if (period && period.length == 19) {
        return [period substringWithRange:NSMakeRange(2, 8)];
    }
    
    return @"00:00:00";
}

/// 设置定时开始时间
- (void)setTimingStartTime:(NSString *)startTime{
    NSString *period = [self keepDayPeriod];
    if (period && period.length == 19 && startTime.length == 8) {
        period = [period stringByReplacingCharactersInRange:NSMakeRange(2, 8) withString:startTime];
        [self setKeepDayPeriod:period];
    }
}

/// 获取定时结束时间 HH:mm:ss
- (NSString *)timingEndTime{
    NSString *period = [self keepDayPeriod];
    if (period && period.length == 19) {
        return [period substringWithRange:NSMakeRange(11, 8)];
    }
    
    return @"24:00:00";
}

/// 设置定时结束时间
- (void)setTimingEndTime:(NSString *)endTime{
    NSString *period = [self keepDayPeriod];
    if (period && period.length == 19 && endTime.length == 8) {
        period = [period stringByReplacingCharactersInRange:NSMakeRange(11, 8) withString:endTime];
        [self setKeepDayPeriod:period];
    }
}

/**
 * @brief 保存摄像机参数配置
 * @param completion SetCameraParamExCallBack
 * @return void
 */
- (void)requestSaveCameraParamExCompleted:(SetCameraParamExCallBack)completion{
    self.setCameraParamExCallBack = completion;
    
    if (!self.arrayCfg && !self.dicCfg) {
        [self sendSetCameraParamExResult:-1];
        return;
    }
    NSString *cfgName = @"Camera.ParamEx";
    if (self.channel >= 0) {
        cfgName = [NSString stringWithFormat:@"Camera.ParamEx.[%i]",self.channel];
    }
    NSDictionary *dic = @{@"Name":cfgName,@"SessionID":@"0x0000000001",cfgName:self.arrayCfg ? self.arrayCfg : self.dicCfg};
    NSString *str = [NSString convertToJSONData:dic];
    int size = [NSString getCharArraySize:str];
    char cfg[size];
    memcpy(cfg, [str cStringUsingEncoding:NSUTF8StringEncoding], 2*[str length]);
    
    FUN_DevCmdGeneral(self.msgHandle, self.devID.UTF8String, 1040, cfgName.UTF8String, -1, 15000, cfg, (int)strlen(cfg) + 1, -1, 1040);
}

- (void)sendGetCameraParamExResult:(int)result{
    if (self.getCameraParamExCallBack) {
        self.getCameraParamExCallBack(result);
    }
}

- (void)sendSetCameraParamExResult:(int)result{
    if (self.setCameraParamExCallBack) {
        self.setCameraParamExCallBack(result);
    }
}

- (void)OnFunSDKResult:(NSNumber *) pParam{
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    switch (msg->id) {
        case EMSG_DEV_CMD_EN:
        {
            if (msg->seq == 1042) {
                if (msg->param1 >= 0) {
                    NSDictionary *jsonDic = [NSDictionary dictionaryFromData:msg->pObject];
                    if (jsonDic && [jsonDic isKindOfClass:[NSDictionary class]]) {
                        NSArray *arrayInfo = [jsonDic objectForKey:self.lastCfgName];
                        if (arrayInfo && [arrayInfo isKindOfClass:[NSArray class]]) {
                            self.dicCfg = nil;
                            self.arrayCfg = [arrayInfo mutableCopy];
                            [self sendGetCameraParamExResult:1];
                            return;
                        }else if (arrayInfo && [arrayInfo isKindOfClass:[NSDictionary class]]){
                            self.arrayCfg = nil;
                            self.dicCfg = [arrayInfo mutableCopy];
                            [self sendGetCameraParamExResult:1];
                            return;
                        }
                    }
                }
                
                [self sendGetCameraParamExResult:-1];
            }else if (msg->seq == 1040){
                [self sendSetCameraParamExResult:msg->param1];
            }
        }
            break;
        default:
            break;
    }
}

@end
