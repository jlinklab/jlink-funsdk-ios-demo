//
//  DetectCryDetectionManager.m
//  iCSee
//
//  Created by Megatron on 2023/09/25
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import "DetectCryDetectionManager.h"
#import <FunSDK/FunSDK.h>
#import "NSString+Utils.h"
#import "NSDictionary+Extension.h"

@interface DetectCryDetectionManager ()

@property (nonatomic,strong) NSMutableArray *arrayCfg;

@end
@implementation DetectCryDetectionManager

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

//MARK: 获取哭声检测配置
- (void)requestDetectCryDetectionWithDevice:(NSString *)devID completed:(GetDetectCryDetectionCallBack)completion{
    self.devID = devID;
    self.getDetectCryDetectionCallBack = completion;

    NSString *cfgName = @"Detect.CryDetection";
    NSDictionary *dic = @{@"Name":cfgName,@"SessionID":@"0x0000000001"};
    NSString *str = [NSString convertToJSONData:dic];
    int size = [NSString getCharArraySize:str];
    char cfg[size];
    memcpy(cfg, [str cStringUsingEncoding:NSUTF8StringEncoding], 2*[str length]);

    FUN_DevCmdGeneral(self.msgHandle, self.devID.UTF8String, 1042, cfgName.UTF8String, -1, 15000, cfg, (int)strlen(cfg) + 1, -1, 1042);
}

//MARK: 保存哭声检测配置
- (void)requestSaveDetectCryDetectionCompleted:(GetDetectCryDetectionCallBack)completion{
    self.setDetectCryDetectionCallBack = completion;

    if (!self.arrayCfg) {
        [self sendSetDetectCryDetectionResult:-1];
        return;
    }

    NSString *cfgName = @"Detect.CryDetection";
    NSDictionary *dic = @{@"Name":cfgName,@"SessionID":@"0x0000000001",cfgName:self.arrayCfg};
    NSString *str = [NSString convertToJSONData:dic];
    int size = [NSString getCharArraySize:str];
    char cfg[size];
    memcpy(cfg, [str cStringUsingEncoding:NSUTF8StringEncoding], 2*[str length]);

    FUN_DevCmdGeneral(self.msgHandle, self.devID.UTF8String, 1040, cfgName.UTF8String, -1, 15000, cfg, (int)strlen(cfg) + 1, -1, 1040);
}

//MARK: 获取和设置【Enable】配置项
- (BOOL)enable{
    if (self.arrayCfg) {
        NSDictionary *dicCfg = [self.arrayCfg objectAtIndex:0];
        if (dicCfg && [dicCfg isKindOfClass:[NSDictionary class]]) {
            BOOL enable = [[dicCfg objectForKey:@"Enable"] boolValue];
            return enable;
        }
    }

    return NO;
}

- (void)setEnable:(BOOL)enable{
    if (self.arrayCfg) {
        NSMutableDictionary *dicCfg = [[self.arrayCfg objectAtIndex:0] mutableCopy];
        if (dicCfg && [dicCfg isKindOfClass:[NSDictionary class]]) {
            [dicCfg setObject:[NSNumber numberWithBool:enable] forKey:@"Enable"];
            [self.arrayCfg replaceObjectAtIndex:0 withObject:dicCfg];
        }
    }
}

//MARK: 获取和设置【Sensitivity】配置项
- (int)sensitivity{
    if (self.arrayCfg) {
        NSDictionary *dicCfg = [self.arrayCfg objectAtIndex:0];
        if (dicCfg && [dicCfg isKindOfClass:[NSDictionary class]]) {
            int sensitivity = [[dicCfg objectForKey:@"Sensitivity"] intValue];
            return sensitivity;
        }
    }

    return 0;
}

- (void)setSensitivity:(int)sensitivity{
    if (self.arrayCfg) {
        NSMutableDictionary *dicCfg = [[self.arrayCfg objectAtIndex:0] mutableCopy];
        if (dicCfg && [dicCfg isKindOfClass:[NSDictionary class]]) {
            [dicCfg setObject:[NSNumber numberWithInt:sensitivity] forKey:@"Sensitivity"];
            [self.arrayCfg replaceObjectAtIndex:0 withObject:dicCfg];
        }
    }
}

//MARK: 获取和设置【TimeSection】配置项
- (NSArray *)timeSection{
    if (self.arrayCfg) {
        NSDictionary *dicCfg = [self.arrayCfg objectAtIndex:0];
        if (dicCfg && [dicCfg isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dicEventHandler = [dicCfg objectForKey:@"EventHandler"];
            if (dicEventHandler && [dicEventHandler isKindOfClass:[NSDictionary class]]) {
                NSArray * timeSection = [dicEventHandler objectForKey:@"TimeSection"];
                return timeSection;
            }
        }
    }

    return nil;
}

- (void)setTimeSection:(NSArray *)timeSection{
    if (self.arrayCfg) {
        NSMutableDictionary *dicCfg = [[self.arrayCfg objectAtIndex:0] mutableCopy];
        if (dicCfg && [dicCfg isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *dicEventHandler = [[dicCfg objectForKey:@"EventHandler"] mutableCopy];
            if (dicEventHandler && [dicEventHandler isKindOfClass:[NSDictionary class]]) {
                [dicEventHandler setObject:timeSection forKey:@"TimeSection"];
                [dicCfg setObject:dicEventHandler forKey:@"EventHandler"];
                [self.arrayCfg replaceObjectAtIndex:0 withObject:dicCfg];
            }
        }
    }
}

//MARK: 获取和设置【MessageEnable】配置项
- (BOOL)messageEnable{
    BOOL enable = NO;
    if (self.arrayCfg) {
        NSDictionary *dicCfg = [self.arrayCfg objectAtIndex:0];
        if (dicCfg && [dicCfg isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dicEventHandler = [dicCfg objectForKey:@"EventHandler"];
            if (dicEventHandler && [dicEventHandler isKindOfClass:[NSDictionary class]]) {
                enable = [[dicEventHandler objectForKey:@"MessageEnable"] boolValue];
                return enable;
            }
        }
    }

    return enable;
}

- (void)setMessageEnable:(BOOL)enable{
    if (self.arrayCfg) {
        NSMutableDictionary *dicCfg = [[self.arrayCfg objectAtIndex:0] mutableCopy];
        if (dicCfg && [dicCfg isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *dicEventHandler = [[dicCfg objectForKey:@"EventHandler"] mutableCopy];
            if (dicEventHandler && [dicEventHandler isKindOfClass:[NSDictionary class]]) {
                [dicEventHandler setObject:[NSNumber numberWithBool:enable] forKey:@"MessageEnable"];
                [dicCfg setObject:dicEventHandler forKey:@"EventHandler"];
                [self.arrayCfg replaceObjectAtIndex:0 withObject:dicCfg];
            }
        }
    }
}

//MARK: 是否是自定义报警
- (BOOL)isCustomPeriod {
    BOOL isCustomPeriod = YES;
    NSString *sData = [[[self timeSection] objectAtIndex:0] objectAtIndex:0];
    
    //    NSString *sData = OCSTR(self.jDetect_MotionDetect->mEventHandler.TimeSection[0][0].Value());
    if ( sData.length ) {
        if ([[sData substringWithRange:NSMakeRange(0, 1)] boolValue]) {
            isCustomPeriod = NO;
        }
    }
    return isCustomPeriod;
}

- (void)sendGetDetectCryDetectionResult:(int)result{
    if (self.getDetectCryDetectionCallBack) {
        self.getDetectCryDetectionCallBack(result);
    }
}

- (void)sendSetDetectCryDetectionResult:(int)result{
    if (self.setDetectCryDetectionCallBack) {
        self.setDetectCryDetectionCallBack(result);
    }
}

//MARK: FunSDK CallBack
- (void)baseOnFunSDKResult:(MsgContent *)msg{
    switch (msg->id) {
        case EMSG_DEV_CMD_EN:
        {
            if (msg->seq == 1042) {
                if (msg->param1 >= 0) {
                    NSDictionary *jsonDic = [NSDictionary dictionaryFromData:msg->pObject];
                    if (jsonDic && [jsonDic isKindOfClass:[NSDictionary class]]) {
                        NSArray *arrayInfo = [jsonDic objectForKey:@"Detect.CryDetection"];
                        if (arrayInfo && [arrayInfo isKindOfClass:[NSArray class]]) {
                            self.arrayCfg = [arrayInfo mutableCopy];
                            [self sendGetDetectCryDetectionResult:msg->param1];
                            return;
                        }
                    }
                }

                [self sendGetDetectCryDetectionResult:-1];
            }else if (msg->seq == 1040){
                [self sendSetDetectCryDetectionResult:msg->param1];
            }
        }
            break;
        default:
            break;
    }
}

@end







