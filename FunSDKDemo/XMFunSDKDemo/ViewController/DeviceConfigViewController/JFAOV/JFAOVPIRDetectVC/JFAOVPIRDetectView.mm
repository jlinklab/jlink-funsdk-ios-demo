//
//  JFAOVPIRDetectView.m
//   iCSee
//
//  Created by Megatron on 2024/4/29.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import "JFAOVPIRDetectView.h"
#import "OrderListItem.h"
#import "JFLeftTitleRightSwitchCell.h"
#import "JFLeftTitleRightTitleArrowCell.h"
#import "JFTopTitleBottomSliderCell.h"
#import "PhoneInfoManager.h"
#import "IntelViewController.h"
#import "DrawControl.h"
#import "JFNewAlarmPeriodVc.h"
#import "PirTimeSectionViewController.h"

static NSString *const kJFLeftTitleRightSwitchCell = @"kJFLeftTitleRightSwitchCell";
static NSString *const kJFLeftTitleRightTitleArrowCell = @"kJFLeftTitleRightTitleArrowCell";
static NSString *const kJFTopTitleBottomSliderCell = @"kJFTopTitleBottomSliderCell";

@interface JFAOVPIRDetectView () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tbList;
// 配置顺序列表 修改顺序或者分组 增加项目 都要先在这里确定配置位置
@property (nonatomic,strong) NSMutableArray *cfgOrderList;
// 配置列表数据源
@property (nonatomic,strong) NSMutableArray *dataSource;
///记录下最新的低电量的cell 需要实时改变数据
@property (nonatomic,weak) JFTopTitleBottomSliderCell *lastSliderCell;

@end
@implementation JFAOVPIRDetectView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
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
    if ([self.pirAlarmManager getEnable]) {
        NSMutableArray *arrayHide = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray *arrayShow = [NSMutableArray arrayWithCapacity:0];
        //默认显示智能侦测
        [arrayShow addObject:TS("TR_Setting_PIR_Detection")];
        //是否支持显示PIR灵敏度
        if (self.ifSupportPIRSensitive) {
            [arrayShow addObject:TS("TR_Pir_Sensitivity")];
        }else {
            [arrayHide addObject:TS("TR_Pir_Sensitivity")];
        }
        //是否支持PIR报警时间段
        [arrayShow addObject:TS("alarm_time")];
        [self updateConfigListVisiable:YES cfgNames:arrayShow];
        [self updateConfigListVisiable:NO cfgNames:arrayHide];
        [self updateTableList];
    }else{
        self.dataSource = [@[[self.cfgOrderList objectAtIndex:0]] mutableCopy];
        [self updateTableList];
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
    if ([title isEqualToString:TS("TR_Setting_PIR_Detection")]) {//PIR侦测
        JFLeftTitleRightSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:kJFLeftTitleRightSwitchCell];
        cell.style = JFLeftTitleRightSwitchCellStyle_Title;
        cell.lbTitle.text = title;
        cell.lbSubTitle.text = subTitle;
        cell.rightSwitch.on = [self.pirAlarmManager getEnable];
        cell.RightSwitchValueChanged = ^(BOOL open) {
            [SVProgressHUD show];
            [weakSelf.pirAlarmManager setEnable:open];
            [weakSelf.pirAlarmManager setPirAlarmCompleted:^(int result, int channel) {
                if (result >= 0) {
                    [SVProgressHUD dismiss];
                    [weakSelf configUpdate];
                }else{
                    [MessageUI ShowErrorInt:result];
                }
            }];
        };
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }else if ([title isEqualToString:TS("TR_Pir_Sensitivity")]) {//PIR灵敏度
        JFTopTitleBottomSliderCell *cell = [tableView dequeueReusableCellWithIdentifier:kJFTopTitleBottomSliderCell];
        self.lastSliderCell = cell;
        cell.lbTitle.text = title;
        cell.lbSubTitle.text = subTitle;
        [cell resetSubViewsWithContentWidth:SCREEN_WIDTH - 2 * cTableViewFilletLFBorder - 2 * cTableViewFilletContentLRBorder];
        NSArray *arrayValue = @[@1,@2,@3,@4,@5];
        NSMutableArray *arrayName = [NSMutableArray arrayWithCapacity:0];
        [arrayName addObject:TS("TR_PIR_lowest")];
        [arrayName addObject:TS("TR_PIR_Lower")];
        [arrayName addObject:TS("TR_PIR_Medium")];
        [arrayName addObject:TS("TR_PIR_Higher")];
        [arrayName addObject:TS("TR_PIR_Hightext")];
        cell.slider.arraySegmentValue = arrayValue;
        cell.slider.arraySegmentName = arrayName;
        cell.slider.lblLeft.text = [arrayName firstObject];
        cell.slider.lblRight.text = [arrayName lastObject];
        cell.slider.realValue = [self.pirAlarmManager getPirSensitive];
        cell.slider.style = JFSliderStyle_Segmentation;
        int sensitive = [self.pirAlarmManager getPirSensitive];
        cell.lbTitle.text = [NSString stringWithFormat:@"%@(%@)",TS("TR_Pir_Sensitivity"),[arrayName objectAtIndex:sensitive -1]];
        WeakSelf(weakSelf);
        cell.slider.valueChangedBlock = ^(CGFloat value) {
            [weakSelf.pirAlarmManager setPirSensitive:(int)value];
            weakSelf.lastSliderCell.lbTitle.text = [NSString stringWithFormat:@"%@(%@)",TS("TR_Pir_Sensitivity"),[arrayName objectAtIndex:(int)value -1]];
            [SVProgressHUD show];
            [weakSelf.pirAlarmManager setPirAlarmCompleted:^(int result, int channel) {
                if (result >= 0) {
                    [SVProgressHUD dismiss];
                    [weakSelf configUpdate];
                }else{
                    [MessageUI ShowErrorInt:result];
                }
            }];
        };
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }else if ([title isEqualToString:TS("alarm_time")]) {//报警时间段
        JFLeftTitleRightTitleArrowCell *cell = [tableView dequeueReusableCellWithIdentifier:kJFLeftTitleRightTitleArrowCell];
        cell.lbTitle.text = title;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    OrderListItem *item = [[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSString *title = item.titleName;
    NSString *subTitle = item.subTitle;
    if ([title isEqualToString:TS("TR_Pir_Sensitivity")]) {//PIR灵敏度
        if (self.pirAlarmManager) {
            int sensitive = [self.pirAlarmManager getPirSensitive];
            NSMutableArray *arrayName = [NSMutableArray arrayWithCapacity:0];
            [arrayName addObject:TS("TR_PIR_lowest")];
            [arrayName addObject:TS("TR_PIR_Lower")];
            [arrayName addObject:TS("TR_PIR_Medium")];
            [arrayName addObject:TS("TR_PIR_Higher")];
            [arrayName addObject:TS("TR_PIR_Hightext")];
            title = [NSString stringWithFormat:@"%@(%@)",TS("TR_Pir_Sensitivity"),[arrayName objectAtIndex:sensitive - 1]];
            CGFloat height = [self cellHeightWithTitle:title titleFont:JFFont(cTableViewFilletTitleFont) subTitle:subTitle subTitleFont:JFFont(cTableViewFilletSubTitleFont) maxWidht:SCREEN_WIDTH - cTableViewFilletLFBorder * 2  tbOffset:cTableViewFilletContentLRBorder];
            height = height + 2 + 11 + 65 - cTableViewFilletLFBorder;
            
            return height;
        }
    }
    
    return 50;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    OrderListItem *item = [[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSString *title = item.titleName;
    
    if ([title isEqualToString:TS("alarm_time")]) {//报警时间段
        PirTimeSectionViewController *pirTimeSectionViewController = [[PirTimeSectionViewController alloc] init];
        pirTimeSectionViewController.navTitle = TS("alarm_time");
        WeakSelf(weakSelf);
        pirTimeSectionViewController.PIRAlarmTimeSection = ^(PirAlarmManager *manager) {
            weakSelf.pirAlarmManager = manager;
            [SVProgressHUD show];
            [weakSelf.pirAlarmManager setPirAlarmCompleted:^(int result, int channel) {
                if (result >= 0) {
                    [SVProgressHUD dismiss];
                    [weakSelf configUpdate];
                }else{
                    [MessageUI ShowErrorInt:result];
                }
            }];
        };
        pirTimeSectionViewController.pirAlarmManager = self.pirAlarmManager;
        [[VCManager getCurrentVC].navigationController pushViewController:pirTimeSectionViewController animated:YES];
    }
}

//MARK: - LazyLoad
- (UITableView *)tbList{
    if (!_tbList) {
        _tbList = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        [_tbList registerClass:[JFTopTitleBottomSliderCell class] forCellReuseIdentifier:kJFTopTitleBottomSliderCell];
        [_tbList registerClass:[JFLeftTitleRightSwitchCell class] forCellReuseIdentifier:kJFLeftTitleRightSwitchCell];
        [_tbList registerClass:[JFLeftTitleRightTitleArrowCell class] forCellReuseIdentifier:kJFLeftTitleRightTitleArrowCell];
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
         2:带slider的cell
         */
        _cfgOrderList = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray *section0 = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray *section1 = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray *section2 = [NSMutableArray arrayWithCapacity:0];
        [_cfgOrderList addObject:section0];
        [_cfgOrderList addObject:section1];
        [_cfgOrderList addObject:section2];
        
        //PIR侦测
        OrderListItem *itemIPIRDetectSwitch = [[OrderListItem alloc] init];
        itemIPIRDetectSwitch.titleName = TS("TR_Setting_PIR_Detection");
        itemIPIRDetectSwitch.hidden = NO;
        itemIPIRDetectSwitch.iMarker = 0;
        [section0 addObject:itemIPIRDetectSwitch];
        
        //PIR灵敏度
        OrderListItem *itemPIRSensitivity = [[OrderListItem alloc] init];
        itemPIRSensitivity.titleName = TS("TR_Pir_Sensitivity");
        itemPIRSensitivity.hidden = YES;
        itemPIRSensitivity.iMarker = 2;
        [section1 addObject:itemPIRSensitivity];
        
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
