//
//  JFAOVIntelligentDetectAffairManager.m
//   iCSee
//
//  Created by Megatron on 2024/4/29.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import "JFAOVIntelligentDetectAffairManager.h"
#import "CfgStatusManager.h"


@interface JFAOVIntelligentDetectAffairManager ()

///配置状态管理器
@property (nonatomic,strong) CfgStatusManager *cfgStatusManager;

@end
@implementation JFAOVIntelligentDetectAffairManager

- (instancetype)init{
    self = [super init];
    if (self) {
        self.multiSensor = -1;
    }
    
    return self;
}

///获取配置
- (void)requestCfgWithDeviceID:(NSString *)devID{
    [SVProgressHUD show];
    self.devID = devID;
    WeakSelf(weakSelf);
    //获取支人形检测规则配置
    [self.humanRuleLimitManager requestHumanRuleLimitConfigDeviceID:self.devID channel:-1 completed:^(int result) {
        if (result >= 0) {
            //人形检测配置需要通过规则配置判断如何解析数据
            [self requestHumanDetectionConfig];
            [weakSelf getConfigSuccess:@"HumanRuleLimitManager"];
        }else{
            [MessageUI ShowErrorInt:result];
            [weakSelf getConfigFailed:@"HumanRuleLimitManager"];
        }
    }];
    //获取智能警戒管理器
    [self.intellAlertAlarmMannager getIntellAlertAlarm:self.devID channel:-1 completed:^(int result, int channel) {
        if (result >= 0) {
            [weakSelf getConfigSuccess:@"IntellAlertAlarmMannager"];
        }else{
            [MessageUI ShowErrorInt:result];
            [weakSelf getConfigFailed:@"IntellAlertAlarmMannager"];
        }
    }];
}

- (void)requestHumanDetectionConfig{
    self.humanDetectionManager.ifMultiSensor = [self.humanRuleLimitManager supportMultiSensor];
    if (self.humanDetectionManager.ifMultiSensor) {
        self.multiSensor = 1;
    }else{
        self.multiSensor = 0;
    }
    WeakSelf(weakSelf);
    //获取人形检测配置
    [self.humanDetectionManager requestHumanDetectionConfigDeviceID:self.devID channel:-1 completed:^(int result) {
        if (result >= 0) {
            [weakSelf getConfigSuccess:@"JFHumanDetectionManager"];
        }else{
            [MessageUI ShowErrorInt:result];
            [weakSelf getConfigFailed:@"JFHumanDetectionManager"];
        }
    }];
}

///配置获取成功时 调用一次
- (void)getConfigSuccess:(NSString *)cfgName{
    [self.cfgStatusManager changeCfgStatus:XMCfgStatus_Success name:cfgName];
    if([self.cfgStatusManager checkAllCfgFinishedRequest]){
        [SVProgressHUD dismiss];
        //通知UI刷新
        if (self.AllConfigRequestedCallBack) {
            self.AllConfigRequestedCallBack();
        }
    }
}

///配置回去失败时 调用
- (void)getConfigFailed:(NSString *)cfgName{
    if (self.ConfigRequestFailedCallBack) {
        self.ConfigRequestFailedCallBack();
    }
}

//MARK: - LazyLoad
- (JFHumanDetectionManager *)humanDetectionManager{
    if (!_humanDetectionManager) {
        _humanDetectionManager = [[JFHumanDetectionManager alloc] init];
    }
    
    return _humanDetectionManager;
}

- (HumanRuleLimitManager *)humanRuleLimitManager{
    if (!_humanRuleLimitManager) {
        _humanRuleLimitManager = [[HumanRuleLimitManager alloc] init];
    }
    
    return _humanRuleLimitManager;
}

- (IntellAlertAlarmMannager *)intellAlertAlarmMannager{
    if (!_intellAlertAlarmMannager) {
        _intellAlertAlarmMannager = [[IntellAlertAlarmMannager alloc] init];
    }
    
    return _intellAlertAlarmMannager;
}

- (CfgStatusManager *)cfgStatusManager{
     if (!_cfgStatusManager) {
          _cfgStatusManager = [[CfgStatusManager alloc] init];
          
          [_cfgStatusManager addCfgName:@"JFHumanDetectionManager"];//人形检测配置
          [_cfgStatusManager addCfgName:@"HumanRuleLimitManager"];//支人形检测规则配置
          [_cfgStatusManager addCfgName:@"IntellAlertAlarmMannager"];//智能警戒管理器
     }
     
     return _cfgStatusManager;
}

@end
