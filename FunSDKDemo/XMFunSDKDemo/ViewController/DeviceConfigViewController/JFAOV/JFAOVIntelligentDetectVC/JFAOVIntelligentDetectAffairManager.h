//
//  JFAOVIntelligentDetectAffairManager.h
//   iCSee
//
//  Created by Megatron on 2024/4/29.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JFHumanDetectionManager.h"
#import "HumanRuleLimitManager.h"
#import "IntellAlertAlarmMannager.h"

NS_ASSUME_NONNULL_BEGIN

///AOV智能侦测事务管理器
@interface JFAOVIntelligentDetectAffairManager : NSObject

///设备序列号
@property (nonatomic,copy) NSString *devID;
///所有配置获取成功，通知UI刷新
@property (nonatomic,copy) void (^AllConfigRequestedCallBack)();
///获取配置失败回调
@property (nonatomic,copy) void (^ConfigRequestFailedCallBack)();
///人形检测配置管理器
@property (nonatomic,strong) JFHumanDetectionManager *humanDetectionManager;
///人形检测规则配置管理器
@property (nonatomic,strong) HumanRuleLimitManager *humanRuleLimitManager;
///智能警戒管理器
@property (nonatomic,strong) IntellAlertAlarmMannager *intellAlertAlarmMannager;
///是否是多镜头设备 -1:未知 0:否 1:是
@property (nonatomic,assign) int multiSensor;

///获取配置
- (void)requestCfgWithDeviceID:(NSString *)devID;

@end

NS_ASSUME_NONNULL_END
