//
//  JFAOVSmartSecurityVC.h
//   iCSee
//
//  Created by kevin on 2024/4/29.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//
/*
 aov 智能报警新首页
 */
#import <UIKit/UIKit.h>
#import "FunSDKBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface JFAOVSmartSecurityVC : FunSDKBaseViewController
@property (nonatomic,copy) NSString *navTitle;
@property (nonatomic, assign) BOOL iSupportHumanPedDetection;//智能侦测
@property (nonatomic, assign) BOOL iSupportPirAlarm;//PIR侦测
@property (nonatomic, assign) BOOL iSupportIntellAlertAlarm;// 报警联动
///是否支持PIR灵敏度设置
@property (nonatomic,assign) BOOL ifSupportPIRSensitive;
@property (nonatomic, assign) BOOL iSupportSetVolume;// 报警联动--报警音量
@property (nonatomic, assign) BOOL supportAlarmVoiceTipInterval;//支持报警间隔
@property (nonatomic, assign) BOOL iMultiAlgoCombinePed;//AOV多算法组合, 支持人车
@end

NS_ASSUME_NONNULL_END
