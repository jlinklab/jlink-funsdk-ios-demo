//
//  DeviceAbilityManager.h
//  XWorld_General
//
//  Created by Tony Stark on 13/08/2019.
//  Copyright © 2019 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CYFunSDKObject.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^GetDeviceAbilityCallBack)(int result);

/*
 设备能力集管理者
 */
@interface DeviceAbilityManager : CYFunSDKObject

@property (nonatomic,copy) GetDeviceAbilityCallBack callBack;

//是否支持人形检测
@property (nonatomic,assign) BOOL supportPEAInHumanPed;
//是否支持报警提示音选择
@property (nonatomic,assign) BOOL supportAlarmVoiceTipsType;
//是否支持获取4G信号强度
@property (nonatomic,assign) BOOL supportNet4GSignalLevel;
//是否支持充电时不休眠
@property (nonatomic,assign) BOOL supportChargeNoShutdown;
//是否支持强制关机
@property (nonatomic,assign) BOOL supportForceShutDownControl;
//是否支持设备呼吸灯
@property (nonatomic,assign) BOOL supportNotifyLight;

//是否支持获取WIFI信号
@property (nonatomic,assign) BOOL supportNetWiFiSignalLevel;
//是否支持多目枪球云台定位 和Android统一用来判断是否是指哪看哪设备
@property (nonatomic,assign) int iSupportGunBallTwoSensorPtzLocate;
//带屏摇头机
@property (nonatomic, assign)BOOL supportVideoTalkV2;
 //是否支持缩影录像
@property (nonatomic, assign)BOOL supportEpitomeRecord;
 //是否支持手动警戒
@property (nonatomic, assign)BOOL supportManuIntellAlertAlarm;
//是否支持宽动态 WDR
@property (nonatomic,assign) BOOL SupportBT;
// 是否支持红外白光切换
@property (nonatomic, assign) int iSupportLP4GSupportDoubleLightSwitch;
//支持白光灯控制
@property (nonatomic, assign) int iSupportCameraWhiteLight;
// 是否支持智能警戒
@property (nonatomic,assign) int iIntellAlertAlarm;
// 是否支持低电量和常电模式切换
@property (nonatomic,assign) int iSupportLPWorkModeSwitchV2;
//是否支持红蓝报警灯开关
@property (nonatomic, assign) int iSupportLowPowerSetAlarmLed;
// 是否支持双光警戒
@property (nonatomic, assign) int iSupportLPDoubleLightAlert;
// 仅支持白光灯开关
@property (nonatomic, assign) int iNotSupportAutoAndIntelligent;
// BoxCameraBulb
@property (nonatomic, assign) int iSupportBoxCameraBulb;
@property (nonatomic, assign) int iSupportDoubleLightBoxCamera;
//支持双光灯
@property (nonatomic, assign) int iSupportDoubleLightBul;
// 是否支持人形检测
@property (nonatomic,assign) int iPEAInHumanPed;
// 是否支持音量设置
@property (nonatomic,assign) BOOL ifSupportSetVolume;
//是否支持红外白光切换转照明开关
@property (nonatomic, assign) int iSupportLowPowerDoubleLightToLightingSwitch;
@property (nonatomic, assign) int iSupportMusicLightBulb;//支持音乐灯

@property (nonatomic, assign) int AovWorkModeIndieControl;//支持AOV工作模式新协议

//MARK:获取设备能力集
- (void)getSystemFunctionConfig:(GetDeviceAbilityCallBack)callBack;

@end

NS_ASSUME_NONNULL_END
