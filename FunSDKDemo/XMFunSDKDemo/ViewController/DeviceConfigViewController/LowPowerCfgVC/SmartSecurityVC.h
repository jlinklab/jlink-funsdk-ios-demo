//
//  SmartSecurityVC.h
//   
//
//  Created by Tony Stark on 2022/5/19.
//  Copyright © 2022 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FunSDKBaseViewController.h"

typedef NS_ENUM(NSInteger, SMARTSECURITYALARMTYPE) {
    SMARTSECURITYALARMTYPE_VideoEnable,//本地录像是否保存
    SMARTSECURITYALARMTYPE_PirAlarm,//人体感应报警配置
    SMARTSECURITYALARMTYPE_IntellAlertAlarmAndVideoVolumeOutput,//报警音和智能报警一块保存
    SMARTSECURITYALARMTYPE_MessageAlarm,//是否支持推送报警

};


NS_ASSUME_NONNULL_BEGIN

/*
 低功耗智能警戒
 */
@interface SmartSecurityVC : FunSDKBaseViewController

//是否支持白光红外切换转照明开关
@property (nonatomic,assign) BOOL ifSupportLowPowerDoubleLightToLightingSwitch;

@end

NS_ASSUME_NONNULL_END
