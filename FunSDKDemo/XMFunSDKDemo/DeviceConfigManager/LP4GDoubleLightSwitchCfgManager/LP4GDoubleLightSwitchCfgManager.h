//
//  LP4GDoubleLightSwitchCfgManager.h
//  XWorld_General
//
//  Created by Tony Stark on 2020/7/15.
//  Copyright © 2020 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMStateDefine.h"
#import "FunSDKBaseObject.h"

/*
 白光红外切换配置管理者
 ConfigName:"Dev.LP4GLedParameter";
 */
@interface LP4GDoubleLightSwitchCfgManager : FunSDKBaseObject

@property (nonatomic,copy) XMRESCALLBACK getResult;

@property (nonatomic,copy) XMRESCALLBACK setResult;

- (void)getLP4GDoubleLight:(NSString *)devID channel:(int)channel completed:(XMRESCALLBACK)completion;

- (void)setLP4GDoubleLightCompleted:(XMRESCALLBACK)completion;

//MARK: 获取灯类型：1.红外 2.白光
- (int)getLightType;
//MARK: 设置灯类型
- (void)setLightType:(int)type;
//MARK: 获取灯亮度 Brightness是亮度，默认亮度80，取值范围 20-100
- (int)getLightBrightness;
//MARK: 设置灯亮度
- (void)setLightBrightness:(int)brightness;

@end

