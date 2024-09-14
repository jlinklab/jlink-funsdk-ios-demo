//
//  JFWakeUpManager.m
//   iCSee
//
//  Created by Megatron on 2023/12/26.
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import "JFWakeUpManager.h"
#import <FunSDK/FunSDK.h>

@implementation JFWakeUpManager

//MARK: 开始唤醒设备
- (void)requestWakeUpDevice:(NSString *)devID completed:(JFWakeUpCallBack)completion{
    self.wakeUpCallBack = completion;
    self.devID = devID;
    if (!devID) {
        [self sendWakeResult:-1];
        return;
    }
    
    //兼容普通设备 如果设备类型不是低功耗设备 就默认直接唤醒成功
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    DeviceObject *device = [[DeviceControl getInstance] GetDeviceObjectBySN:channel.deviceMac];
    
    if ([device getDeviceTypeLowPowerConsumption]) {
        FUN_DevWakeUp(self.msgHandle, CSTR(self.devID), 0);
    }else{
        [self sendWakeResult:1];
    }
}

- (void)sendWakeResult:(int)result{
    if (self.wakeUpCallBack) {
        self.wakeUpCallBack(result);
        self.wakeUpCallBack = nil;
    }
}

- (void)baseOnFunSDKResult:(MsgContent *)msg{
    switch (msg->id) {
        case EMSG_DEV_WAKE_UP:
        {
            [self sendWakeResult:msg->param1];
        }
            break;
        default:
            break;
    }
}

@end
