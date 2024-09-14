//
//  JFHumanDetectionManager.h
//   iCSee
//
//  Created by Megatron on 2023/8/22.
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

//人形检测 新封装的工具类

#import <Foundation/Foundation.h>
#import "FunSDKBaseObject.h"

typedef void(^GetHumanDetectionCallBack)(int result);
typedef void(^SetHumanDetectionCallBack)(int result);

NS_ASSUME_NONNULL_BEGIN

@interface JFHumanDetectionManager : FunSDKBaseObject

@property (nonatomic,copy) GetHumanDetectionCallBack getHumanDetectionCallBack;
@property (nonatomic,copy) SetHumanDetectionCallBack setHumanDetectionCallBack;

/**人形检测配置**/
@property (nonatomic,strong) NSMutableDictionary *dicCfg;
/// 0:RuleLine  1:RuleRegion 当前目标检测规则是检测线还是区域
@property (nonatomic,assign) int RuleType;
@property (nonatomic,assign) int alarmDirection;    // 报警线类型
@property (nonatomic,assign) int areaPointNum;      // 报警区域类型
///是否是多镜头设备 多镜头设备报警区域部分需要区分不同镜头 通过RuleLimit配置判断
@property (nonatomic,assign) BOOL ifMultiSensor;

//MARK: 获取人形检测是否开启
- (BOOL)getHumanDetectEnable;
//MARK: 设置人形检测是否开启
- (void)setHumanDetectEnable:(BOOL)enable;
//MARK: 获取显示踪迹是否开启
- (BOOL)getShowTrackEnable;
//MARK: 设置显示踪迹是否开启
- (void)setShowTrackEnable:(BOOL)enable;
//MARK: 获取智能规则开关
- (BOOL)getHumanDetectRuleEnableWithPedRuleIndex:(int)pedRuleIndex;
//MARK: 设置智能规则开关
- (void)setHumanDetectRuleEnable:(BOOL)enable pedRuleIndex:(int)pedRuleIndex;
//MARK: 获取警戒规则类型
- (int)getHumanDetectRuleTypeWithPedRuleIndex:(int)pedRuleIndex;
//MARK: 设置警戒规则类型 RuleType:0 线性报警 1:区域报警
- (void)setHumanDetectRuleType:(int)type pedRuleIndex:(int)pedRuleIndex;
//MARK: 获取报警区域点位配置
- (NSMutableArray *)getAlarmAreaPointsWithPedRuleIndex:(int)pedRuleIndex;
//MARK: 获取报警线点位配置
- (NSMutableArray *)getAlarmLinePoints;
//MARK: 设置报警区域点位
- (void)setAlarmAreaPoints:(NSMutableArray *)points pedRuleIndex:(int)pedRuleIndex;
//MARK: 获取报警区域类型
- (int)areaPointNumWithPedRuleIndex:(int)pedRuleIndex;
//MARK: 设置报警区域类型
- (void)setAreaPointNum:(int)pointNum pedRuleIndex:(int)pedRuleIndex;

/**
不选择任何算法: 0
人形: 1<< 0
车形: 1<<1
人形+ 车形:  1<<0 | 1<< 1
 **/
//MARK: 获取人形车形检测
- (int)getObjectType;
//MARK: 设置人形车形检测
- (void)setObjectTypeValue:(int)objectType;
/**
 @brief 获取人形检测配置
 @param devID 设备序列号
 @param channel 通道号 IPC： -1  多通道设备： >= 0
 @param completion GetHumanDetectionCallBack  请求结果回调 按照FunSDK标准结果返回处理
 */
- (void)requestHumanDetectionConfigDeviceID:(NSString *)devID channel:(int)channel completed:(GetHumanDetectionCallBack)completion;

/**
 @brief 设置人形检测规则配置
 */
- (void)requestSaveConfigCompleted:(SetHumanDetectionCallBack)completion;

@end

NS_ASSUME_NONNULL_END
