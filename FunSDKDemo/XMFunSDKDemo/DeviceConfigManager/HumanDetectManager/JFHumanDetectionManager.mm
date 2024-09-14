//
//  JFHumanDetectionManager.m
//   iCSee
//
//  Created by Megatron on 2023/8/22.
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import "JFHumanDetectionManager.h"
#import "FunSDK/FunSDK.h"
#import "NSDictionary+Extension.h"

@implementation JFHumanDetectionManager

//MARK: 获取人形检测规则配置
- (void)requestHumanDetectionConfigDeviceID:(NSString *)devID channel:(int)channel completed:(GetHumanDetectionCallBack)completion{
    self.devID = devID;
    self.channelNumber = channel;
    self.getHumanDetectionCallBack = completion;
    
    FUN_DevGetConfig_Json(self.msgHandle, [self.devID UTF8String], "Detect.HumanDetection", 0,self.channelNumber == -1 ? 0 : self.channelNumber);
}

//MARK: 设置人形检测规则配置
- (void)requestSaveConfigCompleted:(SetHumanDetectionCallBack)completion{
    self.setHumanDetectionCallBack = completion;
    
    if (self.dicCfg){
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:self.dicCfg options:NSJSONWritingPrettyPrinted error:&error];
        NSString *strValues = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        FUN_DevSetConfig_Json(self.msgHandle, [self.devID UTF8String],"Detect.HumanDetection",[strValues UTF8String] ,(int)[strValues length]+1,self.channelNumber == -1 ? 0 : self.channelNumber);
    }else{
        [self sendSetConfigResult:-1];
    }
}

- (void)sendGetConfigResult:(int)result{
    if (self.getHumanDetectionCallBack) {
        self.getHumanDetectionCallBack(result);
    }
}

- (void)sendSetConfigResult:(int)result{
    if (self.setHumanDetectionCallBack) {
        self.setHumanDetectionCallBack(result);
    }
}

//MARK: 获取人形检测是否开启
- (BOOL)getHumanDetectEnable{
    return [[self.dicCfg objectForKey:@"Enable"] boolValue];
}

//MARK: 设置人形检测是否开启
- (void)setHumanDetectEnable:(BOOL)enable{
    if (self.dicCfg) {
        [self.dicCfg setObject:[NSNumber numberWithBool:enable] forKey:@"Enable"];
    }
}

//MARK: 获取人形车形检测
- (int)getObjectType {
    if (self.dicCfg) {
        NSNumber *ObjectType = [self.dicCfg objectForKey:@"ObjectType"];
        return [ObjectType intValue];
    }
    return -1;
}
//MARK: 设置人形车形检测
- (void)setObjectTypeValue:(int)objectType {
    if (self.dicCfg) {
         
        [self.dicCfg setObject:[NSNumber numberWithInt:objectType] forKey:@"ObjectType"];
    }
}


//MARK: 获取显示踪迹是否开启
- (BOOL)getShowTrackEnable{
    return [[self.dicCfg objectForKey:@"ShowTrack"] boolValue];
}

//MARK: 设置显示踪迹是否开启
- (void)setShowTrackEnable:(BOOL)enable{
    if (self.dicCfg) {
        [self.dicCfg setObject:[NSNumber numberWithBool:enable] forKey:@"ShowTrack"];
    }
}

//MARK: 获取智能规则开关
- (BOOL)getHumanDetectRuleEnableWithPedRuleIndex:(int)pedRuleIndex{
    if (self.dicCfg) {
        NSArray *arrayPedRule = [self.dicCfg objectForKey:@"PedRule"];
        NSMutableDictionary *dicPedRule = [JFSafeArray(arrayPedRule, pedRuleIndex) mutableCopy];
        NSNumber *enableNumber = [dicPedRule objectForKey:@"Enable"];
        
        return [enableNumber boolValue];
    }
    
    return NO;
}

//MARK: 设置智能规则开关
- (void)setHumanDetectRuleEnable:(BOOL)enable pedRuleIndex:(int)pedRuleIndex{
    NSMutableArray *arrayPedRule = [[self.dicCfg objectForKey:@"PedRule"] mutableCopy];
    NSMutableDictionary *dicPedRule = [JFSafeArray(arrayPedRule, pedRuleIndex) mutableCopy];
    [dicPedRule setObject:[NSNumber numberWithBool:enable] forKey:@"Enable"];
    [arrayPedRule replaceObjectAtIndex:pedRuleIndex withObject:dicPedRule];
    [self.dicCfg setObject:arrayPedRule forKey:@"PedRule"];
}

//MARK: 获取警戒规则类型
- (int)getHumanDetectRuleTypeWithPedRuleIndex:(int)pedRuleIndex{
    if (self.dicCfg) {
        NSArray *arrayPedRule = [self.dicCfg objectForKey:@"PedRule"];
        NSDictionary *dicPedRule = JFSafeArray(arrayPedRule, pedRuleIndex);
        NSNumber *typeNumber = [dicPedRule objectForKey:@"RuleType"];
        
        return [typeNumber intValue];
    }
    
    return -1;
}

//MARK: 设置警戒规则类型 RuleType:0 线性报警 1:区域报警
- (void)setHumanDetectRuleType:(int)type pedRuleIndex:(int)pedRuleIndex{
    NSMutableArray *arrayPedRule = [[self.dicCfg objectForKey:@"PedRule"] mutableCopy];
    NSMutableDictionary *dicPedRule = [JFSafeArray(arrayPedRule, pedRuleIndex) mutableCopy];
    [dicPedRule setObject:[NSNumber numberWithInt:type] forKey:@"RuleType"];
    [arrayPedRule replaceObjectAtIndex:pedRuleIndex withObject:dicPedRule];
    [self.dicCfg setObject:arrayPedRule forKey:@"PedRule"];
}

//MARK: 获取报警区域点位配置
- (NSMutableArray *)getAlarmAreaPointsWithPedRuleIndex:(int)pedRuleIndex{
    NSArray *arrayPedRule = [self.dicCfg objectForKey:@"PedRule"];
    NSDictionary *dicPedRule = JFSafeArray(arrayPedRule, pedRuleIndex);
    NSDictionary *dicRuleRegion = JFSafeDictionary(dicPedRule, @"RuleRegion");
    NSMutableArray *arrayPts = [JFSafeDictionary(dicRuleRegion, @"Pts") mutableCopy];
    
    return JFForceArray(arrayPts);
}

//MARK: 获取报警线点位配置
- (NSMutableArray *)getAlarmLinePoints{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:0];
    NSArray *arrayPedRule = [self.dicCfg objectForKey:@"PedRule"];
    NSDictionary *dicPedRule = JFSafeArray(arrayPedRule, 0);
    NSDictionary *dicRuleLine = JFSafeDictionary(dicPedRule, @"RuleLine");
    NSDictionary *dicPts = JFSafeDictionary(dicRuleLine, @"Pts");
    NSNumber *numberSatrtX = JFSafeDictionary(dicPts, @"StartX");
    NSNumber *numberSatrtY = JFSafeDictionary(dicPts, @"StartY");
    NSNumber *numberStopX = JFSafeDictionary(dicPts, @"StopX");
    NSNumber *numberStopY = JFSafeDictionary(dicPts, @"StopY");
    if (numberSatrtX && numberSatrtY && numberStopX && numberStopY) {
        NSDictionary *dicStart = @{@"X":numberSatrtX,@"Y":numberSatrtY};
        NSDictionary *dicStop = @{@"X":numberStopX,@"Y":numberStopY};
        [result addObject:dicStart];
        [result addObject:dicStop];
    }
    
    return result;
}

//MARK: 设置报警区域点位
- (void)setAlarmAreaPoints:(NSMutableArray *)points pedRuleIndex:(int)pedRuleIndex{
    if (points && [points isKindOfClass:[NSArray class]]) {
        NSMutableArray *arrayPedRule = [[self.dicCfg objectForKey:@"PedRule"] mutableCopy];
        NSMutableDictionary *dicPedRule = [JFSafeArray(arrayPedRule, pedRuleIndex) mutableCopy];
        NSMutableDictionary *dicRuleRegion = [JFSafeDictionary(dicPedRule, @"RuleRegion") mutableCopy];
        [dicRuleRegion setObject:points forKey:@"Pts"];
        [dicPedRule setObject:dicRuleRegion forKey:@"RuleRegion"];
        [arrayPedRule replaceObjectAtIndex:pedRuleIndex withObject:dicPedRule];
        [self.dicCfg setObject:arrayPedRule forKey:@"PedRule"];
    }
}

///获取报警区域类型
- (int)areaPointNumWithPedRuleIndex:(int)pedRuleIndex{
    NSArray *arrayPedRule = [self.dicCfg objectForKey:@"PedRule"];
    int areaPointNum = [[[[arrayPedRule objectAtIndex:pedRuleIndex] objectForKey:@"RuleRegion"] objectForKey:@"PtsNum"] intValue];
    
    return areaPointNum;
}

//MARK: 设置报警区域类型
- (void)setAreaPointNum:(int)pointNum pedRuleIndex:(int)pedRuleIndex {
    NSMutableArray *arrayPedRule = [[self.dicCfg objectForKey:@"PedRule"] mutableCopy];
    NSMutableDictionary *dicPedRule =[[arrayPedRule objectAtIndex:pedRuleIndex] mutableCopy];
    NSMutableDictionary *dicRuleRegion = [[dicPedRule objectForKey:@"RuleRegion"] mutableCopy];
    [dicRuleRegion setObject:[NSNumber numberWithInt:pointNum] forKey:@"PtsNum"];
    [dicPedRule setObject:dicRuleRegion forKey:@"RuleRegion"];
    [arrayPedRule replaceObjectAtIndex:pedRuleIndex withObject:dicPedRule];
    [self.dicCfg setObject:arrayPedRule forKey:@"PedRule"];
}

- (void)baseOnFunSDKResult:(MsgContent *)msg{
    if (msg->id == EMSG_DEV_GET_CONFIG_JSON){
        if (msg->param1 < 0) {
            [self sendGetConfigResult:msg->param1];
        }else{
            NSDictionary *dicInfo = [NSDictionary dictionaryFromData:msg->pObject];
            if (dicInfo && [dicInfo isKindOfClass:[NSDictionary class]]) {
                NSString *cfgName = [dicInfo objectForKey:@"Name"];
                self.dicCfg = [[dicInfo objectForKey:cfgName] mutableCopy];
                NSArray *pedRuleArray = [self.dicCfg objectForKey:@"PedRule"];
                if (pedRuleArray.count > 0) {
                    self.RuleType = [[[pedRuleArray firstObject] objectForKey:@"RuleType"] intValue];
                }
                // 取出报警线类型和区域类型
                self.alarmDirection = [[[[pedRuleArray objectAtIndex:0] objectForKey:@"RuleLine"] objectForKey:@"AlarmDirect"] intValue];
                self.areaPointNum = [[[[pedRuleArray objectAtIndex:0] objectForKey:@"RuleRegion"] objectForKey:@"PtsNum"] intValue];
                [self sendGetConfigResult:msg->param1];
                return;
            }
            
            [self sendGetConfigResult:-1];
        }
    }else{
        [self sendSetConfigResult:msg->param1];
    }
}

@end
