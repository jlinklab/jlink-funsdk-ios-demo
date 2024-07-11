//
//  LowPowerRecordConfigManager.m
//  FunSDKDemo
//
//  Created by plf on 2024/6/25.
//  Copyright © 2024 plf. All rights reserved.
//

#import "LowPowerRecordConfigManager.h"
#import "NSString+Utils.h"
#import <FunSDK/FunSDK.h>

@interface LowPowerRecordConfigManager ()

@property (nonatomic,strong) NSDictionary *dicConfig;

@end

@implementation LowPowerRecordConfigManager

//MARK: 获取低功耗录像配置
- (void)getLowPowerRecordConfig:(GetLowPowerRecordConfigResult)completion
{
    self.getLowPowerRecordConfigResult = completion;
    
    FUN_DevGetConfig_Json(self.msgHandle, self.devID.UTF8String, "NetWork.SetEnableVideo", 1024);
}
//MARK: 设置低功耗录像配置
- (void)setLowPowerRecordConfig:(BOOL)openState completed:(SetLowPowerRecordConfigResult)completion
{
    self.setLowPowerRecordConfigResult = completion;
    
    NSDictionary* jsonDic1 = @{@"Name":@"NetWork.SetEnableVideo",@"NetWork.SetEnableVideo":@{@"Enable":openState?@1:@0}};
    NSError *error;
    NSData *jsonData1 = [NSJSONSerialization dataWithJSONObject:jsonDic1 options:NSJSONWritingPrettyPrinted error:&error];
    NSString *pCfgBufString1 = [[NSString alloc] initWithData:jsonData1 encoding:NSUTF8StringEncoding];

    FUN_DevSetConfig_Json(self.msgHandle, self.devID.UTF8String, "NetWork.SetEnableVideo", [pCfgBufString1 UTF8String], int(strlen([pCfgBufString1 UTF8String]) + 1));
}

//MARK: SDKCallBack
- (void)baseOnFunSDKResult:(MsgContent *)msg{
    switch (msg->id) {
        case EMSG_DEV_GET_CONFIG_JSON:
        {
            if (msg->param1 >= 0) {
                NSData *jsonData = [NSData dataWithBytes:msg->pObject length:strlen(msg->pObject)];
                NSError *error;
                NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
                
                if (self.getLowPowerRecordConfigResult) {
                    self.getLowPowerRecordConfigResult(jsonDic);
                }
                
                self.dicConfig = [NSDictionary dictionaryWithDictionary:jsonDic];
            }
            else
            {
                [MessageUI ShowErrorInt:msg->param1];
            }
        }
            break;
        case EMSG_DEV_SET_CONFIG_JSON:
        {
            if (msg->param1 >= 0) {
                [SVProgressHUD showSuccessWithStatus:TS("Success") duration:1.5];
            }
            else
            {
                [MessageUI ShowErrorInt:msg->param1];
            }
        }
        default:
            break;
    }
}

@end
