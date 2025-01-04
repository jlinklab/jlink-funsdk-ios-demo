//
//  JFAOVBatteryManagementVC.m
//   iCSee
//
//  Created by Megatron on 2024/4/25.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import "JFAOVBatteryManagementVC.h"
#import "JFAOVBatteryManagemenView.h"
#import "JFAOVBatteryManagementAffairManager.h"

@interface JFAOVBatteryManagementVC () <JFAOVBatteryManagemenViewDelegate>

/**导航栏按钮*/
@property (nonatomic, strong) UIButton *btnNavBack;
@property (nonatomic, strong) JFAOVBatteryManagemenView *contentView;
///工作模式事务管理器
@property (nonatomic, strong) JFAOVBatteryManagementAffairManager *affairManager;
///是否是首次进入
@property (nonatomic, assign) BOOL viewDidAppaerBefore;

@end

@implementation JFAOVBatteryManagementVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    self.devID = channel.deviceMac;
    
    self.contentView.notAOVDevice = self.notAOVDevice;
    [self.view addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.contentView updateTableList];
    [self.affairManager requestCfgWithDeviceID:self.devID ifAOVDevice:!self.notAOVDevice];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //不是首次进入页面时继续电量上报
    if (self.viewDidAppaerBefore) {
        [self.affairManager startBatteryUpload];
    }
    self.viewDidAppaerBefore = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    //离开页面时停止电量上报
    [self.affairManager stopBatteryUpload];
}

//MARK: - EventAction
- (void)btnNavBackClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

///更新内容视图
- (void)updateContentView {
    if (!self.notAOVDevice) {
        //设备配置都获取到就先显示
        if ([self.affairManager configRequestedWithName:@"DevLowElectrModeManager"] && \
            [self.affairManager configRequestedWithName:@"AbilityAovAbility"] && \
            [self.affairManager configRequestedWithName:@"JFAlarmNumberStatisticsManager"] && \
            [self.affairManager configRequestedWithName:@"JFAlarmNumberStatisticsManager7"] && \
            [self.affairManager configRequestedWithName:@"SystemLowPowerWorkTimeManager"]) {
            self.contentView.lowBatteryLevel = [self.affairManager.lowElectrModeManager powerThreshold];
            self.contentView.lowElectrMax = [self.affairManager.abilityManager lowElectrMax];
            self.contentView.lowElectrMin = [self.affairManager.abilityManager lowElectrMin];
            self.contentView.alarmNumberOneDay = self.affairManager.alarmNumberStatisticsOneDayManager.alarmNumber;
            self.contentView.alarmNumberSevenDay = self.affairManager.alarmNumberStatisticsSevenDayManager.alarmNumber;
            [self.contentView updateTableFooterBatteryInfoAbility:JFBatteryInfo_PreviewTimeStatistics support:self.supportLowPowerWorkTime];
            [self.contentView updateTableFooterBatteryInfoAbility:JFBatteryInfo_WakeUpTimeStatistics support:self.supportLowPowerWorkTime];
            [self.contentView updateTableFooterBatteryInfoAbility:JFBatteryInfo_AlarmFrequencyStatistics support:YES];
            if (self.supportLowPowerWorkTime) {
                NSArray *previews = [self.affairManager.systemLowPowerWorkTimeManager realViewTime];
                int previewSeconds = 0;
                for (int i = 0; i < previews.count; i++) {
                    previewSeconds = previewSeconds + [[previews objectAtIndex:i] intValue];
                }
                NSArray *wakeUps = [self.affairManager.systemLowPowerWorkTimeManager wakeupTime];
                int wakeUpSeconds = 0;
                for (int i = 0; i < wakeUps.count; i++) {
                    wakeUpSeconds = wakeUpSeconds + [[wakeUps objectAtIndex:i] intValue];
                }
                self.contentView.previewSecondsOneDay = [[previews lastObject] intValue];
                self.contentView.previewSecondsSevenDay = previewSeconds;
                self.contentView.wakeUpSecondsOneDay = [[wakeUps lastObject] intValue];
                self.contentView.wakeUpSecondsSevenDay = wakeUpSeconds;
            }
            [self.contentView updateConfigListVisiable:YES cfgNames:@[TS("TR_Setting_Low_Power_Mode")]];
        }
        
        if ([self.affairManager configRequestedWithName:@"JFDeviceLogInfoManager"]) {
            self.contentView.arrayPowerOneDay = self.affairManager.deviceLogInfoOneDayManager.arrayPower;
            self.contentView.arraySignalOneDay = self.affairManager.deviceLogInfoOneDayManager.arraySignal;
            [self.contentView updateTableFooterBatteryInfoAbility:JFBatteryInfo_BatteryChart support:self.affairManager.deviceLogInfoOneDayManager.arrayPower.count > 0 ? YES : NO];
            [self.contentView updateTableFooterBatteryInfoAbility:JFBatteryInfo_SignalChart support:self.affairManager.deviceLogInfoOneDayManager.arraySignal.count > 0 ? YES : NO];
        }
        if ([self.affairManager configRequestedWithName:@"JFDeviceLogInfoManager7"]) {
            self.contentView.arrayPowerSevenDay = self.affairManager.deviceLogInfoSevenDayManager.arrayPower;
            self.contentView.arraySignalSevenDay = self.affairManager.deviceLogInfoSevenDayManager.arraySignal;
        }
        
        [self.contentView updateTableFooterFromAbility];
    }else {
        //设备配置都获取到就先显示
        if ([self.affairManager configRequestedWithName:@"JFAlarmNumberStatisticsManager"] && \
            [self.affairManager configRequestedWithName:@"JFAlarmNumberStatisticsManager7"] && \
            [self.affairManager configRequestedWithName:@"SystemLowPowerWorkTimeManager"]) {
            self.contentView.alarmNumberOneDay = self.affairManager.alarmNumberStatisticsOneDayManager.alarmNumber;
            self.contentView.alarmNumberSevenDay = self.affairManager.alarmNumberStatisticsSevenDayManager.alarmNumber;
            [self.contentView updateTableFooterBatteryInfoAbility:JFBatteryInfo_PreviewTimeStatistics support:self.supportLowPowerWorkTime];
            [self.contentView updateTableFooterBatteryInfoAbility:JFBatteryInfo_WakeUpTimeStatistics support:self.supportLowPowerWorkTime];
            [self.contentView updateTableFooterBatteryInfoAbility:JFBatteryInfo_AlarmFrequencyStatistics support:YES];
            if (self.supportLowPowerWorkTime) {
                NSArray *previews = [self.affairManager.systemLowPowerWorkTimeManager realViewTime];
                int previewSeconds = 0;
                for (int i = 0; i < previews.count; i++) {
                    previewSeconds = previewSeconds + [[previews objectAtIndex:i] intValue];
                }
                NSArray *wakeUps = [self.affairManager.systemLowPowerWorkTimeManager wakeupTime];
                int wakeUpSeconds = 0;
                for (int i = 0; i < wakeUps.count; i++) {
                    wakeUpSeconds = wakeUpSeconds + [[wakeUps objectAtIndex:i] intValue];
                }
                self.contentView.previewSecondsOneDay = [[previews lastObject] intValue];
                self.contentView.previewSecondsSevenDay = previewSeconds;
                self.contentView.wakeUpSecondsOneDay = [[wakeUps lastObject] intValue];
                self.contentView.wakeUpSecondsSevenDay = wakeUpSeconds;
            }
        }
        
        if ([self.affairManager configRequestedWithName:@"JFDeviceLogInfoManager"]) {
            self.contentView.arrayPowerOneDay = self.affairManager.deviceLogInfoOneDayManager.arrayPower;
            self.contentView.arraySignalOneDay = self.affairManager.deviceLogInfoOneDayManager.arraySignal;
            [self.contentView updateTableFooterBatteryInfoAbility:JFBatteryInfo_BatteryChart support:self.affairManager.deviceLogInfoOneDayManager.arrayPower.count > 0 ? YES : NO];
            [self.contentView updateTableFooterBatteryInfoAbility:JFBatteryInfo_SignalChart support:self.affairManager.deviceLogInfoOneDayManager.arraySignal.count > 0 ? YES : NO];
        }
        if ([self.affairManager configRequestedWithName:@"JFDeviceLogInfoManager7"]) {
            self.contentView.arrayPowerSevenDay = self.affairManager.deviceLogInfoSevenDayManager.arrayPower;
            self.contentView.arraySignalSevenDay = self.affairManager.deviceLogInfoSevenDayManager.arraySignal;
        }
        
        [self.contentView updateTableFooterFromAbility];
    }
    
    [self.contentView updateTableList];
}

//MARK: - JFAOVBatteryManagemenViewDelegate
- (void)userChangeLowBatteryLevel:(int)level {
    ///保存低电量配置
    [self.affairManager.lowElectrModeManager setPowerThreshold:level];
    [SVProgressHUD show];
    WeakSelf(weakSelf);
    [self.affairManager.lowElectrModeManager requestSaveDevLowElectrModeCompleted:^(int result) {
        if (result >= 0) {
            [SVProgressHUD showSuccessWithStatus:TS("Save_Success")];
            [weakSelf updateContentView];
        }else{
            [MessageUI ShowErrorInt:result];
        }
    }];
}

//MARK: - LazyLoad
- (UIButton *)btnNavBack {
    if (!_btnNavBack) {
        _btnNavBack = [UIButton buttonWithType:UIButtonTypeSystem];
        _btnNavBack.frame = CGRectMake(0, 0, 32, 32);
        [_btnNavBack setBackgroundImage:[UIImage imageNamed:@"UserLoginView-back-nor"] forState:UIControlStateNormal];
        [_btnNavBack addTarget:self action:@selector(btnNavBackClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _btnNavBack;
}

- (JFAOVBatteryManagemenView *)contentView {
    if (!_contentView){
        _contentView = [[JFAOVBatteryManagemenView alloc] init];
        _contentView.delegate = self;
    }
    
    return _contentView;
}

- (JFAOVBatteryManagementAffairManager *)affairManager {
    if (!_affairManager) {
        _affairManager = [[JFAOVBatteryManagementAffairManager alloc] init];
        _affairManager.supportLowPowerWorkTime = self.supportLowPowerWorkTime;
        WeakSelf(weakSelf);
        _affairManager.AllConfigRequestedCallBack = ^{
            [weakSelf updateContentView];
        };
        _affairManager.SingleConfigResuestedCallBack = ^(NSString * _Nonnull cfgName) {
            [weakSelf updateContentView];
        };
        _affairManager.ConfigRequestFailedCallBack = ^{
            [weakSelf btnNavBackClicked];
        };
        _affairManager.BatteryLevelChanged = ^(int percentage) {
            weakSelf.contentView.batteryLevel = percentage;
            [weakSelf.contentView updateTableList];
        };
        _affairManager.BatteryChargingChanged = ^(BOOL ifCharging) {
            weakSelf.contentView.ifCharging = ifCharging;
            [weakSelf.contentView updateTableList];
        };
    }
    
    return _affairManager;
}

@end
