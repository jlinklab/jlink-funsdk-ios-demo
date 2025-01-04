//
//  JFAOVBatteryManagemenView.m
//   iCSee
//
//  Created by Megatron on 2024/4/25.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import "JFAOVBatteryManagemenView.h"
#import "JFLeftTitleRightImageTitleCell.h"
#import "OrderListItem.h"
#import "JFTopTitleBottomSliderCell.h"
#import "JFLineChartView.h"
#import "JFSegment.h"

static NSString *const kJFLeftTitleRightImageTitleCell = @"kJFLeftTitleRightImageTitleCell";
static NSString *const kJFTopTitleBottomSliderCell = @"kJFTopTitleBottomSliderCell";

@interface JFAOVBatteryManagemenView () <UITableViewDelegate,UITableViewDataSource,JFSegmentDelegate>

@property (nonatomic, strong) UITableView *tbList;
///配置顺序列表 修改顺序或者分组 增加项目 都要先在这里确定配置位置
@property (nonatomic,strong) NSMutableArray *cfgOrderList;
///配置列表数据源
@property (nonatomic,strong) NSMutableArray *dataSource;
///记录下最新的低电量的cell 需要实时改变数据
@property (nonatomic,weak) JFTopTitleBottomSliderCell *lastSliderCell;
///电池电量统计Footer
@property (nonatomic,strong) UIView *batteryInfoFooter;
///tableviewfooter标题
@property (nonatomic,strong) UILabel *lbTitle;
///tableviewfooter白色底
@property (nonatomic,strong) UIView *whiteBG;
///电量线性统计图
@property (nonatomic,strong) JFLineChartView *batteryChart;
///信号线性统计图
@property (nonatomic,strong) JFLineChartView *signalChart;
///选择框
@property (nonatomic,strong) JFSegment *segmentedControl;
///预览时间统计图
@property (nonatomic,strong) UIView *previewCountView;
///预览时间显示
@property (nonatomic,strong) UILabel *lbPreviewCount;
///唤醒时间统计图
@property (nonatomic,strong) UIView *wakeUpCountView;
///唤醒时间显示
@property (nonatomic,strong) UILabel *lbWakeUpCount;
///报警次数统计图
@property (nonatomic,strong) UIView *alarmCountView;
///报警次数显示
@property (nonatomic,strong) UILabel *lbAlarmCount;
///segmentControl当前选中的index 默认0
@property (nonatomic,assign) int segIndex;

@end
@implementation JFAOVBatteryManagemenView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //默认值
        self.segIndex = 0;
        self.batteryLevel = -1;
        self.lowBatteryLevel = -1;
        self.lowElectrMax = -1;
        self.lowElectrMin = -1;
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

/// 更新电池信息显示能力
- (void)updateTableFooterBatteryInfoAbility:(JFBatteryInfoAbility)ability support:(BOOL)support {
    NSString *key = [NSString stringWithFormat:@"%i",(int)ability];
    if (support) {
        [self.dicInfoAbility setObject:key forKey:key];
    }else {
        [self.dicInfoAbility removeObjectForKey:key];
    }
}

/// 根据能力刷新UI区域
- (void)updateTableFooterFromAbility {
    if (self.dicInfoAbility.allKeys.count > 0) {
        CGFloat titleTopLeftTopOffset = 20;//标题顶部边距
        CGFloat titleTopLeftHeight = 20;//标题高度
        CGFloat whiteBGTopOffset = 10;//白色背景顶部距离标题底部边距
        CGFloat segmentTopOffset = 15;//选择框距离白色背景顶部边距
        CGFloat segmentHeight = 30;//选择框高度
        CGFloat chartViewTopOffset = 20;//图表距离顶部边距
        CGFloat chartHeight = (SCREEN_WIDTH - 2 * cTableViewFilletLFBorder) * 0.618;//图表高度
        CGFloat previewAcountViewTopOffset = 15;//预览时间图表距离顶部边距
        CGFloat previewAccountViewHeight = 80;//预览时间图表高度
        CGFloat alarmCountViewTopOffset = 15;//图表距离白色背景顶部边距
        CGFloat alarmCountViewHeight = 80;//报警数量展示view高度
        
        UIView *nextUITopConstraintView = self.segmentedControl;
        // 白色背景view高度
        CGFloat whiteBGHeight = segmentTopOffset + segmentHeight;
        // 是否支持电量图
        if ([self.dicInfoAbility objectForKey:[NSString stringWithFormat:@"%i",(int)JFBatteryInfo_BatteryChart]]) {
            whiteBGHeight = whiteBGHeight + chartViewTopOffset + chartHeight;
            [self.batteryChart mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_batteryInfoFooter);
                make.right.equalTo(_batteryInfoFooter);
                make.top.equalTo(nextUITopConstraintView.mas_bottom).mas_offset(chartViewTopOffset);
                make.height.mas_equalTo(chartHeight);
            }];
            self.batteryChart.hidden = NO;
            nextUITopConstraintView = self.batteryChart;
        }else {
            [self.batteryChart mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_batteryInfoFooter);
                make.right.equalTo(_batteryInfoFooter);
                make.top.equalTo(nextUITopConstraintView.mas_bottom).mas_offset(chartViewTopOffset);
                make.height.mas_equalTo(0);
            }];
            self.batteryChart.hidden = YES;
        }
        // 是否支持信号图
        if ([self.dicInfoAbility objectForKey:[NSString stringWithFormat:@"%i",(int)JFBatteryInfo_SignalChart]]) {
            whiteBGHeight = whiteBGHeight + chartViewTopOffset + chartHeight;
            [self.signalChart mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_batteryInfoFooter);
                make.right.equalTo(_batteryInfoFooter);
                make.top.equalTo(nextUITopConstraintView.mas_bottom).mas_offset(chartViewTopOffset);
                make.height.mas_equalTo(chartHeight);
            }];
            self.signalChart.hidden = NO;
            nextUITopConstraintView = self.signalChart;
        }else {
            [self.signalChart mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_batteryInfoFooter);
                make.right.equalTo(_batteryInfoFooter);
                make.top.equalTo(nextUITopConstraintView.mas_bottom).mas_offset(chartViewTopOffset);
                make.height.mas_equalTo(0);
            }];
            self.signalChart.hidden = YES;
        }
        // 是否支持预览时间和唤醒时间
        if ([self.dicInfoAbility objectForKey:[NSString stringWithFormat:@"%i",(int)JFBatteryInfo_PreviewTimeStatistics]]) {
            whiteBGHeight = whiteBGHeight + (previewAcountViewTopOffset + previewAccountViewHeight) * 2;
            [self.previewCountView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_batteryInfoFooter).mas_offset(15);;
                make.right.equalTo(_batteryInfoFooter).mas_offset(-15);
                make.top.equalTo(nextUITopConstraintView.mas_bottom).mas_offset(alarmCountViewTopOffset);
                make.height.mas_equalTo(previewAccountViewHeight);
            }];
            [self.wakeUpCountView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_batteryInfoFooter).mas_offset(15);;
                make.right.equalTo(_batteryInfoFooter).mas_offset(-15);
                make.top.equalTo(self.previewCountView.mas_bottom).mas_offset(alarmCountViewTopOffset);
                make.height.mas_equalTo(previewAccountViewHeight);
            }];
            self.previewCountView.hidden = NO;
            self.wakeUpCountView.hidden = NO;
            nextUITopConstraintView = self.wakeUpCountView;
        }else {
            [self.previewCountView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_batteryInfoFooter).mas_offset(15);;
                make.right.equalTo(_batteryInfoFooter).mas_offset(-15);
                make.top.equalTo(nextUITopConstraintView.mas_bottom).mas_offset(alarmCountViewTopOffset);
                make.height.mas_equalTo(0);
            }];
            [self.wakeUpCountView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_batteryInfoFooter).mas_offset(15);;
                make.right.equalTo(_batteryInfoFooter).mas_offset(-15);
                make.top.equalTo(self.previewCountView.mas_bottom).mas_offset(alarmCountViewTopOffset);
                make.height.mas_equalTo(0);
            }];
            self.previewCountView.hidden = YES;
            self.wakeUpCountView.hidden = YES;
        }
        // 是否支持报警次数
        if ([self.dicInfoAbility objectForKey:[NSString stringWithFormat:@"%i",(int)JFBatteryInfo_AlarmFrequencyStatistics]]) {
            whiteBGHeight = whiteBGHeight + previewAcountViewTopOffset + previewAccountViewHeight;
            [self.alarmCountView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_batteryInfoFooter).mas_offset(15);;
                make.right.equalTo(_batteryInfoFooter).mas_offset(-15);
                make.top.equalTo(nextUITopConstraintView.mas_bottom).mas_offset(alarmCountViewTopOffset);
                make.height.mas_equalTo(alarmCountViewHeight);
            }];
            self.alarmCountView.hidden = NO;
            nextUITopConstraintView = self.alarmCountView;
        }else {
            [self.alarmCountView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_batteryInfoFooter).mas_offset(15);;
                make.right.equalTo(_batteryInfoFooter).mas_offset(-15);
                make.top.equalTo(nextUITopConstraintView.mas_bottom).mas_offset(alarmCountViewTopOffset);
                make.height.mas_equalTo(0);
            }];
            self.alarmCountView.hidden = YES;
        }
        whiteBGHeight = whiteBGHeight + segmentTopOffset;
        [self.whiteBG mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_batteryInfoFooter);
            make.right.equalTo(_batteryInfoFooter);
            make.top.equalTo(self.lbTitle.mas_bottom).mas_offset(10);
            make.height.mas_equalTo(whiteBGHeight);
        }];
        self.batteryInfoFooter.frame = CGRectMake(0, 0, SCREEN_WIDTH - 2 * cTableViewFilletLFBorder, titleTopLeftTopOffset + titleTopLeftHeight + whiteBGTopOffset + whiteBGHeight);
        self.tbList.tableFooterView = self.batteryInfoFooter;
    }else {
        self.tbList.tableFooterView = [[UIView alloc] init];
    }
}

///更新配置项是否需要显示或隐藏
- (void)updateConfigListVisiable:(BOOL)visiable cfgNames:(NSArray *)cfgNames {
    NSMutableArray *dataSource = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i < self.cfgOrderList.count; i++) {
        OrderListItem *item = [self.cfgOrderList objectAtIndex:i];
        if ([cfgNames containsObject:item.titleName]) {
            item.hidden = !visiable;
        }
        if (!item.hidden) {
            [dataSource addObject:item];
        }
    }
    self.dataSource = [dataSource mutableCopy];
}

/// 计算cell需要的高度
- (CGFloat)cellHeightWithTitle:(NSString *)title titleFont:(UIFont *)titleFont subTitle:(NSString *)subTitle subTitleFont:(UIFont *)subTitleFont maxWidht:(CGFloat)maxWdith tbOffset:(CGFloat)tbOffset {
    CGFloat titleHeight = 0,subTitleHeight = 0;
    if (title.length > 0) {
        titleHeight = [UIServiceManager getTextHeightFromContent:title maxWidth:maxWdith font:titleFont];
    }
    if (subTitle.length > 0) {
        subTitleHeight = [UIServiceManager getTextHeightFromContent:subTitle maxWidth:maxWdith font:subTitleFont];
    }
    
    return titleHeight + subTitleHeight + 2 * tbOffset;
}

///更新列表
- (void)updateTableList {
    [self.tbList reloadData];
    
    //配置电量
    NSMutableArray *yNames = [NSMutableArray arrayWithCapacity:0];
    [yNames addObject:@"0%"];
    [yNames addObject:@"20%"];
    [yNames addObject:@"40%"];
    [yNames addObject:@"60%"];
    [yNames addObject:@"80%"];
    [yNames addObject:@"100%"];
    NSMutableArray *xNames = [NSMutableArray arrayWithCapacity:0];
    
    self.batteryChart.lineView.yAxisLineNumbers = (int)yNames.count - 1;
    self.batteryChart.lbTitle.text = TS("TR_Setting_Power_Level");
    
    NSMutableArray *pointsPowerArr = [NSMutableArray arrayWithCapacity:0];
    if (self.segIndex == 0) {//一天的信息
        [xNames addObject:@"0"];
        [xNames addObject:@"4"];
        [xNames addObject:@"8"];
        [xNames addObject:@"12"];
        [xNames addObject:@"16"];
        [xNames addObject:@"20"];
        [xNames addObject:@"24"];
        self.batteryChart.lbRightTitleX.text = TS("sHour");
        for (int i = 0; i < self.arrayPowerOneDay.count; i++) {
            NSDictionary *dicInfo = [self.arrayPowerOneDay objectAtIndex:i];
            CGFloat xPoint = [[NSString stringWithFormat:@"%@",[dicInfo objectForKey:@"x_percent"]] floatValue] ;
            CGFloat yPoint = [[NSString stringWithFormat:@"%@",[dicInfo objectForKey:@"y_percent"]] floatValue] ;

            CGPoint point = CGPointMake(xPoint, yPoint);
            NSValue *value = [NSValue valueWithCGPoint:point];
            [pointsPowerArr addObject:value];
        }
    }else{//一周的信息
        //获取近7天时间
       [xNames addObjectsFromArray:[NSDate getPastSevenDays]];
        self.batteryChart.lbRightTitleX.text = TS("day");
        for (int i = 0; i < self.arrayPowerSevenDay.count; i++) {
            NSDictionary *dicInfo = [self.arrayPowerSevenDay objectAtIndex:i];
             
            CGFloat xPoint = [[NSString stringWithFormat:@"%@",[dicInfo objectForKey:@"x_percent"]] floatValue] ;
            CGFloat yPoint = [[NSString stringWithFormat:@"%@",[dicInfo objectForKey:@"y_percent"]] floatValue] ;

            CGPoint point = CGPointMake(xPoint, yPoint);
            NSValue *value = [NSValue valueWithCGPoint:point];
            [pointsPowerArr addObject:value];
        }
    }
    [self.batteryChart updateXYNames:xNames yNames:yNames];
//    self.batteryChart.lineView.points = [@[[NSValue valueWithCGPoint:CGPointMake(0, 0.6)],[NSValue valueWithCGPoint:CGPointMake(0.1, 0.3)],[NSValue valueWithCGPoint:CGPointMake(0.15, 0.5)],[NSValue valueWithCGPoint:CGPointMake(0.2, 0.0)],[NSValue valueWithCGPoint:CGPointMake(0.3, 0.2)],[NSValue valueWithCGPoint:CGPointMake(0.35, 0.6)],[NSValue valueWithCGPoint:CGPointMake(0.4, 0.6)],[NSValue valueWithCGPoint:CGPointMake(0.5, 0.7)],[NSValue valueWithCGPoint:CGPointMake(0.8, 0.1)],[NSValue valueWithCGPoint:CGPointMake(0.9, 0)],[NSValue valueWithCGPoint:CGPointMake(1, 0.5)]] mutableCopy];
    
    
    self.batteryChart.lineView.points = [pointsPowerArr  mutableCopy];
    [self.batteryChart.lineView updateLine];
    
    //配置信号
    NSMutableArray *yNames2 = [NSMutableArray arrayWithCapacity:0];
    [yNames2 addObject:@"0%"];
    [yNames2 addObject:@"20%"];
    [yNames2 addObject:@"40%"];
    [yNames2 addObject:@"60%"];
    [yNames2 addObject:@"80%"];
    [yNames2 addObject:@"100%"];
    NSMutableArray *xNames2 = [NSMutableArray arrayWithCapacity:0];
    
    self.signalChart.lineView.yAxisLineNumbers = (int)yNames2.count - 1;
    self.signalChart.lbTitle.text = TS("TR_Setting_Signal");
    
    NSMutableArray *pointsSignalArr = [NSMutableArray arrayWithCapacity:0];

    if (self.segIndex == 0) {//一天的信息
        [xNames2 addObject:@"0"];
        [xNames2 addObject:@"4"];
        [xNames2 addObject:@"8"];
        [xNames2 addObject:@"12"];
        [xNames2 addObject:@"16"];
        [xNames2 addObject:@"20"];
        [xNames2 addObject:@"24"];
        self.signalChart.lbRightTitleX.text = TS("sHour");
        
        for (int i = 0; i < self.arraySignalOneDay.count; i++) {
            NSDictionary *dicInfo = [self.arraySignalOneDay objectAtIndex:i];
            CGFloat xPoint = [[NSString stringWithFormat:@"%@",[dicInfo objectForKey:@"x_percent"]] floatValue] ;
            CGFloat yPoint = [[NSString stringWithFormat:@"%@",[dicInfo objectForKey:@"y_percent"]] floatValue] ;

            CGPoint point = CGPointMake(xPoint, yPoint);
            NSValue *value = [NSValue valueWithCGPoint:point];
            [pointsSignalArr addObject:value];
        }
        
        //预览时间和唤醒时间
        [self updatePreviewSeconds:self.previewSecondsOneDay wakeUpSeconds:self.wakeUpSecondsOneDay];
        //报警次数
        self.lbAlarmCount.text = [NSString stringWithFormat:@"%i",self.alarmNumberOneDay];
    }else{//一周的信息
        self.signalChart.lbRightTitleX.text = TS("day");
        //获取近7天时间
        [xNames2 addObjectsFromArray:[NSDate getPastSevenDays]];
        for (int i = 0; i < self.arraySignalSevenDay.count; i++) {
            NSDictionary *dicInfo = [self.arraySignalSevenDay objectAtIndex:i];
             
            CGFloat xPoint = [[NSString stringWithFormat:@"%@",[dicInfo objectForKey:@"x_percent"]] floatValue] ;
            CGFloat yPoint = [[NSString stringWithFormat:@"%@",[dicInfo objectForKey:@"y_percent"]] floatValue] ;

            CGPoint point = CGPointMake(xPoint, yPoint);
            NSValue *value = [NSValue valueWithCGPoint:point];
            [pointsSignalArr addObject:value];
        }
        
        //预览时间和唤醒时间
        [self updatePreviewSeconds:self.previewSecondsSevenDay wakeUpSeconds:self.wakeUpSecondsSevenDay];
        //报警次数
        self.lbAlarmCount.text = [NSString stringWithFormat:@"%i",self.alarmNumberSevenDay];
    }
    
    [self.signalChart updateXYNames:xNames2 yNames:yNames2];
    self.signalChart.lineView.points = [pointsSignalArr mutableCopy];
    self.signalChart.lineView.lineColor = GlobalMainColor;
    self.signalChart.lineView.gradientStartColor = JFColor(@"#3478F6");
    self.signalChart.lineView.gradientEndColor = JFColor(@"#3478F6");
    [self.signalChart.lineView updateLine];
}

- (void)updatePreviewSeconds:(int)previewSeconds wakeUpSeconds:(int)wakeUpSeconds {
    self.lbPreviewCount.text = [self timeDescriptionFromSeconds:previewSeconds];
    self.lbWakeUpCount.text = [self timeDescriptionFromSeconds:wakeUpSeconds];
    
    int minFontSize = 10;
    if (self.lbPreviewCount.size.width > 0) {
        int fitFontSize = 20;
        CGFloat textWith = [UIServiceManager getTextWidthFromContent:self.lbPreviewCount.text maxHeight:self.lbPreviewCount.size.height font:JFFontWeightAndSize(@"Semibold", 20)];
        if (textWith > self.lbPreviewCount.size.width) {
            for (int i = 19; i > minFontSize; i--) {
                textWith = [UIServiceManager getTextWidthFromContent:self.lbPreviewCount.text maxHeight:self.lbPreviewCount.size.height font:JFFontWeightAndSize(@"Semibold", i)];
                if (textWith <= self.lbPreviewCount.size.width) {
                    fitFontSize = i;
                    break;
                }
                fitFontSize = i;
            }
        }
        self.lbPreviewCount.font = JFFontWeightAndSize(@"Semibold", fitFontSize);
    }
    
    if (self.lbWakeUpCount.size.width > 0) {
        int fitFontSize = 20;
        CGFloat textWith = [UIServiceManager getTextWidthFromContent:self.lbWakeUpCount.text maxHeight:self.lbWakeUpCount.size.height font:JFFontWeightAndSize(@"Semibold", 20)];
        if (textWith > self.lbWakeUpCount.size.width) {
            for (int i = 19; i > minFontSize; i--) {
                textWith = [UIServiceManager getTextWidthFromContent:self.lbWakeUpCount.text maxHeight:self.lbWakeUpCount.size.height font:JFFontWeightAndSize(@"Semibold", i)];
                if (textWith <= self.lbWakeUpCount.size.width) {
                    fitFontSize = i;
                    break;
                }
                fitFontSize = i;
            }
        }
        self.lbWakeUpCount.font = JFFontWeightAndSize(@"Semibold", fitFontSize);
    }
}

- (NSString *)timeDescriptionFromSeconds:(int)seconds {
    if (seconds >= 86400) {
        return [NSString stringWithFormat:@"%.2f%@", seconds / 86400.0,seconds / 86400.0 == 1 ? TS("day") : ([TS("day") isEqualToString:@"Day"] ? @"Days" : TS("day"))];
    } else if (seconds >= 3600) {
        return [NSString stringWithFormat:@"%.2f%@", seconds / 3600.0,TS("sHour")];
    } else if (seconds >= 60) {
        return [NSString stringWithFormat:@"%.2f%@", seconds / 60.0,TS("sMin")];
    } else {
        return [NSString stringWithFormat:@"%i%@", seconds,seconds == 1 ? TS("sSec") : ([TS("sSec") isEqualToString:@"Second"] ? @"Seconds" : TS("sSec"))];
    }
}

//MARK: - JFSegmentDelegate
- (void)segmentSelectedIndexChanged:(int)index {
    self.segIndex = index;
    [self updateTableList];
}

//MARK: - Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderListItem *item = [self.dataSource objectAtIndex:indexPath.row];
    NSString *title = item.titleName;
    NSString *subTitle = item.subTitle;
    
    if (item.iMarker == 0) {
        JFLeftTitleRightImageTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:kJFLeftTitleRightImageTitleCell];
        cell.bottomLine.hidden = NO;
        cell.lbTitle.text = item.titleName;
        if ([item.titleName isEqualToString:TS("TR_Setting_Power_Supply_Mode")]) {//供电方式
            cell.lbRight.text = TS("TR_Setting_Battery");
            cell.curStyle = JFLeftTitleRightImageTitleCell_Default;
            [cell showImageView:NO size:CGSizeMake(0, 0) maxRightTitleWidth:0];
        }else if ([item.titleName isEqualToString:TS("TR_Setting_Current_Battery_Level")]) {//当前电量
            cell.lbRight.text = self.batteryLevel >= 0 ? [NSString stringWithFormat:@"%i%%",self.batteryLevel] : @"";
            if (self.batteryLevel >= 0) {
                NSString *titleRight = self.batteryLevel >= 0 ? [NSString stringWithFormat:@"%i%%",self.batteryLevel] : @"";
                CGFloat rightWidth = [UIServiceManager getTextWidthFromContent:titleRight maxHeight:50 font:[UIFont systemFontOfSize:cTableViewFilletSubTitleFont]];
                if (self.ifCharging) {
                    [cell showImageView:YES size:CGSizeMake(35, 17.5) maxRightTitleWidth:rightWidth];
                    cell.curStyle = JFLeftTitleRightImageTitleCell_Default;
                    cell.imgView.image = [UIImage imageNamed:@"ic_charging"];
                }else{
                    [cell showImageView:NO size:CGSizeMake(0, 0) maxRightTitleWidth:0];
                    cell.curStyle = JFLeftTitleRightImageTitleCell_Default;
                }
            }else{
                [cell showImageView:NO size:CGSizeMake(0, 0) maxRightTitleWidth:0];
                cell.curStyle = JFLeftTitleRightImageTitleCell_Default;
            }
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }else {
        if (self.lowBatteryLevel >= 0) {
            title = [NSString stringWithFormat:@"%@(%i%%)",TS("TR_Setting_Low_Power_Mode"),self.lowBatteryLevel];
        }
        JFTopTitleBottomSliderCell *cell = [tableView dequeueReusableCellWithIdentifier:kJFTopTitleBottomSliderCell];
        self.lastSliderCell = cell;
        cell.lbTitle.text = title;
        cell.lbSubTitle.text = subTitle;
        [cell resetSubViewsWithContentWidth:SCREEN_WIDTH - 2 * cTableViewFilletLFBorder - 2 * cTableViewFilletContentLRBorder];
        cell.slider.maxValue = self.lowElectrMax;
        cell.slider.minValue = self.lowElectrMin;
        cell.slider.currentValue = self.lowBatteryLevel;
        cell.slider.bubbleUnit = @"%";
        cell.slider.lblLeft.text = [NSString stringWithFormat:@"%i%%",self.lowElectrMin];
        cell.slider.lblRight.text = [NSString stringWithFormat:@"%i%%",self.lowElectrMax];
        WeakSelf(weakSelf);
        cell.slider.valueChangedBlock = ^(CGFloat value) {
            weakSelf.lowBatteryLevel = (int)value;
            weakSelf.lastSliderCell.lbTitle.text = [NSString stringWithFormat:@"%@(%i%%)",TS("TR_Setting_Low_Power_Mode"),weakSelf.lowBatteryLevel];
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(userChangeLowBatteryLevel:)]) {
                [weakSelf.delegate userChangeLowBatteryLevel:weakSelf.lowBatteryLevel];
            }
        };
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderListItem *item = [self.dataSource objectAtIndex:indexPath.row];
    NSString *title = item.titleName;
    NSString *titleRight = @"";
    NSString *subTitle = item.subTitle;
    if (item.iMarker == 0) {
        CGFloat imageWidth = 0;
        CGFloat rightWidth = 0;
        CGFloat height = 0;
        if ([item.titleName isEqualToString:TS("TR_Setting_Power_Supply_Mode")]) {//供电方式
            titleRight = TS("TR_Setting_Battery");
            rightWidth = [UIServiceManager getTextWidthFromContent:titleRight maxHeight:50 font:[UIFont systemFontOfSize:cTableViewFilletSubTitleFont]];
            height = [self cellHeightWithTitle:title titleFont:JFFont(cTableViewFilletTitleFont) subTitle:subTitle subTitleFont:JFFont(cTableViewFilletSubTitleFont) maxWidht:SCREEN_WIDTH - 15 * 2 - rightWidth - imageWidth tbOffset:cTableViewFilletContentLRBorder];
        }else if ([item.titleName isEqualToString:TS("TR_Setting_Current_Battery_Level")]) {//当前电量
            titleRight = self.batteryLevel >= 0 ? [NSString stringWithFormat:@"%i%%",self.batteryLevel] : @"";
            rightWidth = [UIServiceManager getTextWidthFromContent:titleRight maxHeight:50 font:[UIFont systemFontOfSize:cTableViewFilletSubTitleFont]];
            imageWidth = self.ifCharging ? 40 : 0;
            height = [self cellHeightWithTitle:title titleFont:JFFont(cTableViewFilletTitleFont) subTitle:subTitle subTitleFont:JFFont(cTableViewFilletSubTitleFont) maxWidht:SCREEN_WIDTH - 15 * 2 - rightWidth - imageWidth tbOffset:cTableViewFilletContentLRBorder];
        }
         
        return height < 50 ? 50 : height;
    }else {
        if (self.lowBatteryLevel >= 0) {
            title = [NSString stringWithFormat:@"%@(%i%%)",TS("TR_Setting_Low_Power_Mode"),self.lowBatteryLevel];
        }
        CGFloat height = [self cellHeightWithTitle:title titleFont:JFFont(cTableViewFilletTitleFont) subTitle:subTitle subTitleFont:JFFont(cTableViewFilletSubTitleFont) maxWidht:SCREEN_WIDTH - cTableViewFilletLFBorder * 2  tbOffset:cTableViewFilletContentLRBorder];
        height = height + 2 + 11 + 65 - cTableViewFilletLFBorder;
        
        return height;
    }
    
    return 50;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    OrderListItem *item = [self.dataSource objectAtIndex:indexPath.row];
}

//MARK: 更新电池统计footer内容和高度
- (void)updateTableFooter {
    
}

//MARK: - LazyLoad
- (UITableView *)tbList {
    if (!_tbList) {
        _tbList = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        [_tbList registerClass:[JFLeftTitleRightImageTitleCell class] forCellReuseIdentifier:kJFLeftTitleRightImageTitleCell];
        [_tbList registerClass:[JFTopTitleBottomSliderCell class] forCellReuseIdentifier:kJFTopTitleBottomSliderCell];
        _tbList.dataSource = self;
        _tbList.delegate = self;
        _tbList.showsVerticalScrollIndicator = NO;
        _tbList.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tbList.sectionHeaderHeight = 0;
        _tbList.sectionFooterHeight = 0;
        _tbList.tableFooterView = self.batteryInfoFooter;
    }
    
    return _tbList;
}

- (NSMutableArray *)cfgOrderList {
    if (!_cfgOrderList) {
        /*
         */
        _cfgOrderList = [NSMutableArray arrayWithCapacity:0];
        //供电方式
        OrderListItem *itemPowerSupplyMode = [[OrderListItem alloc] init];
        itemPowerSupplyMode.titleName = TS("TR_Setting_Power_Supply_Mode");
        itemPowerSupplyMode.hidden = NO;
        itemPowerSupplyMode.iMarker = 0;
        [_cfgOrderList addObject:itemPowerSupplyMode];
        //当前电量
        OrderListItem *itemCurrentBatteryLevel = [[OrderListItem alloc] init];
        itemCurrentBatteryLevel.titleName = TS("TR_Setting_Current_Battery_Level");
        itemCurrentBatteryLevel.hidden = NO;
        itemCurrentBatteryLevel.iMarker = 0;
        [_cfgOrderList addObject:itemCurrentBatteryLevel];
        //低电量模式
        OrderListItem *itemCustom = [[OrderListItem alloc] init];
        itemCustom.titleName = TS("TR_Setting_Low_Power_Mode");
        itemCustom.subTitle = TS("TR_Setting_Low_Power_Mode_Description");
        itemCustom.hidden = YES;
        itemCustom.iMarker = 1;
        [_cfgOrderList addObject:itemCustom];
    }
    
    return _cfgOrderList;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:0];
        [self updateConfigListVisiable:NO cfgNames:@[]];
    }
    
    return _dataSource;
}

- (UIView *)batteryInfoFooter {
    if (!_batteryInfoFooter) {
        CGFloat titleTopLeftTopOffset = 20;//标题顶部边距
        CGFloat titleTopLeftHeight = 20;//标题高度
        CGFloat whiteBGTopOffset = 10;//白色背景顶部距离标题底部边距
        CGFloat segmentTopOffset = 15;//选择框距离白色背景顶部边距
        CGFloat segmentHeight = 30;//选择框高度
        CGFloat chartViewTopOffset = 20;//图表距离顶部边距
        CGFloat chartHeight = (SCREEN_WIDTH - 2 * cTableViewFilletLFBorder) * 0.618;//图表高度
        CGFloat previewAcountViewTopOffset = 15;//预览时间图表距离顶部边距
        CGFloat previewAccountViewHeight = 80;//预览时间图表高度
        CGFloat alarmCountViewTopOffset = 15;//图表距离白色背景顶部边距
        CGFloat alarmCountViewHeight = 80;//报警数量展示view高度
        // 白色背景view高度
        CGFloat whiteBGHeight = segmentTopOffset + segmentHeight + chartViewTopOffset * 2 + chartHeight * 2 + previewAcountViewTopOffset + previewAccountViewHeight + alarmCountViewTopOffset + alarmCountViewHeight + segmentTopOffset;
        _batteryInfoFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 2 * cTableViewFilletLFBorder, titleTopLeftTopOffset + titleTopLeftHeight + whiteBGTopOffset + whiteBGHeight)];
        _batteryInfoFooter.backgroundColor = UIColor.clearColor;
        
        self.lbTitle = [[UILabel alloc] init];
        self.lbTitle.text = TS("TR_Setting_Battery_Statistic");
        self.lbTitle.font = JFFont(13);
        self.lbTitle.textColor = JFColor(@"#777777");
        self.lbTitle.numberOfLines = 1;
        [_batteryInfoFooter addSubview:self.lbTitle];
        [self.lbTitle mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_batteryInfoFooter).mas_offset(12.5);
            make.height.mas_equalTo(titleTopLeftHeight);
            make.right.equalTo(_batteryInfoFooter);
            make.top.mas_equalTo(titleTopLeftTopOffset);
        }];
        
        self.whiteBG = [[UIView alloc] init];
        self.whiteBG.backgroundColor = UIColor.whiteColor;
        self.whiteBG.layer.cornerRadius = 10;
        self.whiteBG.layer.masksToBounds = YES;
        [_batteryInfoFooter addSubview:self.whiteBG];
        [self.whiteBG mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_batteryInfoFooter);
            make.right.equalTo(_batteryInfoFooter);
            make.top.equalTo(self.lbTitle.mas_bottom).mas_offset(10);
            make.height.mas_equalTo(whiteBGHeight);
        }];
        
        NSArray *segmentedArray = [NSArray arrayWithObjects:TS("TR_Today"),TS("TR_Setting_Last_Week"),nil];
        self.segmentedControl = [[JFSegment alloc] initWithItemNames:segmentedArray frame:CGRectMake(0, 0, SCREEN_WIDTH - 30 - 30, 44)];
        self.segmentedControl.delegate = self;
        [self.whiteBG addSubview:self.segmentedControl];
        [self.segmentedControl mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.whiteBG).mas_offset(15);
            make.right.equalTo(self.whiteBG).mas_offset(-15);
            make.top.equalTo(self.whiteBG).mas_offset(segmentTopOffset);
            make.height.mas_equalTo(segmentHeight);
        }];
        
        [self.whiteBG addSubview:self.batteryChart];
        [self.batteryChart mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_batteryInfoFooter);
            make.right.equalTo(_batteryInfoFooter);
            make.top.equalTo(self.segmentedControl.mas_bottom).mas_offset(chartViewTopOffset);
            make.height.mas_equalTo(chartHeight);
        }];
        [self.whiteBG addSubview:self.signalChart];
        [self.signalChart mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_batteryInfoFooter);
            make.right.equalTo(_batteryInfoFooter);
            make.top.equalTo(self.batteryChart.mas_bottom).mas_offset(chartViewTopOffset);
            make.height.mas_equalTo(chartHeight);
        }];
        
        [self.whiteBG addSubview:self.previewCountView];
        [self.previewCountView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_batteryInfoFooter).mas_offset(15);;
            make.right.equalTo(_batteryInfoFooter).mas_offset(-15);
            make.top.equalTo(self.signalChart.mas_bottom).mas_offset(alarmCountViewTopOffset);
            make.height.mas_equalTo(previewAccountViewHeight);
        }];
        
        [self.whiteBG addSubview:self.wakeUpCountView];
        [self.wakeUpCountView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_batteryInfoFooter).mas_offset(15);;
            make.right.equalTo(_batteryInfoFooter).mas_offset(-15);
            make.top.equalTo(self.previewCountView.mas_bottom).mas_offset(alarmCountViewTopOffset);
            make.height.mas_equalTo(previewAccountViewHeight);
        }];
        
        [self.whiteBG addSubview:self.alarmCountView];
        [self.alarmCountView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_batteryInfoFooter).mas_offset(15);;
            make.right.equalTo(_batteryInfoFooter).mas_offset(-15);
            make.top.equalTo(self.previewCountView.mas_bottom).mas_offset(alarmCountViewTopOffset);
            make.height.mas_equalTo(alarmCountViewHeight);
        }];
    }
    
    return _batteryInfoFooter;
}

- (JFLineChartView *)batteryChart {
    if (!_batteryChart) {
        _batteryChart = [[JFLineChartView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 2 * cTableViewFilletLFBorder, (SCREEN_WIDTH - 2 * cTableViewFilletLFBorder) * 0.618)];
    }
    
    return _batteryChart;
}

- (JFLineChartView *)signalChart {
    if (!_signalChart) {
        _signalChart = [[JFLineChartView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 2 * cTableViewFilletLFBorder, (SCREEN_WIDTH - 2 * cTableViewFilletLFBorder) * 0.618)];
    }
    
    return _signalChart;
}

- (UIView *)previewCountView {
    if (!_previewCountView) {
        _previewCountView = [[UIView alloc] init];
        _previewCountView.backgroundColor = JFColor(@"#E4EAFC");
        _previewCountView.layer.cornerRadius = 10;
        _previewCountView.layer.masksToBounds = YES;
        
        UIImageView *imageRight = [[UIImageView alloc] init];
        UIImage *img = [UIImage imageNamed:@"battery_icon_preview"];
        imageRight.image = img;
        [_previewCountView addSubview:imageRight];
        [imageRight mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_previewCountView);
            make.top.equalTo(_previewCountView);
            make.bottom.equalTo(_previewCountView);
            make.width.equalTo(_previewCountView.mas_height).multipliedBy(0.68);
        }];
        
        //文字可用宽度
        CGFloat titleWidthAvailable = SCREEN_WIDTH - 2 * cTableViewFilletLFBorder - 4 * 15;
        CGSize size = CGSizeMake(MAXFLOAT, 30);
        CGRect rect = [TS("TR_Setting_Preview_Time") boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:JFFont(15)} context:nil];
        BOOL needSmallFont = NO;
        if (rect.size.width > titleWidthAvailable) {
            needSmallFont = YES;
        }
        UILabel *lbTitle = [[UILabel alloc] init];
        lbTitle.font = JFFont(needSmallFont ? 12 : 15);
        lbTitle.textColor = JFColor(@"#444E89");
        lbTitle.text = TS("TR_Setting_Preview_Time");
        lbTitle.numberOfLines = 2;
        [_previewCountView addSubview:lbTitle];
        [lbTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_previewCountView).mas_offset(15);
            make.top.equalTo(_previewCountView.mas_top).mas_offset(5);
            make.right.equalTo(_previewCountView).mas_offset(-15);
            make.height.equalTo(@34.5);
        }];
        
        [_previewCountView addSubview:self.lbPreviewCount];
        [self.lbPreviewCount mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_previewCountView).mas_offset(15);
            make.top.equalTo(lbTitle.mas_bottom).mas_offset(needSmallFont ? 5 : 0);
            make.right.equalTo(_previewCountView).mas_offset(-15);
            make.height.equalTo(@28);
        }];
    }
    
    return _previewCountView;
}

- (UILabel *)lbPreviewCount {
    if (!_lbPreviewCount) {
        _lbPreviewCount = [[UILabel alloc] init];
        _lbPreviewCount.font = JFFontWeightAndSize(@"Semibold", 20);
        _lbPreviewCount.textColor = JFColor(@"#444E89");
        _lbPreviewCount.text = @"0";
    }
    
    return _lbPreviewCount;
}

- (UIView *)wakeUpCountView {
    if (!_wakeUpCountView) {
        _wakeUpCountView = [[UIView alloc] init];
        _wakeUpCountView.backgroundColor = JFColor(@"#E3F2FD");
        _wakeUpCountView.layer.cornerRadius = 10;
        _wakeUpCountView.layer.masksToBounds = YES;
        
        UIImageView *imageRight = [[UIImageView alloc] init];
        UIImage *img = [UIImage imageNamed:@"battery_icon_awaken"];
        imageRight.image = img;
        [_wakeUpCountView addSubview:imageRight];
        [imageRight mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_wakeUpCountView);
            make.top.equalTo(_wakeUpCountView);
            make.bottom.equalTo(_wakeUpCountView);
            make.width.equalTo(_wakeUpCountView.mas_height).multipliedBy(0.68);
        }];
        
        //文字可用宽度
        CGFloat titleWidthAvailable = SCREEN_WIDTH - 2 * cTableViewFilletLFBorder - 4 * 15;
        CGSize size = CGSizeMake(MAXFLOAT, 30);
        CGRect rect = [TS("TR_Setting_Wake_Up_Time") boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:JFFont(15)} context:nil];
        BOOL needSmallFont = NO;
        if (rect.size.width > titleWidthAvailable) {
            needSmallFont = YES;
        }
        UILabel *lbTitle = [[UILabel alloc] init];
        lbTitle.font = JFFont(needSmallFont ? 12 : 15);
        lbTitle.textColor = JFColor(@"#2D454D");
        lbTitle.text = TS("TR_Setting_Wake_Up_Time");
        lbTitle.numberOfLines = 2;
        [_wakeUpCountView addSubview:lbTitle];
        [lbTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_wakeUpCountView).mas_offset(15);
            make.top.equalTo(_wakeUpCountView.mas_top).mas_offset(5);
            make.right.equalTo(_wakeUpCountView).mas_offset(-15);
            make.height.equalTo(@34.5);
        }];
        
        [_wakeUpCountView addSubview:self.lbWakeUpCount];
        [self.lbWakeUpCount mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_wakeUpCountView).mas_offset(15);
            make.top.equalTo(lbTitle.mas_bottom).mas_offset(needSmallFont ? 5 : 0);
            make.right.equalTo(_wakeUpCountView).mas_offset(-15);
            make.height.equalTo(@28);
        }];
    }
    
    return _wakeUpCountView;
}

- (UILabel *)lbWakeUpCount {
    if (!_lbWakeUpCount) {
        _lbWakeUpCount = [[UILabel alloc] init];
        _lbWakeUpCount.font = JFFontWeightAndSize(@"Semibold", 20);
        _lbWakeUpCount.textColor = JFColor(@"#2D454D");
        _lbWakeUpCount.text = @"0";
    }
    
    return _lbWakeUpCount;
}

- (UIView *)alarmCountView {
    if (!_alarmCountView) {
        _alarmCountView = [[UIView alloc] init];
        _alarmCountView.backgroundColor = JFColor(@"#FBEAE4");
        _alarmCountView.layer.cornerRadius = 10;
        _alarmCountView.layer.masksToBounds = YES;
        
        UIImageView *imageRight = [[UIImageView alloc] init];
        UIImage *img = [UIImage imageNamed:@"battery_icon_alarm"];
        imageRight.image = img;
        [_alarmCountView addSubview:imageRight];
        [imageRight mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_alarmCountView);
            make.top.equalTo(_alarmCountView);
            make.bottom.equalTo(_alarmCountView);
            make.width.equalTo(_alarmCountView.mas_height).multipliedBy(0.68);
        }];
        
        UILabel *lbTitle = [[UILabel alloc] init];
        lbTitle.font = JFFont(15);
        lbTitle.textColor = JFColor(@"#6B4D3E");
        lbTitle.text = TS("TR_Setting_Number_Of_Alarms");
        [_alarmCountView addSubview:lbTitle];
        [lbTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_alarmCountView).mas_offset(15);
            make.top.equalTo(_alarmCountView.mas_top).mas_offset(13);
            make.right.equalTo(imageRight.mas_left);
            make.height.equalTo(@18.5);
        }];
        
        [_alarmCountView addSubview:self.lbAlarmCount];
        [self.lbAlarmCount mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_alarmCountView).mas_offset(15);
            make.top.equalTo(lbTitle.mas_bottom).mas_offset(8);
            make.right.equalTo(imageRight.mas_left);
            make.height.equalTo(@28);
        }];
    }
    
    return _alarmCountView;
}

- (UILabel *)lbAlarmCount {
    if (!_lbAlarmCount) {
        _lbAlarmCount = [[UILabel alloc] init];
        _lbAlarmCount.font = JFFontWeightAndSize(@"Semibold", 20);
        _lbAlarmCount.textColor = JFColor(@"#6B4D3E");
        _lbAlarmCount.text = @"0";
    }
    
    return _lbAlarmCount;
}

- (NSMutableDictionary *)dicInfoAbility {
    if (!_dicInfoAbility) {
        _dicInfoAbility = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    
    return _dicInfoAbility;
}

@end
