//
//  JFAOVPIRDetectView.h
//   iCSee
//
//  Created by Megatron on 2024/4/29.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PirAlarmManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface JFAOVPIRDetectView : UIView

///设备序列号
@property (nonatomic,copy) NSString *devID;
///是否支持PIR灵敏度设置
@property (nonatomic,assign) BOOL ifSupportPIRSensitive;
///PIR配置管理器
@property (nonatomic,weak) PirAlarmManager *pirAlarmManager;

///配置变化更新数据源
- (void)configUpdate;
///更新配置项是否需要显示或隐藏
- (void)updateConfigListVisiable:(BOOL)visiable cfgNames:(NSArray *)cfgNames;
///更新列表
- (void)updateTableList;

@end

NS_ASSUME_NONNULL_END
