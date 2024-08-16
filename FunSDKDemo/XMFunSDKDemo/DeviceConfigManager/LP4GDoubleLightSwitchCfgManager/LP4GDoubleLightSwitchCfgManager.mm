//
//  LP4GDoubleLightSwitchCfgManager.m
//  XWorld_General
//
//  Created by Tony Stark on 2020/7/15.
//  Copyright © 2020 xiongmaitech. All rights reserved.
//

#import "LP4GDoubleLightSwitchCfgManager.h"
#import <FunSDK/FunSDK.h>

@interface LP4GDoubleLightSwitchCfgManager ()

@property (nonatomic,strong) NSMutableDictionary *dicCfg;

@end

@implementation LP4GDoubleLightSwitchCfgManager

- (instancetype)init{
    self = [super init];
    if (self) {
        self.msgHandle = FUN_RegWnd((__bridge void*)self);
    }
    
    return self;
}

- (void)dealloc{
    FUN_UnRegWnd(self.msgHandle);
    self.msgHandle = -1;
}

- (void)getLP4GDoubleLight:(NSString *)devID channel:(int)channel  completed:(XMRESCALLBACK)completion{
    self.getResult = completion;
    self.channelNumber = channel;
    self.devID = devID;
    
    FUN_DevGetConfig_Json(self.msgHandle, self.devID.UTF8String, self.needPenetrate ? "bypass@Dev.LP4GLedParameter" : "Dev.LP4GLedParameter", 1024,self.channelNumber);
}

- (void)setLP4GDoubleLightCompleted:(XMRESCALLBACK)completion{
    self.setResult = completion;
    
    if (!self.cfgName || !self.dicCfg) {
        [SVProgressHUD showErrorWithStatus:TS("TR_Get_Config_F_Can_Not_Save")];
        return;
    }
    NSDictionary* jsonDic1 = @{@"Name":self.cfgName,self.cfgName:self.dicCfg};
    NSError *error;
    NSData *jsonData1 = [NSJSONSerialization dataWithJSONObject:jsonDic1 options:NSJSONWritingPrettyPrinted error:&error];
    NSString *pCfgBufString1 = [[NSString alloc] initWithData:jsonData1 encoding:NSUTF8StringEncoding];

    FUN_DevSetConfig_Json(self.msgHandle, [self.devID UTF8String], "Dev.LP4GLedParameter", [pCfgBufString1 UTF8String], (int)(strlen([pCfgBufString1 UTF8String]) + 1),self.channelNumber);
}

//MARK: 获取灯类型：1.红外 2.白光
- (int)getLightType{
    int type = 0;
    
    if (self.dicCfg && [self.dicCfg isKindOfClass:[NSDictionary class]]) {
        type = [[self.dicCfg objectForKey:@"Type"] intValue];
    }

    return type;
}

//MARK: 设置灯类型
- (void)setLightType:(int)type{
    if (self.dicCfg && [self.dicCfg isKindOfClass:[NSDictionary class]]) {
        [self.dicCfg setObject:[NSNumber numberWithInt:type] forKey:@"Type"];
    }
}

//MARK: 获取灯亮度 Brightness是亮度，默认亮度80，取值范围 20-100
- (int)getLightBrightness{
    int brightness = 0;
    
    if (self.dicCfg && [self.dicCfg isKindOfClass:[NSDictionary class]]) {
        brightness = [[self.dicCfg objectForKey:@"Brightness"] intValue];
    }

    return brightness;
}

//MARK: 设置灯亮度
- (void)setLightBrightness:(int)brightness{
    if (self.dicCfg && [self.dicCfg isKindOfClass:[NSDictionary class]]) {
        [self.dicCfg setObject:[NSNumber numberWithInt:brightness] forKey:@"Brightness"];
    }
}

//MARK: FunSDK CallBack
- (void)baseOnFunSDKResult:(MsgContent *)msg{
    switch (msg->id) {
        case EMSG_DEV_GET_CONFIG_JSON:{
            if ([OCSTR(msg->szStr) containsString:@"Dev.LP4GLedParameter"]) {
                if (msg->param1 >= 0) {
                    if (msg->pObject == NULL) {
                        if (self.getResult) {
                            self.getResult(XM_REQ_FAILED, @{@"result":@-1,@"channel":[NSNumber numberWithInt:self.channelNumber]});
                        }
                        return;
                    }
                    NSData *retJsonData = [NSData dataWithBytes:msg->pObject length:strlen(msg->pObject)];
                    
                    NSError *error;
                    NSDictionary *retDic = [NSJSONSerialization JSONObjectWithData:retJsonData options:NSJSONReadingMutableLeaves error:&error];
                    if (!retDic) {
                        if (self.getResult) {
                            self.getResult(XM_REQ_FAILED, @{@"result":@-1,@"channel":[NSNumber numberWithInt:self.channelNumber]});
                        }
                        return;
                    }
                    
                    self.cfgName = OCSTR(msg->szStr);
                    if (self.channelNumber >= 0) {
                        self.cfgName = [NSString stringWithFormat:@"%@.[%i]",self.cfgName,self.channelNumber];
                    }
                    NSDictionary *dicAlarm = [retDic objectForKey:self.cfgName];
                    if ([dicAlarm isKindOfClass:[NSDictionary class]]) {
                        self.dicCfg = [dicAlarm mutableCopy];
                        
                        if (self.getResult) {
                            self.getResult(XM_REQ_SUCCESS, @{@"result":[NSNumber numberWithInt:msg->param1],@"channel":[NSNumber numberWithInt:self.channelNumber]});
                        }
                    }else{
                        if (self.getResult) {
                            self.getResult(XM_REQ_FAILED, @{@"result":@-1,@"channel":[NSNumber numberWithInt:self.channelNumber]});
                        }
                    }
                }else{
                    if (self.getResult) {
                        self.getResult(XM_REQ_FAILED, @{@"result":[NSNumber numberWithInt:msg->param1],@"channel":[NSNumber numberWithInt:self.channelNumber]});
                    }
                }
            }
            break;
            case EMSG_DEV_SET_CONFIG_JSON:{
                if ([OCSTR(msg->szStr) isEqualToString:@"Dev.LP4GLedParameter"]) {
                    if (msg->param1 >= 0) {
                        if (self.setResult) {
                            self.setResult(XM_REQ_SUCCESS, @{@"result":[NSNumber numberWithInt:msg->param1],@"channel":[NSNumber numberWithInt:self.channelNumber]});
                        }
                    }else{
                        if (self.setResult) {
                            self.setResult(XM_REQ_FAILED, @{@"result":[NSNumber numberWithInt:msg->param1],@"channel":[NSNumber numberWithInt:self.channelNumber]});
                        }
                    }
                }
            }
            break;
            default:
            break;
        }
    }
}

//MARK: - LazyLoad
- (NSMutableDictionary *)dicCfg{
    if (!_dicCfg) {
        _dicCfg = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    
    return _dicCfg;
}

@end
