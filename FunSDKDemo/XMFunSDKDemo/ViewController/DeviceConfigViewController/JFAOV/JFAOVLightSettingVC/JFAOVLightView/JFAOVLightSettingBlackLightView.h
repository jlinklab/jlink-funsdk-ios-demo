//
//  JFAOVLightSettingBlackLightView.h
//   iCSee
//
//  Created by kevin on 2024/4/24.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//  AOV黑光灯 灯光设置view

#import <UIKit/UIKit.h>
#import "WhiteLightManager.h"
#import "CameraParamExManager.h"
#import "XMFbExtraStateCtrlManager.h"
NS_ASSUME_NONNULL_BEGIN

@interface JFAOVLightSettingBlackLightView : UIView

@property (nonatomic,weak) XMFbExtraStateCtrlManager *fbExtraStateCtrlManager;
//MARK: 白光灯配置管理器
@property (nonatomic,weak) WhiteLightManager *whiteLightManager;
//MARK: 白光灯 自动灯光  灵敏度 配置
@property (nonatomic,weak) CameraParamExManager *cameraParamExManager;
@property (nonatomic,assign) BOOL supportSetBrightness;// 支持亮度调整
@property (nonatomic,assign) BOOL SoftLedThr; // 支持自动灯光模式下的灵敏度设置，取值范围固定为1~5
/// 定时开始的时间 HH:mm:ss
@property (nonatomic,copy) NSString *startTime;
/// 定时结束的时间 HH:mm:ss
@property (nonatomic,copy) NSString *endTime;
@property (nonatomic,copy) void (^saveBlock)();
///是否需要显示设备指示灯
@property (nonatomic,assign) BOOL needShowStatusLed;
@property (nonatomic,copy) void (^AOVLightViewSaveLed)();
///是否支持微光灯
@property (nonatomic,assign) BOOL supportMicroFillLight;
@property (nonatomic,copy) void (^AOVMicroLightSaveAction)(BOOL open);
///微光灯的开关状态
@property (nonatomic,assign) BOOL microFillLightOpen;

- (void)configData;
- (void)updateList;

@end

NS_ASSUME_NONNULL_END
