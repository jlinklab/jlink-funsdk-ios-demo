//
//  CameraLinkHomeView.h
//   iCSee
//
//  Created by Megatron on 2023/4/15.
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CameraLinkHomeViewDelegate <NSObject>

- (void)changeLinkSwitchState:(BOOL)open;
- (void)goPTZLocateVC;

@end
NS_ASSUME_NONNULL_BEGIN

@interface CameraLinkHomeView : UIView

@property (nonatomic,weak) id <CameraLinkHomeViewDelegate>delegate;
@property (nonatomic,strong) UITableView *tbFunction;                   // 配置功能列表
@property (nonatomic,strong) UIView *tbContainer;
@property (nonatomic,strong) NSMutableArray *cfgOrderList;              // 配置顺序列表 修改顺序或者分组 增加项目 都要先在这里确定配置位置

@property (nonatomic, assign) BOOL cameraLinkEnable;                    // 相机联动是否打开

@end

NS_ASSUME_NONNULL_END
