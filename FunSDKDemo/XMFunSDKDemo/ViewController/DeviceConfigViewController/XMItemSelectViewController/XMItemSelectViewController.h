//
//  XMItemSelectViewController.h
//  XWorld
//
//  Created by DingLin on 17/1/9.
//  Copyright © 2017年 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "XMBaseViewController.h"

@interface XMItemSelectViewController : UIViewController

@property (nonatomic, copy) void (^itemChangedAction)(int);
@property (nonatomic, copy) void(^clickSaveAction)(int index);

@property (nonatomic,assign) BOOL ifNeedSleepTips;
@property (nonatomic) NSArray *arrItems;

@property(nonatomic,assign) int lastIndex;

@property (nonatomic,assign) BOOL filletMode;  // 是否显示圆角模式

//是否需要保存按钮 默认不需要
@property (nonatomic,assign) BOOL needSaveButton;
//选择后是否需要自动返回
@property (nonatomic,assign) BOOL needAutoBack;

- (void)backViewControllerAnimated:(BOOL)animated;
@property (nonatomic,assign) BOOL isAOVFPS;  // 是否是aov的帧率设置
///自定义模式FPS
@property (nonatomic,copy) NSString *customFPS;
//MARK: - 配置保存成功处理
- (void)saveSuccess;

@end
