//
//  DetectPetDetectionManager.m
//  iCSee
//
//  Created by Megatron on 2023/09/25
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import "DetectPetDetectionManager.h"
#import <FunSDK/FunSDK.h>
#import "NSString+Utils.h"
#import "NSDictionary+Extension.h"

@interface DetectPetDetectionManager ()

@property (nonatomic,strong) NSMutableArray *arrayCfg;

@end
@implementation DetectPetDetectionManager

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

//MARK: 获取宠物检测配置
- (void)requestDetectPetDetectionWithDevice:(NSString *)devID completed:(GetDetectPetDetectionCallBack)completion{
    self.devID = devID;
    self.getDetectPetDetectionCallBack = completion;

    NSString *cfgName = @"Detect.PetDetection";
    NSDictionary *dic = @{@"Name":cfgName,@"SessionID":@"0x0000000001"};
    NSString *str = [NSString convertToJSONData:dic];
    int size = [NSString getCharArraySize:str];
    char cfg[size];
    memcpy(cfg, [str cStringUsingEncoding:NSUTF8StringEncoding], 2*[str length]);

    FUN_DevCmdGeneral(self.msgHandle, self.devID.UTF8String, 1042, cfgName.UTF8String, -1, 15000, cfg, (int)strlen(cfg) + 1, -1, 1042);
}

//MARK: 保存宠物检测配置
- (void)requestSaveDetectPetDetectionCompleted:(GetDetectPetDetectionCallBack)completion{
    self.setDetectPetDetectionCallBack = completion;

    if (!self.arrayCfg) {
        [self sendSetDetectPetDetectionResult:-1];
        return;
    }

    NSString *cfgName = @"Detect.PetDetection";
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

//MARK: 获取和设置【SnapEnable】配置项
- (BOOL)snapEnable{
    if (self.arrayCfg) {
        NSDictionary *dicCfg = [self.arrayCfg objectAtIndex:0];
        if (dicCfg && [dicCfg isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dicEventHandler = [dicCfg objectForKey:@"EventHandler"];
            if (dicEventHandler && [dicEventHandler isKindOfClass:[NSDictionary class]]) {
                BOOL snapEnable = [[dicEventHandler objectForKey:@"SnapEnable"] boolValue];
                return snapEnable;
            }
        }
    }

    return NO;
}

- (void)setSnapEnable:(BOOL)snapEnable{
    if (self.arrayCfg) {
        NSMutableDictionary *dicCfg = [[self.arrayCfg objectAtIndex:0] mutableCopy];
        if (dicCfg && [dicCfg isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *dicEventHandler = [[dicCfg objectForKey:@"EventHandler"] mutableCopy];
            if (dicEventHandler && [dicEventHandler isKindOfClass:[NSDictionary class]]) {
                [dicEventHandler setObject:[NSNumber numberWithBool:snapEnable] forKey:@"SnapEnable"];
                [dicCfg setObject:dicEventHandler forKey:@"EventHandler"];
                [self.arrayCfg replaceObjectAtIndex:0 withObject:dicCfg];
            }
        }
    }
}

//MARK: 获取和设置【SnapShotMask】配置项
- (NSString *)snapShotMask{
    if (self.arrayCfg) {
        NSDictionary *dicCfg = [self.arrayCfg objectAtIndex:0];
        if (dicCfg && [dicCfg isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dicEventHandler = [dicCfg objectForKey:@"EventHandler"];
            if (dicEventHandler && [dicEventHandler isKindOfClass:[NSDictionary class]]) {
                NSString * snapShotMask = [dicEventHandler objectForKey:@"SnapShotMask"];
                return snapShotMask;
            }
        }
    }

    return @"";
}

- (void)setSnapShotMask:(NSString *)snapShotMask{
    if (self.arrayCfg) {
        NSMutableDictionary *dicCfg = [[self.arrayCfg objectAtIndex:0] mutableCopy];
        if (dicCfg && [dicCfg isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *dicEventHandler = [[dicCfg objectForKey:@"EventHandler"] mutableCopy];
            if (dicEventHandler && [dicEventHandler isKindOfClass:[NSDictionary class]]) {
                [dicEventHandler setObject:snapShotMask forKey:@"SnapShotMask"];
                [dicCfg setObject:dicEventHandler forKey:@"EventHandler"];
                [self.arrayCfg replaceObjectAtIndex:0 withObject:dicCfg];
            }
        }
    }
}

//MARK: 获取和设置【RecordEnable】配置项
- (BOOL)recordEnable{
    if (self.arrayCfg) {
        NSDictionary *dicCfg = [self.arrayCfg objectAtIndex:0];
        if (dicCfg && [dicCfg isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dicEventHandler = [dicCfg objectForKey:@"EventHandler"];
            if (dicEventHandler && [dicEventHandler isKindOfClass:[NSDictionary class]]) {
                BOOL recordEnable = [[dicEventHandler objectForKey:@"RecordEnable"] boolValue];
                return recordEnable;
            }
        }
    }

    return NO;
}

- (void)setRecordEnable:(BOOL)recordEnable{
    if (self.arrayCfg) {
        NSMutableDictionary *dicCfg = [[self.arrayCfg objectAtIndex:0] mutableCopy];
        if (dicCfg && [dicCfg isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *dicEventHandler = [[dicCfg objectForKey:@"EventHandler"] mutableCopy];
            if (dicEventHandler && [dicEventHandler isKindOfClass:[NSDictionary class]]) {
                [dicEventHandler setObject:[NSNumber numberWithBool:recordEnable] forKey:@"RecordEnable"];
                [dicCfg setObject:dicEventHandler forKey:@"EventHandler"];
                [self.arrayCfg replaceObjectAtIndex:0 withObject:dicCfg];
            }
        }
    }
}

//MARK: 获取和设置【RecordMask】配置项
- (NSString *)recordMask{
    if (self.arrayCfg) {
        NSDictionary *dicCfg = [self.arrayCfg objectAtIndex:0];
        if (dicCfg && [dicCfg isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dicEventHandler = [dicCfg objectForKey:@"EventHandler"];
            if (dicEventHandler && [dicEventHandler isKindOfClass:[NSDictionary class]]) {
                NSString * recordMask = [dicEventHandler objectForKey:@"RecordMask"];
                return recordMask;
            }
        }
    }

    return @"";
}

- (void)setRecordMask:(NSString *)recordMask{
    if (self.arrayCfg) {
        NSMutableDictionary *dicCfg = [[self.arrayCfg objectAtIndex:0] mutableCopy];
        if (dicCfg && [dicCfg isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *dicEventHandler = [[dicCfg objectForKey:@"EventHandler"] mutableCopy];
            if (dicEventHandler && [dicEventHandler isKindOfClass:[NSDictionary class]]) {
                [dicEventHandler setObject:recordMask forKey:@"RecordMask"];
                [dicCfg setObject:dicEventHandler forKey:@"EventHandler"];
                [self.arrayCfg replaceObjectAtIndex:0 withObject:dicCfg];
            }
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

//MARK: 判断报警方式
- (int)getAlarmTimePeriod{
    int result = -1;
    NSArray *timeSection = [self timeSection];
    if (timeSection) {
        result = 1;
        NSString *sData = timeSection[0][0];
        if ( sData.length ) {
            if ([[sData substringWithRange:NSMakeRange(0, 1)] boolValue]) {
                result = 0;
            }
        }
    }
    
    return result;
}

- (void)sendGetDetectPetDetectionResult:(int)result{
    if (self.getDetectPetDetectionCallBack) {
        self.getDetectPetDetectionCallBack(result);
    }
}

- (void)sendSetDetectPetDetectionResult:(int)result{
    if (self.setDetectPetDetectionCallBack) {
        self.setDetectPetDetectionCallBack(result);
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
                        NSArray *arrayInfo = [jsonDic objectForKey:@"Detect.PetDetection"];
                        if (arrayInfo && [arrayInfo isKindOfClass:[NSArray class]]) {
                            self.arrayCfg = [arrayInfo mutableCopy];
                            [self sendGetDetectPetDetectionResult:msg->param1];
                            return;
                        }
                    }
                }

                [self sendGetDetectPetDetectionResult:-1];
            }else if (msg->seq == 1040){
                [self sendSetDetectPetDetectionResult:msg->param1];
            }
        }
            break;
        default:
            break;
    }
}

@end







