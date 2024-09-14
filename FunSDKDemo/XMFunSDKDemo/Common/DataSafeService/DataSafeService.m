//
//  DataSafeService.m
//   iCSee
//
//  Created by Megatron on 2023/8/23.
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import "DataSafeService.h"

@implementation DataSafeService

/// 安全方式获取数组存储对象
+ (id)safeObjectAtIndex:(int)index fromArray:(NSArray *)array{
    id object = nil;
    if ([array isKindOfClass:[NSArray class]]){
        if (array.count > index){
            object = [array objectAtIndex:index];
        }
    }
    
    return object;
}

/// 强制数组校验转换 不是数组就转换成空数组
+ (id)forceSafeArray:(NSArray *)array{
    if ([array isKindOfClass:[NSArray class]]){
        return array;
    }
    
    return [NSMutableArray array];
}

/// 安全方式获取字典存储对象
+ (id)safeObjectForkey:(NSString *)key fromDictionary:(NSDictionary *)dic{
    id object = nil;
    // 检查字典是否为 NSDictionary 类型
    if ([dic isKindOfClass:[NSDictionary class]]) {
        // 检查键是否符合 NSCopying 协议并且非 nil
        if ([key conformsToProtocol:@protocol(NSCopying)] && key != nil) {
            object = [dic objectForKey:key];
        }
    }
    
    return object;
}

/// 强制字典校验转换 不是数组就转换成空字典
+ (id)forceSafeDictionary:(NSDictionary *)dic{
    if ([dic isKindOfClass:[NSDictionary class]]){
        return dic;
    }
    
    return [NSMutableDictionary dictionary];
}

@end
