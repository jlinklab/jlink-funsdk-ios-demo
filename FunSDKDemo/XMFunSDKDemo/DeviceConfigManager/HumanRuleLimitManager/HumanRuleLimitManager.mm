//
//  HumanRuleLimitManager.m
//   iCSee
//
//  Created by Megatron on 2023/8/18.
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import "HumanRuleLimitManager.h"
#import "FunSDK/FunSDK.h"
#import "NSDictionary+Extension.h"

@interface HumanRuleLimitManager ()

@property (nonatomic,strong) NSMutableDictionary *dicCfg;

@end
@implementation HumanRuleLimitManager

//MARK: 获取人形检测规则配置
- (void)requestHumanRuleLimitConfigDeviceID:(NSString *)devID channel:(int)channel completed:(GetHumanRuleLimitCallBack)completion {
    self.devID = devID;
    self.channelNumber = channel;
    self.getHumanRuleLimitCallBack = completion;
    self.areaLineArray = [[NSMutableArray alloc] initWithCapacity:0];
    self.lineDirectArray = [[NSMutableArray alloc] initWithCapacity:0];
    self.areaDirectArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    if (self.channelNumber == -1) {
        FUN_DevCmdGeneral(self.msgHandle, [self.devID UTF8String], 1360, "HumanRuleLimit", 4096, 20000, NULL, 0, -1, -1);
    }else{
        NSString *szCmd = [NSString stringWithFormat:@"ChannelHumanRuleLimit.[%d]",self.channelNumber];
        FUN_DevCmdGeneral(self.msgHandle, [self.devID UTF8String], 1362, [szCmd UTF8String], 4096, 20000, NULL, 0, -1, self.channelNumber);
    }
}

/// @brief 是否是多镜头的设备
/// @param 带有"MultiSensor"说明是多目的
/// @param "AreaNum": [1,1],          // 每个镜头支持几个警戒区域.e.g: 画面0,1 分别支持一个警戒区域. 如果不支持就赋值为0即可
/// @param "SensorOrder": [1,0]      // 镜头顺序. e.g:画面0对应SensorIndex 1, 画面1对应SensorIndex 0
- (BOOL)supportMultiSensor {
    BOOL supportMultiSensor = NO;
    if ([self.dicCfg objectForKey:@"MultiSensor"]) {
        supportMultiSensor = YES;
    }
    
    return supportMultiSensor;
}

/// 获取支持设置警戒区域镜头的数组 如果2个镜头都支持 返回 @[1,2] 只有镜头2支持返回@[2]
- (NSMutableArray *)supportAreaSensorList {
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:0];
    NSArray *arrayAreaNum = JFForceArray(JFSafeDictionary(JFSafeDictionary(self.dicCfg, @"MultiSensor"),@"AreaNum"));
    for (int i = 0; i < arrayAreaNum.count; i++) {
        int num = [[arrayAreaNum objectAtIndex:i] intValue];
        if (num >= 1) {
            [list addObject:[NSNumber numberWithInt:i]];
        }
    }
    
    return list;
}

/// @brief 获取镜头对应的警戒第x个警戒区域的 对应pedRule数组的index
/// @param sensorIndex表示第几个镜头 从0开始
/// @param areaIndex表示第几个警戒区域 从0开始
- (int)pedRuleArrayIndexWithSensorIndex:(int)sensorIndex areaIndex:(int)areaIndex {
    NSArray *arraySensorOrder = JFForceArray(JFSafeDictionary(JFSafeDictionary(self.dicCfg, @"MultiSensor"),@"SensorOrder"));
    int pedRuleIndex = 0;
    int areaIndexSearched = -1;
    for (int i = 0; i < arraySensorOrder.count; i++) {
        if ([[arraySensorOrder objectAtIndex:i] intValue] == sensorIndex) {
            areaIndexSearched = areaIndexSearched + 1;
            if (areaIndexSearched == areaIndex) {
                pedRuleIndex = i;
                break;
            }
        }
    }
    
    return pedRuleIndex;
}

- (void)sendGetConfigResult:(int)result{
    if (self.getHumanRuleLimitCallBack) {
        self.getHumanRuleLimitCallBack(result);
    }
}

- (NSInteger)numberWithHexString:(NSString *)hexString {
    const char *hexChar = [hexString cStringUsingEncoding:NSUTF8StringEncoding];
    int hexNumber;
    sscanf(hexChar, "%x", &hexNumber);
    
    return (NSInteger)hexNumber;
}

//MARK: OnFunSDKResult
- (void)baseOnFunSDKResult:(MsgContent *)msg {
    if (msg->id == EMSG_DEV_CMD_EN){
        if (msg->param1 < 0) {
            [self sendGetConfigResult:msg->param1];
        }else{
            NSDictionary *dicInfo = [NSDictionary dictionaryFromData:msg->pObject];
            if (dicInfo && [dicInfo isKindOfClass:[NSDictionary class]]) {
                NSString *cfgName = [dicInfo objectForKey:@"Name"];
                if ([cfgName isEqualToString:@"HumanRuleLimit"] || [cfgName isEqualToString:[NSString stringWithFormat:@"ChannelHumanRuleLimit.[%d]",msg->seq]]) {
                    NSDictionary *dicCfg = [dicInfo objectForKey:cfgName];
                    if ([dicCfg isKindOfClass:[NSDictionary class]]) {
                        self.dicCfg = [dicCfg mutableCopy];
                        //支持警戒线设置
                        self.supportLine = [[dicCfg objectForKey:@"SupportLine"] boolValue];
                        //支持警戒区域设置
                        self.supportArea = [[dicCfg objectForKey:@"SupportArea"] boolValue];
                        //支持轨迹跟踪
                        self.supportShowTrack = [[dicCfg objectForKey:@"ShowTrack"] boolValue];
                        //区域报警方向(i = 0 正向，1就是反向  2就是双向)
                        NSString *dwAreaDirectStr = [dicCfg objectForKey:@"dwAreaDirect"];
                        NSInteger dwAreaDirect = [self numberWithHexString:dwAreaDirectStr];
                        for (int i = 0; i< 10 ; i++) {
                            if (dwAreaDirect & (0x01<<i)){
                                [self.areaDirectArray addObject:[NSNumber numberWithInt:i]];
                            }
                        }
                        //区域形状(支持几种形状  i为2就是三边，3就是四边  以此类推)
                        NSString *dwAreaLineStr = [dicCfg objectForKey:@"dwAreaLine"];
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
                        NSString *dwLineDirectStr = [dicCfg objectForKey:@"dwLineDirect"];
                        NSInteger dwLineDirect = [self numberWithHexString:dwLineDirectStr];
                        for (int i = 0; i< 10 ; i++) {
                            if (dwLineDirect & (0x01<<i)){
                                [self.lineDirectArray addObject:[NSNumber numberWithInt:i]];
                            }
                        }
                        //
                        self.dwLowObjectType = [dicCfg objectForKey:@"dwLowObjectType"];
                        [self sendGetConfigResult:msg->param1];
                        return;
                    }
                }
            }
            
            [self sendGetConfigResult:-1];
        }
    }
}

@end
