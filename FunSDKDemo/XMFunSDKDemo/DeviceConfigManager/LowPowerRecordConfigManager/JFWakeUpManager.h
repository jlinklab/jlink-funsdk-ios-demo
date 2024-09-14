//
//  JFWakeUpManager.h
//   iCSee
//
//  Created by Megatron on 2023/12/26.
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FunSDKBaseObject.h"

NS_ASSUME_NONNULL_BEGIN

//result >= 0表示唤醒成功
typedef void(^JFWakeUpCallBack)(int result);

/*
 低功耗设备唤醒配置管理器
 兼容普通设备 如果设备类型不是低功耗设备 就默认直接唤醒成功
 */
@interface JFWakeUpManager : FunSDKBaseObject

@property (nonatomic, copy, nullable) JFWakeUpCallBack wakeUpCallBack;

//MARK: 开始唤醒设备
- (void)requestWakeUpDevice:(NSString *)devID completed:(JFWakeUpCallBack)completion;

@end

NS_ASSUME_NONNULL_END
