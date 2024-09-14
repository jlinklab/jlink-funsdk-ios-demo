//
//  JFAOVPIRDetectAffairManager.h
//   iCSee
//
//  Created by Megatron on 2024/4/29.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PirAlarmManager.h"

NS_ASSUME_NONNULL_BEGIN

///AOVPIR侦测事务管理器
@interface JFAOVPIRDetectAffairManager : NSObject

///设备序列号
@property (nonatomic,copy) NSString *devID;
///所有配置获取成功，通知UI刷新
@property (nonatomic,copy) void (^AllConfigRequestedCallBack)();
///获取配置失败回调
@property (nonatomic,copy) void (^ConfigRequestFailedCallBack)();
///PIR配置管理器
@property (nonatomic,strong) PirAlarmManager *pirAlarmManager;

///获取配置
- (void)requestCfgWithDeviceID:(NSString *)devID;

@end

NS_ASSUME_NONNULL_END
