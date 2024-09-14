//
//  HumanRuleLimitManager.h
//   iCSee
//
//  Created by Megatron on 2023/8/18.
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FunSDKBaseObject.h"
typedef void(^GetHumanRuleLimitCallBack)(int result);

NS_ASSUME_NONNULL_BEGIN

/**
 人形检测规则配置管理器
 */
@interface HumanRuleLimitManager : FunSDKBaseObject

@property (nonatomic,copy) GetHumanRuleLimitCallBack getHumanRuleLimitCallBack;

/**
 下面几个参数控制区域人形检测
 */
/**是否支持警戒线设置**/
@property (nonatomic,assign) BOOL supportLine;
/**是否支持警戒区域设置**/
@property (nonatomic,assign) BOOL supportArea;
/**是否支持轨迹跟踪**/
@property (nonatomic,assign) BOOL supportShowTrack;
// "0x3". // e.g 支持人行/车型
@property (nonatomic,copy)NSString *dwLowObjectType;
/**区域方向**/
@property (nonatomic, strong) NSMutableArray* areaDirectArray;
/**区域形状(一个数组  里面值多少就是支持几种类型   比如：@[3，4，5],就是支持四边形，五边形和六边形)**/
@property (nonatomic, strong) NSMutableArray* areaLineArray;
/**
 下面几个参数控制线性人形检测
 */
/**线性方向**/
@property (nonatomic, strong) NSMutableArray* lineDirectArray;

/**
 @brief 获取人形检测规则配置
 @param devID 设备序列号
 @param channel 通道号 IPC： -1  多通道设备： >= 0
 @param completion GetHumanRuleLimitCallBack  请求结果回调 按照FunSDK标准结果返回处理
 */
- (void)requestHumanRuleLimitConfigDeviceID:(NSString *)devID channel:(int)channel completed:(GetHumanRuleLimitCallBack)completion;

/// @brief 是否是多镜头的设备
/// @param 带有"MultiSensor"说明是多目的
/// @param "AreaNum": [1,1],          // 每个镜头支持几个警戒区域.e.g: 画面0,1 分别支持一个警戒区域. 如果不支持就赋值为0即可
/// @param "SensorOrder": [1,0]      // // 警戒区域排序. pedrule数组对应的的数字表示支持的镜头 第0个是1表示数组第0个是镜头1的警戒区域配置
- (BOOL)supportMultiSensor;
/// 获取支持设置警戒区域镜头的数组 如果2个镜头都支持 返回 @[0,1] 只有镜头2支持返回@[1] 注意配置镜头是从0开始计算的，但是APP显示是从1开始的
- (NSMutableArray *)supportAreaSensorList;
/// @brief 获取镜头对应的警戒第x个警戒区域的 对应pedRule数组的index
/// @param sensorIndex表示第几个镜头 从0开始
/// @param areaIndex表示第几个警戒区域 从0开始
- (int)pedRuleArrayIndexWithSensorIndex:(int)sensorIndex areaIndex:(int)areaIndex;

@end

NS_ASSUME_NONNULL_END
