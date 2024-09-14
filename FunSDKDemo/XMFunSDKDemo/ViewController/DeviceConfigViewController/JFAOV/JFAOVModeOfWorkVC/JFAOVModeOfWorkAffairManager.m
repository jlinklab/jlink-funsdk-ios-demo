//
//  JFAOVModeOfWorkAffairManager.m
//   iCSee
//
//  Created by Megatron on 2024/4/24.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import "JFAOVModeOfWorkAffairManager.h"
#import "CfgStatusManager.h"
#import "DoorBellModel.h"
@interface JFAOVModeOfWorkAffairManager ()

///配置状态管理器
@property (nonatomic,strong) CfgStatusManager *cfgStatusManager;

@end
@implementation JFAOVModeOfWorkAffairManager

///获取配置
- (void)requestCfgWithDeviceID:(NSString *)devID{
    [SVProgressHUD show];
    self.devID = devID;
    WeakSelf(weakSelf);
    //获取低电量配置
    [self.lowElectrModeManager requestDevLowElectrModeWithDevice:devID completed:^(int result) {
        if (result >= 0) {
            [weakSelf getConfigSuccess:@"DevLowElectrModeManager"];
        }else{
            [MessageUI ShowErrorInt:result];
            [weakSelf getConfigFailed:@"DevLowElectrModeManager"];
        }
    }];
    //获取工作模式
    [self.workModeManager requestDevAovWorkModeWithDevice:devID completed:^(int result) {
        if (result >= 0) {
            [weakSelf getConfigSuccess:@"DevAovWorkModeManager"];
        }else{
            [MessageUI ShowErrorInt:result];
            [weakSelf getConfigFailed:@"DevAovWorkModeManager"];
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

///配置获取失败时 调用
- (void)getConfigFailed:(NSString *)cfgName{
    if (self.ConfigRequestFailedCallBack) {
        self.ConfigRequestFailedCallBack();
    }
}

//MARK: - LazyLoad
- (DevAovWorkModeManager *)workModeManager{
    if (!_workModeManager) {
        _workModeManager = [[DevAovWorkModeManager alloc] init];
    }
    
    return _workModeManager;
}

- (AbilityAovAbilityManager *)abilityManager{
    if (!_abilityManager) {
        _abilityManager = [[AbilityAovAbilityManager alloc] init];
    }
    
    return _abilityManager;
}
- (DevLowElectrModeManager *)lowElectrModeManager{
    if (!_lowElectrModeManager) {
        _lowElectrModeManager = [[DevLowElectrModeManager alloc] init];
    }
    
    return _lowElectrModeManager;
}
- (CfgStatusManager *)cfgStatusManager{
     if (!_cfgStatusManager) {
          _cfgStatusManager = [[CfgStatusManager alloc] init];
         [_cfgStatusManager addCfgName:@"DevLowElectrModeManager"];//低电量配置
          [_cfgStatusManager addCfgName:@"DevAovWorkModeManager"];//工作模式配置
          [_cfgStatusManager addCfgName:@"AbilityAovAbility"];//支持的编码能力配置
     }
     
     return _cfgStatusManager;
}

@end
