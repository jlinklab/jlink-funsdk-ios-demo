//
//  BatteryInfoManager.h
//   iCSee
//
//  Created by 一位神秘的码农 on 2023/2/27.
//  Copyright © 2023 xiongmaitech. All rights reserved.

#import <Foundation/Foundation.h>

typedef NS_ENUM(int,LPDevWorkMode) {
    LPDevWorkMode_unkown = -1,               //未知
    LPDevWorkMode_LowConsumption = 0,        //低功耗模式
    LPDevWorkMode_NoSleep = 1                //常电模式
};

typedef void(^LPWorkModeSwitchV2)(int result);
typedef void(^SetLPWorkModeSwitchV2)(int success);
typedef void(^LPDevWorkModeValue)(LPDevWorkMode value);


@interface BatteryInfoManager : NSObject

@property (nonatomic, copy) LPWorkModeSwitchV2 LPWorkMode;
@property (nonatomic, copy) SetLPWorkModeSwitchV2 setLPWorkMode;
@property (nonatomic, copy) LPDevWorkModeValue WorkModeValue;

#pragma mark -- 获取低常模式配置项
-(void)getLPWorkModeSwitchV2:(NSString *)devID Completion:(LPWorkModeSwitchV2)completion;

#pragma mark -- 设置低常模式配置项
-(void)setLPWorkModeSwitchV2:(NSString *)devID Completion:(SetLPWorkModeSwitchV2)completion;

#pragma mark -- 获取配置值,低功耗模式和常电模式切换
-(void)LPDevWorkMode:(NSString *)devID ActualTimeValue:(BOOL)actual Completion:(LPDevWorkModeValue)completion;

#pragma mark -- 获取本地配置值,低功耗模式和常电模式切换
-(LPDevWorkMode)LPDevWorkModeFromLocal:(NSString *)devID;

#pragma mark -- 获取设备电量阈值
-(int)powerThresholdValue;
#pragma mark -- 获取智能省电模式（实时=1  省电=0）
- (int)getWorkStateNow;
#pragma mark -- 修改配置,低功耗模式和常电模式切换
-(void)modifyLPDevWorkMode:(LPDevWorkMode)mode;

@end

