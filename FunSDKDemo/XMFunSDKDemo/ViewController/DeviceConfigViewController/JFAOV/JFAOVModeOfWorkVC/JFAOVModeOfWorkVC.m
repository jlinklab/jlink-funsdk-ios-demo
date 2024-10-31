//
//  JFAOVModeOfWorkVC.m
//   iCSee
//
//  Created by Megatron on 2024/4/24.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import "JFAOVModeOfWorkVC.h"
#import "JFAOVModeOfWorkView.h"
#import "JFAOVModeOfWorkAffairManager.h"


@interface JFAOVModeOfWorkVC () <JFAOVModeOfWorkViewDelegate>

/**导航栏按钮*/
@property (nonatomic, strong) UIButton *btnNavBack;
@property (nonatomic, strong) JFAOVModeOfWorkView *contentView;
///工作模式事务管理器
@property (nonatomic, strong) JFAOVModeOfWorkAffairManager *affairManager;
///是否是首次进入
@property (nonatomic, assign) BOOL viewDidAppaerBefore;
@end

@implementation JFAOVModeOfWorkVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    self.devID = channel.deviceMac;
    
    [self.view addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.affairManager requestCfgWithDeviceID:self.devID];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //不是首次进入页面时继续电量上报
    if (self.viewDidAppaerBefore) {
        [self.affairManager startBatteryUpload];
    }
    self.viewDidAppaerBefore = YES;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    //离开页面时停止电量上报
    [self.affairManager stopBatteryUpload];
}

//MARK: - EventAction
- (void)btnNavBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

///更新内容视图
- (void)updateContentView{
    NSString *mode = [self.affairManager.workModeManager mode];
    if ([mode isEqualToString:@"Balance"]) {
        self.contentView.workMode = JFAOVWorkMode_Saving;
    }else if ([mode isEqualToString:@"Performance"]) {
        self.contentView.workMode = JFAOVWorkMode_Performance;
    }else if ([mode isEqualToString:@"Custom"]) {
        self.contentView.workMode = JFAOVWorkMode_Custom;
    }else{
        self.contentView.workMode = JFAOVWorkMode_Unknow;
    }
    self.contentView.savingModeFPS = JFSafeDictionary([self.affairManager.workModeManager balance], @"Fps");
    self.contentView.performanceModeFPS = JFSafeDictionary([self.affairManager.workModeManager performance], @"Fps");
    self.contentView.customFPS = JFSafeDictionary([self.affairManager.workModeManager custom], @"Fps");
    self.contentView.customRecordLatch = [JFSafeDictionary([self.affairManager.workModeManager custom], @"RecordLatch") intValue];
    self.contentView.aovAlarmHoldTime = [self.affairManager.workModeManager AlarmHoldTime];

    self.contentView.customRecordLatchList = [self.affairManager.abilityManager recordLatch];
    self.contentView.customFPSList = [self.affairManager.abilityManager videoFps];
    self.contentView.aovAlarmHoldTimeList = [self.affairManager.abilityManager AlarmHoldTime];

    self.contentView.lowBatteryLevel = [self.affairManager.lowElectrModeManager powerThreshold];
    
    if (self.supportAovWorkModeIndieControl) {
        self.contentView.savingModeAlarmHoldTime = [JFSafeDictionary([self.affairManager.workModeManager balance], @"AlarmHoldTime") intValue];
        self.contentView.savingModeRecordLength = [JFSafeDictionary([self.affairManager.workModeManager balance], @"RecordLength") intValue];
        self.contentView.performanceModeAlarmHoldTime = [JFSafeDictionary([self.affairManager.workModeManager performance], @"AlarmHoldTime") intValue];
        self.contentView.performanceModeRecordLength = [JFSafeDictionary([self.affairManager.workModeManager performance], @"RecordLength") intValue];
        
        self.contentView.customAlarmHoldTime = [JFSafeDictionary([self.affairManager.workModeManager custom], @"AlarmHoldTime") intValue];
        self.contentView.customRecordLength = [JFSafeDictionary([self.affairManager.workModeManager custom], @"RecordLength") intValue];
        
        self.contentView.customRecordLengthList = [self.affairManager.abilityManager RecordLengthList];
        self.contentView.customAlarmHoldTimeList = [self.affairManager.abilityManager AlarmHoldTime];
    }
    
    [self.contentView updateTableList];
};

- (void)setWorkModeManager:(DevAovWorkModeManager *)workModeManager{
    self.affairManager.workModeManager = workModeManager;
}

//MARK: - JFAOVModeOfWorkViewDelegate
- (void)userChangeWorkMode:(JFAOVWorkMode)mode{
    NSString *modeStr = @"Balance";
    if (mode == JFAOVWorkMode_Performance) {
        modeStr = @"Performance";
    }else if (mode == JFAOVWorkMode_Custom) {
        modeStr = @"Custom";
    }
    [self.affairManager.workModeManager setMode:modeStr];
    WeakSelf(weakSelf);
    [SVProgressHUD show];
    [self.affairManager.workModeManager requestSaveDevAovWorkModeCompleted:^(int result) {
        if (result >= 0) {
            [SVProgressHUD dismiss];
            [weakSelf updateContentView];
        }else{
            [weakSelf.affairManager requestCfgWithDeviceID:weakSelf.devID];
        }
    }];
}

- (void)userChangeCustomFPS:(NSString *)fps{
    NSMutableDictionary *dicCfg = [[self.affairManager.workModeManager custom] mutableCopy];
    [dicCfg setObject:fps forKey:@"Fps"];
    [self.affairManager.workModeManager setCustom:dicCfg];
    WeakSelf(weakSelf);
    [SVProgressHUD show];
    [self.affairManager.workModeManager requestSaveDevAovWorkModeCompleted:^(int result) {
        if (result >= 0) {
            [SVProgressHUD dismiss];
            [weakSelf updateContentView];
        }else{
            [MessageUI ShowErrorInt:result];
        }
    }];
}

///用户切换报警间隔 （自定义模式）
- (void)userChangeCustomAlarmHoldTime:(int)alarmHoldTime {
    NSMutableDictionary *dicCfg = [[self.affairManager.workModeManager custom] mutableCopy];
    [dicCfg setObject:@(alarmHoldTime) forKey:@"AlarmHoldTime"];
    [self.affairManager.workModeManager setCustom:dicCfg];
    WeakSelf(weakSelf);
    [SVProgressHUD show];
    [self.affairManager.workModeManager requestSaveDevAovWorkModeCompleted:^(int result) {
        if (result >= 0) {
            [SVProgressHUD dismiss];
            [weakSelf updateContentView];
        }else{
            [MessageUI ShowErrorInt:result];
        }
    }];
}
///用户切换最大录像时长（自定义模式）
- (void)userChangeCustomRecordLength:(int)RecordLength {
    NSMutableDictionary *dicCfg = [[self.affairManager.workModeManager custom] mutableCopy];
    [dicCfg setObject:@(RecordLength) forKey:@"RecordLength"];
    [self.affairManager.workModeManager setCustom:dicCfg];
    WeakSelf(weakSelf);
    [SVProgressHUD show];
    [self.affairManager.workModeManager requestSaveDevAovWorkModeCompleted:^(int result) {
        if (result >= 0) {
            [SVProgressHUD dismiss];
            [weakSelf updateContentView];
        }else{
            [MessageUI ShowErrorInt:result];
        }
    }];
}

- (void)userChangeCustomEventRecordLatch:(int)recordLatch{
    NSMutableDictionary *dicCfg = [[self.affairManager.workModeManager custom] mutableCopy];
    [dicCfg setObject:[NSNumber numberWithInt:recordLatch] forKey:@"RecordLatch"];
    [self.affairManager.workModeManager setCustom:dicCfg];
    WeakSelf(weakSelf);
    [SVProgressHUD show];
    [self.affairManager.workModeManager requestSaveDevAovWorkModeCompleted:^(int result) {
        if (result >= 0) {
            [SVProgressHUD dismiss];
            [weakSelf updateContentView];
        }else{
            [MessageUI ShowErrorInt:result];
        }
    }];
}

- (void)userChangeAlarmHoldTime:(int)alarmHoldTime {
    [self.affairManager.workModeManager setAlarmHoldTime:alarmHoldTime];
    WeakSelf(weakSelf);
    [SVProgressHUD show];
    [self.affairManager.workModeManager requestSaveDevAovWorkModeCompleted:^(int result) {
        if (result >= 0) {
            [SVProgressHUD dismiss];
            [weakSelf updateContentView];
        }else{
            [MessageUI ShowErrorInt:result];
        }
    }];
}

//MARK: - LazyLoad
- (UIButton *)btnNavBack{
    if (!_btnNavBack) {
        _btnNavBack = [UIButton buttonWithType:UIButtonTypeSystem];
        _btnNavBack.frame = CGRectMake(0, 0, 32, 32);
        [_btnNavBack setBackgroundImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
        [_btnNavBack addTarget:self action:@selector(btnNavBackClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _btnNavBack;
}

- (JFAOVModeOfWorkView *)contentView{
    if (!_contentView){
        _contentView = [[JFAOVModeOfWorkView alloc] init];
        _contentView.delegate = self;
        _contentView.supportDoubleLightBoxCamera = self.supportDoubleLightBoxCamera;
        _contentView.supportAovAlarmHold = self.supportAovAlarmHold;
        _contentView.supportAovWorkModeIndieControl = self.supportAovWorkModeIndieControl;
    }
    
    return _contentView;
}

- (JFAOVModeOfWorkAffairManager *)affairManager{
    if (!_affairManager) {
        _affairManager = [[JFAOVModeOfWorkAffairManager alloc] init];
        WeakSelf(weakSelf);
        _affairManager.AllConfigRequestedCallBack = ^{
            [weakSelf updateContentView];
        };
        _affairManager.ConfigRequestFailedCallBack = ^{
            [weakSelf btnNavBackClicked];
        };
        _affairManager.BatteryLevelChanged = ^(int percentage) {
            weakSelf.contentView.batteryLevel = percentage;
            [weakSelf.contentView configBatterValueTips];
        };
        _affairManager.BatteryChargingChanged = ^(BOOL ifCharging) {
            weakSelf.contentView.ifCharging = ifCharging;
            [weakSelf.contentView configBatterValueTips];
        };
    }
    
    return _affairManager;
}

@end
