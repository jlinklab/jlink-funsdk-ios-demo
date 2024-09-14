#pragma once
#import <FunSDK/JObject.h>

#define JK_OtherFunction "OtherFunction"
class OtherFunction : public JObject
{
public:
    JBoolObj        AlterDigitalName;
    JBoolObj        DownLoadPause;
    JBoolObj        HddLowSpaceUseMB;
    JBoolObj        HideDigital;
    JBoolObj        MusicFilePlay;
    JBoolObj        NOHDDRECORD;
    JBoolObj        NotSupportAH;
    JBoolObj        NotSupportAV;
    JBoolObj        NotSupportTalk;
    JBoolObj        SDsupportRecord;
    JBoolObj        ShowAlarmLevelRegion;
    JBoolObj        ShowFalseCheckTime;
    JBoolObj        SupportAbnormitySendMail;
    JBoolObj        SupportAlarmLinkLight;
    JBoolObj        SupportAlarmVoiceTips;          // 是否支持报警提示音
    JBoolObj        SupportBT;                      // 是否支持宽动态
    JBoolObj        SupportBallCameraTrackDetect;
    JBoolObj        SupportBulbAlarmLightOn;
    JBoolObj        SupportC7Platform;
    JBoolObj        SupportCamareStyle;
    JBoolObj        SupportCameraMotorCtrl;
    JBoolObj        SupportCameraWhiteLight;
    JBoolObj        SupportSoftPhotosensitive;          // 球机灯泡配置功能
    JBoolObj        SupportCfgCloudupgrade;
    JBoolObj        SupportCloseVoiceTip;
    JBoolObj        SupportCloudUpgrade;
    JBoolObj        SupportCommDataUpload;
    JBoolObj        SupportConsSensorAlarmLink;
    JBoolObj        SupportContinueUpgrade;
    JBoolObj        SupportCustomOemInfo;
    JBoolObj        SupportDeviceInfoNew;
    JBoolObj        SupportDigitalEncode;
    JBoolObj        SupportDigitalPre;
    JBoolObj        SupportDimenCode;
    JBoolObj        SupportDoorLock;
    JBoolObj        SupportDoubleLightBulb;
    JBoolObj        SupportEncodeAddBeep;
    JBoolObj        SupportFTPTest;
    JBoolObj        SupportFaceDetect;
    JBoolObj        SupportFishEye;
    JBoolObj        SupportImpRecord;
    JBoolObj        SupportIntelligentPlayBack;
    JBoolObj        SupportLowLuxMode;
    JBoolObj        SupportMailTest;
    JBoolObj        SupportMaxPlayback;
    JBoolObj        SupportModifyFrontcfg;
    JBoolObj        SupportNVR;
    JBoolObj        SupportNetLocalSearch;
    JBoolObj        SupportNetWorkMode;
    JBoolObj        SupportOSDInfo;
    JBoolObj        SupportOnvifClient;
    JBoolObj        SupportPOS;
    JBoolObj        SupportPWDSafety;
    JBoolObj        SupportPlateDetect;
    JBoolObj        SupportPlayBackExactSeek;
    JBoolObj        SupportPlaybackLocate;
    JBoolObj        SupportPtzIdleState;
    JBoolObj        SupportRPSVideo;
    JBoolObj        SupportRTSPClient;
    JBoolObj        SupportResumePtzState;
    JBoolObj        SupportSPVMNNasServer;
    JBoolObj        SupportSafetyEmail;
    JBoolObj        SupportSensorAbilitySetting;
    JBoolObj        SupportSetDigIP;
    JBoolObj        SupportSetHardwareAbility;
    JBoolObj        SupportShowConnectStatus;
    JBoolObj        SupportShowProductType;
    JBoolObj        SupportSlowMotion;
    JBoolObj        SupportSmallChnTitleFont;
    JBoolObj        SupportSnapCfg;
    JBoolObj        SupportSnapSchedule;
    JBoolObj        SupportSnapV2Stream;
    JBoolObj        SupportSplitControl;
    JBoolObj        SupportStatusLed;
    JBoolObj        SupportStorageFailReboot;
    JBoolObj        SupportStorageNAS;
    JBoolObj        SupportSwitchResolution;
    JBoolObj        SupportTextPassword;
    JBoolObj        SupportTimeZone;
    JBoolObj        SupportUserProgram;
    JBoolObj        SupportWIFINVR;
    JBoolObj        SupportWriteLog;
    JBoolObj        Supportonviftitle;
    JBoolObj        SuppportChangeOnvifPort;
    JBoolObj        TitleAndStateUpload;
    JBoolObj        USBsupportRecord;
    JBoolObj        SupportDNChangeByImage;//日夜切换灵敏度 日夜转换通过图像判断，不用光敏
    JBoolObj        SupportSetPTZPresetAttribute;//是否支持预置点
    JBoolObj        SupportGunBallTwoSensorCamera;//是否是双目枪球 目前支持这种的设备都是一路码流上下分屏的
    JBoolObj        SupportPTZTour; //支持巡航
    JBoolObj        SupportMusicLightBulb;//音乐灯
    JBoolObj        SupportDoubleLightBoxCamera;// 双光枪机
    JBoolObj        SupportPushLowBatteryMsg;   // 设备是否支持电量低消息推送
    JBoolObj        SupportPirAlarm;            // 是否支持智能人体检测
    JBoolObj        SupportReserveWakeUp;       // 是否支持门铃来电预约
    JBoolObj        SupportIntervalWakeUp;      // 是否支持间隔录像功能
    JBoolObj        SupportNoDisturbing;        // 是否支持消息免打扰
    JBoolObj        SupportNotifyLight;         // 是否支持呼吸灯
    JBoolObj        SupportKeySwitchManager;    // 是否支持按键管理
    JBoolObj        SupportDetectTrack;         // 是否支持人形跟随
    JBoolObj        SupportDevRingControl;      // 是否支持设备铃声
    JBoolObj        SupportForceShutDownControl;// 是否支持强制关机
    JBoolObj        SupportPirTimeSection;      // 是否支持PIR控制
    JBoolObj        Support433Ring;             // 433是否支持铃声设置
    JBoolObj        SupportSetVolume;           // XM510 Volume Control Ability
    JBoolObj        SupportAppBindFlag;         // 是否支持读写恢复出厂绑定状态
    JBoolObj        SupportGetMcuVersion;       // 是否支持单片机版本号获取
    JBoolObj        SupportBallTelescopic;      // 是否支持视频变倍
    JBoolObj        SupportCorridorMode;        // 是否支持门铃90度旋转
    JBoolObj        SupportAlarmVoiceTipsType;  // 是否支持警戒提示音选择
    JBoolObj        SupportFullAndHalfDuplexTalkBack;   // 暂时是门锁是否支持双向对讲
    JBoolObj        SupportSetDetectTrackWatchPoint;    // 是否支持守望功能
    JBoolObj        SupportChargeNoShutdown;            // 是否支持充电时不休眠配置
    JBoolObj        SupportAlarmRemoteCall;             // 是否支持一键呼叫
    JBoolObj        SupportQuickReply;                  // 是否支持快速回复
    JBoolObj        SupportOneKeyMaskVideo;             // 是否支持一键遮蔽
    JBoolObj        SupportTimingSleep;                 // 是否支持一键休眠
    JBoolObj        SupportBoxCameraBulb;               // BoxCamera灯泡能力集
    JBoolObj        SupportPTZDirectionControl;         // 是否支持云台 云台新能力集 如果支持这个就表示支持云台
    JBoolObj        SupportPTZDirectionHorizontalControl;// 云台仅支持水平
    JBoolObj        SupportPTZDirectionVerticalControl;  // 云台仅支持垂直
    JBoolObj        SupportForceDismantleSwitch;        // 是否支持防强拆
    JBoolObj        SupportPIRMicrowaveAlarm;           // 是否支持PIR微波报警组合
    JBoolObj        LP4GSupportDoubleLightSwitch;       // 是否支持白光红外切换
    JBoolObj        SupportLowPowerDoubleLightToLightingSwitch; // 是否支持白光红外切换配置项转变成照明开关配置项 两个同时支持才是显示照明开关
    JBoolObj        SupportLPWorkModeSwitch;            // 低功耗设备是否支持工作模式切换
    JBoolObj        SupportWifiHotSpot;                 // 是否支持信道设置
    JBoolObj        AlarmOutUsedAsLed;                  // 是否支持人形报警联动的红蓝指示灯设置
    JBoolObj        SupportAPPGetCameraVersion;         // 是否支持获取前端摄像机版本配置
    JBoolObj        SupprotBaseStationModeChange;       // 是否支持中继模式
    JBoolObj        SupportAPPDeleteDigitalChannel;     // 是否支持通道删除
    JBoolObj        SupportAPPCtrlWifiNVRPairIPC;       // 是否支持无线对码
    JBoolObj        NotSupportAutoAndIntelligent;       // 白光灯是不是仅支持开关
    JBoolObj        SupportScaleTwoLens;                // 是否支持双目设备端变倍
    JBoolObj        SupportScaleThreeLens;              // 是否支持三目设备端变倍
    JBoolObj        MultiLensTwoSensor;                 // 是否支持双目APP变倍
    JBoolObj        MultiLensThreeSensor;               // 是否支持三目APP变倍
    JBoolObj        SupportLocalTipSwitch;              // 是否支持基站灯光和警戒音免打扰配置
    JBoolObj        SupportPirSensitive;                // 是否支持PIR灵敏度设置
    JBoolObj        SupportTwoWayVoiceTalk;             // 是否支持双向对讲
    JBoolObj        SupportIOTOperateWithServer;        // 是否向服务器请求处理IOT操作
    JBoolObj        SupportHidePictureFlip;             // 是否支持隐藏图像上下翻转
    JBoolObj        SupportHidePictureMirror;           // 是否支持隐藏图像左右翻转
    JBoolObj        SupportTraditionalPtzNormalDirect;  // 是否支持传统ptz方向控制
    JBoolObj        SupportConsumerPtzMirrorDirect;     // 是否支持消费类云台控制
    JBoolObj        SupportLowPowerSetBrightness;       // 是否支持设置照明灯亮度
    JBoolObj        SupportLowPowerSetAlarmLed;         // 是否支持使用报警输出作为灯的亮度即控制红蓝报警灯开关
    JBoolObj        SupportMultiLensLinkageSplitScreen; // 是否支持双目分屏
    JBoolObj        SupportMultiLensSplicingWfsRecordStream; // 是否支持双目变焦录像拼接缩放
    JBoolObj        SupportRecMainOrExtUseMainType;     // 是否支持录像模式设置
    JBoolObj        SupportHidePirCheckTime;            // 是否隐藏PIR检测时间
    JBoolObj        SupportDetectTrackInvertDirection;  // 移动追踪方向
    JBoolObj        SupportLPWorkModeSwitchV2;          // 低功耗是否支持低常模式
    JBoolObj        SupportGunBallTwoSensorPtzLocate;   // 是否支持多目枪球云台定位
    JBoolObj        SupportBleButtonManager;            // 是否支持蓝牙按钮一键呼叫按钮
    JBoolObj        SupportVolumeDetect;                // 是否支持异响检测
    JBoolObj        NoSupportInfraredLight;             // 设备没有红外灯
    JBoolObj        SupportFullColorManualAdjustLightBrightness; // 白光全彩（手动控制挡位来调节白光灯亮度）
    JBoolObj        SupportListCameraDayLightModes;     // 支持 日夜模式
    JBoolObj        SupportFullColorLightWorkPeriod;    // 支持 黑光灯 设置自动亮灯时间段
    JBoolObj        SupportLPDoubleLightAlert;          // 低功耗双光警戒 支持这个就会多一个双光警戒选项
    JBoolObj        SupportPtzAutoAdjust;                 // 手动校准功能
    JBoolObj        SupportControlWhiteLightDuration;    // 支持 黑光灯 设置人形警戒持续亮灯时间段
    JBoolObj        MultiChnSplitWindows;               // 是否是多目枪球设备（3目）
    JBoolObj        SupportAlarmVoiceTipInterval;       // 支持警铃间隔
    JBoolObj        SupportVideoTalk;                    //支持视频对讲（废弃）
    JBoolObj        SupportVideoTalkV2;                    //支持视频对讲（新加）
    JBoolObj        SupportSetScreenWorkTime;              //支持视频对讲息屏时间设置
    JBoolObj        SupManualSwitchDayNight;               //是否支持新的日夜模式
    JBoolObj        SetScreenSwitch;                       //带屏设备支持设置屏幕开关
    JBoolObj        SetScreenLuminance;                    //带屏设备支持调节屏幕亮度
    JBoolObj        KeyWordDetect;                         //带屏设备是否支持语音控制
    JBoolObj        SupportGetSecondaryVersion;            //是否支持显示枪机的软件版本号
    JBoolObj        GetBatteryInfo;                        //因某些客户需求，带屏摇头机需要增加电池，用于设备断电后维持运行。APP上需要显示电池充电状态和电量
    JBoolObj        SupportLowPowerLongAlarmRecord;        //支持低功耗设备录像时间设置10 20  30
    JBoolObj        AovMode;                               //是否支持AOV模式
    JBoolObj        BatteryManager;                        //是否支持电池管理：目前AOV设备使用
    JBoolObj        ConsumerLightMode;                     //是否支持消费类灯光模式：目前AOV设备使用
    JBoolObj        SupportSetBrightness;                  //是否支持灯光亮度：目前AOV设备使用
    JBoolObj        NightEnhance;                          //是否支持夜视增强：目前AOV设备使用
    JBoolObj        SoftLedThr;                            //支持自动灯光模式下的灵敏度设置，取值范围固定为1~5 目前AOV设备使用
    JBoolObj        MicroFillLight;                        //是否支持微光控制
    JBoolObj        LowPowerWorkTime;                      //是否支持低功耗设备唤醒和预览时长
    JBoolObj        AovAlarmHold;                          //AOV报警抑制
    JBoolObj        TemperatureDetect;                     //温度报警设置
    JBoolObj        AovWorkModeIndieControl;               //AOV新工作模式
    JBoolObj        SupportEpitomeRecord;
    JBoolObj        SupportTimingPtzTour;
public:
    OtherFunction(JObject *pParent = NULL, const char *szName = JK_OtherFunction):
    JObject(pParent,szName),
    AlterDigitalName(this, "AlterDigitalName"),
    DownLoadPause(this, "DownLoadPause"),
    HddLowSpaceUseMB(this, "HddLowSpaceUseMB"),
    HideDigital(this, "HideDigital"),
    MusicFilePlay(this, "MusicFilePlay"),
    NOHDDRECORD(this, "NOHDDRECORD"),
    NotSupportAH(this, "NotSupportAH"),
    NotSupportAV(this, "NotSupportAV"),
    NotSupportTalk(this, "NotSupportTalk"),
    SDsupportRecord(this, "SDsupportRecord"),
    ShowAlarmLevelRegion(this, "ShowAlarmLevelRegion"),
    ShowFalseCheckTime(this, "ShowFalseCheckTime"),
    SupportAbnormitySendMail(this, "SupportAbnormitySendMail"),
    SupportAlarmLinkLight(this, "SupportAlarmLinkLight"),
    SupportAlarmVoiceTips(this, "SupportAlarmVoiceTips"),
    SupportBT(this, "SupportBT"),
    SupportBallCameraTrackDetect(this, "SupportBallCameraTrackDetect"),
    SupportBulbAlarmLightOn(this, "SupportBulbAlarmLightOn"),
    SupportC7Platform(this, "SupportC7Platform"),
    SupportCamareStyle(this, "SupportCamareStyle"),
    SupportCameraMotorCtrl(this, "SupportCameraMotorCtrl"),
    SupportCameraWhiteLight(this, "SupportCameraWhiteLight"),
    SupportSoftPhotosensitive(this, "SupportSoftPhotosensitive"),
    SupportCfgCloudupgrade(this, "SupportCfgCloudupgrade"),
    SupportCloseVoiceTip(this, "SupportCloseVoiceTip"),
    SupportCloudUpgrade(this, "SupportCloudUpgrade"),
    SupportCommDataUpload(this, "SupportCommDataUpload"),
    SupportConsSensorAlarmLink(this, "SupportConsSensorAlarmLink"),
    SupportContinueUpgrade(this, "SupportContinueUpgrade"),
    SupportCustomOemInfo(this, "SupportCustomOemInfo"),
    SupportDeviceInfoNew(this, "SupportDeviceInfoNew"),
    SupportDigitalEncode(this, "SupportDigitalEncode"),
    SupportDigitalPre(this, "SupportDigitalPre"),
    SupportDimenCode(this, "SupportDimenCode"),
    SupportDoorLock(this, "SupportDoorLock"),
    SupportDoubleLightBoxCamera(this, "SupportDoubleLightBoxCamera"),
    SupportDoubleLightBulb(this, "SupportDoubleLightBulb"),
    SupportEncodeAddBeep(this, "SupportEncodeAddBeep"),
    SupportFTPTest(this, "SupportFTPTest"),
    SupportFaceDetect(this, "SupportFaceDetect"),
    SupportFishEye(this, "SupportFishEye"),
    SupportImpRecord(this, "SupportImpRecord"),
    SupportIntelligentPlayBack(this, "SupportIntelligentPlayBack"),
    SupportLowLuxMode(this, "SupportLowLuxMode"),
    SupportMailTest(this, "SupportMailTest"),
    SupportMaxPlayback(this, "SupportMaxPlayback"),
    SupportModifyFrontcfg(this, "SupportModifyFrontcfg"),
    SupportMusicLightBulb(this, "SupportMusicLightBulb"),
    SupportNVR(this, "SupportNVR"),
    SupportNetLocalSearch(this, "SupportNetLocalSearch"),
    SupportNetWorkMode(this, "SupportNetWorkMode"),
    SupportOSDInfo(this, "SupportOSDInfo"),
    SupportOnvifClient(this, "SupportOnvifClient"),
    SupportPOS(this, "SupportPOS"),
    SupportPTZTour(this, "SupportPTZTour"),
    SupportPWDSafety(this, "SupportPWDSafety"),
    SupportPlateDetect(this, "SupportPlateDetect"),
    SupportPlayBackExactSeek(this, "SupportPlayBackExactSeek"),
    SupportPlaybackLocate(this, "SupportPlaybackLocate"),
    SupportPtzIdleState(this, "SupportPtzIdleState"),
    SupportRPSVideo(this, "SupportRPSVideo"),
    SupportRTSPClient(this, "SupportRTSPClient"),
    SupportResumePtzState(this, "SupportResumePtzState"),
    SupportSPVMNNasServer(this, "SupportSPVMNNasServer"),
    SupportSafetyEmail(this, "SupportSafetyEmail"),
    SupportSensorAbilitySetting(this, "SupportSensorAbilitySetting"),
    SupportSetDigIP(this, "SupportSetDigIP"),
    SupportSetHardwareAbility(this, "SupportSetHardwareAbility"),
    SupportSetPTZPresetAttribute(this, "SupportSetPTZPresetAttribute"),
    SupportGunBallTwoSensorCamera(this, "SupportGunBallTwoSensorCamera"),
    SupportShowConnectStatus(this, "SupportShowConnectStatus"),
    SupportShowProductType(this, "SupportShowProductType"),
    SupportSlowMotion(this, "SupportSlowMotion"),
    SupportSmallChnTitleFont(this, "SupportSmallChnTitleFont"),
    SupportSnapCfg(this, "SupportSnapCfg"),
    SupportSnapSchedule(this, "SupportSnapSchedule"),
    SupportSnapV2Stream(this, "SupportSnapV2Stream"),
    SupportSplitControl(this, "SupportSplitControl"),
    SupportStatusLed(this, "SupportStatusLed"),
    SupportStorageFailReboot(this, "SupportStorageFailReboot"),
    SupportStorageNAS(this, "SupportStorageNAS"),
    SupportSwitchResolution(this, "SupportSwitchResolution"),
    SupportTextPassword(this, "SupportTextPassword"),
    SupportTimeZone(this, "SupportTimeZone"),
    SupportUserProgram(this, "SupportUserProgram"),
    SupportWIFINVR(this, "SupportWIFINVR"),
    SupportWriteLog(this, "SupportWriteLog"),
    Supportonviftitle(this, "Supportonviftitle"),
    SuppportChangeOnvifPort(this, "SuppportChangeOnvifPort"),
    TitleAndStateUpload(this, "TitleAndStateUpload"),
    USBsupportRecord(this, "USBsupportRecord"),
    SupportDNChangeByImage(this, "SupportDNChangeByImage"),
    SupportPushLowBatteryMsg(this,"SupportPushLowBatteryMsg"),
    SupportPirAlarm(this,"SupportPirAlarm"),
    SupportReserveWakeUp(this,"SupportReserveWakeUp"),
    SupportIntervalWakeUp(this,"SupportIntervalWakeUp"),
    SupportNoDisturbing(this,"SupportNoDisturbing"),
    SupportNotifyLight(this,"SupportNotifyLight"),
    SupportKeySwitchManager(this,"SupportKeySwitchManager"),
    SupportDetectTrack(this,"SupportDetectTrack"),
    SupportDevRingControl(this,"SupportDevRingControl"),
    SupportForceShutDownControl(this,"SupportForceShutDownControl"),
    SupportPirTimeSection(this,"SupportPirTimeSection"),
    Support433Ring(this,"Support433Ring"),
    SupportSetVolume(this,"SupportSetVolume"),
    SupportAppBindFlag(this,"SupportAppBindFlag"),
    SupportGetMcuVersion(this,"SupportGetMcuVersion"),
    SupportBallTelescopic(this,"SupportBallTelescopic"),
    SupportCorridorMode(this,"SupportCorridorMode"),
    SupportAlarmVoiceTipsType(this,"SupportAlarmVoiceTipsType"),
    SupportFullAndHalfDuplexTalkBack(this,"SupportFullAndHalfDuplexTalkBack"),
    SupportSetDetectTrackWatchPoint(this,"SupportSetDetectTrackWatchPoint"),
    SupportChargeNoShutdown(this,"SupportChargeNoShutdown"),
    SupportAlarmRemoteCall(this,"SupportAlarmRemoteCall"),
    SupportQuickReply(this,"SupportQuickReply"),
    SupportOneKeyMaskVideo(this,"SupportOneKeyMaskVideo"),
    SupportTimingSleep(this,"SupportTimingSleep"),
    SupportBoxCameraBulb(this,"SupportBoxCameraBulb"),
    SupportPTZDirectionControl(this,"SupportPTZDirectionControl"),
    SupportPTZDirectionHorizontalControl(this,"SupportPTZDirectionHorizontalControl"),
    SupportPTZDirectionVerticalControl(this,"SupportPTZDirectionVerticalControl"),
    SupportForceDismantleSwitch(this,"SupportForceDismantleSwitch"),
    SupportPIRMicrowaveAlarm(this,"SupportPIRMicrowaveAlarm"),
    LP4GSupportDoubleLightSwitch(this,"LP4GSupportDoubleLightSwitch"),
    SupportLowPowerDoubleLightToLightingSwitch(this,"SupportLowPowerDoubleLightToLightingSwitch"),
    SupportLPWorkModeSwitch(this,"SupportLPWorkModeSwitch"),
    SupportWifiHotSpot(this,"SupportWifiHotSpot"),
    AlarmOutUsedAsLed(this,"AlarmOutUsedAsLed"),
    SupportAPPGetCameraVersion(this,"SupportAPPGetCameraVersion"),
    SupprotBaseStationModeChange(this,"SupprotBaseStationModeChange"),
    SupportAPPDeleteDigitalChannel(this,"SupportAPPDeleteDigitalChannel"),
    SupportAPPCtrlWifiNVRPairIPC(this,"SupportAPPCtrlWifiNVRPairIPC"),
    NotSupportAutoAndIntelligent(this,"NotSupportAutoAndIntelligent"),
    SupportScaleTwoLens(this,"SupportScaleTwoLens"),
    SupportScaleThreeLens(this,"SupportScaleThreeLens"),
    MultiLensTwoSensor(this,"MultiLensTwoSensor"),
    MultiLensThreeSensor(this,"MultiLensThreeSensor"),
    SupportLocalTipSwitch(this,"SupportLocalTipSwitch"),
    SupportPirSensitive(this,"SupportPirSensitive"),
    SupportTwoWayVoiceTalk(this,"SupportTwoWayVoiceTalk"),
    SupportHidePictureFlip(this,"SupportHidePictureFlip"),
    SupportHidePictureMirror(this,"SupportHidePictureMirror"),
    SupportIOTOperateWithServer(this,"SupportIOTOperateWithServer"),
    SupportTraditionalPtzNormalDirect(this,"SupportTraditionalPtzNormalDirect"),
    SupportConsumerPtzMirrorDirect(this,"SupportConsumerPtzMirrorDirect"),
    SupportLowPowerSetBrightness(this,"SupportLowPowerSetBrightness"),
    SupportLowPowerSetAlarmLed(this,"SupportLowPowerSetAlarmLed"),
    SupportMultiLensLinkageSplitScreen(this,"SupportMultiLensLinkageSplitScreen"),
    SupportMultiLensSplicingWfsRecordStream(this,"SupportMultiLensSplicingWfsRecordStream"),
    SupportRecMainOrExtUseMainType(this,"SupportRecMainOrExtUseMainType"),
    SupportHidePirCheckTime(this,"SupportHidePirCheckTime"),
    SupportDetectTrackInvertDirection(this,"SupportDetectTrackInvertDirection"),
    SupportLPWorkModeSwitchV2(this,"SupportLPWorkModeSwitchV2"),
    SupportGunBallTwoSensorPtzLocate(this,"SupportGunBallTwoSensorPtzLocate"),
    SupportBleButtonManager(this,"SupportBleButtonManager"),
    SupportVolumeDetect(this,"SupportVolumeDetect"),
    NoSupportInfraredLight(this,"NoSupportInfraredLight"),
    SupportFullColorManualAdjustLightBrightness(this,"SupportFullColorManualAdjustLightBrightness"),
    SupportListCameraDayLightModes(this,"SupportListCameraDayLightModes"),
    SupportFullColorLightWorkPeriod(this,"SupportFullColorLightWorkPeriod"),
    SupportLPDoubleLightAlert(this,"SupportLPDoubleLightAlert"),
    SupportPtzAutoAdjust(this,"SupportPtzAutoAdjust"),
    SupportControlWhiteLightDuration(this,"SupportControlWhiteLightDuration"),
    MultiChnSplitWindows(this,"MultiChnSplitWindows"),
    SupportAlarmVoiceTipInterval(this,"SupportAlarmVoiceTipInterval"),
    SupportVideoTalk(this,"SupportVideoTalk"),
    SupportVideoTalkV2(this,"SupportVideoTalkV2"),
    SupportSetScreenWorkTime(this,"SupportSetScreenWorkTime"),
    SupManualSwitchDayNight(this,"SupManualSwitchDayNight"),
    SetScreenSwitch(this,"SetScreenSwitch"),
    SetScreenLuminance(this,"SetScreenLuminance"),
    KeyWordDetect(this,"KeyWordDetect"),
    SupportGetSecondaryVersion(this,"SupportGetSecondaryVersion"),
    GetBatteryInfo(this,"GetBatteryInfo"),
    SupportLowPowerLongAlarmRecord(this,"SupportLowPowerLongAlarmRecord"),
    AovMode(this,"AovMode"),
    BatteryManager(this,"BatteryManager"),
    ConsumerLightMode(this,"ConsumerLightMode"),
    SupportSetBrightness(this,"SupportSetBrightness"),
    NightEnhance(this,"NightEnhance"),
    SoftLedThr(this,"SoftLedThr"),
    MicroFillLight(this,"MicroFillLight"),
    LowPowerWorkTime(this,"LowPowerWorkTime"),
    AovAlarmHold(this,"AovAlarmHold"),
    TemperatureDetect(this,"TemperatureDetect"),
    SupportTimingPtzTour(this,"SupportTimingPtzTour"),
    SupportEpitomeRecord(this,"SupportEpitomeRecord"),
    AovWorkModeIndieControl(this,"AovWorkModeIndieControl"){
    };
    
    ~OtherFunction(void){};
};
