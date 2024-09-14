//
//  JFAlarmNumberStatisticsManager.h
//   iCSee
//
//  Created by Megatron on 2024/5/20.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FunSDKBaseObject.h"

typedef void(^GetAlarmNumberCallBack)(int result);

NS_ASSUME_NONNULL_BEGIN

///获取设备报警次数配置管理器
@interface JFAlarmNumberStatisticsManager : FunSDKBaseObject

@property (nonatomic,copy) GetAlarmNumberCallBack getAlarmNumberCallBack;

///当前时间范围内个的报警数目
@property (nonatomic,assign) int alarmNumber;
///当前时间范围内个的报警数组
@property (nonatomic,strong) NSArray *arrayAlarm;
///@brief 请求开始时间和结束时间之内 某个设备 某些报警类型的报警数目
///@param devID 设备序列号
///@param channel 通道
///@param startTime 开始时间
///@param endTime 结束时间
///@param events 报警类型 "events":["appEventHumanDetectAlarm"],   ///< 查询报警类型【可选】
///@param label AI检测标签 对应也是数组
- (void)requestAlarmNumberWithDeviceID:(NSString *)devID channel:(int)channel startTime:(NSString *)startTime endTime:(NSString *)endTime eventS:(NSArray *)events label:(NSArray *)label  completed:(GetAlarmNumberCallBack)completion;

@end

NS_ASSUME_NONNULL_END
