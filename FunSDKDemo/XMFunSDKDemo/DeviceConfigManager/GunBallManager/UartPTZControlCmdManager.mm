//
//  UartPTZControlCmdManager.m
//   
//
//  Created by Megatron on 2022/8/29.
//  Copyright © 2022 xiongmaitech. All rights reserved.
//

#import "UartPTZControlCmdManager.h"
#import <FunSDK/FunSDK.h>

@interface UartPTZControlCmdManager ()

@property (nonatomic,strong) NSMutableArray *arrayCfg;
//是否是第一次请求设置
@property (nonatomic,assign) BOOL firstSetting;

@end
@implementation UartPTZControlCmdManager

//MARK: 安全获取多个调用时 只有第一个会被执行
- (void)requestSafeGetUartPTZControlCmdConfig:(NSString *)devID channel:(int)channel completed:(GetUartPTZControlCmdCallBack)completion{
    self.safeGetUartPTZControlCmdCallBack = completion;
    self.devID = devID;
    self.channelNumber = channel;
    
    NSString *cfgName = @"Uart.PTZControlCmd";
    int nCmdReq = 1042;
    if (self.byPass && channel >= 0) {
        cfgName = [NSString stringWithFormat:@"bypass@Uart.PTZControlCmd.[%i]",channel];
    }else if (channel >= 0){
        cfgName = [NSString stringWithFormat:@"Uart.PTZControlCmd.[%i]",channel];
    }
    
    FUN_DevCmdGeneral(self.msgHandle, [self.devID UTF8String], nCmdReq, cfgName.UTF8String, 4096, 15000, NULL, 0, -1, channel);
}

//MARK: 获取配置
- (void)requestGetUartPTZControlCmdConfig:(NSString *)devID channel:(int)channel completed:(GetUartPTZControlCmdCallBack)completion{
    self.getUartPTZControlCmdCallBack = completion;
    self.devID = devID;
    self.channelNumber = channel;
    
    FUN_DevGetConfig_Json(self.msgHandle, self.devID.UTF8String, self.byPass ? "bypass@Uart.PTZControlCmd" : "Uart.PTZControlCmd", 1024,self.channelNumber,15000,channel);
}

//MARK: 保存配置
- (void)requestSetUartPTZControlCmdConfigCompleted:(SetUartPTZControlCmdCallBack)completion{
    self.setUartPTZControlCmdCallBack = completion;
    
    if (!self.arrayCfg || !self.cfgName) {
        [self sendSetResult:-1];
        return;
    }
    
    //self.firstSetting = YES;
    [self setUartPTZControlConfig];
}

- (void)setUartPTZControlConfig{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.arrayCfg options:NSJSONWritingPrettyPrinted error:&error];
    NSString *pCfgBufString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    FUN_DevSetConfig_Json(self.msgHandle, self.devID.UTF8String, self.byPass ? "bypass@Uart.PTZControlCmd" : "Uart.PTZControlCmd",[pCfgBufString UTF8String], (int)(strlen([pCfgBufString UTF8String]) + 1), self.channelNumber);
}

//MARK: 判断是否有缓存
- (BOOL)cached{
    if (self.arrayCfg) {
        return YES;
    }
    
    return NO;
}

//MARK: Get Set
//MARK: 是否上下反转
- (BOOL)flipOperation{
    if (self.arrayCfg) {
        NSDictionary *dicCfg = [self.arrayCfg objectAtIndex:0];
        return [[dicCfg objectForKey:@"FlipOperation"] boolValue];
    }else{
        //判断是否有缓存
        DeviceObject *device = [[DeviceControl getInstance]GetDeviceObjectBySN: self.devID];
        if (device && [device PTZUpsideDown:self.channelNumber] != -1) {
            return [NSNumber numberWithBool:[device PTZUpsideDown:self.channelNumber] == 0 ? NO : YES];
        }
    }
    
    return NO;
}

- (void)setFlipOperation:(BOOL)flip{
    NSMutableDictionary *dicCfg = [[self.arrayCfg objectAtIndex:0] mutableCopy];
    [dicCfg setObject:[NSNumber numberWithBool:flip] forKey:@"FlipOperation"];
    [dicCfg setObject:[NSNumber numberWithBool:YES] forKey:@"ModifyCfg"];
    [self.arrayCfg replaceObjectAtIndex:0 withObject:dicCfg];
}

//MARK: 是否左右反转
- (BOOL)mirrorOperation{
    if (self.arrayCfg) {
        NSDictionary *dicCfg = [self.arrayCfg objectAtIndex:0];
        return [[dicCfg objectForKey:@"MirrorOperation"] boolValue];
    }else{
        //判断是否有缓存
        DeviceObject *device = [[DeviceControl getInstance]GetDeviceObjectBySN: self.devID];
        if (device && [device PTZLeftRightReverse:self.channelNumber] != -1) {
            return [NSNumber numberWithBool:[device PTZLeftRightReverse:self.channelNumber] == 0 ? NO : YES];
        }
    }
    
    return NO;
}

- (void)setMirrorOperation:(BOOL)mirror{
    NSMutableDictionary *dicCfg = [[self.arrayCfg objectAtIndex:0] mutableCopy];
    [dicCfg setObject:[NSNumber numberWithBool:mirror] forKey:@"MirrorOperation"];
    [dicCfg setObject:[NSNumber numberWithBool:YES] forKey:@"ModifyCfg"];
    [self.arrayCfg replaceObjectAtIndex:0 withObject:dicCfg];
}

//MARK: 获取是否修改
- (BOOL)modifyCfg{
    if (self.arrayCfg) {
        NSDictionary *dicCfg = [self.arrayCfg objectAtIndex:0];
        return [[dicCfg objectForKey:@"ModifyCfg"] boolValue];
    }else{
        //判断是否有缓存
        DeviceObject *device = [[DeviceControl getInstance]GetDeviceObjectBySN: self.devID];
        if (device && [device PTZModifyCfgReverse:self.channelNumber] != -1) {
            return [NSNumber numberWithBool:[device PTZModifyCfgReverse:self.channelNumber] == 0 ? NO : YES];
        }
    }
    
    return NO;
}

- (void)sendGetResult:(int)result channel:(int)channel safe:(BOOL)safe{
    if (result >= 0) {
        //如果获取成功 需要缓存
        if (result >= 0) {
            [self cachePTZConfigToDB];
        }
        self.getConfigState = GetConfigState_Success;
    }else{
        self.getConfigState = GetConfigState_Failed;
        if (result == -400009 || result == -11406) {
            self.getConfigState = GetConfigState_Success;
            //如果是配置不支持的失败 给一个默认值
            self.cfgName = @"Uart.PTZControlCmd";
            self.byPass = NO;
            [self loadDefaultData];
        }
    }
    
    if (safe) {
        if (self.safeGetUartPTZControlCmdCallBack) {
            self.safeGetUartPTZControlCmdCallBack(result,self.devID,channel);
            self.safeGetUartPTZControlCmdCallBack = nil;
        }
    }else{
        if (self.getUartPTZControlCmdCallBack) {
            self.getUartPTZControlCmdCallBack(result,self.devID,channel);
            self.getUartPTZControlCmdCallBack = nil;
        }
    }
    
}

- (void)sendSetResult:(int)result{
    //如果设置成功 需要缓存
    if (result >= 0) {
        [self cachePTZConfigToDB];
    }
    if (self.setUartPTZControlCmdCallBack) {
        self.setUartPTZControlCmdCallBack(result);
        self.setUartPTZControlCmdCallBack = nil;
    }
}

- (void)cachePTZConfigToDB{
    DeviceObject *device = [[DeviceControl getInstance]GetDeviceObjectBySN: self.devID];
    [device setPTZUpsideDownValue:[self flipOperation] ? 1 : 0 leftRightReverseValue:[self mirrorOperation] ? 1 : 0 modifyCfg:[self modifyCfg] ? 1 : 0 channel:self.channelNumber];
}

- (void)loadDefaultData{
    //判断是否有缓存
    DeviceObject *device = [[DeviceControl getInstance]GetDeviceObjectBySN: self.devID];
    if (device && [device PTZUpsideDown:self.channelNumber] != -1) {
        self.arrayCfg = [@[@{@"FlipOperation":[NSNumber numberWithBool:[device PTZUpsideDown:self.channelNumber] == 0 ? NO : YES],@"MirrorOperation":[NSNumber numberWithBool:[device PTZLeftRightReverse:self.channelNumber] == 0 ? NO : YES],@"ModifyCfg":[NSNumber numberWithBool:[device PTZModifyCfgReverse:self.channelNumber] == 0 ? NO : YES]}] mutableCopy];
    }else{//没有就给默认值
        self.arrayCfg = [@[@{@"FlipOperation":[NSNumber numberWithBool:NO],@"MirrorOperation":[NSNumber numberWithBool:self.consumerProduct ? YES : NO],@"ModifyCfg":[NSNumber numberWithBool:NO]}] mutableCopy];
    }
}

//MARK: FunSDK回调
- (void)baseOnFunSDKResult:(MsgContent *)msg{
    switch (msg->id) {
        case EMSG_DEV_GET_CONFIG_JSON:
        {
            int channel = msg->seq;
            if (msg->param1 >= 0) {
                if (msg->pObject == NULL) {
                    [self sendGetResult:-1 channel:channel safe:NO];
                    return;
                }
                NSData *jsonData = [NSData dataWithBytes:msg->pObject length:strlen(msg->pObject)];
                NSError *error;
                NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
                if(error){
                    [self sendGetResult:-1 channel:channel safe:NO];
                    return;
                }
                
                self.cfgName = OCSTR(msg->szStr);
                NSString *key = self.cfgName;
                if (self.channelNumber >= 0) {
                    key = [NSString stringWithFormat:@"%@.[%i]",self.cfgName,self.channelNumber];
                }
                NSArray *arrayCfg = [jsonDic objectForKey:key];
                if (arrayCfg && [arrayCfg isKindOfClass:[NSArray class]]) {
                    NSDictionary *dicCfg = [arrayCfg objectAtIndex:0];
                    if (![dicCfg isKindOfClass:[NSDictionary class]]) {
                        [self loadDefaultData];
                    }else{
                        self.arrayCfg = [arrayCfg mutableCopy];
                        if ([dicCfg isKindOfClass:[NSDictionary class]]) {
                            if ([dicCfg objectForKey:@"ModifyCfg"] && ![[dicCfg objectForKey:@"ModifyCfg"] boolValue]) {//如果ModifyCfg是false 那么使用默认值
                                [self loadDefaultData];
                            }
                        }
                    }
                    [self sendGetResult:msg->param1 channel:channel safe:NO];
                }else{
                    [self loadDefaultData];
                    [self sendGetResult:msg->param1 channel:channel safe:NO];
                }
            }else{
                [self sendGetResult:msg->param1 channel:channel safe:NO];
            }
        }
            break;
        case EMSG_DEV_CMD_EN:
        {
            int channel = msg->seq;
            if (msg->param1 >= 0) {
                if (msg->pObject == NULL) {
                    [self sendGetResult:-1 channel:channel safe:YES];
                    return;
                }
                NSData *jsonData = [NSData dataWithBytes:msg->pObject length:strlen(msg->pObject)];
                NSError *error;
                NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
                if(error){
                    [self sendGetResult:-1 channel:channel safe:YES];
                    return;
                }
                
                self.cfgName = OCSTR(msg->szStr);
                NSString *key = self.cfgName;
                NSArray *arrayCfg = [jsonDic objectForKey:key];
                if (arrayCfg && [arrayCfg isKindOfClass:[NSArray class]]) {
                    NSDictionary *dicCfg = [arrayCfg objectAtIndex:0];
                    if (![dicCfg isKindOfClass:[NSDictionary class]]) {
                        [self loadDefaultData];
                    }else{
                        self.arrayCfg = [arrayCfg mutableCopy];
                        if ([dicCfg isKindOfClass:[NSDictionary class]]) {
                            if ([dicCfg objectForKey:@"ModifyCfg"] && ![[dicCfg objectForKey:@"ModifyCfg"] boolValue]) {//如果ModifyCfg是false 那么使用默认值
                                [self loadDefaultData];
                            }
                        }
                    }
                    [self sendGetResult:msg->param1 channel:channel safe:YES];
                }else{
                    [self loadDefaultData];
                    [self sendGetResult:msg->param1 channel:channel safe:YES];
                }
            }else{
                [self sendGetResult:msg->param1 channel:channel safe:YES];
            }
        }
            break;
        case EMSG_DEV_SET_CONFIG_JSON:
        {
//            if ((msg->param1 == -400009 || msg->param1 == -11406) && self.firstSetting) {
//                self.firstSetting = NO;
//                self.byPass = YES;
//                [self setUartPTZControlConfig];
//            }else{
//                [self sendSetResult:msg->param1];
//            }
            [self sendSetResult:msg->param1];
        }
            break;
        default:
            break;
    }
}

@end
