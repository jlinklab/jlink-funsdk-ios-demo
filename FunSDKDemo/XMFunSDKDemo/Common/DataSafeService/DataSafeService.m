//
//  DataSafeService.m
//  FunSDKDemo
//
//  Created by feimy on 2024/7/23.
//  Copyright © 2024 feimy. All rights reserved.
//

#import "DataSafeService.h"

@implementation DataSafeService

+ (id)safeObjectAtIndex:(int)index fromArray:(NSArray *)array{
    id object = nil;
    if ([array isKindOfClass:[NSArray class]]){
        if (array.count > index){
            object = [array objectAtIndex:index];
        }
    }
    
    return object;
}

@end
