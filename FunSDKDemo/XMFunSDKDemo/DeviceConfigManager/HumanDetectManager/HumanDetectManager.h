//
//  HumanDetectManager.h
//  XWorld_General
//
//  Created by Megatron on 2019/6/18.
//  Copyright © 2019 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CYFunSDKObject.h"
#import "FunSDKBaseObject.h"

typedef void (^HumanDetectManagerCallBack)(NSDictionary *info,int result);

typedef void(^GetHumanDetectCallBack)(int result);
typedef void(^SaveHumanDetectCallBack)(int result);

/*
 人形检测管理
 人形检测开关
 */
@interface HumanDetectManager : FunSDKBaseObject

@property (nonatomic,copy) HumanDetectManagerCallBack callBack;

@property (nonatomic,copy) GetHumanDetectCallBack getHumanDetectCallBack;
@property (nonatomic,copy) SaveHumanDetectCallBack saveHumanDetectCallBack;

//是否支持多通道设备
@property (nonatomic,assign) BOOL supportMultiChannel;

- (void)listenOperationCallBack:(HumanDetectManagerCallBack)callBack;

//MARK: 获取配置
- (void)request;
//MARK: 获取配置
- (void)request:(GetHumanDetectCallBack)callBack;

//MARK: 保存配置
- (void)saveConfig:(SaveHumanDetectCallBack)callBack;

//MARK: 获取人形检测是否开启
- (BOOL)getHumanDetectEnable;
- (void)setHumanDetectEnable:(BOOL)enable;
//MARK: 显示踪迹
- (BOOL)getShowTraceEnabled;
- (void)setShowTraceEnable:(BOOL)enable;

@end

