//
//  HumanRuleLimitAbilityManager.m
//  XWorld_General
//
//  Created by Tony Stark on 2020/7/22.
//  Copyright © 2020 xiongmaitech. All rights reserved.
//

#import "HumanRuleLimitAbilityManager.h"
#import <FunSDK/FunSDK.h>

@interface HumanRuleLimitAbilityManager ()

@property (nonatomic,assign) int msgHandle;

@property (nonatomic,strong) NSMutableDictionary *dicCfg;

@end

@implementation HumanRuleLimitAbilityManager

- (instancetype)init{
    self = [super init];
    if (self) {
        self.msgHandle = FUN_RegWnd((__bridge void*)self);
        self.areaLineArray = [[NSMutableArray alloc] initWithCapacity:0];
        self.lineDirectArray = [[NSMutableArray alloc] initWithCapacity:0];
        self.areaDirectArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    return self;
}

- (void)getConfig:(GetConfigResult)callBack{
    self.getConfigResult = callBack;
    
    FUN_DevCmdGeneral(self.msgHandle, [self.devID UTF8String], 1360, "HumanRuleLimit", 4096, 20000, NULL, 0, -1, -1);
}

//MARK: 获取是否支持踪迹显示
- (BOOL)supportShowTrack{
    if ([self.dicCfg objectForKey:@"ShowTrack"]) {
        return [[self.dicCfg objectForKey:@"ShowTrack"] boolValue];
    }else{
        return NO;
    }
}

//MARK: 获取是否支持警戒线
- (BOOL)supportLine{
    if ([self.dicCfg objectForKey:@"SupportLine"]) {
        return [[self.dicCfg objectForKey:@"SupportLine"] boolValue];
    }else{
        return NO;
    }
}

//MARK: 获取是否支持警戒区域
- (BOOL)supportArea{
    if ([self.dicCfg objectForKey:@"SupportArea"]) {
        return [[self.dicCfg objectForKey:@"SupportArea"] boolValue];
    }else{
        return NO;
    }
}

- (void)baseOnFunSDKResult:(MsgContent *)msg{
    switch (msg->id) {
        case EMSG_DEV_CMD_EN:
        {
            if (msg->param1 >= 0) {
                if (msg->pObject == NULL) {
                    if (self.getConfigResult) {
                        self.getConfigResult(-1);
                    }
                    return;
                }
                NSData *data = [[[NSString alloc]initWithUTF8String:msg->pObject] dataUsingEncoding:NSUTF8StringEncoding];
                if ( data == nil ){
                    if (self.getConfigResult) {
                        self.getConfigResult(-1);
                    }
                    return;
                }
                NSDictionary *appData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                if ( appData == nil) {
                    if (self.getConfigResult) {
                        self.getConfigResult(-1);
                    }
                    return;
                }
                
                NSString* strConfigName = [appData valueForKey:@"Name"];
                if (strConfigName) {
                    self.dicCfg = [[appData objectForKey:strConfigName] mutableCopy];
                    //区域报警方向(i = 0 正向，1就是反向  2就是双向)
                    NSString *dwAreaDirectStr = [self.dicCfg objectForKey:@"dwAreaDirect"];
                    NSInteger dwAreaDirect = [self numberWithHexString:dwAreaDirectStr];
                    for (int i = 0; i< 10 ; i++) {
                        if (dwAreaDirect & (0x01<<i)){
                            [self.areaDirectArray addObject:[NSNumber numberWithInt:i]];
                        }
                    }
                    
                    //区域形状(支持几种形状  i为2就是三边，3就是四边  以此类推)
                    NSString *dwAreaLineStr = [self.dicCfg objectForKey:@"dwAreaLine"];
                    NSInteger dwAreaLine = [self numberWithHexString:dwAreaLineStr];
                    for (int i = 0; i< 10 ; i++) {
                        if (dwAreaLine & (0x01<<i)){
                            // 屏蔽自定义
                            if (i == 7) {
                                break;
                            }
                            [self.areaLineArray addObject:[NSNumber numberWithInt:i]];
                        }
                    }
                    
                    //线性报警方向(i = 0 正向，1就是反向  2就是双向)
                    NSString *dwLineDirectStr = [self.dicCfg objectForKey:@"dwLineDirect"];
                    NSInteger dwLineDirect = [self numberWithHexString:dwLineDirectStr];
                    for (int i = 0; i< 10 ; i++) {
                        if (dwLineDirect & (0x01<<i)){
                            [self.lineDirectArray addObject:[NSNumber numberWithInt:i]];
                        }
                    }
                    
                    if (self.getConfigResult) {
                        self.getConfigResult(msg->param1);
                    }
                }else{
                    if (self.getConfigResult) {
                        self.getConfigResult(-1);
                    }
                }
            }else{
                if (self.getConfigResult) {
                    self.getConfigResult(msg->param1);
                }
            }
        }
            break;
        default:
            break;
    }
}

- (NSInteger)numberWithHexString:(NSString *)hexString{
    const char *hexChar = [hexString cStringUsingEncoding:NSUTF8StringEncoding];
    int hexNumber;
    sscanf(hexChar, "%x", &hexNumber);
    
    return (NSInteger)hexNumber;
}

- (void)dealloc{
    FUN_UnRegWnd(self.msgHandle);
    self.msgHandle = -1;
}

@end
