//
//  DataSafeService.h
//  FunSDKDemo
//
//  Created by feimy on 2024/7/23.
//  Copyright © 2024 feimy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DataSafeService : NSArray

+ (id)safeObjectAtIndex:(int)index fromArray:(NSArray *)array;

@end

NS_ASSUME_NONNULL_END
