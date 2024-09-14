//
//  DetectCryDetectionManager.h
//  iCSee
//
//  Created by Megatron on 2023/09/25
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FunSDKBaseObject.h"

typedef void(^GetDetectCryDetectionCallBack)(int result);
typedef void(^SetDetectCryDetectionCallBack)(int result);

NS_ASSUME_NONNULL_BEGIN

/*
  哭声检测配置管理器
  */
@interface DetectCryDetectionManager : FunSDKBaseObject

@property (nonatomic,copy) GetDetectCryDetectionCallBack getDetectCryDetectionCallBack;
@property (nonatomic,copy) SetDetectCryDetectionCallBack setDetectCryDetectionCallBack;

/**
 * @brief 获取哭声检测配置
 * @param devID 设备ID
 * @param completion GetDetectCryDetectionCallBack
 * @return void
 */
- (void)requestDetectCryDetectionWithDevice:(NSString *)devID completed:(GetDetectCryDetectionCallBack)completion;

/**
 * @brief 保存哭声检测配置
 * @param completion SetDetectCryDetectionCallBack
 * @return void
 */
- (void)requestSaveDetectCryDetectionCompleted:(SetDetectCryDetectionCallBack)completion;

/*
  获取和设置【Enable】配置项
  */
- (BOOL)enable;
- (void)setEnable:(BOOL)enable;

/*
  获取和设置【Sensitivity】配置项
  */
- (int)sensitivity;
- (void)setSensitivity:(int)sensitivity;

/*
  获取和设置【TimeSection】配置项
  */
- (NSArray *)timeSection;
- (void)setTimeSection:(NSArray *)timeSection;

/*
 获取和设置【MessageEnable】配置项
 */
- (BOOL)messageEnable;
- (void)setMessageEnable:(BOOL)enable;

- (BOOL)isCustomPeriod;

@end

NS_ASSUME_NONNULL_END






