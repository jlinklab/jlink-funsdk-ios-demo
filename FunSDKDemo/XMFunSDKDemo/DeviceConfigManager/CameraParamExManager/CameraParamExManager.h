//
//  CameraParamExManager.h
//   iCSee
//
//  Created by Megatron on 2023/4/8.
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>

///  日夜切换方式：
///  -1: 还未获取到
///  0：根据光敏检测自动切换
///  1：强制为白天
///  2：强制为晚上
///  3：定时切换
typedef NS_ENUM(NSInteger,JFDayNightSwitchMode) {
    JFDayNightNone = -1,
    JFDayNightAuto,
    JFDayNightForceDay,
    JFDayNightForceNight,
    JFDayNightTiming,
};

typedef void(^GetCameraParamExCallBack)(int result);
typedef void(^SetCameraParamExCallBack)(int result);

NS_ASSUME_NONNULL_BEGIN

/*
 摄像机参数配置管理器
 */
@interface CameraParamExManager : NSObject

@property (nonatomic,copy) GetCameraParamExCallBack getCameraParamExCallBack;
@property (nonatomic,copy) SetCameraParamExCallBack setCameraParamExCallBack;

/**
 * @brief 获取摄像机参数配置
 * @param devID 设备ID
 * @param completion GetCameraParamExCallBack
 * @return void
 */
- (void)requestCameraParamEx:(NSString *)devID channel:(int)channel completed:(GetCameraParamExCallBack)completion;

/*
 宽动态开关状态
 "BroadTrends":
 { 宽动态     AutoGain": 0,  1开启，0关闭     "Gain": 50   增益值 }
 */
- (int)autoGain;
- (void)setAutoGain:(int)state;


/*
 图像风格
 "Style":
 { 图像风格    Style:typedefault,type1,type2}
 */
- (NSString *)getStyle;
- (void)setStyle:(NSString *)type;

///白光灯自动模式下自动开关判断阈值(软光敏)
- (int)getSoftLedThr;
- (void)setSoftLedThr:(int)softLedThr;

///是否打开夜视增强功能
- (int)getNightEnhance;
- (void)setNightEnhance:(int)softLedThr;

/// 获取当前的日夜切换方式
- (JFDayNightSwitchMode)dayNightSwitchMode;
/// 设置当前的日夜切换方式
- (void)setDayNightSwitchMode:(JFDayNightSwitchMode)mode;

///获取微光灯开关配置 0:关 1:开
- (int)microFillLight;
///设置微光灯开关
- (void)setMicroFillLight:(int)value;

/// 获取定时切换的时间段
- (NSString *)keepDayPeriod;
/// 设置定时切换的时间段
- (void)setKeepDayPeriod:(NSString *)period;
/// 获取定时开始时间 HH:mm:ss
- (NSString *)timingStartTime;
/// 设置定时开始时间
- (void)setTimingStartTime:(NSString *)startTime;
/// 获取定时结束时间 HH:mm:ss
- (NSString *)timingEndTime;
/// 设置定时结束时间
- (void)setTimingEndTime:(NSString *)endTime;

/**
 * @brief 保存摄像机参数配置
 * @param completion SetCameraParamExCallBack
 * @return void
 */
- (void)requestSaveCameraParamExCompleted:(SetCameraParamExCallBack)completion;

@end

NS_ASSUME_NONNULL_END
