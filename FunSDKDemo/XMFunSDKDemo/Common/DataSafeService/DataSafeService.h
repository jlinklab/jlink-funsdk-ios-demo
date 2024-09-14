//
//  DataSafeService.h
//   iCSee
//
//  Created by Megatron on 2023/8/23.
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// @brief 数据安全服务
@interface DataSafeService : NSObject

/// 安全方式获取数组存储对象
+ (id)safeObjectAtIndex:(int)index fromArray:(NSArray *)array;
/// 强制数组校验转换 不是数组就转换成空数组
+ (id)forceSafeArray:(NSArray *)array;
/// 安全方式获取字典存储对象
+ (id)safeObjectForkey:(NSString *)key fromDictionary:(NSDictionary *)dic;
/// 强制字典校验转换 不是数组就转换成空字典
+ (id)forceSafeDictionary:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
