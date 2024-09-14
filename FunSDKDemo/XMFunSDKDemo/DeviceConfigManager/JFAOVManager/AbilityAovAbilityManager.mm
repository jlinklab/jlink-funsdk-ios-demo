//
//  AbilityAovAbilityManager.m
//  iCSee
//
//  Created by Megatron on 2024/04/24
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import "AbilityAovAbilityManager.h"
#import <FunSDK/FunSDK.h>
#import "NSString+Utils.h"
#import "NSDictionary+Extension.h"

@interface AbilityAovAbilityManager ()

@property (nonatomic,assign) int msgHandle;
@property (nonatomic,copy) NSString *devID;
@property (nonatomic,strong) NSMutableDictionary *dicCfg;

@end
@implementation AbilityAovAbilityManager

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

//MARK: 获取【AbilityAovAbility】配置
- (void)requestAbilityAovAbilityWithDevice:(NSString *)devID completed:(GetAbilityAovAbilityCallBack)completion{
    self.devID = devID;
    self.getAbilityAovAbilityCallBack = completion;

    NSString *cfgName = @"Ability.AovAbility";
    NSDictionary *dic = @{@"Name":cfgName,@"SessionID":@"0x0000000001"};
    NSString *str = [NSString convertToJSONData:dic];
    int size = [NSString getCharArraySize:str];
    char cfg[size];
    memcpy(cfg, [str cStringUsingEncoding:NSUTF8StringEncoding], 2*[str length]);

    FUN_DevCmdGeneral(self.msgHandle, self.devID.UTF8String, 1042, cfgName.UTF8String, -1, 15000, cfg, (int)strlen(cfg) + 1, -1, 1042);
}

//MARK: 保存【AbilityAovAbility】配置
- (void)requestSaveAbilityAovAbilityCompleted:(GetAbilityAovAbilityCallBack)completion{
    self.setAbilityAovAbilityCallBack = completion;

    if (!self.dicCfg) {
        [self sendSetAbilityAovAbilityResult:-1];
        return;
    }

    NSString *cfgName = @"Ability.AovAbility";
    NSDictionary *dic = @{@"Name":cfgName,@"SessionID":@"0x0000000001",cfgName:self.dicCfg};
    NSString *str = [NSString convertToJSONData:dic];
    int size = [NSString getCharArraySize:str];
    char cfg[size];
    memcpy(cfg, [str cStringUsingEncoding:NSUTF8StringEncoding], 2*[str length]);

    FUN_DevCmdGeneral(self.msgHandle, self.devID.UTF8String, 1040, cfgName.UTF8String, -1, 15000, cfg, (int)strlen(cfg) + 1, -1, 1040);
}

//MARK: 获取和设置【VideoFps】配置项
- (NSArray *)videoFps{
    if (self.dicCfg) {
        NSArray * videoFps = [self.dicCfg objectForKey:@"VideoFps"];
        return videoFps;
    }

    return nil;
}

- (void)setVideoFps:(NSArray *)videoFps{
    if (self.dicCfg) {
        [self.dicCfg setObject:videoFps forKey:@"VideoFps"];
    }
}

//MARK: 获取和设置【RecordLatch】配置项
- (NSArray *)recordLatch{
    if (self.dicCfg) {
        NSArray * recordLatch = [self.dicCfg objectForKey:@"RecordLatch"];
        return recordLatch;
    }

    return nil;
}

- (void)setRecordLatch:(NSArray *)recordLatch{
    if (self.dicCfg) {
        [self.dicCfg setObject:recordLatch forKey:@"RecordLatch"];
    }
}

//MARK: 获取和设置【LowElectrMin】配置项
- (int)lowElectrMin{
    if (self.dicCfg) {
        int lowElectrMin = [[self.dicCfg objectForKey:@"LowElectrMin"] intValue];
        return lowElectrMin;
    }

    return 0;
}

- (void)setLowElectrMin:(int)lowElectrMin{
    if (self.dicCfg) {
        [self.dicCfg setObject:[NSNumber numberWithInt:lowElectrMin] forKey:@"LowElectrMin"];
    }
}

//MARK: 获取和设置【LowElectrMax】配置项
- (int)lowElectrMax{
    if (self.dicCfg) {
        int lowElectrMax = [[self.dicCfg objectForKey:@"LowElectrMax"] intValue];
        return lowElectrMax;
    }

    return 0;
}

- (void)setLowElectrMax:(int)lowElectrMax{
    if (self.dicCfg) {
        [self.dicCfg setObject:[NSNumber numberWithInt:lowElectrMax] forKey:@"LowElectrMax"];
    }
}

//MARK: 获取【AlarmHoldTime】配置项
- (NSArray *)AlarmHoldTime{
    if (self.dicCfg) {
        NSArray * AlarmHoldTime = [[self.dicCfg objectForKey:@"AlarmHoldTime"] objectForKey:@"HoldTimeList"];
        return AlarmHoldTime;
    }

    return nil;
}
//MARK: 获取【RecordLengthList】配置项  最大录像时长
- (NSArray *)RecordLengthList{
    if (self.dicCfg) {
        NSArray * RecordLengthList = [[self.dicCfg objectForKey:@"RecordLength"] objectForKey:@"RecordLengthList"];
        return RecordLengthList;
    }

    return nil;
}
- (void)sendGetAbilityAovAbilityResult:(int)result{
    if (self.getAbilityAovAbilityCallBack) {
        self.getAbilityAovAbilityCallBack(result);
    }
}

- (void)sendSetAbilityAovAbilityResult:(int)result{
    if (self.setAbilityAovAbilityCallBack) {
        self.setAbilityAovAbilityCallBack(result);
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
                        NSDictionary *dicInfo = [jsonDic objectForKey:@"Ability.AovAbility"];
                        if (dicInfo && [dicInfo isKindOfClass:[NSDictionary class]]) {
                            self.dicCfg = [dicInfo mutableCopy];
                            [self sendGetAbilityAovAbilityResult:msg->param1];
                            return;
                        }
                    }
                }

                [self sendGetAbilityAovAbilityResult:-1];
            }else if (msg->seq == 1040){
                [self sendSetAbilityAovAbilityResult:msg->param1];
            }
        }
            break;
        default:
            break;
    }
}

@end







