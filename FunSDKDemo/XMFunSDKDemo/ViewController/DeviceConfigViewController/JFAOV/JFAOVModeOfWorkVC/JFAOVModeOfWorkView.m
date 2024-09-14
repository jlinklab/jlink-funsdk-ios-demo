//
//  JFAOVModeOfWorkView.m
//   iCSee
//
//  Created by Megatron on 2024/4/24.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import "JFAOVModeOfWorkView.h"
#import "JFLeftTitleRightButtonCell.h"
#import "OrderListItem.h"
#import "JFLeftTitleRightTitleArrowCell.h"
#import "XMItemSelectViewController.h"
#import "PhoneInfoManager.h"

static NSString *const kJFLeftTitleRightButtonCell = @"kJFLeftTitleRightButtonCell";
static NSString *const kJFLeftTitleRightTitleArrowCell = @"kJFLeftTitleRightTitleArrowCell";

@interface JFAOVModeOfWorkView () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tbList;
// 配置顺序列表 修改顺序或者分组 增加项目 都要先在这里确定配置位置
@property (nonatomic,strong) NSMutableArray *cfgOrderList;
// 配置列表数据源
@property (nonatomic,strong) NSMutableArray *dataSource;

// 底部提示view
@property (nonatomic,strong) UIView *footView;
@property (nonatomic,strong) UILabel *lblFootTitle;
@property (nonatomic,strong) UIImageView *imgIcon;
@end
@implementation JFAOVModeOfWorkView

- (instancetype)init{
    self = [super init];
    if (self) {
        //默认值
        self.workMode = JFAOVWorkMode_Unknow;
        self.savingModeFPS = @"0";
        self.performanceModeFPS = @"0";
        self.customFPS = @"0";
        self.customRecordLatch = 0;
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.tbList];
        [self creatTableFootView];
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

- (void)creatTableFootView {
    [self.footView addSubview:self.imgIcon];
    [self.imgIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.top.mas_equalTo(10);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
    
//    self.lblFootTitle.text = TS("TR_Setting_AOV_Low_Battery_Mode_Description");
     
    [self.footView addSubview:self.lblFootTitle];
    [self.lblFootTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.imgIcon.mas_right).mas_offset(5);
        make.top.mas_equalTo(10);
        make.right.mas_equalTo(-25);
    }];
    
    self.tbList.tableFooterView = self.footView;
    self.footView.hidden = YES;
}

- (void)configBatterValueTips {
    //电量低于最低电量阈值后显示提示
    if (self.batteryLevel < self.lowBatteryLevel) {
        self.footView.hidden = NO;
        if (self.lowBatteryLevel >= 0) {
            NSString *title =  [TS("TR_Setting_AOV_Low_Battery_Mode_Description") stringByReplacingOccurrencesOfString:@"%s" withString:[NSString stringWithFormat:@"%d%%",self.lowBatteryLevel]];
            self.lblFootTitle.text = title;
        }
    } else {
        self.footView.hidden = YES;
    }
}

///工作模式变化时 更新数据源
- (void)setWorkMode:(JFAOVWorkMode)workMode{
    if (_workMode != workMode) {
        _workMode = workMode;
        if (self.supportAovWorkModeIndieControl) {
            [self updateConfigListVisiable:workMode == JFAOVWorkMode_Custom ? YES : NO cfgNames:@[TS("TR_AOV_Fps"),TS("TR_AOV_Alarm_interval"),TS("TR_Setting_Aov_RecordLength")]];

        } else {
            [self updateConfigListVisiable:workMode == JFAOVWorkMode_Custom ? YES : NO cfgNames:@[TS("TR_Setting_Event_Record_Delay"),TS("TR_AOV_Fps")]];

        }
        
        [self updateTableList];
    }
}

//aov 报警间隔
- (void)setSupportAovAlarmHold:(BOOL)supportAovAlarmHold {
    _supportAovAlarmHold = supportAovAlarmHold;
    if (supportAovAlarmHold) {
        [self updateConfigListVisiable:YES cfgNames:@[TS("TR_AOV_Alarm_interval")]];
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
                if ([item.titleName isEqualToString:TS("TR_AOV_Alarm_interval")]) {
                    if (self.supportAovWorkModeIndieControl) {
                        if (item.tempValue == 0) {
                            [sectionNew addObject:item];
                        }
                    } else {
                        if (item.tempValue == 1) {
                            [sectionNew addObject:item];
                        }
                    }
                } else {
                    [sectionNew addObject:item];
                }
                
            }
        }
        [dataSource addObject:sectionNew];
    }
    self.dataSource = [dataSource mutableCopy];
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
- (NSMutableAttributedString *)updateSubTitleAttributedString:(NSString *)contant {
    // 原始字符串
    NSString *originalString = @"";
    // 需要替换的三个变量
    NSString *frameRate = @"";
    NSString *alertInterval = @"";
    NSString *maxDuration = @"";
    if ([contant isEqualToString:TS("TR_Setting_Power_Saving_Mode")]) {
        if (self.supportDoubleLightBoxCamera) {
            originalString = TS("TR_Setting_Aov_Blance_tips");
        } else {
            originalString = TS("TR_Setting_AOV_BlackLight_Blance_Tips");
        }
        frameRate = [NSString stringWithFormat:@"%@fps",self.savingModeFPS];
        alertInterval = [NSString stringWithFormat:@"%ds",self.savingModeAlarmHoldTime];
        maxDuration = [NSString stringWithFormat:@"%ds",self.savingModeRecordLength];
        

    }else if ([contant isEqualToString:TS("TR_Setting_Performance")]) {
        if (self.supportDoubleLightBoxCamera) {
            originalString = TS("TR_Setting_Aov_Blance_tips");
        } else {
            originalString = TS("TR_Setting_AOV_BlackLight_Blance_Tips");
        }
        frameRate = [NSString stringWithFormat:@"%@fps",self.performanceModeFPS];
        alertInterval = [NSString stringWithFormat:@"%ds",self.performanceModeAlarmHoldTime];
        maxDuration = [NSString stringWithFormat:@"%ds",self.performanceModeRecordLength];
    }
    
    // 将原始字符串拆分为多个部分
    NSArray *components = [originalString componentsSeparatedByString:@"%s"];
    
    // 创建可变的富文本字符串
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    
    // 定义红色字体属性
    UIColor *redColor = GlobalMainColor;
    NSDictionary *attributes = @{NSForegroundColorAttributeName: redColor};
    
    // 遍历并替换字符串中的 %s 部分
    for (int i = 0; i < components.count; i++) {
        // 添加常规文本部分
        NSString *part = components[i];
        NSAttributedString *normalText = [[NSAttributedString alloc] initWithString:part];
        [attributedString appendAttributedString:normalText];
        
        // 添加红色文本部分（除最后一个部分外）
        if (i < components.count - 1) {
            NSString *replacement = (i == 0) ? frameRate : (i == 1) ? alertInterval : maxDuration;
            NSAttributedString *redText = [[NSAttributedString alloc] initWithString:replacement attributes:attributes];
            [attributedString appendAttributedString:redText];
        }
    }
    
    return attributedString;
}

- (NSString *)updateSubTitleString:(NSString *)contant{
    // 原始字符串
    NSString *originalString = @"";
    // 需要替换的三个变量
    NSString *frameRate = @"";
    NSString *alertInterval = @"";
    NSString *maxDuration = @"";
    if ([contant isEqualToString:TS("TR_Setting_Power_Saving_Mode")]) {
        if (self.supportDoubleLightBoxCamera) {
            originalString = TS("TR_Setting_Aov_Blance_tips");
        } else {
            originalString = TS("TR_Setting_AOV_BlackLight_Blance_Tips");
        }
        frameRate = [NSString stringWithFormat:@"%@fps",self.savingModeFPS];
        alertInterval = [NSString stringWithFormat:@"%ds",self.savingModeAlarmHoldTime];
        maxDuration = [NSString stringWithFormat:@"%ds",self.savingModeRecordLength];
        

    }else if ([contant isEqualToString:TS("TR_Setting_Performance")]) {
        if (self.supportDoubleLightBoxCamera) {
            originalString = TS("TR_Setting_Aov_Blance_tips");
        } else {
            originalString = TS("TR_Setting_AOV_BlackLight_Blance_Tips");
        }
        frameRate = [NSString stringWithFormat:@"%@fps",self.performanceModeFPS];
        alertInterval = [NSString stringWithFormat:@"%ds",self.performanceModeAlarmHoldTime];
        maxDuration = [NSString stringWithFormat:@"%ds",self.performanceModeRecordLength];
    }
    
    // 手动替换每一个 %s
    NSRange range = [originalString rangeOfString:@"%s"];
    if (range.location != NSNotFound) {
        originalString = [originalString stringByReplacingCharactersInRange:range withString:frameRate];
    }
    
    range = [originalString rangeOfString:@"%s"];
    if (range.location != NSNotFound) {
        originalString = [originalString stringByReplacingCharactersInRange:range withString:alertInterval];
    }
    
    range = [originalString rangeOfString:@"%s"];
    if (range.location != NSNotFound) {
        originalString = [originalString stringByReplacingCharactersInRange:range withString:maxDuration];
    }
    
    return originalString;
}

///更新列表
- (void)updateTableList{
     
    [self.tbList reloadData];
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
    NSString *subTitle = @"";
    NSAttributedString *attributedString = nil;
    if (item.iMarker == 0) {
        JFLeftTitleRightButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:kJFLeftTitleRightButtonCell];
        cell.style = JFLeftTitleRightButtonCellStyle_SubTitle;
        cell.lbTitle.text = title;
        if (attributedString) {
            cell.lbSubTitle.attributedText = attributedString;
        } else {
            cell.lbSubTitle.text = subTitle;
        }
        
        if ([item.titleName isEqualToString:TS("TR_Setting_Power_Saving_Mode")]) {
            if (self.workMode == JFAOVWorkMode_Saving) {
                cell.btnRight.selected = YES;
            }else{
                cell.btnRight.selected = NO;
            }
        }else if ([item.titleName isEqualToString:TS("TR_Setting_Performance")]) {
            if (self.workMode == JFAOVWorkMode_Performance) {
                cell.btnRight.selected = YES;
            }else{
                cell.btnRight.selected = NO;
            }
        }else if ([item.titleName isEqualToString:TS("mode_customize")]) {
            if (self.workMode == JFAOVWorkMode_Custom) {
                cell.btnRight.selected = YES;
            }else{
                cell.btnRight.selected = NO;
            }
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }else{
        JFLeftTitleRightTitleArrowCell *cell = [tableView dequeueReusableCellWithIdentifier:kJFLeftTitleRightTitleArrowCell];
        cell.extraBorderLeft = 15;
        cell.bottomLineHeight = 0.5;
        if ([item.titleName isEqualToString:TS("TR_Setting_Event_Record_Delay")]) {
            cell.bottomLine.hidden = NO;
            [cell showTitle:title description:@"" rightTitle:[NSString stringWithFormat:@"%is",self.customRecordLatch]];
        } else if([item.titleName isEqualToString:TS("TR_AOV_Alarm_interval")]) {
            if (item.tempValue == 0) {
                cell.bottomLine.hidden = NO;
    
                if (self.customAlarmHoldTime == 0) {
                    [cell showTitle:title description:@"" rightTitle:TS("TR_Smart_PowerReal")];
                } else {
                    [cell showTitle:title description:@"" rightTitle:[NSString stringWithFormat:@"%is",self.customAlarmHoldTime]];
                }
            } else if (item.tempValue == 1) {
                cell.bottomLine.hidden = YES;
                cell.extraBorderLeft = 0;
                if (self.aovAlarmHoldTime == 0) {
                    [cell showTitle:title description:@"" rightTitle:TS("TR_Smart_PowerReal")];
                } else {
                    [cell showTitle:title description:@"" rightTitle:[NSString stringWithFormat:@"%is",self.aovAlarmHoldTime]];
                }
            }
            
            
        } else if([item.titleName isEqualToString:TS("TR_AOV_Fps")]) {
            if (self.supportAovWorkModeIndieControl) {
                cell.bottomLine.hidden = NO;
            } else {
                cell.bottomLine.hidden = YES;
            }
            [cell showTitle:title description:@"" rightTitle:[NSString stringWithFormat:@"%@fps",self.customFPS]];
            
        } else if([item.titleName isEqualToString:TS("TR_Setting_Aov_RecordLength")]) {
            
            cell.bottomLine.hidden = YES;
            [cell showTitle:title description:@"" rightTitle:[NSString stringWithFormat:@"%is",self.customRecordLength]];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    OrderListItem *item = [[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSString *title = item.titleName;
    NSString *subTitle = @"";
    if (item.iMarker == 0) {
        
        if (self.supportAovWorkModeIndieControl) {
            if ([item.titleName isEqualToString:TS("mode_customize")]) {
                subTitle = @"";
            } else {
                subTitle = [self updateSubTitleString:item.titleName];
                
            }
            CGFloat height = [self cellHeightWithTitle:title titleFont:JFFont(cTableViewFilletTitleFont) subTitle:subTitle subTitleFont:JFFont(cTableViewFilletSubTitleFont) maxWidht:SCREEN_WIDTH - 15 * 2 - 5 - 20 tbOffset:cTableViewFilletContentLRBorder];
            
            return height;
            
        } else {
            
            if ([item.titleName isEqualToString:TS("TR_Setting_Power_Saving_Mode")]) {
                subTitle = [TS("TR_Setting_AOV_FPS_Description") stringByReplacingOccurrencesOfString:@"%s" withString:self.savingModeFPS];
            }else if ([item.titleName isEqualToString:TS("TR_Setting_Performance")]) {
                subTitle = [TS("TR_Setting_AOV_FPS_Description") stringByReplacingOccurrencesOfString:@"%s" withString:self.performanceModeFPS];
            }else if ([item.titleName isEqualToString:TS("mode_customize")]) {
                subTitle = TS("TR_Setting_Event_Record_Delay");
            }
            CGFloat height = [self cellHeightWithTitle:title titleFont:JFFont(cTableViewFilletTitleFont) subTitle:subTitle subTitleFont:JFFont(cTableViewFilletSubTitleFont) maxWidht:SCREEN_WIDTH - 15 * 2 - 5 - 20 tbOffset:cTableViewFilletContentLRBorder];
            
            return height;
        }
    }else{
        CGFloat height = [self cellHeightWithTitle:title titleFont:JFFont(cTableViewFilletTitleFont) subTitle:@"" subTitleFont:JFFont(cTableViewFilletSubTitleFont) maxWidht:SCREEN_WIDTH - 15 * 2 - 9 - 100 - 15 tbOffset:cTableViewFilletContentLRBorder];
        
        return height + 10;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    OrderListItem *item = [[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (item.iMarker == 0) {
        if ([item.titleName isEqualToString:TS("TR_Setting_Power_Saving_Mode")]) {
            self.workMode = JFAOVWorkMode_Saving;
        }else if ([item.titleName isEqualToString:TS("TR_Setting_Performance")]) {
            self.workMode = JFAOVWorkMode_Performance;
        }else if ([item.titleName isEqualToString:TS("mode_customize")]) {
            self.workMode = JFAOVWorkMode_Custom;
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(userChangeWorkMode:)]) {
            [self.delegate userChangeWorkMode:self.workMode];
        }
    }else{
        if ([item.titleName isEqualToString:TS("TR_Setting_Event_Record_Delay")]) {
            XMItemSelectViewController *vc = [[XMItemSelectViewController alloc] init];
            vc.title = item.titleName;
            vc.filletMode = YES;
            vc.needAutoBack = YES;
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
            for (int i = 0; i < self.customRecordLatchList.count; i++) {
                [array addObject:[NSString stringWithFormat:@"%is",[[self.customRecordLatchList objectAtIndex:i] intValue]]];
            }
            vc.arrItems = array;
            int index = (int)[self.customRecordLatchList indexOfObject:[NSNumber numberWithInt:self.customRecordLatch]];
            vc.lastIndex = index;
            WeakSelf(weakSelf);
            vc.itemChangedAction = ^(int index) {
                weakSelf.customRecordLatch = [[weakSelf.customRecordLatchList objectAtIndex:index] intValue];
                [weakSelf updateTableList];
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(userChangeCustomEventRecordLatch:)]) {
                    [weakSelf.delegate userChangeCustomEventRecordLatch:weakSelf.customRecordLatch];
                }
            };
            [[VCManager getCurrentVC].navigationController pushViewController:vc animated:YES];
        }else if ([item.titleName isEqualToString:TS("TR_AOV_Alarm_interval")]) {
            if (item.tempValue == 0) {
                XMItemSelectViewController *vc = [[XMItemSelectViewController alloc] init];
                vc.title = item.titleName;
                vc.filletMode = YES;
                vc.needAutoBack = YES;
                NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
                for (int i = 0; i < self.customAlarmHoldTimeList.count; i++) {
                    if ([[self.customAlarmHoldTimeList objectAtIndex:i] intValue] == 0) {
                        [array addObject:TS("TR_Smart_PowerReal")];
                    } else {
                        [array addObject:[NSString stringWithFormat:@"%is",[[self.customAlarmHoldTimeList objectAtIndex:i] intValue]]];
                    }
                }
                vc.arrItems = array;
                if (self.customAlarmHoldTime == 0) {
                    vc.lastIndex = 0;
                } else{
                    int index = (int)[self.customAlarmHoldTimeList indexOfObject:[NSNumber numberWithInt:self.customAlarmHoldTime]];
                    vc.lastIndex = index;
                }
                WeakSelf(weakSelf);
                vc.itemChangedAction = ^(int index) {
                    weakSelf.customAlarmHoldTime = [[weakSelf.customAlarmHoldTimeList objectAtIndex:index] intValue];
                    [weakSelf updateTableList];
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(userChangeCustomAlarmHoldTime:)]) {
                        [weakSelf.delegate userChangeCustomAlarmHoldTime:weakSelf.customAlarmHoldTime];
                    }
                };
                [[VCManager getCurrentVC].navigationController pushViewController:vc animated:YES];
            } else if (item.tempValue == 1) {
            
                XMItemSelectViewController *vc = [[XMItemSelectViewController alloc] init];
                vc.title = item.titleName;
                vc.filletMode = YES;
                vc.needAutoBack = YES;
                NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
                for (int i = 0; i < self.aovAlarmHoldTimeList.count; i++) {
                    if ([[self.aovAlarmHoldTimeList objectAtIndex:i] intValue] == 0) {
                        [array addObject:TS("TR_Smart_PowerReal")];
                    } else {
                        [array addObject:[NSString stringWithFormat:@"%is",[[self.aovAlarmHoldTimeList objectAtIndex:i] intValue]]];
                    }
                }
                vc.arrItems = array;
                if (self.aovAlarmHoldTime == 0) {
                    vc.lastIndex = 0;
                } else{
                    int index = (int)[self.aovAlarmHoldTimeList indexOfObject:[NSNumber numberWithInt:self.aovAlarmHoldTime]];
                    vc.lastIndex = index;
                }
                WeakSelf(weakSelf);
                vc.itemChangedAction = ^(int index) {
                    weakSelf.aovAlarmHoldTime = [[weakSelf.aovAlarmHoldTimeList objectAtIndex:index] intValue];
                    [weakSelf updateTableList];
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(userChangeAlarmHoldTime:)]) {
                        [weakSelf.delegate userChangeAlarmHoldTime:weakSelf.aovAlarmHoldTime];
                    }
                };
                [[VCManager getCurrentVC].navigationController pushViewController:vc animated:YES];
            }
        } else if ([item.titleName isEqualToString:TS("TR_AOV_Fps")]){
            XMItemSelectViewController *vc = [[XMItemSelectViewController alloc] init];
            vc.title = item.titleName;
            vc.isAOVFPS = YES;
            
            vc.filletMode = YES;
            vc.needAutoBack = YES;
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
            for (int i = 0; i < self.customFPSList.count; i++) {
                [array addObject:[NSString stringWithFormat:@"%@fps",[self.customFPSList objectAtIndex:i]]];
            }
            vc.arrItems = array;
            int index = (int)[self.customFPSList indexOfObject:self.customFPS];
            vc.lastIndex = index;
            vc.customFPS = self.customFPS;
            WeakSelf(weakSelf);
            vc.itemChangedAction = ^(int index) {
                weakSelf.customFPS = [weakSelf.customFPSList objectAtIndex:index];
                [weakSelf updateTableList];
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(userChangeCustomFPS:)]) {
                    [weakSelf.delegate userChangeCustomFPS:weakSelf.customFPS];
                }
            };
            [[VCManager getCurrentVC].navigationController pushViewController:vc animated:YES];
        }else if ([item.titleName isEqualToString:TS("TR_Setting_Aov_RecordLength")]){
            XMItemSelectViewController *vc = [[XMItemSelectViewController alloc] init];
            vc.title = item.titleName;
            vc.filletMode = YES;
            vc.needAutoBack = YES;
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
            for (int i = 0; i < self.customRecordLengthList.count; i++) {
                [array addObject:[NSString stringWithFormat:@"%is",[[self.customRecordLengthList objectAtIndex:i] intValue]]];
            }
            vc.arrItems = array;
            int index = (int)[self.customRecordLengthList indexOfObject:[NSNumber numberWithInt:self.customRecordLength]];
            vc.lastIndex = index;
            WeakSelf(weakSelf);
            vc.itemChangedAction = ^(int index) {
                weakSelf.customRecordLength = [[weakSelf.customRecordLengthList objectAtIndex:index] intValue];
                [weakSelf updateTableList];
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(userChangeCustomRecordLength:)]) {
                    [weakSelf.delegate userChangeCustomRecordLength:weakSelf.customRecordLength];
                }
            };
            [[VCManager getCurrentVC].navigationController pushViewController:vc animated:YES];
        }
    }
}

//MARK: - LazyLoad
- (UITableView *)tbList{
    if (!_tbList) {
        _tbList = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        [_tbList registerClass:[JFLeftTitleRightButtonCell class] forCellReuseIdentifier:kJFLeftTitleRightButtonCell];
        [_tbList registerClass:[JFLeftTitleRightTitleArrowCell class] forCellReuseIdentifier:kJFLeftTitleRightTitleArrowCell];
        _tbList.dataSource = self;
        _tbList.delegate = self;
        _tbList.separatorStyle = UITableViewCellSeparatorStyleNone;
//        _tbList.sectionHeaderHeight = 0;
//        _tbList.sectionFooterHeight = 0;
        _tbList.tableFooterView = [[UIView alloc] init];
    }
    
    return _tbList;
}
- (UIView *)footView {
    if (!_footView) {
        _footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100)];
        _footView.backgroundColor = cTableViewFilletGroupedBackgroudColor;
    }
    return _footView;
}

- (UIImageView *)imgIcon {
    if (!_imgIcon) {
        _imgIcon = [[UIImageView alloc] init];
        _imgIcon.image = [UIImage imageNamed:@"set_icon_notice_warning"];
    }
    return _imgIcon;
}
- (UILabel *)lblFootTitle {
    if (!_lblFootTitle) {
        _lblFootTitle = [[UILabel alloc] init];
        _lblFootTitle.font = [UIFont systemFontOfSize:12];
        _lblFootTitle.numberOfLines = 0;
        _lblFootTitle.textColor = UIColorFromHex(0x666666);
    }
    return _lblFootTitle;
}

- (NSMutableArray *)cfgOrderList{
    if (!_cfgOrderList) {
        /*
         */
        _cfgOrderList = [NSMutableArray arrayWithCapacity:0];
        
        
        NSMutableArray *section0 = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray *section1 = [NSMutableArray arrayWithCapacity:0];
         
        [_cfgOrderList addObject:section0];
        [_cfgOrderList addObject:section1];
        
        
        //省电模式
        OrderListItem *itemSaveMode = [[OrderListItem alloc] init];
        itemSaveMode.titleName = TS("TR_Setting_Power_Saving_Mode");
        itemSaveMode.hidden = NO;
        itemSaveMode.iMarker = 0;
        [section0 addObject:itemSaveMode];
        //性能模式
        OrderListItem *itemPerformanceMode = [[OrderListItem alloc] init];
        itemPerformanceMode.titleName = TS("TR_Setting_Performance");
        itemPerformanceMode.hidden = NO;
        itemPerformanceMode.iMarker = 0;
        [section0 addObject:itemPerformanceMode];
        //自定义模式
        OrderListItem *itemCustom = [[OrderListItem alloc] init];
        itemCustom.titleName = TS("mode_customize");
        itemCustom.hidden = NO;
        itemCustom.iMarker = 0;
        [section0 addObject:itemCustom];
        //事件录像延迟
        OrderListItem *itemEventRecord = [[OrderListItem alloc] init];
        itemEventRecord.titleName = TS("TR_Setting_Event_Record_Delay");
        itemEventRecord.hidden = YES;
        itemEventRecord.iMarker = 1;
        [section0 addObject:itemEventRecord];
        //帧率
        OrderListItem *itemFPS = [[OrderListItem alloc] init];
        itemFPS.titleName = TS("TR_AOV_Fps");
        itemFPS.hidden = YES;
        itemFPS.iMarker = 1;
        [section0 addObject:itemFPS];
        //报警间隔 （自定义模式）
        OrderListItem *itemCustomAOVAlarmHold = [[OrderListItem alloc] init];
        itemCustomAOVAlarmHold.titleName = TS("TR_AOV_Alarm_interval");
        itemCustomAOVAlarmHold.hidden = YES;
        itemCustomAOVAlarmHold.iMarker = 1;
        itemCustomAOVAlarmHold.tempValue = 0;// 用于区分是新的自定义的报警间隔 还是老的通用的报警间隔 （0：报警间隔 （自定义模式））

        [section0 addObject:itemCustomAOVAlarmHold];
        //最大录像时长 （自定义模式）
        OrderListItem *itemRecordLength = [[OrderListItem alloc] init];
        itemRecordLength.titleName = TS("TR_Setting_Aov_RecordLength");
        itemRecordLength.hidden = YES;
        itemRecordLength.iMarker = 1;
        [section0 addObject:itemRecordLength];
        
        //aov 报警间隔 （老的通用模式）
        OrderListItem *itemAOVAlarmHold = [[OrderListItem alloc] init];
        itemAOVAlarmHold.titleName = TS("TR_AOV_Alarm_interval");
        itemAOVAlarmHold.hidden = YES;
        itemAOVAlarmHold.iMarker = 1;
        itemAOVAlarmHold.tempValue = 1;// // 用于区分是新的自定义的报警间隔 还是老的通用的报警间隔 （1：报警间隔 （老的通用模式））

        [section1 addObject:itemAOVAlarmHold];
        
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
