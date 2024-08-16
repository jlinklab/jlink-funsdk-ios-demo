//
//  BatteryInfoManager.m
//   iCSee
//
//  Created by 一位神秘的码农 on 2023/2/27.
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import "BatteryInfoManager.h"
#import <FunSDK/FunSDK.h>

@interface BatteryInfoManager ()

@property (nonatomic,assign) int msgHandle;

@property (nonatomic, strong) NSMutableDictionary *dataSourceDic;
 
@end

@implementation BatteryInfoManager

#pragma mark -- 获取低常模式配置项
-(void)getLPWorkModeSwitchV2:(NSString *)devID Completion:(LPWorkModeSwitchV2)completion{
    self.LPWorkMode = completion;
    
    //通道默认是0 多通道不支持该配置
    FUN_DevGetConfig_Json(self.msgHandle, [devID UTF8String], "LPDev.WorkMode", 1042);
}

#pragma mark -- 设置低常模式配置项
-(void)setLPWorkModeSwitchV2:(NSString *)devID Completion:(SetLPWorkModeSwitchV2)completion{
    self.setLPWorkMode = completion;
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.dataSourceDic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *pCfgBufString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    //通道默认是0 多通道不支持该配置
    FUN_DevSetConfig_Json(self.msgHandle, devID.UTF8String, "LPDev.WorkMode",[pCfgBufString UTF8String], (int)(strlen([pCfgBufString UTF8String]) + 1));
}

#pragma mark -- 获取配置值,低功耗模式和常电模式切换
-(void)LPDevWorkMode:(NSString *)devID ActualTimeValue:(BOOL)actual Completion:(LPDevWorkModeValue)completion{
    self.WorkModeValue = completion;
    if (actual) {
        //实时获取当前模式
        __weak typeof(self) weakSelf = self;
        [self getLPWorkModeSwitchV2:devID Completion:^(int result) {
            if (result >= 0) {
                [weakSelf LPDevWorkMode:devID ActualTimeValue:NO Completion:^(LPDevWorkMode value) {
                    NSLog(@"%s--success",__FUNCTION__);
                }];
            }
        }];
    }else{
        LPDevWorkMode mode = LPDevWorkMode_unkown;
        NSDictionary *workMode = [[self.dataSourceDic objectForKey:@"LPDev.WorkMode"] mutableCopy];
        if ([[workMode allKeys] containsObject:@"ModeType"]) {
            mode = (LPDevWorkMode)[[workMode objectForKey:@"ModeType"] intValue];
        }
        
        if (self.WorkModeValue) {
            self.WorkModeValue(mode);
        }
    }
    
}

#pragma mark -- 获取本地配置值,低功耗模式和常电模式切换
-(LPDevWorkMode)LPDevWorkModeFromLocal:(NSString *)devID{
    LPDevWorkMode mode = LPDevWorkMode_unkown;
    NSDictionary *workMode = [[self.dataSourceDic objectForKey:@"LPDev.WorkMode"] mutableCopy];
    if ([[workMode allKeys] containsObject:@"ModeType"]) {
        mode = (LPDevWorkMode)[[workMode objectForKey:@"ModeType"] intValue];
    }
    
    return mode;
}

#pragma mark -- 获取设备电量阈值
-(int)powerThresholdValue{
    int value = -1;
    NSDictionary *workMode = [[self.dataSourceDic objectForKey:@"LPDev.WorkMode"] mutableCopy];
    if ([[workMode allKeys] containsObject:@"PowerThreshold"]) {
        value = [[workMode objectForKey:@"PowerThreshold"] intValue];
    }
    
    return value;
}

- (int)getWorkStateNow {
    int value = -1;
    NSDictionary *workMode = [[self.dataSourceDic objectForKey:@"LPDev.WorkMode"] mutableCopy];
    if ([[workMode allKeys] containsObject:@"WorkStateNow"]) {
        value = [[workMode objectForKey:@"WorkStateNow"] intValue];
    }
    
    return value;
}

#pragma mark -- 修改配置,低功耗模式和常电模式切换
-(void)modifyLPDevWorkMode:(LPDevWorkMode)mode {
    if (mode == LPDevWorkMode_unkown) {
        return;
    }
    
    id workMode = [[self.dataSourceDic objectForKey:@"LPDev.WorkMode"] mutableCopy];
    if (![workMode isKindOfClass:[NSMutableDictionary class]]) {
        return;
    }
    [workMode setObject:[NSNumber numberWithInt:(int)mode] forKey:@"ModeType"];
    [self.dataSourceDic setObject:workMode forKey:@"LPDev.WorkMode"];
}

//MARK: - FunSDKCallBack
- (void)OnFunSDKResult:(NSNumber *)pParam{
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    
    switch (msg->id) {
        case EMSG_DEV_GET_CONFIG_JSON:{
            if (msg->param1 >= 0) {
                if (msg->pObject == NULL) {
                    if (self.LPWorkMode) {
                        self.LPWorkMode(-1);
                    }
                    return;
                }
                NSData *jsonData = [NSData dataWithBytes:msg->pObject length:strlen(msg->pObject)];
                NSError *error;
                NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
                if(error){
                    if (self.LPWorkMode) {
                        self.LPWorkMode(-1);
                    }
                    return;
                }
                NSString *name = [jsonDic objectForKey:@"Name"];
                NSDictionary *dic = [jsonDic objectForKey:name];
                
                if (![dic isKindOfClass:[NSNull class]]) {
                    self.dataSourceDic = [jsonDic mutableCopy];
                    if (self.LPWorkMode) {
                        self.LPWorkMode(msg->param1);
                    }
                }else{
                    if (self.LPWorkMode) {
                        self.LPWorkMode(-1);
                    }
                }
            }else{
                if (self.LPWorkMode) {
                    self.LPWorkMode(msg->param1);
                }
            }
        }
            break;
        case EMSG_DEV_SET_CONFIG_JSON:{
            if (self.setLPWorkMode) {
                self.setLPWorkMode(msg->param1);
            }
        }
            break;
        default:
            break;
    }
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.msgHandle = FUN_RegWnd((__bridge LP_WND_OBJ)self);
        self.dataSourceDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    
    return self;
}

- (void)dealloc{
    FUN_UnRegWnd(self.msgHandle);
    self.msgHandle = -1;
}

@end
