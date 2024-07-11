//
//  UartPTZControlCmdManager.h
//   
//
//  Created by Megatron on 2022/8/29.
//  Copyright © 2022 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FunSDKBaseObject.h"

typedef NS_ENUM(NSInteger,GetConfigState) {
    GetConfigState_None,        // 未获取
    GetConfigState_Success,     // 获取成功
    GetConfigState_Unsupport,   // 配置不支持
    GetConfigState_Failed,      // 获取失败
};

typedef void(^GetUartPTZControlCmdCallBack)(int result,NSString *__nullable devID,int channel);
typedef void(^SetUartPTZControlCmdCallBack)(int result);

NS_ASSUME_NONNULL_BEGIN
/*
 Uart.PTZControlCmd 配置管理者
 配置名："Uart.PTZControlCmd"
 配置内容：
 [{
 "FlipOperation":false, //上下翻转
 "MirrorOperation":false, //左右镜像,消费类默认值为true，传统类默认值为false
 "ModifyCfg":false //配置是否修改
 }]
  
 注：
 修改配置：@"ModifyCfg" 这个值就要设置成true
 这个配置需要在PC端、APP和NVR上可修改；修改配置msgId:1040,获取配置msgId:1042
 */
@interface UartPTZControlCmdManager : FunSDKBaseObject

@property (nonatomic,copy,nullable) GetUartPTZControlCmdCallBack safeGetUartPTZControlCmdCallBack;
@property (nonatomic,copy,nullable) GetUartPTZControlCmdCallBack getUartPTZControlCmdCallBack;
@property (nonatomic,copy,nullable) SetUartPTZControlCmdCallBack setUartPTZControlCmdCallBack;

/**是否是消费类设备：如果是消费类默认左右镜像为ture*/
@property (nonatomic,assign) BOOL consumerProduct;
/**当前获取配置的状态*/
@property (nonatomic,assign) GetConfigState getConfigState;
/**是否走透传*/
@property (nonatomic,assign) BOOL byPass;

//MARK: 安全获取多个调用时 只有第一个会被执行
- (void)requestSafeGetUartPTZControlCmdConfig:(NSString *)devID channel:(int)channel completed:(GetUartPTZControlCmdCallBack)completion;
//MARK: 获取配置
- (void)requestGetUartPTZControlCmdConfig:(NSString *)devID channel:(int)channel completed:(GetUartPTZControlCmdCallBack)completion;
//MARK: 保存配置
- (void)requestSetUartPTZControlCmdConfigCompleted:(SetUartPTZControlCmdCallBack)completion;

//MARK: 判断是否有缓存
- (BOOL)cached;
//MARK: Get Set
//MARK: 是否上下反转
/**是否上下反转*/
- (BOOL)flipOperation;
/**是否上下反转*/
- (void)setFlipOperation:(BOOL)flip;
//MARK: 是否左右反转
/**是否左右反转*/
- (BOOL)mirrorOperation;
/**是否左右反转*/
- (void)setMirrorOperation:(BOOL)mirror;
//MARK: 是否修改
- (BOOL)modifyCfg;

@end

NS_ASSUME_NONNULL_END
