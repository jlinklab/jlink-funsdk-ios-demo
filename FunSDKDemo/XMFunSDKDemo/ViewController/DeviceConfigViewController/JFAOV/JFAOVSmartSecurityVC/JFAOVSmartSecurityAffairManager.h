//
//  JFAOVSmartSecurityAffairManager.h
//   iCSee
//
//  Created by kevin on 2024/4/29.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OrderListItem.h"
#import "TitleSwitchCell.h"
#import "TitleComboBoxCell.h"
#import "AlarmSwitchCell.h"
#import "EmptyTableViewCell.h"
#import "FunSDKBaseObject.h"

@protocol JFAOVSmartSecurityAffairManagerDelegate <NSObject>

- (void)backAction;

@end

static NSString * _Nonnull const kTitleSwitchCell = @"TitleSwitchCell";
static NSString * _Nonnull const kTitleComboBoxCell = @"kTitleComboBoxCell";
static NSString * _Nonnull const kAlarmSwitchCellIdentifier = @"kAlarmSwitchCellIdentifier";
static NSString * _Nonnull const kEmptyTableViewCell = @"kEmptyTableViewCell";
NS_ASSUME_NONNULL_BEGIN

@interface JFAOVSmartSecurityAffairManager : FunSDKBaseObject
@property (nonatomic,weak) id<JFAOVSmartSecurityAffairManagerDelegate> delegate;
@property (nonatomic,copy) NSString *devID;
//关联的控制器
@property (nonatomic,weak) UIViewController *associatedVC;
//关联的功能列表
@property (nonatomic,weak) UITableView *associatedList;
//界面总的数据源
@property (nonatomic,strong) NSMutableArray *dataSource;
//tableview刷新数据源
@property (nonatomic,strong) NSMutableArray *dataSourceVisiable;

@property (nonatomic, assign) BOOL iSupportHumanPedDetection;//智能侦测
@property (nonatomic, assign) BOOL iSupportPirAlarm;//PIR侦测
@property (nonatomic, assign) BOOL iSupportIntellAlertAlarm;// 报警联动
///是否支持PIR灵敏度设置
@property (nonatomic,assign) BOOL ifSupportPIRSensitive;

@property (nonatomic, assign) BOOL iSupportSetVolume;// 报警联动--报警音量
@property (nonatomic, assign) BOOL supportAlarmVoiceTipInterval;//支持报警间隔
///AOV多算法组合, 支持人车
@property (nonatomic, assign) BOOL iMultiAlgoCombinePed;


- (void)viewWillAppearAction;
//MARK: 请求所有配置
- (void)requestAllConfigWithDeviceID:(NSString *)devID;
@end

NS_ASSUME_NONNULL_END
