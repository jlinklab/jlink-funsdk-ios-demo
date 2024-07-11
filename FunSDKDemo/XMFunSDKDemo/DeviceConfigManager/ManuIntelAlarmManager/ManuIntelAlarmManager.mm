//
//  ManuIntelAlarmManager.m
//   
//
//  Created by Tony Stark on 2021/7/28.
//  Copyright © 2021 xiongmaitech. All rights reserved.
//

#import "ManuIntelAlarmManager.h"
#import "NSString+Utils.h"
#import <FunSDK/FunSDK.h>

@implementation ManuIntelAlarmManager

//MARK: 开启手动警戒
- (void)startManuIntelAlarm:(NSString *)devID completed:(StartManuIntelAlarmResult)completion{
    self.devID = devID;
    self.startManuIntelAlarmResult = completion;
    
    NSDictionary *dic = @{@"Name":@"OPRemoteCtrl",@"SessionID":@"0x0000000001",@"OPRemoteCtrl":@{@"Type":@"ManuIntelAlarm",@"msg":@"0x00000001",@"p1":@"0x00000000",@"p2":@"0x00000000"}};
    NSString *str = [NSString convertToJSONData:dic];
    int size = [NSString getCharArraySize:str];
    char cfg[size];
    memcpy(cfg, [str cStringUsingEncoding:NSUTF8StringEncoding], 2*[str length]);
    
    FUN_DevCmdGeneral(self.msgHandle, [self.devID UTF8String], 4000, "OPRemoteCtrl", 4096, 15000,cfg, (int)strlen(cfg) + 1, -1, 101);
}

//MARK: 停止手动警戒
- (void)stopManuIntelAlarm:(NSString *)devID completed:(StopManuIntelAlarmResult)completion{
    self.devID = devID;
    self.stopManuIntelAlarmResult = completion;
    
    NSDictionary *dic = @{@"Name":@"OPRemoteCtrl",@"SessionID":@"0x0000000001",@"OPRemoteCtrl":@{@"Type":@"ManuIntelAlarm",@"msg":@"0x00000000",@"p1":@"0x00000000",@"p2":@"0x00000000"}};
    NSString *str = [NSString convertToJSONData:dic];
    int size = [NSString getCharArraySize:str];
    char cfg[size];
    memcpy(cfg, [str cStringUsingEncoding:NSUTF8StringEncoding], 2*[str length]);
    
    FUN_DevCmdGeneral(self.msgHandle, [self.devID UTF8String], 4000, "OPRemoteCtrl", 4096, 15000,cfg, (int)strlen(cfg) + 1, -1, 100);
}

//MARK: SDKCallBack
- (void)baseOnFunSDKResult:(MsgContent *)msg{
    switch (msg->id) {
        case EMSG_DEV_CMD_EN:
        {
            if (msg->seq == 100) {
                if (self.stopManuIntelAlarmResult) {
                    self.stopManuIntelAlarmResult(msg->param1);
                }
            }else if (msg->seq == 101){
                if (self.startManuIntelAlarmResult) {
                    self.startManuIntelAlarmResult(msg->param1);
                }
            }
        }
            break;
        default:
            break;
    }
}

@end
