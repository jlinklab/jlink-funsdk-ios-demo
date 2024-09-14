//
//  DeviceAbilityManager.m
//  XWorld_General
//
//  Created by Tony Stark on 13/08/2019.
//  Copyright © 2019 xiongmaitech. All rights reserved.
//

#import "DeviceAbilityManager.h"
#import "SystemFunction.h"
#import "DeviceConfig.h"

@interface DeviceAbilityManager () <DeviceConfigDelegate>
{
    SystemFunction systemFunction;
}

@end

@implementation DeviceAbilityManager

//MARK:获取设备能力集
- (void)getSystemFunctionConfig:(GetDeviceAbilityCallBack)callBack{
    self.callBack = callBack;
    
    systemFunction.SetName(JK_SystemFunction);
    DeviceConfig* systemFunctionCfg = [[DeviceConfig alloc] initWithJObject:&systemFunction];
    systemFunctionCfg.devId = self.devID;
    systemFunctionCfg.channel = -1;
    systemFunctionCfg.isSet = NO;
    systemFunctionCfg.delegate = self;
    systemFunctionCfg.isGet = YES;
    [self requestGetConfig:systemFunctionCfg];
}

//MARK: - 获取配置返回
-(void)getConfig:(DeviceConfig*)config result:(int)result{
    if ([config.name isEqualToString:OCSTR(JK_SystemFunction)]) {
        if (result >= 0) {
            self.supportPEAInHumanPed = systemFunction.mAlarmFunction.PEAInHumanPed.Value();
            self.supportChargeNoShutdown = systemFunction.mOtherFunction.SupportForceShutDownControl.Value();
            self.supportNotifyLight = systemFunction.mOtherFunction.SupportNotifyLight.Value();
            self.iSupportGunBallTwoSensorPtzLocate = systemFunction.mOtherFunction.SupportGunBallTwoSensorPtzLocate.Value()?1:0;
            self.supportNetWiFiSignalLevel = systemFunction.mNetServerFunction.WifiRouteSignalLevel.Value()?1:0;
            self.supportVideoTalkV2 = systemFunction.mOtherFunction.SupportVideoTalkV2.Value();
            self.supportEpitomeRecord = systemFunction.mOtherFunction.SupportEpitomeRecord.Value();
            self.supportManuIntellAlertAlarm = systemFunction.mAlarmFunction.ManuIntellAlertAlarm.Value();
            self.SupportBT = systemFunction.mOtherFunction.SupportBT.Value();
            self.iSupportCameraWhiteLight = systemFunction.mOtherFunction.SupportCameraWhiteLight.Value()?1:0;
            self.iSupportLP4GSupportDoubleLightSwitch = systemFunction.mOtherFunction.LP4GSupportDoubleLightSwitch.Value()?1 :0;
            self.iIntellAlertAlarm = systemFunction.mAlarmFunction.IntellAlertAlarm.ToBool()?1:0;
            self.iSupportLPWorkModeSwitchV2 = systemFunction.mOtherFunction.SupportLPWorkModeSwitchV2.Value()?1:0;
            self.iSupportLowPowerSetAlarmLed = systemFunction.mOtherFunction.SupportLowPowerSetAlarmLed.Value()?1:0;
            self.iSupportLPDoubleLightAlert = systemFunction.mOtherFunction.SupportLPDoubleLightAlert.Value()?1:0;
            self.iNotSupportAutoAndIntelligent = systemFunction.mOtherFunction.NotSupportAutoAndIntelligent.Value()?1:0;
            self.iSupportBoxCameraBulb = systemFunction.mOtherFunction.SupportBoxCameraBulb.Value()?1:0;
            self.iSupportDoubleLightBoxCamera = systemFunction.mOtherFunction.SupportDoubleLightBoxCamera.Value()?1:0;
            self.iSupportDoubleLightBul = systemFunction.mOtherFunction.SupportDoubleLightBulb.Value()?1:0;
            self.iPEAInHumanPed = systemFunction.mAlarmFunction.PEAInHumanPed.Value()?1:0;
            self.ifSupportSetVolume = systemFunction.mOtherFunction.SupportSetVolume.Value()?1:0;
            self.iSupportLowPowerDoubleLightToLightingSwitch = systemFunction.mOtherFunction.SupportLowPowerDoubleLightToLightingSwitch.Value()?1:0;
            self.iSupportMusicLightBulb = systemFunction.mOtherFunction.SupportMusicLightBulb.Value()?1:0;
            self.AovWorkModeIndieControl = systemFunction.mOtherFunction.AovWorkModeIndieControl.Value()?1:0;
        }
        
        if (self.callBack) {
            self.callBack(result);
        }
    }
}

@end
