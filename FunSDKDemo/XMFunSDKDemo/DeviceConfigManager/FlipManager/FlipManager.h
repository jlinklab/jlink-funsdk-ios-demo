//
//  FlipManager.h
//  FunSDKDemo
//
//  Created by wujiangbo on 2020/8/17.
//  Copyright © 2020 wujiangbo. All rights reserved.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*
 Camera.ParamEx 配置，demo示例如下：
 门锁翻转配置
 宽动态配置 WDR
 
 Camera.ParamEx配置 json格式如下：
 {
     AeMeansure = 0; //测光模式 0平均测光 1中样测光
     AutomaticAdjustment = 3; 自动调节档次 1-4
     BroadTrends =     {
         AutoGain = 0;   //宽动态开关
         Gain = 50; //增益值
     };
     CorridorMode = 0; //1:走廊模式 0:普通模式
     DayNightSwitch =     {   //日夜模式
         KeepDayPeriod = "0 07:00:00-18:00:00";
         SwitchMode = 0;  0：根据光敏检测自动切换 1：强制为白天 2：强制为晚上 3：定时切换
     };
     Dis = 0; //子防抖设置
     ExposureTime = 0x00000100; //实际生效的曝光时间
     Ldc = 0; //镜头畸变校正
     LowLuxMode = 1; //微光模式
     MicroFillLight = 0;
     NightEnhance = 0;
     PreventOverExpo = 0;
     SoftLedThr = 3;
     SoftPhotosensitivecontrol = 0;
     Style = type1;  //图像风格
 }
 */



@protocol FlipManagerDelegate <NSObject>
//获取WDR配置代理回调
- (void)getWDRConfigResult:(NSInteger)result;
//保存WWDR配置代理回调
- (void)setWDRConfigResult:(NSInteger)result;

@end

@interface FlipManager : NSObject
@property (nonatomic,copy) NSString *devID;

@property (nonatomic, assign) id <FlipManagerDelegate> delegate;

//MARK:获取翻转配置
-(void)getFlipInfo;
//MARK:设置翻转配置
-(void)setFlip;

//获取和保存宽动态
- (void)getWDRConfig;
- (void)setWDRConfig:(BOOL)type;

//读取宽动态
- (BOOL)readWDR;

@end

NS_ASSUME_NONNULL_END
