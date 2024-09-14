//
//  XMFbExtraStateCtrlManager.m
//   
//
//  Created by Tony Stark on 2022/5/21.
//  Copyright © 2022 xiongmaitech. All rights reserved.
//

#import "XMFbExtraStateCtrlManager.h"
#import <FunSDK/FunSDK.h>
#import "DeviceConfig.h"
#import "FbExtraStateCtrl.h"

@interface XMFbExtraStateCtrlManager () <DeviceConfigDelegate>
{
    FbExtraStateCtrl jFbExtraStateCtrl;
}
@end
@implementation XMFbExtraStateCtrlManager

//MARK: SDK请求
- (void)requestGetXMFbExtraStateCtrlCfg:(NSString *)devID completed:(GetXMFbExtraStateCtrlCallBack)completion{
    self.devID = devID;
    self.getXMFbExtraStateCtrlCallBack = completion;

    DeviceConfig* devCfg1 = [[DeviceConfig alloc] initWithJObject:&jFbExtraStateCtrl];
    devCfg1.devId = self.devID;
    devCfg1.channel = -1;
    devCfg1.isGet = YES;
    devCfg1.delegate = self;
    [self requestGetConfig:devCfg1];
}

- (void)requestSetXMFbExtraStateCtrlCfgCompleted:(SetXMFbExtraStateCtrlCallBack)completion{
    self.setXMFbExtraStateCtrlCallBack = completion;
    
    jFbExtraStateCtrl.ison = self.iStatueLed;
    jFbExtraStateCtrl.PlayVoiceTip = self.iVoiceTip;
    DeviceConfig* devCfg1 = [[DeviceConfig alloc] initWithJObject:&jFbExtraStateCtrl];
    devCfg1.devId = self.devID;
    devCfg1.channel = -1;
    devCfg1.isSet = YES;
    devCfg1.delegate = self;
    [self requestSetConfig:devCfg1];
}


//MARK: SDK回调
- (void)getConfig:(DeviceConfig *)config result:(int)result{
    if (result >= 0) {
        self.iStatueLed = jFbExtraStateCtrl.ison.Value();
        self.iVoiceTip = jFbExtraStateCtrl.PlayVoiceTip.Value();
    }
    
    if (self.getXMFbExtraStateCtrlCallBack) {
        self.getXMFbExtraStateCtrlCallBack(result);
    }
}

- (void)setConfig:(DeviceConfig *)config result:(int)result{
    if (self.setXMFbExtraStateCtrlCallBack) {
        self.setXMFbExtraStateCtrlCallBack(result);
    }
}

@end
