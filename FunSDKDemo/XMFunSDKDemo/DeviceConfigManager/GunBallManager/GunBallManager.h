//
//  GunBallManager.h
//   iCSee
//
//  Created by Megatron on 2023/4/12.
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^GetGunBallLocateCallBack)(int result);
typedef void(^SetGunBallLocateCallBack)(int result);

NS_ASSUME_NONNULL_BEGIN

/*
 枪球配置管理者
 */
@interface GunBallManager : NSObject

@property (nonatomic,copy) GetGunBallLocateCallBack getGunBallLocateCallBack;
@property (nonatomic,copy) SetGunBallLocateCallBack setGunBallLocateCallBack;

/**
 * @brief 获取枪球联动配置
 * @param devID 设备ID
 * @param completion GetGunBallLocateCallBack
 * @return void
 */
- (void)requestGunBallLocate:(NSString *)devID completed:(GetGunBallLocateCallBack)completion;

/**
 联动开关状态
 */
- (BOOL)gunBallLocateEnable;
- (void)setGunBallLocateEnable:(BOOL)enable;

/**
 * @brief 保存枪球联动配置
 * @param completion SetGunBallLocateCallBack
 * @return void
 */
- (void)requestSaveGunBallLocateCompleted:(SetGunBallLocateCallBack)completion;

@end

NS_ASSUME_NONNULL_END
