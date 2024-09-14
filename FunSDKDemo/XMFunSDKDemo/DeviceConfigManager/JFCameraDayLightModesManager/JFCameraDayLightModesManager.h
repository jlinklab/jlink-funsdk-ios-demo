//
//  JFCameraDayLightModesManager.h
//   iCSee
//
//  Created by kevin on 2023/11/2.
//  Copyright © 2023 xiongmaitech. All rights reserved.
//
/*
 黑光灯获取支持的日夜模式列表
 */
#import <Foundation/Foundation.h>
#import "FunSDKBaseObject.h"

typedef void(^GetCameraDayLightModesCallBack)(int result);
typedef void(^SetCameraDayLightModesCallBack)(int result);
NS_ASSUME_NONNULL_BEGIN

@interface JFCameraDayLightModesManager : FunSDKBaseObject
@property (nonatomic,copy) GetCameraDayLightModesCallBack getCameraDayLightModesCallBack;
@property (nonatomic,copy) SetCameraDayLightModesCallBack setCameraDayLightModesCallBack;

/**
 * @brief 获取支持的日夜模式列表
 * @param devID 设备ID
 * @param completion GetCameraDayLightModesCallBack
 * @return void
 */
- (void)requestCameraDayLightModesWithDevice:(NSString *)devID channel:(int)channel completed:(GetCameraDayLightModesCallBack)completion;

- (NSArray *)getLightModes;



@end

NS_ASSUME_NONNULL_END
