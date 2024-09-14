//
//  DevAovWorkModeManager.m
//  iCSee
//
//  Created by Megatron on 2024/04/24
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import "DevAovWorkModeManager.h"
#import <FunSDK/FunSDK.h>
#import "NSString+Utils.h"
#import "NSDictionary+Extension.h"

@interface DevAovWorkModeManager ()

@property (nonatomic,assign) int msgHandle;
@property (nonatomic,copy) NSString *devID;
@property (nonatomic,strong) NSMutableDictionary *dicCfg;

@end
@implementation DevAovWorkModeManager

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

//MARK: 获取【DevAovWorkMode】配置
- (void)requestDevAovWorkModeWithDevice:(NSString *)devID completed:(GetDevAovWorkModeCallBack)completion{
    self.devID = devID;
    self.getDevAovWorkModeCallBack = completion;

    NSString *cfgName = @"Dev.AovWorkMode";
    NSDictionary *dic = @{@"Name":cfgName,@"SessionID":@"0x0000000001"};
    NSString *str = [NSString convertToJSONData:dic];
    int size = [NSString getCharArraySize:str];
    char cfg[size];
    memcpy(cfg, [str cStringUsingEncoding:NSUTF8StringEncoding], 2*[str length]);

    FUN_DevCmdGeneral(self.msgHandle, self.devID.UTF8String, 1042, cfgName.UTF8String, -1, 15000, cfg, (int)strlen(cfg) + 1, -1, 1042);
}

//MARK: 保存【DevAovWorkMode】配置
- (void)requestSaveDevAovWorkModeCompleted:(GetDevAovWorkModeCallBack)completion{
    self.setDevAovWorkModeCallBack = completion;

    if (!self.dicCfg) {
        [self sendSetDevAovWorkModeResult:-1];
        return;
    }

    NSString *cfgName = @"Dev.AovWorkMode";
    NSDictionary *dic = @{@"Name":cfgName,@"SessionID":@"0x0000000001",cfgName:self.dicCfg};
    NSString *str = [NSString convertToJSONData:dic];
    int size = [NSString getCharArraySize:str];
    char cfg[size];
    memcpy(cfg, [str cStringUsingEncoding:NSUTF8StringEncoding], 2*[str length]);

    FUN_DevCmdGeneral(self.msgHandle, self.devID.UTF8String, 1040, cfgName.UTF8String, -1, 15000, cfg, (int)strlen(cfg) + 1, -1, 1040);
}

//MARK: 获取和设置【Mode】配置项
- (NSString *)mode{
    if (self.dicCfg) {
        NSString * mode = [self.dicCfg objectForKey:@"Mode"];
        return mode;
    }

    return @"";
}

- (void)setMode:(NSString *)mode{
    if (self.dicCfg) {
        [self.dicCfg setObject:mode forKey:@"Mode"];
    }
}

//MARK: 获取和设置【Custom】配置项
- (NSDictionary *)custom{
    if (self.dicCfg) {
        NSDictionary * custom = [self.dicCfg objectForKey:@"Custom"];
        return custom;
    }

    return nil;
}

- (void)setCustom:(NSDictionary *)custom{
    if (self.dicCfg) {
        [self.dicCfg setObject:custom forKey:@"Custom"];
    }
}

/*
  获取和设置【Performance】配置项
  */
- (NSDictionary *)performance{
    if (self.dicCfg) {
        NSDictionary * custom = [self.dicCfg objectForKey:@"Performance"];
        return custom;
    }

    return nil;
}

- (void)setPerformance:(NSDictionary *)performance{
    if (self.dicCfg) {
        [self.dicCfg setObject:performance forKey:@"Performance"];
    }
}

/*
  获取和设置【Balance】配置项
  */
- (NSDictionary *)balance{
    if (self.dicCfg) {
        NSDictionary * custom = [self.dicCfg objectForKey:@"Balance"];
        return custom;
    }

    return nil;
}

- (void)setBalance:(NSDictionary *)balance{
    if (self.dicCfg) {
        [self.dicCfg setObject:balance forKey:@"Balance"];
    }
}
 
//MARK: 获取和设置【AlarmHoldTime】报警抑制时间  报警间隔配置项
- (int)AlarmHoldTime{
    if (self.dicCfg) {
        int AlarmHoldTime = [[self.dicCfg objectForKey:@"AlarmHoldTime"] intValue];
        return AlarmHoldTime;
    }

    return 0;
}

- (void)setAlarmHoldTime:(int)alarmHoldTime{
    if (self.dicCfg) {
        [self.dicCfg setObject:[NSNumber numberWithInt:alarmHoldTime] forKey:@"AlarmHoldTime"];
    }
}






- (void)sendGetDevAovWorkModeResult:(int)result{
    if (self.getDevAovWorkModeCallBack) {
        self.getDevAovWorkModeCallBack(result);
    }
}

- (void)sendSetDevAovWorkModeResult:(int)result{
    if (self.setDevAovWorkModeCallBack) {
        self.setDevAovWorkModeCallBack(result);
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
                        NSDictionary *dicInfo = [jsonDic objectForKey:@"Dev.AovWorkMode"];
                        if (dicInfo && [dicInfo isKindOfClass:[NSDictionary class]]) {
                            self.dicCfg = [dicInfo mutableCopy];
                            [self sendGetDevAovWorkModeResult:msg->param1];
                            return;
                        }
                    }
                }

                [self sendGetDevAovWorkModeResult:-1];
            }else if (msg->seq == 1040){
                [self sendSetDevAovWorkModeResult:msg->param1];
            }
        }
            break;
        default:
            break;
    }
}

@end







