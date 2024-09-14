//
//  JFAOVIntelligentDetectView.m
//   iCSee
//
//  Created by Megatron on 2024/4/29.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import "JFAOVIntelligentDetectView.h"
#import "OrderListItem.h"
#import "JFLeftTitleRightSwitchCell.h"
#import "JFLeftTitleRightTitleArrowCell.h"
#import "TitleComboBoxCell.h"

#import "IntelViewController.h"
#import "DrawControl.h"
#import "JFNewAlarmPeriodVc.h"
#import "JFAOVIntelligentDetectCell.h"
#import "JFLeftSelectRightArrowCell.h"

static NSString *const kJFLeftTitleRightSwitchCell = @"kJFLeftTitleRightSwitchCell";
static NSString *const kJFLeftTitleRightTitleArrowCell = @"kJFLeftTitleRightTitleArrowCell";
static NSString *const kTitleComboBoxCell = @"kTitleComboBoxCell";
static NSString *const kJFAOVIntelligentDetectCell = @"kJFAOVIntelligentDetectCell";
static NSString *const kJFLeftSelectRightArrowCell = @"kJFLeftSelectRightArrowCell";

@interface JFAOVIntelligentDetectView () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tbList;
// 配置顺序列表 修改顺序或者分组 增加项目 都要先在这里确定配置位置
@property (nonatomic,strong) NSMutableArray *cfgOrderList;
// 配置列表数据源
@property (nonatomic,strong) NSMutableArray *dataSource;

@end
@implementation JFAOVIntelligentDetectView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.multiSensor = -1;
        //默认值
        [self addSubview:self.tbList];
        CGFloat safeBottom = [PhoneInfoManager safeAreaLength:SafeArea_Bottom];
        [self.tbList mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).mas_offset(cTableViewFilletLFBorder);
            make.right.equalTo(self).mas_offset(-cTableViewFilletLFBorder);
            make.top.equalTo(self);
            make.bottom.equalTo(self).mas_offset(-cTableViewFilletLFBorder);
            make.bottom.equalTo(self).mas_offset(-safeBottom);
        }];
    }
    
    return self;
}

///配置变化更新数据源
- (void)configUpdate{
    
    if (self.iMultiAlgoCombinePed && [self.humanRuleLimitManager.dwLowObjectType isEqualToString:@"0x3"] ) {
        _tbList.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _tbList.sectionFooterHeight = 10;
        // 人形 车形 新样式
        if ([self.humanDetectionManager getObjectType] == 0 || ![self.humanDetectionManager getHumanDetectEnable]) {
            //人形和车型都为关闭
            NSMutableArray *arrayShow = [NSMutableArray arrayWithCapacity:0];
            NSMutableArray *arrayHide = [NSMutableArray arrayWithCapacity:0];
            [arrayShow addObject:TS("TR_Setting_Intelligent_DetectionPersonCar")];
            [arrayHide addObject:TS("TR_Setting_Intelligent_Detection")];
            [arrayHide addObject:TS("TR_Setting_Display_Smart_Trace")];
            [arrayHide addObject:TS("type_alert_line")];
            [arrayHide addObject:TS("type_alert_area")];
            [arrayHide addObject:@"itemSensor1"];
            [arrayHide addObject:@"itemSensor2"];
            [arrayHide addObject:TS("TR_Rule_Setting")];
            [arrayHide addObject:TS("alarm_time")];
            [self updateConfigListVisiable:YES cfgNames:arrayShow];
            [self updateConfigListVisiable:NO cfgNames:arrayHide];
            [self updateTableList];
        }else {
            //人形和车型都为开启 或者其中一个开启
            NSMutableArray *arrayHide = [NSMutableArray arrayWithCapacity:0];
            NSMutableArray *arrayShow = [NSMutableArray arrayWithCapacity:0];
            [arrayShow addObject:TS("TR_Setting_Intelligent_DetectionPersonCar")];
            [arrayHide addObject:TS("TR_Setting_Intelligent_Detection")];
            
            //是否支持显示智能轨迹
            if (self.humanRuleLimitManager.supportShowTrack) {
                [arrayShow addObject:TS("TR_Setting_Display_Smart_Trace")];
            }else {
                [arrayHide addObject:TS("TR_Setting_Display_Smart_Trace")];
            }
            //默认支持智能规则设置 如果是多镜头就不显示 勾选状态就是智能规则
            if (self.multiSensor == 1) {
                [arrayHide addObject:TS("TR_Rule_Setting")];
            }else{
                [arrayShow addObject:TS("TR_Rule_Setting")];
            }
            //是否支持警戒线 支持且开启智能规则才显示警戒线
            if (self.humanRuleLimitManager.supportLine && [self.humanDetectionManager getHumanDetectRuleEnableWithPedRuleIndex:0]) {
                [arrayShow addObject:TS("type_alert_line")];
            }else{
                [arrayHide addObject:TS("type_alert_line")];
            }
            //是否支持警戒区域 支持且开启智能规则才显示警区域
            if (self.humanRuleLimitManager.supportArea && [self.humanDetectionManager getHumanDetectRuleEnableWithPedRuleIndex:0] && self.multiSensor != 1) {
                [arrayShow addObject:TS("type_alert_area")];
                //判断是否需要显示多镜头的
                if (self.multiSensor == 1) {
                    for (int i = 0; i < self.arraySensors.count; i++) {
                        int sensorNum = [[self.arraySensors objectAtIndex:i] intValue] + 1;
                        [arrayShow addObject:[NSString stringWithFormat:@"itemSensor%i",sensorNum]];
                    }
                }else{
                    [arrayHide addObject:@"itemSensor1"];
                    [arrayHide addObject:@"itemSensor2"];
                }
            }else{
                //判断是否需要显示多镜头的 多镜头的需要一直显示
                if (self.multiSensor == 1) {
                    [arrayShow addObject:TS("type_alert_area")];
                    for (int i = 0; i < self.arraySensors.count; i++) {
                        int sensorNum = [[self.arraySensors objectAtIndex:i] intValue] + 1;
                        [arrayShow addObject:[NSString stringWithFormat:@"itemSensor%i",sensorNum]];
                    }
                }else{
                    [arrayHide addObject:TS("type_alert_area")];
                    [arrayHide addObject:@"itemSensor1"];
                    [arrayHide addObject:@"itemSensor2"];
                }
            }
            //有智能警戒配置就算支持
            if (self.intellAlertAlarmMannager) {
                [arrayShow addObject:TS("alarm_time")];
            }else{
                [arrayHide addObject:TS("alarm_time")];
            }
            [self updateConfigListVisiable:YES cfgNames:arrayShow];
            [self updateConfigListVisiable:NO cfgNames:arrayHide];
            [self updateTableList];
        }
        
         
    } else {
        
        // 老样式
        if ([self.humanDetectionManager getHumanDetectEnable]) {
            NSMutableArray *arrayHide = [NSMutableArray arrayWithCapacity:0];
            NSMutableArray *arrayShow = [NSMutableArray arrayWithCapacity:0];
            
            [arrayShow addObject:TS("TR_Setting_Intelligent_Detection")];
            [arrayHide addObject:TS("TR_Setting_Intelligent_DetectionPersonCar")];
            
            //是否支持显示智能轨迹
            if (self.humanRuleLimitManager.supportShowTrack) {
                [arrayShow addObject:TS("TR_Setting_Display_Smart_Trace")];
            }else {
                [arrayHide addObject:TS("TR_Setting_Display_Smart_Trace")];
            }
            //默认支持智能规则设置 如果是多镜头就不显示 勾选状态就是智能规则
            if (self.multiSensor == 1) {
                [arrayHide addObject:TS("TR_Rule_Setting")];
            }else{
                [arrayShow addObject:TS("TR_Rule_Setting")];
            }
            //是否支持警戒线 支持且开启智能规则才显示警戒线
            if (self.humanRuleLimitManager.supportLine && [self.humanDetectionManager getHumanDetectRuleEnableWithPedRuleIndex:0]) {
                [arrayShow addObject:TS("type_alert_line")];
            }else{
                [arrayHide addObject:TS("type_alert_line")];
            }
            //是否支持警戒区域 支持且开启智能规则才显示警区域
            if (self.humanRuleLimitManager.supportArea && [self.humanDetectionManager getHumanDetectRuleEnableWithPedRuleIndex:0] && self.multiSensor != 1) {
                [arrayShow addObject:TS("type_alert_area")];
                //判断是否需要显示多镜头的
                if (self.multiSensor == 1) {
                    for (int i = 0; i < self.arraySensors.count; i++) {
                        int sensorNum = [[self.arraySensors objectAtIndex:i] intValue] + 1;
                        [arrayShow addObject:[NSString stringWithFormat:@"itemSensor%i",sensorNum]];
                    }
                }else{
                    [arrayHide addObject:@"itemSensor1"];
                    [arrayHide addObject:@"itemSensor2"];
                }
            }else{
                //判断是否需要显示多镜头的 多镜头的需要一直显示
                if (self.multiSensor == 1) {
                    [arrayShow addObject:TS("type_alert_area")];
                    for (int i = 0; i < self.arraySensors.count; i++) {
                        int sensorNum = [[self.arraySensors objectAtIndex:i] intValue] + 1;
                        [arrayShow addObject:[NSString stringWithFormat:@"itemSensor%i",sensorNum]];
                    }
                }else{
                    [arrayHide addObject:TS("type_alert_area")];
                    [arrayHide addObject:@"itemSensor1"];
                    [arrayHide addObject:@"itemSensor2"];
                }
            }
            //有智能警戒配置就算支持
            if (self.intellAlertAlarmMannager) {
                [arrayShow addObject:TS("alarm_time")];
            }else{
                [arrayHide addObject:TS("alarm_time")];
            }
            [self updateConfigListVisiable:YES cfgNames:arrayShow];
            [self updateConfigListVisiable:NO cfgNames:arrayHide];
            [self updateTableList];
        }else{
            NSMutableArray *arrayShow = [NSMutableArray arrayWithCapacity:0];
            NSMutableArray *arrayHide = [NSMutableArray arrayWithCapacity:0];
            [arrayShow addObject:TS("TR_Setting_Intelligent_Detection")];
            [arrayHide addObject:TS("TR_Setting_Intelligent_DetectionPersonCar")];
            [arrayHide addObject:TS("TR_Setting_Display_Smart_Trace")];
            [arrayHide addObject:TS("type_alert_line")];
            [arrayHide addObject:TS("type_alert_area")];
            [arrayHide addObject:@"itemSensor1"];
            [arrayHide addObject:@"itemSensor2"];
            [arrayHide addObject:TS("TR_Rule_Setting")];
            [arrayHide addObject:TS("alarm_time")];
            [self updateConfigListVisiable:YES cfgNames:arrayShow];
            [self updateConfigListVisiable:NO cfgNames:arrayHide];
            [self updateTableList];
        }
    }
}

///更新配置项是否需要显示或隐藏
- (void)updateConfigListVisiable:(BOOL)visiable cfgNames:(NSArray *)cfgNames{
    NSMutableArray *dataSource = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i < self.cfgOrderList.count; i++) {
        NSArray *section = [self.cfgOrderList objectAtIndex:i];
        NSMutableArray *sectionNew = [NSMutableArray arrayWithCapacity:0];
        for (int x = 0; x < section.count; x++) {
            OrderListItem *item = [section objectAtIndex:x];
            if ([cfgNames containsObject:item.titleName]) {
                item.hidden = !visiable;
            }
            if (!item.hidden) {
                [sectionNew addObject:item];
            }
        }
        [dataSource addObject:sectionNew];
    }
    self.dataSource = [dataSource mutableCopy];
}

///更新列表
- (void)updateTableList{
    [self.tbList reloadData];
}

/// 保存人形检测配置
- (void)saveHumanDetectAction {
    WeakSelf(weakSelf);
    [self.humanDetectionManager requestSaveConfigCompleted:^(int result) {
        if (result >= 0) {
            [SVProgressHUD showSuccessWithStatus:TS("Save_Success")];
            [weakSelf configUpdate];
        }else{
            [MessageUI ShowErrorInt:result];
        }
    }];
}

/// 计算cell需要的高度
- (CGFloat)cellHeightWithTitle:(NSString *)title titleFont:(UIFont *)titleFont subTitle:(NSString *)subTitle subTitleFont:(UIFont *)subTitleFont maxWidht:(CGFloat)maxWdith tbOffset:(CGFloat)tbOffset{
    CGFloat titleHeight = 0,subTitleHeight = 0;
    if (title.length > 0) {
        titleHeight = [UIServiceManager getTextHeightFromContent:title maxWidth:maxWdith font:titleFont];
    }
    if (subTitle.length > 0) {
        subTitleHeight = [UIServiceManager getTextHeightFromContent:subTitle maxWidth:maxWdith font:subTitleFont];
    }
    
    return titleHeight + subTitleHeight + 2 * tbOffset;
}

//MARK: - Delegate
//MARK: - UITableViewDelegate/DataSource
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.iMultiAlgoCombinePed && [self.humanRuleLimitManager.dwLowObjectType isEqualToString:@"0x3"] ) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 48)];
        view.backgroundColor = [UIColor clearColor];
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(15, 15, 200, 33);
        label.backgroundColor = [UIColor clearColor];
        [view addSubview:label];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];
        //    style.firstLineHeadIndent = 20.0f;
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc]initWithString:@"" attributes:@{NSForegroundColorAttributeName : NormalFontColor, NSParagraphStyleAttributeName : style, NSFontAttributeName : [UIFont fontWithName:@"Helvetica-Bold" size:10], NSStrokeWidthAttributeName:@-3, NSStrokeColorAttributeName:NormalFontColor}];
        if (section == 0) {
            NSAttributedString *string = [[NSAttributedString alloc]initWithString:TS("TR_DetectionObject") attributes:@{NSForegroundColorAttributeName : UIColorFromHex(0x777777), NSFontAttributeName : [UIFont systemFontOfSize:13]}];
            [attributedText appendAttributedString:string];
            label.attributedText = attributedText;
            
        }   else {
            return nil;
        }
        return view;
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.iMultiAlgoCombinePed && [self.humanRuleLimitManager.dwLowObjectType isEqualToString:@"0x3"] ) {
        if (section == 0) {
            return 48;
        }
        return 0;
    } else {
        return 0;
    }
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *arraySection = [self.dataSource objectAtIndex:section];
    
    return arraySection.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    OrderListItem *item = [[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSString *title = item.titleName;
    NSString *subTitle = item.subTitle;
    
    WeakSelf(weakSelf);
    if ([title isEqualToString:TS("TR_Setting_Intelligent_Detection")]) {//智能侦测
        JFLeftTitleRightSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:kJFLeftTitleRightSwitchCell];
        cell.style = JFLeftTitleRightSwitchCellStyle_SubTitle_Title;
        cell.lbTitle.text = title;
        cell.lbSubTitle.text = subTitle;
        cell.rightSwitch.on = [self.humanDetectionManager getHumanDetectEnable];
        cell.RightSwitchValueChanged = ^(BOOL open) {
            [SVProgressHUD show];
            [weakSelf.humanDetectionManager setHumanDetectEnable:open];
            [weakSelf saveHumanDetectAction];
        };
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }else if ([title isEqualToString:TS("TR_Setting_Intelligent_DetectionPersonCar")]) {//人形车形
        JFAOVIntelligentDetectCell *cell = [tableView dequeueReusableCellWithIdentifier:kJFAOVIntelligentDetectCell];
//    不选择任何算法: 0
//    人形: 1<< 0
//    车形: 1<<1
//    人形+ 车形:  1<<0 | 1<< 1
        if ([self.humanDetectionManager getObjectType] == 0) {
            cell.rightSwitch.on = NO;
            cell.leftSwitch.on = NO;
        } else if ([self.humanDetectionManager getObjectType] == (1<<0)) {
            cell.rightSwitch.on = NO;
            cell.leftSwitch.on = YES;
        } else if ([self.humanDetectionManager getObjectType] == (1<<1)) {
            cell.rightSwitch.on = YES;
            cell.leftSwitch.on = NO;
        } else if ([self.humanDetectionManager getObjectType] == (1<<0 | 1<<1)) {
            cell.rightSwitch.on = YES;
            cell.leftSwitch.on = YES;
        }
        __weak JFAOVIntelligentDetectCell *weakCell = cell;
        cell.LeftSwitchValueChanged = ^(BOOL open) {
            [SVProgressHUD show];
            if (open) {
                [weakSelf.humanDetectionManager setHumanDetectEnable:YES];
                if (weakCell.rightSwitch.on) {
                    [weakSelf.humanDetectionManager setObjectTypeValue:(1<<0 | 1<<1)];
                } else {
                    [weakSelf.humanDetectionManager setObjectTypeValue:(1<<0)];
                }
            } else {
                if (weakCell.rightSwitch.on) {
                    [weakSelf.humanDetectionManager setHumanDetectEnable:YES];

                    [weakSelf.humanDetectionManager setObjectTypeValue:(1<<1)];
                } else {
                    [weakSelf.humanDetectionManager setHumanDetectEnable:NO];

                    [weakSelf.humanDetectionManager setObjectTypeValue:0];
                }
            }
            
            [weakSelf saveHumanDetectAction];
        };
        cell.RightSwitchValueChanged = ^(BOOL open) {
            [SVProgressHUD show];
            if (open) {
                [weakSelf.humanDetectionManager setHumanDetectEnable:YES];

                if (weakCell.leftSwitch.on) {
                    [weakSelf.humanDetectionManager setObjectTypeValue:(1<<0 | 1<<1)];
                } else {
                    [weakSelf.humanDetectionManager setObjectTypeValue:(1<<1)];
                }
            } else {
                if (weakCell.leftSwitch.on) {
                    [weakSelf.humanDetectionManager setHumanDetectEnable:YES];

                    [weakSelf.humanDetectionManager setObjectTypeValue:(1<<0)];
                } else {
                    [weakSelf.humanDetectionManager setHumanDetectEnable:NO];

                    [weakSelf.humanDetectionManager setObjectTypeValue:0];
                }
            }
            
            [weakSelf saveHumanDetectAction];
        };
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }else if ([title isEqualToString:TS("TR_Setting_Display_Smart_Trace")]) {//显示智能轨迹
        JFLeftTitleRightSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:kJFLeftTitleRightSwitchCell];
        cell.style = JFLeftTitleRightSwitchCellStyle_Title;
        cell.lbTitle.text = title;
        cell.rightSwitch.on = [self.humanDetectionManager getShowTrackEnable];
        cell.RightSwitchValueChanged = ^(BOOL open) {
            [SVProgressHUD show];
            [weakSelf.humanDetectionManager setShowTrackEnable:open];
            [weakSelf saveHumanDetectAction];
        };
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }else if ([title isEqualToString:TS("TR_Rule_Setting")]) {//智能规则设置
        JFLeftTitleRightSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:kJFLeftTitleRightSwitchCell];
        cell.style = JFLeftTitleRightSwitchCellStyle_Title;
        cell.lbTitle.text = title;
        cell.rightSwitch.on = [self.humanDetectionManager getHumanDetectRuleEnableWithPedRuleIndex:0];
        cell.RightSwitchValueChanged = ^(BOOL open) {
            [SVProgressHUD show];
            [weakSelf.humanDetectionManager setHumanDetectRuleEnable:open pedRuleIndex:0];
            [weakSelf saveHumanDetectAction];
        };
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }else if ([title isEqualToString:TS("type_alert_line")]) {//警戒线
        TitleComboBoxCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleComboBoxCell];
        cell.titleLeftBorder = -5;
        [cell enterFilletMode];
        cell.titleLabel.text = title;
        cell.accessoryImageView.hidden = NO;
        if ([self.humanDetectionManager getHumanDetectRuleTypeWithPedRuleIndex:0] == 0) {
            cell.accessoryImageView.image = [UIImage imageNamed:@"new_icon_select"];
            [cell.accessoryImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(-10);
                make.centerY.mas_equalTo(cell.contentView.mas_centerY);
                make.size.mas_equalTo(CGSizeMake(30, 30));
            }];
        } else {
            cell.accessoryImageView.image = nil;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }else if ([title isEqualToString:TS("type_alert_area")]) {//警戒区域
        TitleComboBoxCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleComboBoxCell];
        cell.titleLeftBorder = -5;
        [cell enterFilletMode];
        cell.titleLabel.text = title;
        cell.accessoryImageView.hidden = NO;
        if ([self.humanDetectionManager getHumanDetectRuleTypeWithPedRuleIndex:0] == 1) {
            cell.accessoryImageView.image = [UIImage imageNamed:@"new_icon_select"];
            [cell.accessoryImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(-10);
                make.centerY.mas_equalTo(cell.contentView.mas_centerY);
                make.size.mas_equalTo(CGSizeMake(30, 30));
            }];
        } else {
            cell.accessoryImageView.image = nil;
        }
        if (self.multiSensor == 1) {
            cell.accessoryImageView.image = nil;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }else if ([title isEqualToString:@"itemSensor1"]) {//镜头1
        JFLeftSelectRightArrowCell *cell = [tableView dequeueReusableCellWithIdentifier:kJFLeftSelectRightArrowCell];
        //通过镜头获取index
        int pedRuleIndex = [self.humanRuleLimitManager pedRuleArrayIndexWithSensorIndex:0 areaIndex:0];
        cell.btnSelected.selected = [self.humanDetectionManager getHumanDetectRuleEnableWithPedRuleIndex:pedRuleIndex];
        cell.lbTitle.text = [NSString stringWithFormat:@"%@1",TS("TR_Setting_Lens")];
        cell.underLine.hidden = NO;
        cell.SelectStateChanged = ^(BOOL selected) {
            [SVProgressHUD show];
            [weakSelf.humanDetectionManager setHumanDetectRuleEnable:selected pedRuleIndex:pedRuleIndex];
            [weakSelf saveHumanDetectAction];
        };
        
        return cell;
    }else if ([title isEqualToString:@"itemSensor2"]) {//镜头2
        JFLeftSelectRightArrowCell *cell = [tableView dequeueReusableCellWithIdentifier:kJFLeftSelectRightArrowCell];
        //通过镜头获取index
        int pedRuleIndex = [self.humanRuleLimitManager pedRuleArrayIndexWithSensorIndex:1 areaIndex:0];
        cell.btnSelected.selected = [self.humanDetectionManager getHumanDetectRuleEnableWithPedRuleIndex:pedRuleIndex];
        cell.lbTitle.text = [NSString stringWithFormat:@"%@2",TS("TR_Setting_Lens")];
        cell.underLine.hidden = YES;

        cell.SelectStateChanged = ^(BOOL selected) {
            [SVProgressHUD show];
            [weakSelf.humanDetectionManager setHumanDetectRuleEnable:selected pedRuleIndex:pedRuleIndex];
            [weakSelf saveHumanDetectAction];
        };
        
        return cell;
    }else if ([title isEqualToString:TS("alarm_time")]) {//报警时间段
        JFLeftTitleRightTitleArrowCell *cell = [tableView dequeueReusableCellWithIdentifier:kJFLeftTitleRightTitleArrowCell];
        cell.lbTitle.text = title;
        int timePeriod = [self.intellAlertAlarmMannager getAlarmTimePeriod];
        if (timePeriod == 0){
            cell.lbRight.text = TS("time_day");
        }else if (timePeriod == 1){
            cell.lbRight.text = TS("time_diy");
        }else{
            cell.lbRight.text = @"";
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    OrderListItem *item = [[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSString *title = item.titleName;
    NSString *subTitle = item.subTitle;
    
    if ([title isEqualToString:TS("TR_Setting_Intelligent_Detection")]) {//智能侦测
        CGFloat height = [self cellHeightWithTitle:title titleFont:JFFont(cTableViewFilletTitleFont) subTitle:subTitle subTitleFont:JFFont(cTableViewFilletSubTitleFont) maxWidht:SCREEN_WIDTH - 15 * 2 - 5 - 20 - 62 tbOffset:cTableViewFilletContentLRBorder];
        
        return height < 50 ? 50 : height;
    } else if ([title isEqualToString:TS("TR_Setting_Intelligent_DetectionPersonCar")]) {
        return 120;
    }
    
    return 50;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    OrderListItem *item = [[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSString *title = item.titleName;
    
    if ([title isEqualToString:TS("type_alert_line")]) {//警戒线
        IntelViewController *indelVC = [[IntelViewController alloc] init];
        indelVC.humanDetection = YES;
        indelVC.drawType = (DrawType)0;
        indelVC.navTitle = TS("alert_line");
        indelVC.directArray = [self.humanRuleLimitManager.lineDirectArray mutableCopy];
        indelVC.alarmDirection = self.humanDetectionManager.alarmDirection;
        indelVC.areaPointNum = -1;
        indelVC.devID = self.devID;
        indelVC.humanDetectionDic = self.humanDetectionManager.dicCfg;
        indelVC.channelNum = 0;
        
        [[VCManager getCurrentVC].navigationController pushViewController:indelVC animated:YES];
    }else if ([title isEqualToString:TS("type_alert_area")]) {//警戒区域
        if (self.multiSensor == 1) {
            return;
        }
        IntelViewController *indelVC = [[IntelViewController alloc] init];
        indelVC.humanDetection = YES;
        indelVC.drawType = (DrawType)1;
        indelVC.navTitle = TS("alert_area");
        indelVC.directArray = [self.humanRuleLimitManager.areaDirectArray mutableCopy];
        indelVC.areaShapeArray = [self.humanRuleLimitManager.areaLineArray mutableCopy];
        indelVC.alarmDirection = -1;
        indelVC.areaPointNum = self.humanDetectionManager.areaPointNum;
        indelVC.devID = self.devID;
        indelVC.humanDetectionDic = self.humanDetectionManager.dicCfg;
        indelVC.channelNum = 0;
//        WeakSelf(weakSelf);
//        indelVC.AreaPointNumSaveSuccessAction = ^(int areaPointNum) {
//            weakSelf.humanDetectionManager.areaPointNum = areaPointNum;
//        };
        
        [[VCManager getCurrentVC].navigationController pushViewController:indelVC animated:YES];
    }else if ([title isEqualToString:@"itemSensor1"]) {//镜头1
        //通过镜头获取index
        int pedRuleIndex = [self.humanRuleLimitManager pedRuleArrayIndexWithSensorIndex:0 areaIndex:0];
        IntelViewController *indelVC = [[IntelViewController alloc] init];
        indelVC.humanDetection = YES;
//        indelVC.ifMultiSensor = self.multiSensor == 1 ? YES : NO;
//        indelVC.sensorIndex = 0;
//        indelVC.pedRuleIndex = pedRuleIndex;
        indelVC.drawType = (DrawType)1;
        indelVC.navTitle = [NSString stringWithFormat:@"%@1",TS("TR_Setting_Lens")];
        indelVC.directArray = [self.humanRuleLimitManager.areaDirectArray mutableCopy];
        indelVC.areaShapeArray = [self.humanRuleLimitManager.areaLineArray mutableCopy];
        indelVC.alarmDirection = -1;
        indelVC.areaPointNum = [self.humanDetectionManager areaPointNumWithPedRuleIndex:pedRuleIndex];
        indelVC.devID = self.devID;
        indelVC.humanDetectionDic = self.humanDetectionManager.dicCfg;
        indelVC.channelNum = 0;
//        WeakSelf(weakSelf);
//        indelVC.AreaPointNumSaveSuccessAction = ^(int areaPointNum) {
//            [weakSelf.humanDetectionManager setAreaPointNum:areaPointNum pedRuleIndex:pedRuleIndex];
//        };
        [[VCManager getCurrentVC].navigationController pushViewController:indelVC animated:YES];
    }else if ([title isEqualToString:@"itemSensor2"]) {//镜头2
        //通过镜头获取index
        int pedRuleIndex = [self.humanRuleLimitManager pedRuleArrayIndexWithSensorIndex:1 areaIndex:0];
        IntelViewController *indelVC = [[IntelViewController alloc] init];
        indelVC.humanDetection = YES;
//        indelVC.ifMultiSensor = self.multiSensor == 1 ? YES : NO;
//        indelVC.sensorIndex = 1;
//        indelVC.pedRuleIndex = pedRuleIndex;
        indelVC.drawType = (DrawType)1;
        indelVC.navTitle = [NSString stringWithFormat:@"%@2",TS("TR_Setting_Lens")];
        indelVC.directArray = [self.humanRuleLimitManager.areaDirectArray mutableCopy];
        indelVC.areaShapeArray = [self.humanRuleLimitManager.areaLineArray mutableCopy];
        indelVC.alarmDirection = -1;
        indelVC.areaPointNum = [self.humanDetectionManager areaPointNumWithPedRuleIndex:pedRuleIndex];
        indelVC.devID = self.devID;
        indelVC.humanDetectionDic = self.humanDetectionManager.dicCfg;
        indelVC.channelNum = 0;
//        WeakSelf(weakSelf);
//        indelVC.AreaPointNumSaveSuccessAction = ^(int areaPointNum) {
//            [weakSelf.humanDetectionManager setAreaPointNum:areaPointNum pedRuleIndex:pedRuleIndex];
//        };
        [[VCManager getCurrentVC].navigationController pushViewController:indelVC animated:YES];
    }else if ([title isEqualToString:TS("alarm_time")]) {//报警时间段
        JFNewAlarmPeriodVc* alarmPeriodVC = [[JFNewAlarmPeriodVc alloc] init];
        WeakSelf(weakSelf);
        alarmPeriodVC.AlarmPeriodBack = ^{
            [weakSelf updateTableList];
        };
        alarmPeriodVC.devID = self.devID;
        alarmPeriodVC.periodKind = NewAlarmPeriodKink_Intelligent;
        alarmPeriodVC.intellAlertAlarmMannager = self.intellAlertAlarmMannager;
        [[VCManager getCurrentVC].navigationController pushViewController:alarmPeriodVC animated:YES];
    }
}

//MARK: - LazyLoad
- (UITableView *)tbList{
    if (!_tbList) {
        _tbList = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        [_tbList registerClass:[TitleComboBoxCell class] forCellReuseIdentifier:kTitleComboBoxCell];
        [_tbList registerClass:[JFLeftTitleRightSwitchCell class] forCellReuseIdentifier:kJFLeftTitleRightSwitchCell];
        [_tbList registerClass:[JFLeftTitleRightTitleArrowCell class] forCellReuseIdentifier:kJFLeftTitleRightTitleArrowCell];
        [_tbList registerClass:[JFAOVIntelligentDetectCell class] forCellReuseIdentifier:kJFAOVIntelligentDetectCell];
        [_tbList registerClass:[JFLeftSelectRightArrowCell class] forCellReuseIdentifier:kJFLeftSelectRightArrowCell];
        _tbList.dataSource = self;
        _tbList.delegate = self;
//        [_tbList setCellSectionDefaultHeight];
        _tbList.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tbList.sectionHeaderHeight = 0;
        _tbList.sectionFooterHeight = 10;
        _tbList.tableFooterView = [[UIView alloc] init];
    }
    
    return _tbList;
}

- (NSMutableArray *)cfgOrderList{
    if (!_cfgOrderList) {
        /*
         iMaker:
         0:右侧带开关的cell
         1:右侧带文字箭头的cell
         2:右侧勾选状态cell
         */
        _cfgOrderList = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray *section0 = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray *section1 = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray *section2 = [NSMutableArray arrayWithCapacity:0];
        [_cfgOrderList addObject:section0];
        [_cfgOrderList addObject:section1];
        [_cfgOrderList addObject:section2];
        
        //智能侦测
        OrderListItem *itemIntelligentDetectSwitch = [[OrderListItem alloc] init];
        itemIntelligentDetectSwitch.titleName = TS("TR_Setting_Intelligent_Detection");
        itemIntelligentDetectSwitch.subTitle = TS("TR_Setting_Intelligent_Detection_Description");
        itemIntelligentDetectSwitch.hidden = YES;
        itemIntelligentDetectSwitch.iMarker = 0;
        [section0 addObject:itemIntelligentDetectSwitch];
        
        //智能侦测人形车形
        OrderListItem *itemPersonCarSwitch = [[OrderListItem alloc] init];
        itemPersonCarSwitch.titleName = TS("TR_Setting_Intelligent_DetectionPersonCar");
        itemPersonCarSwitch.subTitle = @"";
        itemPersonCarSwitch.hidden = YES;
        itemPersonCarSwitch.iMarker = 0;
        [section0 addObject:itemPersonCarSwitch];
        
        //显示智能轨迹
        OrderListItem *itemDisplayTrace = [[OrderListItem alloc] init];
        itemDisplayTrace.titleName = TS("TR_Setting_Display_Smart_Trace");
        itemDisplayTrace.hidden = YES;
        itemDisplayTrace.iMarker = 0;
        [section1 addObject:itemDisplayTrace];
        //智能规则设置
        OrderListItem *itemRule = [[OrderListItem alloc] init];
        itemRule.titleName = TS("TR_Rule_Setting");
        itemRule.hidden = YES;
        itemRule.iMarker = 1;
        [section1 addObject:itemRule];
        //警戒线
        OrderListItem *itemAlertLine = [[OrderListItem alloc] init];
        itemAlertLine.titleName = TS("type_alert_line");
        itemAlertLine.hidden = YES;
        itemAlertLine.iMarker = 2;
        [section1 addObject:itemAlertLine];
        //警戒区域
        OrderListItem *itemDetectionArea = [[OrderListItem alloc] init];
        itemDetectionArea.titleName = TS("type_alert_area");
        itemDetectionArea.hidden = YES;
        itemDetectionArea.iMarker = 2;
        [section1 addObject:itemDetectionArea];
        //警戒区域对应的镜头
        OrderListItem *itemSensor1 = [[OrderListItem alloc] init];
        itemSensor1.titleName = @"itemSensor1";
        itemSensor1.hidden = YES;
        itemSensor1.iMarker = 3;
        [section1 addObject:itemSensor1];
        OrderListItem *itemSensor2 = [[OrderListItem alloc] init];
        itemSensor2.titleName = @"itemSensor2";
        itemSensor2.hidden = YES;
        itemSensor2.iMarker = 3;
        [section1 addObject:itemSensor2];
        
        //报警时段
        OrderListItem *itemAlarmTime = [[OrderListItem alloc] init];
        itemAlarmTime.titleName = TS("alarm_time");
        itemAlarmTime.hidden = YES;
        itemAlarmTime.iMarker = 1;
        [section2 addObject:itemAlarmTime];
    }
    
    return _cfgOrderList;
}

- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:0];
        [self updateConfigListVisiable:NO cfgNames:@[]];
    }
    
    return _dataSource;
}

@end
