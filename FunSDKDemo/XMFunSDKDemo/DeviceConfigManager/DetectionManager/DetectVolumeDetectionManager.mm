//
//  DetectVolumeDetectionManager.m
//  iCSee
//
//  Created by Megatron on 2023/09/25
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import "DetectVolumeDetectionManager.h"
#import <FunSDK/FunSDK.h>
#import "NSString+Utils.h"
#import "NSDictionary+Extension.h"

@interface DetectVolumeDetectionManager ()

@property (nonatomic,strong) NSMutableDictionary *dicCfg;

@end
@implementation DetectVolumeDetectionManager

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

//MARK: 获取异响检测配置
- (void)requestDetectVolumeDetectionWithDevice:(NSString *)devID completed:(GetDetectVolumeDetectionCallBack)completion{
    self.devID = devID;
    self.getDetectVolumeDetectionCallBack = completion;

    NSString *cfgName = @"Detect.VolumeDetection";
    NSDictionary *dic = @{@"Name":cfgName,@"SessionID":@"0x0000000001"};
    NSString *str = [NSString convertToJSONData:dic];
    int size = [NSString getCharArraySize:str];
    char cfg[size];
    memcpy(cfg, [str cStringUsingEncoding:NSUTF8StringEncoding], 2*[str length]);

    FUN_DevCmdGeneral(self.msgHandle, self.devID.UTF8String, 1042, cfgName.UTF8String, -1, 15000, cfg, (int)strlen(cfg) + 1, -1, 1042);
}

//MARK: 保存异响检测配置
- (void)requestSaveDetectVolumeDetectionCompleted:(GetDetectVolumeDetectionCallBack)completion{
    self.setDetectVolumeDetectionCallBack = completion;

    if (!self.dicCfg) {
        [self sendSetDetectVolumeDetectionResult:-1];
        return;
    }

    NSString *cfgName = @"Detect.VolumeDetection";
    NSDictionary *dic = @{@"Name":cfgName,@"SessionID":@"0x0000000001",cfgName:self.dicCfg};
    NSString *str = [NSString convertToJSONData:dic];
    int size = [NSString getCharArraySize:str];
    char cfg[size];
    memcpy(cfg, [str cStringUsingEncoding:NSUTF8StringEncoding], 2*[str length]);

    FUN_DevCmdGeneral(self.msgHandle, self.devID.UTF8String, 1040, cfgName.UTF8String, -1, 15000, cfg, (int)strlen(cfg) + 1, -1, 1040);
}

//MARK: 获取和设置【Enable】配置项
- (BOOL)enable{
    if (self.dicCfg) {
        BOOL enable = [[self.dicCfg objectForKey:@"Enable"] boolValue];
        return enable;
    }

    return NO;
}

- (void)setEnable:(BOOL)enable{
    if (self.dicCfg) {
        [self.dicCfg setObject:[NSNumber numberWithBool:enable] forKey:@"Enable"];
    }
}

//MARK: 获取和设置【TimeSection】配置项
- (NSArray *)timeSection{
    if (self.dicCfg) {
        NSDictionary *dicEventHandler = [self.dicCfg objectForKey:@"EventHandler"];
        if (dicEventHandler && [dicEventHandler isKindOfClass:[NSDictionary class]]) {
            NSArray * timeSection = [dicEventHandler objectForKey:@"TimeSection"];
            return timeSection;
        }
    }

    return nil;
}

- (void)setTimeSection:(NSArray *)timeSection{
    if (self.dicCfg) {
        NSMutableDictionary *dicEventHandler = [[self.dicCfg objectForKey:@"EventHandler"] mutableCopy];
        if (dicEventHandler && [dicEventHandler isKindOfClass:[NSDictionary class]]) {
            [dicEventHandler setObject:timeSection forKey:@"TimeSection"];
            [self.dicCfg setObject:dicEventHandler forKey:@"EventHandler"];
        }
    }
}

//MARK: 获取和设置【MessageEnable】配置项
- (BOOL)messageEnable{
    BOOL enable = NO;
    if (self.dicCfg) {
        NSDictionary *dicEventHandler = [self.dicCfg objectForKey:@"EventHandler"];
        if (dicEventHandler && [dicEventHandler isKindOfClass:[NSDictionary class]]) {
            enable = [[dicEventHandler objectForKey:@"MessageEnable"] boolValue];
            return enable;
        }
    }

    return enable;
}

- (void)setMessageEnable:(BOOL)enable{
    if (self.dicCfg) {
        NSMutableDictionary *dicEventHandler = [[self.dicCfg objectForKey:@"EventHandler"] mutableCopy];
        if (dicEventHandler && [dicEventHandler isKindOfClass:[NSDictionary class]]) {
            [dicEventHandler setObject:[NSNumber numberWithBool:enable] forKey:@"MessageEnable"];
            [self.dicCfg setObject:dicEventHandler forKey:@"EventHandler"];
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

//MARK: 获取和设置【Sensitivity】配置项
- (int)sensitivity{
    if (self.dicCfg) {
        int sensitivity = [[self.dicCfg objectForKey:@"Sensitivity"] intValue];
        return sensitivity;
    }

    return 0;
}

- (void)setSensitivity:(int)sensitivity{
    if (self.dicCfg) {
        [self.dicCfg setObject:[NSNumber numberWithInt:sensitivity] forKey:@"Sensitivity"];
    }
}

- (void)sendGetDetectVolumeDetectionResult:(int)result{
    if (self.getDetectVolumeDetectionCallBack) {
        self.getDetectVolumeDetectionCallBack(result);
    }
}

- (void)sendSetDetectVolumeDetectionResult:(int)result{
    if (self.setDetectVolumeDetectionCallBack) {
        self.setDetectVolumeDetectionCallBack(result);
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
                        NSDictionary *dicInfo = [jsonDic objectForKey:@"Detect.VolumeDetection"];
                        if (dicInfo && [dicInfo isKindOfClass:[NSDictionary class]]) {
                            self.dicCfg = [dicInfo mutableCopy];
                            [self sendGetDetectVolumeDetectionResult:msg->param1];
                            return;
                        }
                    }
                }

                [self sendGetDetectVolumeDetectionResult:-1];
            }else if (msg->seq == 1040){
                [self sendSetDetectVolumeDetectionResult:msg->param1];
            }
        }
            break;
        default:
            break;
    }
}

@end







