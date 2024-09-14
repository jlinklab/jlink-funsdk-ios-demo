//
//  JFAOVLightSettingVc.h
//   iCSee
//
//  Created by kevin on 2024/4/24.
//  Copyright © 2024 xiongmaitech. All rights reserved.
// aov 灯光设置界面

#import <UIKit/UIKit.h>
#import "JFAOVLightSettingBlackLightView.h"
#import "JFAOVLightSettingDoubleLightView.h"
#import "FunSDKBaseViewController.h"
NS_ASSUME_NONNULL_BEGIN

@interface JFAOVLightSettingVc : FunSDKBaseViewController
@property (nonatomic, assign) BOOL supportDoubleLightBoxCamera;//支持双光
@property (nonatomic, assign) BOOL supportSetBrightness;// 支持亮度调整
@property (nonatomic, assign) BOOL SoftLedThr;// 支持自动灯光模式下的灵敏度设置，取值范围固定为1~5
///是否支持状态灯
@property (nonatomic, assign) BOOL supportStatusLed;
///是否支持微光灯
@property (nonatomic, assign) BOOL supportMicroFillLight;
///是否是常电设备进来
@property (nonatomic, assign) BOOL isCommonDevice;

@property (nonatomic, strong) JFAOVLightSettingBlackLightView *blackLightView;
@property (nonatomic, strong) JFAOVLightSettingDoubleLightView *doubleLightView;

@end

NS_ASSUME_NONNULL_END
