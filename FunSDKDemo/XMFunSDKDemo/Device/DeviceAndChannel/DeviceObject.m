//
//  DeviceObject.m
//  XMEye
//
//  Created by XM on 2018/4/13.
//  Copyright © 2018年 Megatron. All rights reserved.
//

#import "DeviceObject.h"

@implementation DeviceObject

- (instancetype)init {
    self = [super init];
    if (self) {
        _deviceMac = @"";
        _deviceName = @"";
        _loginName = @"admin";
        _loginPsw = @"";
        _nPort = 34567;
        _nType = 0;
        _nID = 0;
        _state = -1;
        _eFunDevStateNotCode = -1;
        _channelArray = [[NSMutableArray alloc] initWithCapacity:0];
        _info = [[ObSysteminfo alloc] init];
        _sysFunction = [[ObSystemFunction alloc] init];
        _enableEpitomeRecord = NO;
        _threeScreen = @"";
    }
    return self;
}

-(BOOL)getDeviceTypeLowPowerConsumption{
    if (self.nType == XM_DEV_DOORBELL || self.nType == XM_DEV_CAT || self.nType == CZ_DOORBELL || self.nType == XM_DEV_INTELLIGENT_LOCK || self.nType == XM_DEV_LOW_POWER || self.nType == XM_DEV_DOORLOCK_V2 || self.nType == XM_DEV_LOCK_CAT) {
        return YES;
    }else{
        return NO;
    }
}

/**缓存的上下反转配置 -1:未缓存 0:关闭 1:开启*/
- (int)PTZUpsideDown:(int)channel{
    return [self PTZReverse:channel index:0];
}

/**缓存的左右反转配置 -1:未缓存 0:关闭 1:开启*/
- (int)PTZLeftRightReverse:(int)channel{
    return [self PTZReverse:channel index:1];
}

/**缓存的是否修改配置 -1:未缓存 0:否 1:是*/
- (int)PTZModifyCfgReverse:(int)channel{
    return [self PTZReverse:channel index:2];
}

/**缓存上下左右反转配置*/
- (void)setPTZUpsideDownValue:(int)valueUD leftRightReverseValue:(int)valueLR modifyCfg:(int)valueModify channel:(int)channel{
    NSMutableDictionary *dicCfg = [[self dicPTZReverse] mutableCopy];
    if (!dicCfg){
        dicCfg = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    
    NSString *key = [NSString stringWithFormat:@"%i",channel];
    [dicCfg setObject:[NSString stringWithFormat:@"%i:%i:%i",valueUD,valueLR,valueModify] forKey:key];
    NSString *strCfg = [NSString convertToJSONData:dicCfg];
    self.sPTZReverseCfg = strCfg;
}

- (int)PTZReverse:(int)channel index:(int)index{
    NSDictionary *dicCfg = [self dicPTZReverse];
    if (dicCfg){
        NSString *key = [NSString stringWithFormat:@"%i",channel];
        NSString *strContent = [dicCfg objectForKey:key];
        if (strContent.length > 0){
            NSArray *array = [strContent componentsSeparatedByString:@":"];
            if (array.count > 1){
                NSString *strValue = [array objectAtIndex:index];
                if (strValue){
                    return [strValue intValue];
                }
            }
        }
    }
    
    return -1;
}


- (NSDictionary *)dicPTZReverse{
    //判断是否有缓存值
    NSString *strCfg = self.sPTZReverseCfg;
    if (strCfg.length > 0){
        //配置转成字典
        NSDictionary *dicCfg = [NSString dictionaryWithJsonString:strCfg];
        if (dicCfg && [dicCfg isKindOfClass:[NSDictionary class]]){
            return dicCfg;
        }
    }
    
    return nil;
}

//MARK: - 是否蓝牙配网设备
- (BOOL)isMeshBLE{
    if (self.sPid && self.sPid.length > 0) {
        return ([self.sPid isEqualToString:@"HABLK0012000100H"]|| [self.sPid isEqualToString:@"HABLK0013000100I"]|| [self.sPid isEqualToString:@"HABLK00140001006"])? YES:NO;
    }
    return NO;
    
}
+ (BOOL)isMeshBLE:(NSString*)pid {
    return ([pid isEqualToString:@"HABLK0012000100H"]|| [pid isEqualToString:@"HABLK0013000100I"]|| [pid isEqualToString:@"HABLK00140001006"])? YES:NO;
}
@end
