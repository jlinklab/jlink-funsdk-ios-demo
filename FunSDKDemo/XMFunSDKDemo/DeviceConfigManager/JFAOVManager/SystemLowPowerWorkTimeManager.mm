//
//  SystemLowPowerWorkTimeManager.m
//  iCSee
//
//  Created by Megatron on 2024/05/25
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import "SystemLowPowerWorkTimeManager.h"
#import <FunSDK/FunSDK.h>
#import "NSString+Utils.h"
#import "NSDictionary+Extension.h"

@interface SystemLowPowerWorkTimeManager ()

@property (nonatomic,assign) int msgHandle;
@property (nonatomic,copy) NSString *devID;
@property (nonatomic,strong) NSMutableDictionary *dicCfg;

@end
@implementation SystemLowPowerWorkTimeManager

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

//MARK: 获取【SystemLowPowerWorkTime】配置
- (void)requestSystemLowPowerWorkTimeWithDevice:(NSString *)devID completed:(GetSystemLowPowerWorkTimeCallBack)completion{
    self.devID = devID;
    self.getSystemLowPowerWorkTimeCallBack = completion;

    NSString *cfgName = @"System.LowPowerWorkTime";
    NSDictionary *dic = @{@"Name":cfgName,@"SessionID":@"0x0000000001"};
    NSString *str = [NSString convertToJSONData:dic];
    int size = [NSString getCharArraySize:str];
    char cfg[size];
    memcpy(cfg, [str cStringUsingEncoding:NSUTF8StringEncoding], 2*[str length]);

    FUN_DevCmdGeneral(self.msgHandle, self.devID.UTF8String, 1042, cfgName.UTF8String, -1, 15000, cfg, (int)strlen(cfg) + 1, -1, 1042);
}

//MARK: 保存【SystemLowPowerWorkTime】配置
- (void)requestSaveSystemLowPowerWorkTimeCompleted:(GetSystemLowPowerWorkTimeCallBack)completion{
    self.setSystemLowPowerWorkTimeCallBack = completion;

    if (!self.dicCfg) {
        [self sendSetSystemLowPowerWorkTimeResult:-1];
        return;
    }

    NSString *cfgName = @"System.LowPowerWorkTime";
    NSDictionary *dic = @{@"Name":cfgName,@"SessionID":@"0x0000000001",cfgName:self.dicCfg};
    NSString *str = [NSString convertToJSONData:dic];
    int size = [NSString getCharArraySize:str];
    char cfg[size];
    memcpy(cfg, [str cStringUsingEncoding:NSUTF8StringEncoding], 2*[str length]);

    FUN_DevCmdGeneral(self.msgHandle, self.devID.UTF8String, 1040, cfgName.UTF8String, -1, 15000, cfg, (int)strlen(cfg) + 1, -1, 1040);
}

//MARK: 获取和设置【RealViewTime】配置项
- (NSArray *)realViewTime{
    if (self.dicCfg) {
        NSArray * realViewTime = [self.dicCfg objectForKey:@"RealViewTime"];
        return realViewTime;
    }

    return nil;
}

- (void)setRealViewTime:(NSArray *)realViewTime{
    if (self.dicCfg) {
        [self.dicCfg setObject:realViewTime forKey:@"RealViewTime"];
    }
}

//MARK: 获取和设置【WakeupTime】配置项
- (NSArray *)wakeupTime{
    if (self.dicCfg) {
        NSArray * wakeupTime = [self.dicCfg objectForKey:@"WakeupTime"];
        return wakeupTime;
    }

    return nil;
}

- (void)setWakeupTime:(NSArray *)wakeupTime{
    if (self.dicCfg) {
        [self.dicCfg setObject:wakeupTime forKey:@"WakeupTime"];
    }
}

- (void)sendGetSystemLowPowerWorkTimeResult:(int)result{
    if (self.getSystemLowPowerWorkTimeCallBack) {
        self.getSystemLowPowerWorkTimeCallBack(result);
    }
}

- (void)sendSetSystemLowPowerWorkTimeResult:(int)result{
    if (self.setSystemLowPowerWorkTimeCallBack) {
        self.setSystemLowPowerWorkTimeCallBack(result);
    }
}

//MARK: FunSDK CallBack
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
                        NSDictionary *dicInfo = [jsonDic objectForKey:@"System.LowPowerWorkTime"];
                        if (dicInfo && [dicInfo isKindOfClass:[NSDictionary class]]) {
                            self.dicCfg = [dicInfo mutableCopy];
                            [self sendGetSystemLowPowerWorkTimeResult:msg->param1];
                            return;
                        }
                    }
                }

                [self sendGetSystemLowPowerWorkTimeResult:-1];
            }else if (msg->seq == 1040){
                [self sendSetSystemLowPowerWorkTimeResult:msg->param1];
            }
        }
            break;
        default:
            break;
    }
}

@end







