//
//  JFAOVBatteryManagementAffairManager.m
//   iCSee
//
//  Created by Megatron on 2024/4/25.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import "JFAOVBatteryManagementAffairManager.h"
#import "DoorBellModel.h"
#import "CfgStatusManager.h"
#import "NSDate+Ex.h"
#import "JFDeviceTransaction.h"

@interface JFAOVBatteryManagementAffairManager ()

///配置状态管理器
@property (nonatomic,strong) CfgStatusManager *cfgStatusManager;
///是否需要Dismiss 如果提前消失了 所有配置都完成后就不用再dismiss了
@property (nonatomic,assign) BOOL needSVPDismiss;

@end
@implementation JFAOVBatteryManagementAffairManager

///获取配置
- (void)requestCfgWithDeviceID:(NSString *)devID ifAOVDevice:(BOOL)ifAOV {
    [SVProgressHUD show];
    self.needSVPDismiss = YES;
    self.devID = devID;
    WeakSelf(weakSelf);
    
    if (ifAOV) {
        //获取低电量配置
        [self.lowElectrModeManager requestDevLowElectrModeWithDevice:devID completed:^(int result) {
            if (result >= 0) {
                [weakSelf getConfigSuccess:@"DevLowElectrModeManager"];
            }else{
                [MessageUI ShowErrorInt:result];
                [weakSelf getConfigFailed:@"DevLowElectrModeManager"];
            }
        }];
        //获取支持的编码能力
        [self.abilityManager requestAbilityAovAbilityWithDevice:devID completed:^(int result) {
            if (result >= 0) {
                [weakSelf getConfigSuccess:@"AbilityAovAbility"];
            }else{
                [MessageUI ShowErrorInt:result];
                [weakSelf getConfigFailed:@"AbilityAovAbility"];
            }
        }];
        
        //获取一天内的日志信息
        NSArray *time1 = [NSDate getRecentDaysStartAndEndDateTime:1];
        [self.deviceLogInfoOneDayManager requestDeviceLogWithDevice:self.devID startTime:[time1 objectAtIndex:0] endTime:[time1 objectAtIndex:1] completed:^(int result) {
            if (result >= 0) {
                [weakSelf getConfigSuccess:@"JFDeviceLogInfoManager"];
            }else{
                [weakSelf getConfigFailed:@"JFDeviceLogInfoManager"];
            }
        }];
        
        //获取7天内的日志信息
        NSArray *time7 = [NSDate getRecentDaysStartAndEndDateTime:7];
        [self.deviceLogInfoSevenDayManager requestDeviceLogWithDevice:self.devID startTime:[time7 objectAtIndex:0] endTime:[time7 objectAtIndex:1] completed:^(int result) {
            if (result >= 0) {
                [weakSelf getConfigSuccess:@"JFDeviceLogInfoManager7"];
            }else{
                [weakSelf getConfigFailed:@"JFDeviceLogInfoManager7"];
            }
        }];
        
        //强制校验目前有前提 必须token设备才强制校验
        BOOL forceCheckUserID = YES;
        if (![JFDeviceTransaction tokenDeviceForForceUsrIDCheckWithDeviceID:self.devID]) {
            forceCheckUserID = NO;
        }
        //获取1天的报警消息
        NSArray *time1Seconds = [NSDate getRecentDaysStartAndEndDateTimeAccurateToSecond:1];
        [self.alarmNumberStatisticsOneDayManager requestAlarmNumberWithDeviceID:self.devID channel:-1 startTime:[time1Seconds objectAtIndex:0] endTime:[time1Seconds objectAtIndex:1] eventS:@[] label:@[] completed:^(int result) {
            if (result >= 0) {
                [weakSelf getConfigSuccess:@"JFAlarmNumberStatisticsManager"];
            }else{
                [weakSelf getConfigFailed:@"JFAlarmNumberStatisticsManager"];
            }
        }];
        
        //获取7天的报警消息
        NSArray *time7Seconds = [NSDate getRecentDaysStartAndEndDateTimeAccurateToSecond:7];
        [self.alarmNumberStatisticsSevenDayManager requestAlarmNumberWithDeviceID:self.devID channel:-1 startTime:[time7Seconds objectAtIndex:0] endTime:[time7Seconds objectAtIndex:1] eventS:@[] label:@[]  completed:^(int result) {
            if (result >= 0) {
                [weakSelf getConfigSuccess:@"JFAlarmNumberStatisticsManager7"];
            }else{
                [weakSelf getConfigFailed:@"JFAlarmNumberStatisticsManager7"];
            }
        }];
        
        //预览唤醒时间
        if (self.supportLowPowerWorkTime) {
            [self.systemLowPowerWorkTimeManager requestSystemLowPowerWorkTimeWithDevice:self.devID completed:^(int result) {
                if (result >= 0) {
                    [weakSelf getConfigSuccess:@"SystemLowPowerWorkTimeManager"];
                }else{
                    [MessageUI ShowErrorInt:result];
                    [weakSelf getConfigFailed:@"SystemLowPowerWorkTimeManager"];
                }
            }];
        }else{
            [self getConfigSuccess:@"SystemLowPowerWorkTimeManager"];
        }
    }else{
        [self getConfigSuccess:@"DevLowElectrModeManager"];
        [self getConfigSuccess:@"AbilityAovAbility"];
        //获取一天内的日志信息
        NSArray *time1 = [NSDate getRecentDaysStartAndEndDateTime:1];
        [self.deviceLogInfoOneDayManager requestDeviceLogWithDevice:self.devID startTime:[time1 objectAtIndex:0] endTime:[time1 objectAtIndex:1] completed:^(int result) {
            if (result >= 0) {
                [weakSelf getConfigSuccess:@"JFDeviceLogInfoManager"];
            }else{
                [weakSelf getConfigFailed:@"JFDeviceLogInfoManager"];
            }
        }];
        
        //获取7天内的日志信息
        NSArray *time7 = [NSDate getRecentDaysStartAndEndDateTime:7];
        [self.deviceLogInfoSevenDayManager requestDeviceLogWithDevice:self.devID startTime:[time7 objectAtIndex:0] endTime:[time7 objectAtIndex:1] completed:^(int result) {
            if (result >= 0) {
                [weakSelf getConfigSuccess:@"JFDeviceLogInfoManager7"];
            }else{
                [weakSelf getConfigFailed:@"JFDeviceLogInfoManager7"];
            }
        }];
        
        //强制校验目前有前提 必须token设备才强制校验
        BOOL forceCheckUserID = YES;
        if (![JFDeviceTransaction tokenDeviceForForceUsrIDCheckWithDeviceID:self.devID]) {
            forceCheckUserID = NO;
        }
        //获取1天的报警消息
        NSArray *time1Seconds = [NSDate getRecentDaysStartAndEndDateTimeAccurateToSecond:1];
        [self.alarmNumberStatisticsOneDayManager requestAlarmNumberWithDeviceID:self.devID channel:-1 startTime:[time1Seconds objectAtIndex:0] endTime:[time1Seconds objectAtIndex:1] eventS:@[] label:@[]  completed:^(int result) {
            if (result >= 0) {
                [weakSelf getConfigSuccess:@"JFAlarmNumberStatisticsManager"];
            }else{
                [weakSelf getConfigFailed:@"JFAlarmNumberStatisticsManager"];
            }
        }];
        
        //获取7天的报警消息
        NSArray *time7Seconds = [NSDate getRecentDaysStartAndEndDateTimeAccurateToSecond:7];
        [self.alarmNumberStatisticsSevenDayManager requestAlarmNumberWithDeviceID:self.devID channel:-1 startTime:[time7Seconds objectAtIndex:0] endTime:[time7Seconds objectAtIndex:1] eventS:@[] label:@[]  completed:^(int result) {
            if (result >= 0) {
                [weakSelf getConfigSuccess:@"JFAlarmNumberStatisticsManager7"];
            }else{
                [weakSelf getConfigFailed:@"JFAlarmNumberStatisticsManager7"];
            }
        }];
        
        //预览唤醒时间
        if (self.supportLowPowerWorkTime) {
            [self.systemLowPowerWorkTimeManager requestSystemLowPowerWorkTimeWithDevice:self.devID completed:^(int result) {
                if (result >= 0) {
                    [weakSelf getConfigSuccess:@"SystemLowPowerWorkTimeManager"];
                }else{
                    [MessageUI ShowErrorInt:result];
                    [weakSelf getConfigFailed:@"SystemLowPowerWorkTimeManager"];
                }
            }];
        }else{
            [self getConfigSuccess:@"SystemLowPowerWorkTimeManager"];
        }
    }
    
    //获取电池电量信息 非UI阻塞
    [[DoorBellModel shareInstance] beginStopUploadData:devID];
    [[DoorBellModel shareInstance] beginUploadData:devID];
    [DoorBellModel shareInstance].DevUploadDataCallBack = ^(NSDictionary *state, NSString *devMac) {
        if ([state isKindOfClass:[NSDictionary class]] && [devMac isKindOfClass:[NSString class]]) {
            NSNumber *numberP = [state objectForKey:@"percent"];
            NSNumber *numberL = [state objectForKey:@"level"];
            NSNumber *numberS = [state objectForKey:@"DevStorageStatus"];
            NSNumber *numberElectable = [state objectForKey:@"electable"];
            
            if (numberElectable && ![numberElectable isMemberOfClass:[NSNull class]]) {
                if ([numberElectable intValue] == 3) {//说明返回电量数据不准确 不需要处理
                    return;
                }
            }
            
            if (((numberP && ![numberP isMemberOfClass:[NSNull class]]) || (numberL && ![numberL isMemberOfClass:[NSNull class]])) && numberS && ![numberS isMemberOfClass:[NSNull class]]) {
                //电量上报时，会有两个字段level和percent来计算和判断具体的电量。有level就用level，没有level那么percent就当成level，都有就用percent。level是0-7的整数，代表大致的电量百分比使用以下计算：level * 100 / 7。如果两个字段都有，就直接用percent当作电量百分比。
                int percentage = 0;
                if ([state objectForKey:@"level"]){
                    int electLevel = [[state objectForKey:@"level"] intValue];
                    percentage = electLevel * 100 / 7;
                    if ([state objectForKey:@"percent"]) {
                        percentage = [[state objectForKey:@"percent"] intValue];
                    }
                }else if ([state objectForKey:@"percent"]){
                    int electLevel = [[state objectForKey:@"percent"] intValue];
                    percentage = electLevel * 100 / 7;
                }
                
                if (percentage <= 0) {
                    percentage = 0;
                }else if (percentage > 100){
                    percentage = 100;
                }

                [[DoorBellModel shareInstance] setDevice:devMac batteryNum:percentage];
                [[DoorBellModel shareInstance] updateDeviceBatteryRecord];
                
                if (weakSelf.BatteryChargingChanged) {
                    weakSelf.BatteryChargingChanged([numberElectable intValue] == 1 ? YES : NO);
                }
                if (weakSelf.BatteryLevelChanged) {
                    weakSelf.BatteryLevelChanged(percentage);
                }
            }
        }
    };
}

///停止电量上报
- (void)stopBatteryUpload{
    [[DoorBellModel shareInstance] beginStopUploadData:self.devID];
}

///开启电量上报
- (void)startBatteryUpload{
    [[DoorBellModel shareInstance] beginStopUploadData:self.devID];
    [[DoorBellModel shareInstance] beginUploadData:self.devID];
}

///通过配置名称检测配置是否获取成功
- (BOOL)configRequestedWithName:(NSString *)cfgName {
    XMCfgStatus status = [self.cfgStatusManager configStatusWithName:cfgName];
    if (status == XMCfgStatus_Success) {
        return YES;
    }
    
    return NO;
}

///配置获取成功时 调用一次
- (void)getConfigSuccess:(NSString *)cfgName {
    [self.cfgStatusManager changeCfgStatus:XMCfgStatus_Success name:cfgName];
    if ([self configRequestedWithName:@"DevLowElectrModeManager"] && \
        [self configRequestedWithName:@"AbilityAovAbility"] && \
        [self configRequestedWithName:@"JFAlarmNumberStatisticsManager"] && \
        [self configRequestedWithName:@"JFAlarmNumberStatisticsManager7"] && \
        [self configRequestedWithName:@"SystemLowPowerWorkTimeManager"]) {
        [SVProgressHUD dismiss];
        self.needSVPDismiss = NO;
    }
    
    if([self.cfgStatusManager checkAllCfgFinishedRequest]) {
        if (self.needSVPDismiss) {
            [SVProgressHUD dismiss];
            self.needSVPDismiss = NO;
        }
        
        //通知UI刷新
        if (self.AllConfigRequestedCallBack) {
            self.AllConfigRequestedCallBack();
        }
    }else {
        //如果是多个配置同时获取的 所有配置没有获取成功之前 每获取到一个会回调一次 最后一个获取的不在这里回调 在上面回调AllConfigRequestedCallBack
        if (self.SingleConfigResuestedCallBack) {
            self.SingleConfigResuestedCallBack(cfgName);
        }
    }
}

///配置回去失败时 调用
- (void)getConfigFailed:(NSString *)cfgName{
    // 如果是获取一天或者七点的电量信息和 报警信息的，获取失败不用返回
    if ([cfgName isEqualToString:@"DevLowElectrModeManager"] || [cfgName isEqualToString:@"SystemLowPowerWorkTimeManager"] || [cfgName isEqualToString:@"AbilityAovAbility"] ) {
        if (self.ConfigRequestFailedCallBack) {
            self.ConfigRequestFailedCallBack();
        }
    }
    
}

//MARK: - LazyLoad
- (DevLowElectrModeManager *)lowElectrModeManager{
    if (!_lowElectrModeManager) {
        _lowElectrModeManager = [[DevLowElectrModeManager alloc] init];
    }
    
    return _lowElectrModeManager;
}

- (AbilityAovAbilityManager *)abilityManager{
    if (!_abilityManager) {
        _abilityManager = [[AbilityAovAbilityManager alloc] init];
    }
    
    return _abilityManager;
}

- (JFDeviceLogInfoManager *)deviceLogInfoOneDayManager{
    if (!_deviceLogInfoOneDayManager) {
        _deviceLogInfoOneDayManager = [[JFDeviceLogInfoManager alloc] init];
    }
    
    return _deviceLogInfoOneDayManager;
}

- (JFDeviceLogInfoManager *)deviceLogInfoSevenDayManager{
    if (!_deviceLogInfoSevenDayManager) {
        _deviceLogInfoSevenDayManager = [[JFDeviceLogInfoManager alloc] init];
    }
    
    return _deviceLogInfoSevenDayManager;
}

- (JFAlarmNumberStatisticsManager *)alarmNumberStatisticsOneDayManager{
    if (!_alarmNumberStatisticsOneDayManager) {
        _alarmNumberStatisticsOneDayManager = [[JFAlarmNumberStatisticsManager alloc] init];
    }
    
    return _alarmNumberStatisticsOneDayManager;
}

- (JFAlarmNumberStatisticsManager *)alarmNumberStatisticsSevenDayManager{
    if (!_alarmNumberStatisticsSevenDayManager) {
        _alarmNumberStatisticsSevenDayManager = [[JFAlarmNumberStatisticsManager alloc] init];
    }
    
    return _alarmNumberStatisticsSevenDayManager;
}

- (SystemLowPowerWorkTimeManager *)systemLowPowerWorkTimeManager{
    if (!_systemLowPowerWorkTimeManager) {
        _systemLowPowerWorkTimeManager = [[SystemLowPowerWorkTimeManager alloc] init];
    }
    
    return _systemLowPowerWorkTimeManager;
}

- (CfgStatusManager *)cfgStatusManager{
     if (!_cfgStatusManager) {
        _cfgStatusManager = [[CfgStatusManager alloc] init];

        [_cfgStatusManager addCfgName:@"DevLowElectrModeManager"];//低电量配置
        [_cfgStatusManager addCfgName:@"AbilityAovAbility"];//支持的电池模式其他能力配置
        [_cfgStatusManager addCfgName:@"JFDeviceLogInfoManager"];//1天的日志信息
        [_cfgStatusManager addCfgName:@"JFDeviceLogInfoManager7"];//7天的日志信息
        [_cfgStatusManager addCfgName:@"JFAlarmNumberStatisticsManager"];//1天的报警信息
        [_cfgStatusManager addCfgName:@"JFAlarmNumberStatisticsManager7"];//7天的报警信息
        [_cfgStatusManager addCfgName:@"SystemLowPowerWorkTimeManager"];//预览唤醒时间
     }
     
     return _cfgStatusManager;
}

@end
