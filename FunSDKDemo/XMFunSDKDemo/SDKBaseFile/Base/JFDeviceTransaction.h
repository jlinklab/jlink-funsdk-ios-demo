//
//  JFDeviceTransaction.h
//   iCSee
//
//  Created by Megatron on 2024/10/15.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 @brief 设备事务
 */
@interface JFDeviceTransaction : NSObject

/**
 判断设备是否是用户强制校验token设备
 */
+ (BOOL)tokenDeviceForForceUsrIDCheckWithDeviceID:(NSString *)devID;

@end

NS_ASSUME_NONNULL_END
