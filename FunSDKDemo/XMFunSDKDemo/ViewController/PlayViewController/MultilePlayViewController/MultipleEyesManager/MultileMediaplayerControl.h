//
//  MultileMediaplayerControl.h
//  FunSDKDemo
//
//  Created by zhang on 2024/10/24.
//  Copyright © 2024 zhang. All rights reserved.
//

#import "MediaplayerControl.h"
#import "MultipleEyesManager.h"

//多目播放窗口模式
typedef NS_ENUM(NSInteger,JFMultipleEyesPlayViewWindowMode) {
    //假3目的竖屏模式 一路码流上下分屏的设备
    /// 竖屏 原始模式 上下两个窗口
    JFMultipleEyesPlayViewWindowMode_Fake_Portrait_Original = 2000,
    ///竖屏 从上往下上面两个小窗口底部一个大的
    JFMultipleEyesPlayViewWindowMode_Fake_Portrait_Two_Small_Up_List = 2002,
};


NS_ASSUME_NONNULL_BEGIN

@interface MultileMediaplayerControl : MediaplayerControl

@property (nonatomic, assign) FUN_HANDLE mainPlayer;                 //播放器句柄
@property (nonatomic, assign) int windowNumber; //多目效果画面数量

@property (nonatomic, assign) JFMultipleEyesPlayViewWindowMode playWindowMode;
@property (nonatomic, assign) JF_Multiple_Eyes_Fake_Display_Mode  display_Mode;

//MARK: 开始播放
- (void)startPlay;

//MARK: 修改播放窗口的显示范围
- (void)updateWindowDisplayMode:(JF_Multiple_Eyes_Fake_Display_Mode)mode playWindowMode:(JFMultipleEyesPlayViewWindowMode)windowMode;
@end

NS_ASSUME_NONNULL_END
