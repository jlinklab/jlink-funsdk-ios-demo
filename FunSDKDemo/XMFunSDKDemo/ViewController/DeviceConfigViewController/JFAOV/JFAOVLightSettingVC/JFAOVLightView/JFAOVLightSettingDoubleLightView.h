//
//  JFAOVLightSettingDoubleLightView.h
//   iCSee
//
//  Created by kevin on 2024/4/24.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//  AOV 双光灯 灯光设置view

#import <UIKit/UIKit.h>
#import "JFCameraDayLightModesManager.h"
#import "WhiteLightManager.h"
#import "XMFbExtraStateCtrlManager.h"
NS_ASSUME_NONNULL_BEGIN

@interface JFAOVLightSettingDoubleLightView : UIView

@property (nonatomic,weak) JFCameraDayLightModesManager  *cameraDayLightModesManager;
@property (nonatomic,weak) XMFbExtraStateCtrlManager *fbExtraStateCtrlManager;
//MARK: 白光灯配置管理器
@property (nonatomic,weak) WhiteLightManager *whiteLightManager;
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
