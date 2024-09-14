//
//  ObSystemFunction.h
//  FunSDKDemo
//
//  Created by XM on 2018/5/11.
//  Copyright © 2018年 XM. All rights reserved.
//
/***
 
设备能力级类，表明设备对特殊功能的支持情况
 
 *****/
#import "ObjectCoder.h"

@interface ObSystemFunction : ObjectCoder

@property (nonatomic, copy) NSString *deviceMac;
@property (nonatomic) int channelNumber;


//设备功能支持情况的部分能力级
@property (nonatomic) BOOL NewVideoAnalyze;//是否支持智能分析报警
@property (nonatomic) BOOL SupportIntelligentPlayBack;//是否支持智能快放
@property (nonatomic) BOOL SupportSetDigIP;//是否支持修改前端IP
@property (nonatomic) BOOL IPConsumer433Alarm;//是否支持433报警
@property (nonatomic) BOOL SupportSmartH264;//是否支持h264+
@property (nonatomic) BOOL SupportPirAlarm; //是否支持智能人体检测 （徘徊检测等）
@property (nonatomic) BOOL PEAInHumanPed; //是否支持IPC人行检测 PEAInHumanPed
@property (nonatomic) BOOL SupportDoorLock; //是否支持远程开锁
@property (nonatomic,assign) BOOL SupportDevRingControl;            // 是否支持设备响铃控制
@property (nonatomic,assign) BOOL SupportCloseVoiceTip;             // 是否支持设备提示音
@property (nonatomic,assign) BOOL SupportStatusLed;                 // 是否支持状态灯
@property (nonatomic,assign) BOOL ifSupportSetVolume;               // 是否支持音量设置
@property (nonatomic,assign) BOOL WifiModeSwitch;                  // 是否支持网络配置
@property (nonatomic,assign) BOOL SupportPTZTour;                  // 是否支持自动巡航
@property (nonatomic,assign) BOOL SupportTimingPtzTour;             // 对否支持定时巡航
@property (nonatomic,assign) BOOL SupportSetDetectTrackWatchPoint;  // 是否支持守望功能
@property (nonatomic,assign) BOOL SupportDetectTrack;              // 是否支持移动追踪（人形跟随）
@property (nonatomic,assign) BOOL SupportOneKeyMaskVideo;           // 是否支持一键遮蔽
@property (nonatomic,assign) BOOL supportAlarmVoiceTipsType;        //是否支持警戒提示音选择
@property (nonatomic,assign) BOOL supportAlarmVoiceTips;            //是否支持报警提示音
@property (nonatomic, assign) int iSupportCameraWhiteLight; //支持白光灯控制
@property (nonatomic, assign) int iSupportDoubleLightBul;//支持双光灯
@property (nonatomic, assign) int iSupportMusicLightBulb;//支持音乐灯
@property (nonatomic, assign) int iSupportDoubleLightBoxCamera;//双光枪机
@property (nonatomic, assign) int isupportDNChangeByImage;//日夜切换灵敏度
@property (nonatomic, assign) int iSupportGunBallTwoSensorPtzLocate;  //是否支持多目枪球云台定位 和Android统一用来判断是否是指哪看哪设备
@property (nonatomic, assign) BOOL supportVideoTalkV2;  //带屏摇头机视频对讲
@property (nonatomic, assign)BOOL supportEpitomeRecord;  // 是否支持缩影录像
@property (nonatomic, assign)BOOL supportTraditionalPtzNormalDirect; // 是否支持传统ptz方向控制
@property (nonatomic, assign)BOOL netWifi;
@property (nonatomic, assign)BOOL SupportPtzAutoAdjust;  // 是否支持云台校正
@property (nonatomic, assign)BOOL supportManuIntellAlertAlarm;  // 是否支持手动警戒
@property (nonatomic,assign) BOOL SupportBT;//是否支持宽动态 WDR
@property (nonatomic, assign) int iSupportLP4GSupportDoubleLightSwitch; // 是否支持红外白光切换
@property (nonatomic, assign) int iSupportLowPowerDoubleLightToLightingSwitch;//是否支持红外白光切换转照明开关
@property (nonatomic, assign) int iSupportLowPowerSetBrightness;//是否支持设置照明灯亮度
@property (nonatomic,assign) int iIntellAlertAlarm;             // 是否支持智能警戒
@property (nonatomic,assign) int iSupportLPWorkModeSwitchV2;   // 是否支持低电量和常电模式切换
@property (nonatomic, assign) int iSupportLowPowerSetAlarmLed;//是否支持红蓝报警灯开关
@property (nonatomic, assign) int iSupportLPDoubleLightAlert; // 是否支持双光警戒
@property (nonatomic, assign) int iNotSupportAutoAndIntelligent;// 仅支持白光灯开关
@property (nonatomic, assign) int iSupportBoxCameraBulb;  // BoxCameraBulb
@property (nonatomic, assign) int AovMode; //支持AOV功能
@property (nonatomic, assign) int AovWorkModeIndieControl;  // AOV 支持工作模式协议
@property (nonatomic, assign) int AovAlarmHold; //AOV报警抑制，限制设备不能频繁触发报警
@property (nonatomic, assign) int supportSetBrightness; ////是否支持灯光亮度：目前AOV设备使用
@property (nonatomic, assign) int MicroFillLight; //是否支持微光控制
@property (nonatomic, assign) int SoftLedThr; //支持自动灯光模式下的灵敏度设置，取值范围固定为1~5 目前AOV设备使用
@property (nonatomic, assign) int LowPowerWorkTime; //是否支持低功耗设备唤醒和预览时长 目前AOV设备使用
@property (nonatomic, assign) int BatteryManager; //是否支持低功耗设备电池管理

@end
