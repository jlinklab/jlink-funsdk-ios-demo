//
//  JFDeviceLogInfoManager.h
//   iCSee
//
//  Created by Megatron on 2024/4/30.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FunSDKBaseObject.h"

typedef void(^GetBatteryInfoFromShadowServerCallBack)(int result);
typedef void(^SetBatteryInfoFromShadowServerCallBack)(int result);

NS_ASSUME_NONNULL_BEGIN

///AOV获取设备日志信息配置管理器
@interface JFDeviceLogInfoManager : FunSDKBaseObject

@property (nonatomic,copy) GetBatteryInfoFromShadowServerCallBack getBatteryInfoFromShadowServerCallBack;
@property (nonatomic,copy) SetBatteryInfoFromShadowServerCallBack setBatteryInfoFromShadowServerCallBack;

///电量信息的数据
@property (nonatomic, strong) NSMutableArray *arrayPower;
///信号量信息的数据
@property (nonatomic, strong) NSMutableArray *arraySignal;

- (void)requestDeviceLogWithDevice:(NSString *)devID startTime:(NSString *)startTime endTime:(NSString *)endTime completed:(GetBatteryInfoFromShadowServerCallBack)completion;

@end

NS_ASSUME_NONNULL_END
