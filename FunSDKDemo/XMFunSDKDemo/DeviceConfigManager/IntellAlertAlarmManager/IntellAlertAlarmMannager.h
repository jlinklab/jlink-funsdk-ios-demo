//
//  IntellAlertAlarmMannager.h
//   
//
//  Created by Tony Stark on 2021/7/22.
//  Copyright © 2021 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FunSDKBaseObject.h"


NS_ASSUME_NONNULL_BEGIN

//获取警戒配置回调
typedef void(^GetIntellAlertAlarmCallBack)(int result,int channel);
//保存警戒配置回调
typedef void(^SetIntellAlertAlarmCallBack)(int result,int channel);

/*
 智能警戒管理者
 */
@interface IntellAlertAlarmMannager : FunSDKBaseObject

@property (nonatomic,copy) GetIntellAlertAlarmCallBack getIntellAlertAlarmCallBack;

@property (nonatomic,copy) SetIntellAlertAlarmCallBack setIntellAlertAlarmCallBack;

//MARK: 获取警戒配置
- (void)getIntellAlertAlarm:(NSString *)devID channel:(int)channel completed:(GetIntellAlertAlarmCallBack)completion;
//MARK: 保存警戒配置
- (void)setIntellAlertAlarmCompleted:(SetIntellAlertAlarmCallBack)completion;

//MARK: 判断是否请求到配置
- (BOOL)checkRequestedCfg;
//MARK: 获取总开关状态
- (BOOL)getEnable;
//MARK: 设置总开关状态
- (void)setEnable:(BOOL)enable;
//MARK: 获取报警持续时间
- (int)getDuration;
//MARK: 设置报警持续时间
- (void)setDuration:(int)seconds;
//MARK: 获取提示音类型
- (int)getVoiceType;
//MARK: 设置提示音类型
- (void)setVoiceType:(int)type;
//MARK: 获取报警灯开关状态
- (BOOL)getAlarmOutEnable;
//MARK: 设置报警灯开关状态
- (void)setAlarmOutEnable:(BOOL)enable;

/*
 配置已废弃 2022-03-19
 */
//MARK: 获取通道联动报警状态
- (BOOL)getRemoteEnableChannel:(int)channel;
//MARK: 设置通道联动报警状态
- (void)setRemoteEnable:(BOOL)enable channel:(int)channel;

@end

NS_ASSUME_NONNULL_END