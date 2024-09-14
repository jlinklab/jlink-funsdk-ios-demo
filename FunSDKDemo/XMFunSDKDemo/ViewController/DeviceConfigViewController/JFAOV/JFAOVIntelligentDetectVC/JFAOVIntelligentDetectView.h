//
//  JFAOVIntelligentDetectView.h
//   iCSee
//
//  Created by Megatron on 2024/4/29.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JFHumanDetectionManager.h"
#import "HumanRuleLimitManager.h"
#import "IntellAlertAlarmMannager.h"

@protocol JFAOVIntelligentDetectDelegate <NSObject>

@end

NS_ASSUME_NONNULL_BEGIN

@interface JFAOVIntelligentDetectView : UIView

///设备序列号
@property (nonatomic,copy) NSString *devID;
@property (nonatomic,weak) id<JFAOVIntelligentDetectDelegate>delegate;
///人形检测配置管理器
@property (nonatomic,weak) JFHumanDetectionManager *humanDetectionManager;
///人形检测规则配置管理器
@property (nonatomic,weak) HumanRuleLimitManager *humanRuleLimitManager;
///智能警戒管理器
@property (nonatomic,weak) IntellAlertAlarmMannager *intellAlertAlarmMannager;
///AOV多算法组合, 支持人车
@property (nonatomic, assign) BOOL iMultiAlgoCombinePed;
///是否是多镜头设备 -1:未知 0:否 1:是
@property (nonatomic,assign) int multiSensor;
///支持警戒区域的镜头数组 数组中的数字表示镜头1 镜头2
@property (nonatomic,strong) NSMutableArray *arraySensors;

///配置变化更新数据源
- (void)configUpdate;
///更新配置项是否需要显示或隐藏
- (void)updateConfigListVisiable:(BOOL)visiable cfgNames:(NSArray *)cfgNames;
///更新列表
- (void)updateTableList;

@end

NS_ASSUME_NONNULL_END
