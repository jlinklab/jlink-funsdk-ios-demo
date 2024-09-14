//
//  DevLowElectrModeManager.m
//  iCSee
//
//  Created by Megatron on 2024/04/28
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import "DevLowElectrModeManager.h"
#import <FunSDK/FunSDK.h>
#import "NSString+Utils.h"
#import "NSDictionary+Extension.h"

@interface DevLowElectrModeManager ()

@property (nonatomic,assign) int msgHandle;
@property (nonatomic,copy) NSString *devID;
@property (nonatomic,strong) NSMutableDictionary *dicCfg;

@end
@implementation DevLowElectrModeManager

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

//MARK: 获取【DevLowElectrMode】配置
- (void)requestDevLowElectrModeWithDevice:(NSString *)devID completed:(GetDevLowElectrModeCallBack)completion{
    self.devID = devID;
    self.getDevLowElectrModeCallBack = completion;

    NSString *cfgName = @"Dev.LowElectrMode";
    NSDictionary *dic = @{@"Name":cfgName,@"SessionID":@"0x0000000001"};
    NSString *str = [NSString convertToJSONData:dic];
    int size = [NSString getCharArraySize:str];
    char cfg[size];
    memcpy(cfg, [str cStringUsingEncoding:NSUTF8StringEncoding], 2*[str length]);

    FUN_DevCmdGeneral(self.msgHandle, self.devID.UTF8String, 1042, cfgName.UTF8String, -1, 15000, cfg, (int)strlen(cfg) + 1, -1, 1042);
}

//MARK: 保存【DevLowElectrMode】配置
- (void)requestSaveDevLowElectrModeCompleted:(GetDevLowElectrModeCallBack)completion{
    self.setDevLowElectrModeCallBack = completion;

    if (!self.dicCfg) {
        [self sendSetDevLowElectrModeResult:-1];
        return;
    }

    NSString *cfgName = @"Dev.LowElectrMode";
    NSDictionary *dic = @{@"Name":cfgName,@"SessionID":@"0x0000000001",cfgName:self.dicCfg};
    NSString *str = [NSString convertToJSONData:dic];
    int size = [NSString getCharArraySize:str];
    char cfg[size];
    memcpy(cfg, [str cStringUsingEncoding:NSUTF8StringEncoding], 2*[str length]);

    FUN_DevCmdGeneral(self.msgHandle, self.devID.UTF8String, 1040, cfgName.UTF8String, -1, 15000, cfg, (int)strlen(cfg) + 1, -1, 1040);
}

//MARK: 获取和设置【PowerThreshold】配置项
- (int)powerThreshold{
    if (self.dicCfg) {
        int powerThreshold = [[self.dicCfg objectForKey:@"PowerThreshold"] intValue];
        return powerThreshold;
    }

    return 0;
}

- (void)setPowerThreshold:(int)powerThreshold{
    if (self.dicCfg) {
        [self.dicCfg setObject:[NSNumber numberWithInt:powerThreshold] forKey:@"PowerThreshold"];
    }
}

- (void)sendGetDevLowElectrModeResult:(int)result{
    if (self.getDevLowElectrModeCallBack) {
        self.getDevLowElectrModeCallBack(result);
    }
}

- (void)sendSetDevLowElectrModeResult:(int)result{
    if (self.setDevLowElectrModeCallBack) {
        self.setDevLowElectrModeCallBack(result);
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
                        NSDictionary *dicInfo = [jsonDic objectForKey:@"Dev.LowElectrMode"];
                        if (dicInfo && [dicInfo isKindOfClass:[NSDictionary class]]) {
                            self.dicCfg = [dicInfo mutableCopy];
                            [self sendGetDevLowElectrModeResult:msg->param1];
                            return;
                        }
                    }
                }

                [self sendGetDevLowElectrModeResult:-1];
            }else if (msg->seq == 1040){
                [self sendSetDevLowElectrModeResult:msg->param1];
            }
        }
            break;
        default:
            break;
    }
}

@end







