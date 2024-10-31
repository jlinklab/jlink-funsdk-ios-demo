//
//  JFAOVLightSettingVc.m
//   iCSee
//
//  Created by kevin on 2024/4/24.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import "JFAOVLightSettingVc.h"
#import <FunSDK/FunSDK.h>

#import "CameraParamExManager.h"
#import "JFWakeUpManager.h"

@interface JFAOVLightSettingVc ()

@property (nonatomic, strong) UIButton *btnNavBack;
@property (nonatomic,assign) UI_HANDLE msgHandle;
///唤醒配置管理器
@property (nonatomic,strong) JFWakeUpManager *wakeUpManager;
//MARK: 白光灯配置管理器
@property (nonatomic,strong) WhiteLightManager *whiteLightManager;
//MARK: 双光灯日夜模式列表
@property (nonatomic,strong) JFCameraDayLightModesManager *cameraDayLightModesManager;
//MARK: 白光灯 自动灯光  灵敏度 配置
@property (nonatomic,strong) CameraParamExManager *cameraParamExManager;
//MARK: 状态灯提示音配置管理器
@property (nonatomic,strong) XMFbExtraStateCtrlManager *fbExtraStateCtrlManager;

@end

@implementation JFAOVLightSettingVc
- (void)dealloc
{
    FUN_UnRegWnd(self.msgHandle);
    self.msgHandle = -1;
}
- (instancetype)init{
    self = [super init];
    if (self) {
        self.msgHandle = FUN_RegWnd((__bridge void*)self);
    }
    
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    self.devID = channel.deviceMac;
    
    [self buildUI];
    if (self.isCommonDevice) {
        [self getLightConfig];
    } else {
        [self wakeUpGetConfig];
    }
}
- (void)buildUI {

    if (self.supportDoubleLightBoxCamera) {
        [self.view addSubview:self.doubleLightView];
        [self.doubleLightView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
            
        }];
    } else {
        [self.view addSubview:self.blackLightView];
        self.blackLightView.supportSetBrightness = self.supportSetBrightness;
        self.blackLightView.SoftLedThr = self.SoftLedThr;

        [self.blackLightView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
            
        }];
    }
}
#pragma mark - **************** request ****************
//MARK: wake up to get config
- (void)wakeUpGetConfig{
    //低功耗先唤醒再操作
    [SVProgressHUD showWithStatus:TS("Waking_up")];
    FUN_DevWakeUp(self.msgHandle, CSTR(self.devID), 0);
        
}
- (void)wakeUpSetConfig{
    if (self.isCommonDevice) {
        [self setLightConfig];
    } else {
        [SVProgressHUD show];
        FUN_DevWakeUp(self.msgHandle, CSTR(self.devID), 1);
    }
}

- (void)getLightConfig {
    [SVProgressHUD show];
    WeakSelf(weakSelf);
    if (self.supportStatusLed) {
        [self.fbExtraStateCtrlManager requestGetXMFbExtraStateCtrlCfg:weakSelf.devID completed:^(int result) {
             if (result == -11406 || result == -400009) {
                 weakSelf.supportStatusLed = NO;
                 if (weakSelf.supportDoubleLightBoxCamera) {
                     [weakSelf getCameraDayLightModesManagerRequest];
                 } else {
                     [weakSelf getWhiteLightManagerRequest];
                 }
             }else{
                  if (result >= 0) {
                      if (weakSelf.supportDoubleLightBoxCamera) {
                          weakSelf.doubleLightView.fbExtraStateCtrlManager = weakSelf.fbExtraStateCtrlManager;
                          weakSelf.doubleLightView.needShowStatusLed = weakSelf.supportStatusLed;
                          [weakSelf getCameraDayLightModesManagerRequest];
                      } else {
                          weakSelf.blackLightView.fbExtraStateCtrlManager = weakSelf.fbExtraStateCtrlManager;
                          weakSelf.blackLightView.needShowStatusLed = weakSelf.supportStatusLed;
                          [weakSelf getWhiteLightManagerRequest];
                      }
                  }else{
                       [MessageUI ShowErrorInt:result];
                       [weakSelf.navigationController popViewControllerAnimated:YES];
                  }
             }
        }];
    }else{
        if (self.supportDoubleLightBoxCamera) {
            [self getCameraDayLightModesManagerRequest];
        } else {
            [self getWhiteLightManagerRequest];
        }
    }
}

- (void)setLightConfig {
    
    [self saveWhiteLightManagerRequest];
     
}

- (void)safeLedConfig{
    [SVProgressHUD show];
    WeakSelf(weakSelf);
    [self.wakeUpManager requestWakeUpDevice:self.devID completed:^(int result) {
        if (result >= 0) {
            [weakSelf.fbExtraStateCtrlManager requestSetXMFbExtraStateCtrlCfgCompleted:^(int result1) {
                 if (result1 >= 0) {
                      [SVProgressHUD showSuccessWithStatus:TS("Save_Success")];
                 }else{
                      [weakSelf.fbExtraStateCtrlManager requestGetXMFbExtraStateCtrlCfg:weakSelf.devID completed:^(int result2) {
                           [MessageUI ShowErrorInt:result1];
                          if (weakSelf.supportDoubleLightBoxCamera) {
                              [weakSelf.doubleLightView updateList];
                          }else{
                              [weakSelf.blackLightView updateList];
                          }
                      }];
                 }
            }];
        }else{
            [MessageUI ShowErrorInt:result];
        }
    }];
}

- (void)saveMicroLight{
    [SVProgressHUD show];
    WeakSelf(weakSelf);
    [self.wakeUpManager requestWakeUpDevice:self.devID completed:^(int result) {
        if (result >= 0) {
            [weakSelf.cameraParamExManager requestSaveCameraParamExCompleted:^(int result1) {
                 if (result1 >= 0) {
                      [SVProgressHUD showSuccessWithStatus:TS("Save_Success")];
                 }else{
                     [weakSelf.cameraParamExManager requestCameraParamEx:weakSelf.devID channel:-1 completed:^(int result2) {
                        [MessageUI ShowErrorInt:result1];
                        if (weakSelf.supportDoubleLightBoxCamera) {
                            [weakSelf.doubleLightView updateList];
                        }else{
                            [weakSelf.blackLightView updateList];
                        }
                     }];
                 }
            }];
        }else{
            [MessageUI ShowErrorInt:result];
        }
    }];
}

- (void)getWhiteLightManagerRequest {
    
    WeakSelf(weakSelf);
    
    [self.whiteLightManager getWhiteLight:self.devID channel:-1 completed:^(WhiteLightManagerRequestType requestType, int result, int channel) {
        if (result >= 0) {
            if (weakSelf.supportDoubleLightBoxCamera) {
                if (weakSelf.supportMicroFillLight) {
                    weakSelf.doubleLightView.whiteLightManager = weakSelf.whiteLightManager;
                    [weakSelf getCameraParamExRequest];
                }else{
                    [SVProgressHUD dismiss];
                    weakSelf.doubleLightView.whiteLightManager = weakSelf.whiteLightManager;
                    [weakSelf.doubleLightView configData];
                }
            } else {
                weakSelf.blackLightView.whiteLightManager = weakSelf.whiteLightManager;
                [weakSelf getCameraParamExRequest];
            }
        } else {
            [MessageUI ShowErrorInt:result];
        }
        
    }];
}

- (void)saveWhiteLightManagerRequest {
    WeakSelf(weakSelf);
    [SVProgressHUD show];
    [self.whiteLightManager setWhiteLight:^(WhiteLightManagerRequestType requestType, int result, int channel) {
        if (result < 0) {
            [MessageUI ShowErrorInt:result];
        }else{
            if (weakSelf.supportDoubleLightBoxCamera) {
                [SVProgressHUD showSuccessWithStatus:TS("Save_Success")];
                weakSelf.doubleLightView.whiteLightManager = weakSelf.whiteLightManager;
                [weakSelf.doubleLightView configData];
            } else {
                weakSelf.blackLightView.whiteLightManager = weakSelf.whiteLightManager;
                [weakSelf setCameraParamExRequest];
            }
        }
    }];
}

- (void)getCameraParamExRequest {
    WeakSelf(weakSelf);
     
    [self.cameraParamExManager requestCameraParamEx:self.devID channel:-1 completed:^(int result) {
        if (result >= 0) {
            [SVProgressHUD dismiss];
            if (weakSelf.supportDoubleLightBoxCamera) {
                weakSelf.doubleLightView.supportMicroFillLight = weakSelf.supportMicroFillLight;
                if (weakSelf.supportMicroFillLight) {
                    weakSelf.doubleLightView.microFillLightOpen = [weakSelf.cameraParamExManager microFillLight] == 0 ? NO : YES;
                }
                [weakSelf.doubleLightView configData];
            }else{
                weakSelf.blackLightView.supportMicroFillLight = weakSelf.supportMicroFillLight;
                if (weakSelf.supportMicroFillLight) {
                    weakSelf.blackLightView.microFillLightOpen = [weakSelf.cameraParamExManager microFillLight] == 0 ? NO : YES;
                }
                weakSelf.blackLightView.cameraParamExManager = weakSelf.cameraParamExManager;
                [weakSelf.blackLightView configData];
            }
        } else {
            [MessageUI ShowErrorInt:result];
        }
    }];
}
- (void)setCameraParamExRequest {
    WeakSelf(weakSelf);
    
    [self.cameraParamExManager requestSaveCameraParamExCompleted:^(int result) {
        if (result >= 0) {
            [SVProgressHUD showSuccessWithStatus:TS("Save_Success")];
            if (weakSelf.supportDoubleLightBoxCamera) {
                if (weakSelf.supportMicroFillLight) {
                    weakSelf.doubleLightView.microFillLightOpen = [weakSelf.cameraParamExManager microFillLight] == 0 ? NO : YES;
                }
                [weakSelf.doubleLightView configData];
            }else{
                weakSelf.blackLightView.cameraParamExManager = weakSelf.cameraParamExManager;
                if (weakSelf.supportMicroFillLight) {
                    weakSelf.blackLightView.microFillLightOpen = [weakSelf.cameraParamExManager microFillLight] == 0 ? NO : YES;
                }
                [weakSelf.blackLightView configData];
            }
        } else {
            [MessageUI ShowErrorInt:result];
        }
    }];
    
}
//
- (void)getCameraDayLightModesManagerRequest {
    WeakSelf(weakSelf);
     
    [self.cameraDayLightModesManager requestCameraDayLightModesWithDevice:self.devID channel:-1 completed:^(int result) {
        if (result >= 0) {
            weakSelf.doubleLightView.cameraDayLightModesManager = weakSelf.cameraDayLightModesManager;
            [weakSelf getWhiteLightManagerRequest];
        } else {
            [MessageUI ShowErrorInt:result];
        }
    }];
}
 

//MARK: - OnFunSDKResult
- (void)baseOnFunSDKResult:(MsgContent *)msg{
    switch (msg->id) {
//MARK: 唤醒返回
        case EMSG_DEV_WAKE_UP:
        {
            if (msg->param1 >= 0) {
                if (msg->seq == 0) {
                    [self getLightConfig];
                    
                }else{
                    [self setLightConfig];
                }
            }else{
                if (msg->seq == 0) {
                    [self getConfigFailed:msg->param1];
                } else {
                    [MessageUI ShowErrorInt:msg->param1];
                }
            }
        }
            break;
        
        default:
            break;
    }
}
- (void)getConfigFailed:(int)result{
    [MessageUI ShowErrorInt:result];
    [self.navigationController popViewControllerAnimated:YES];
}


//MARK: - EventAction
//MARK: 点击返回
- (void)btnNavBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
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

- (JFAOVLightSettingBlackLightView *)blackLightView{
    if (!_blackLightView) {
        WeakSelf(weakSelf);
        _blackLightView = [[JFAOVLightSettingBlackLightView alloc] init];
        [_blackLightView setSaveBlock:^{
            [weakSelf wakeUpSetConfig];
        }];
        _blackLightView.AOVLightViewSaveLed = ^{
            [weakSelf safeLedConfig];
        };
        _blackLightView.AOVMicroLightSaveAction = ^(BOOL open) {
            [weakSelf.cameraParamExManager setMicroFillLight:open ? 1 : 0];
            [weakSelf saveMicroLight];
        };
    }
    
    return _blackLightView;
}

- (JFAOVLightSettingDoubleLightView *)doubleLightView{
    if (!_doubleLightView) {
        WeakSelf(weakSelf);

        _doubleLightView = [[JFAOVLightSettingDoubleLightView alloc] init];
        [_doubleLightView setSaveBlock:^{
            [weakSelf wakeUpSetConfig];
        }];
        _doubleLightView.AOVLightViewSaveLed = ^{
            [weakSelf safeLedConfig];
        };
        _doubleLightView.AOVMicroLightSaveAction = ^(BOOL open) {
            [weakSelf.cameraParamExManager setMicroFillLight:open ? 1 : 0];
            [weakSelf saveMicroLight];
        };
         
    }
    
    return _doubleLightView;
}


- (WhiteLightManager *)whiteLightManager{
    if (!_whiteLightManager) {
        _whiteLightManager = [[WhiteLightManager alloc] init];
    }
    
    return _whiteLightManager;
}
- (JFCameraDayLightModesManager *)cameraDayLightModesManager{
    if (!_cameraDayLightModesManager) {
        _cameraDayLightModesManager = [[JFCameraDayLightModesManager alloc] init];
    }
    
    return _cameraDayLightModesManager;
}
- (CameraParamExManager *)cameraParamExManager{
    if (!_cameraParamExManager) {
        _cameraParamExManager = [[CameraParamExManager alloc] init];
    }
    
    return _cameraParamExManager;
}

- (JFWakeUpManager *)wakeUpManager{
    if (!_wakeUpManager) {
        _wakeUpManager = [[JFWakeUpManager alloc] init];
    }
    
    return _wakeUpManager;
}

- (XMFbExtraStateCtrlManager *)fbExtraStateCtrlManager{
    if (!_fbExtraStateCtrlManager) {
        _fbExtraStateCtrlManager = [[XMFbExtraStateCtrlManager alloc] init];
    }
    
    return _fbExtraStateCtrlManager;
}

@end
