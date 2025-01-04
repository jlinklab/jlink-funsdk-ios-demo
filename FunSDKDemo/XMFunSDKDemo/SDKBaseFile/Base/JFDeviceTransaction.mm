//
//  JFDeviceTransaction.m
//   iCSee
//
//  Created by Megatron on 2024/10/15.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import "JFDeviceTransaction.h"
#import "FunSDK/FunSDK.h"

@implementation JFDeviceTransaction

/**
 判断设备是否是用户强制校验token设备
 */
+ (BOOL)tokenDeviceForForceUsrIDCheckWithDeviceID:(NSString *)devID {
    // 目前该接口只给账号隔离功能使用 该功能无法开放 先改成都不是token设备 后续功能开放再改回来
    // 除了订单以外的强制校验 不传_user 让服务器自行判断是否需要校验 APP只保证命令中带了用户ID即可
    return NO;
    char szToken[80] = {0};
    FUN_DevGetLocalEncToken(devID.UTF8String, szToken);
    if (OCSTR(szToken).length > 0) {
        return YES;
    }
    
    return NO;
}

@end
