//
//  CfgStatusManager.h
//  XWorld_General
//
//  Created by Tony Stark on 25/10/2019.
//  Copyright © 2019 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(int,XMCfgStatus) {
    XMCfgStatus_UnRequest,   //未请求
    XMCfgStatus_Success,     //请求成功
    XMCfgStatus_Failed,      //请求失败
    XMCfgStatus_NotSupport,  //不支持改功能
};

NS_ASSUME_NONNULL_BEGIN

/*
 设备配置状态管理者
 
 统一管理某个界面配置请求的状态
 
 一个界面可能会有很多不同的请求 为了快速请求信息 需要同时发送各种请求 当所有请求返回成功时 需要通知用户 当有请求返回失败时 也需要做对应的处理 请求状态的数据更新 最好独立在控制器外 减少耦合
 */
@interface CfgStatusManager : NSObject

//MARK: 添加配置
- (void)addCfgName:(NSString *)cfgName;
//MARK: 修改配置状态 未请求 请求中 请求成功 请求失败
- (void)changeCfgStatus:(XMCfgStatus)status name:(NSString *)cfgName;
//MARK: 检测所有配置是否请求完成
- (BOOL)checkAllCfgFinishedRequest;
//MARK: 重制所有请求状态
- (void)resetAllCfgStatus;

@end

NS_ASSUME_NONNULL_END
