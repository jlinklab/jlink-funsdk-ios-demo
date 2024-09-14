//
//  WhiteLightManager.h
//  XWorld_General
//
//  Created by Megatron on 2019/7/1.
//  Copyright © 2019 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FunSDKBaseObject.h"

typedef NS_ENUM(int,WhiteLightManagerRequestType) {
    WhiteLightManagerRequestTypeGet,
    WhiteLightManagerRequestTypeSet,
};

typedef void(^WhiteLightManagerRequestBlock)(WhiteLightManagerRequestType requestType,int result,int channel);

@protocol WhiteLightManagerDelegate <NSObject>

// 获取回调
- (void)getWhiteLightConfigResult:(int)result;
// 设置回调
- (void)setWhiteLightConfigResult:(int)result;

@end
/*
 白光灯配置管理器
 
 获取设置工作模式 开(KeepOpen) 关(Close) 自动(Auto) 智能(Intelligent) 定时(Timing) 等模式
 获取设置定时开灯时间关灯时间
 获取设置移动触发开灯灵敏度
 获取设置移动触发持续亮灯时间
 
 白光灯配置 配置名称： “Camera.WhiteLight”
 获取到的json格式：{
 "MoveTrigLight":    {
 "Duration":    60,
 "Level":    5
 },
 "WorkMode":    "Intelligent",
 "WorkPeriod":    {
 "EHour":    6,
 "EMinute":    0,
 "Enable":    1,
 "SHour":    18,
 "SMinute":    0
 }
 }
 对应解释：MoveTrigLight：移动物体自动亮灯
 Duration：持续亮灯时间 超级看看中设置范围(5s,10s,30s,60s,90s,120s)
 Level: 灵敏度 1->低 3->中 5->高
 WorkMode: 工作模式  Auto：自动模式，isp里根据环境亮度自动开关
 Timming：定时模式
 KeepOpen：一直开启
 Intelligent：智能模式 (双光灯专有)
 Atmosphere: 气氛灯 (音乐灯专有)
 Glint: 随音乐闪动 (音乐灯专有)
 Close：关闭
 WorkPeriod：工作时间段 在timming模式下有效
 
 */
@interface WhiteLightManager : FunSDKBaseObject

@property (nonatomic,weak) id<WhiteLightManagerDelegate> delegate;

@property (nonatomic,copy) WhiteLightManagerRequestBlock requestAction;

//MARK: 请求配置
- (void)getWhiteLight:(NSString *)devID channel:(int)channel completed:(WhiteLightManagerRequestBlock)completion;
//MARK: 保存配置
- (void)setWhiteLight:(WhiteLightManagerRequestBlock)action;

//MARK: 设置工作模式
- (void)setWorkMode:(NSString *)wordMode;
//MARK: 设置移动触发开灯灵敏度
- (void)setMoveTrigLightLevel:(int)level;
//MARK: 设置移动触发持续亮灯时间
- (void)setMoveTrigLightDuration:(int)duration;
//MARK: 设置定时开灯时间 (HH:MM)
- (void)setLightOpenTime:(NSString *)time;
//MARK: 设置定时关灯时间 (HH:MM)
- (void)setLightCloseTime:(NSString *)time;
//MARK: 获取定时灯开关
- (BOOL)getLightOpenEnable;
//MARK: 设置定时灯开关
- (void)setLightOpenEnable:(BOOL)isON;
//MARK: 设置灯光亮度
- (void)setBrightness:(int)value;

//MARK: 获取工作模式
- (NSString *)getWordMode;
//MARK: 获取移动触发开灯灵敏度
- (int)getMoveTrigLightLevel;
//MARK: 获取移动触发持续亮灯时间
- (int)getMoveTrigLightDuration;
//MARK: 获取定时开灯时间
- (NSString *)getLightOpenTime;
//MARK: 获取定时关灯时间
- (NSString *)getLightCloseTime;
//MARK: 获取灯光亮度
- (int)getBrightness;
@end

