//
//  JFAOVPIRDetectAffairManager.m
//   iCSee
//
//  Created by Megatron on 2024/4/29.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import "JFAOVPIRDetectAffairManager.h"
#import "CfgStatusManager.h"

@interface JFAOVPIRDetectAffairManager ()

///配置状态管理器
@property (nonatomic,strong) CfgStatusManager *cfgStatusManager;

@end
@implementation JFAOVPIRDetectAffairManager

///获取配置
- (void)requestCfgWithDeviceID:(NSString *)devID{
    [SVProgressHUD show];
    self.devID = devID;
    WeakSelf(weakSelf);
    //获取PIR报警配置
    [self.pirAlarmManager getPirAlarm:self.devID channel:-1 completed:^(int result, int channel) {
        if (result >= 0) {
            [weakSelf getConfigSuccess:@"PirAlarmManager"];
        }else{
            [MessageUI ShowErrorInt:result];
            [weakSelf getConfigFailed:@"PirAlarmManager"];
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
- (PirAlarmManager *)pirAlarmManager{
    if (!_pirAlarmManager) {
        _pirAlarmManager = [[PirAlarmManager alloc] init];
    }
    
    return _pirAlarmManager;
}

- (CfgStatusManager *)cfgStatusManager{
     if (!_cfgStatusManager) {
          _cfgStatusManager = [[CfgStatusManager alloc] init];
          
          [_cfgStatusManager addCfgName:@"PirAlarmManager"];//PIR报警配置
     }
     
     return _cfgStatusManager;
}

@end
