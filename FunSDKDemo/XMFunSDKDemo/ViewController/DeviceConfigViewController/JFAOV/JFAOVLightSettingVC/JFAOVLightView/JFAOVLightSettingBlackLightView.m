//
//  JFAOVLightSettingBlackLightView.m
//   iCSee
//
//  Created by kevin on 2024/4/24.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import "JFAOVLightSettingBlackLightView.h"
#import "OrderListItem.h"
#import "MyDatePickerView.h"
#import "JFLeftTitleRightButtonCell.h"
#import "TitleSwitchCell.h"
#import "JFLeftTitleCell.h"
#import "JFBottomSliderCell.h"
#import "EmptyTableViewCell.h"
#import "JFNewAlarmSliderValueCell.h"

#import "AppDelegate.h"
static NSString *const kTitleSwitchCell = @"TitleSwitchCell";
static NSString *const kJFLeftTitleRightButtonCell = @"kJFLeftTitleRightButtonCell";
static NSString *const kJFLeftTitleCell = @"kJFLeftTitleCell";
static NSString *const kJFBottomSliderCell = @"kJFBottomSliderCell";
static NSString *const kEmptyTableViewCell = @"kEmptyTableViewCell";
static NSString *const kJFNewAlarmSliderValueCell = @"kJFNewAlarmSliderValueCell";
@interface JFAOVLightSettingBlackLightView ()<UITableViewDelegate,UITableViewDataSource,MyDatePickerViewDelegate>

@property (nonatomic, strong) UITableView *tbList;
// 配置顺序列表 修改顺序或者分组 增加项目 都要先在这里确定配置位置
@property (nonatomic,strong) NSMutableArray *cfgOrderList;
// 配置列表数据源
@property (nonatomic,strong) NSMutableArray *dataSource;
// 时间选择器
@property (nonatomic,strong) MyDatePickerView *pickerView;

@end
@implementation JFAOVLightSettingBlackLightView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.tbList];
        [self.tbList mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).mas_offset(cTableViewFilletLFBorder);
            make.right.equalTo(self).mas_offset(-cTableViewFilletLFBorder);
            make.top.equalTo(self);
            make.bottom.equalTo(self);
        }];
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGRAction:)];
        tapGR.numberOfTapsRequired = 10;
        tapGR.delegate = self;
        [self.tbList addGestureRecognizer:tapGR];
    }
    
    return self;
}

- (void)configData {
    
    NSString *workMode = [self.whiteLightManager getWordMode];
    if ([workMode isEqualToString:@"Close"]){
        //灯光开光 关闭
        [self lightSwitchIsOn:NO];
    } else{
        [self lightSwitchIsOn:YES];
        [self configWorkMode:workMode];
    }
    [self.tbList reloadData];
}

- (void)lightSwitchIsOn:(BOOL)isOn {
    if (isOn) {
        if (self.supportSetBrightness) {
            [self updateTableViewItem:TS("TR_Adjustment_Of_Brightness") hidden:NO];
        } else {
            [self updateTableViewItem:TS("TR_Adjustment_Of_Brightness") hidden:YES];
        }
        
    } else {
        //灯光开关关闭
        [self updateTableViewItem:TS("TR_Adjustment_Of_Brightness") hidden:YES];
        [self updateTableViewItem:TS("TR_AutoLight") hidden:YES];
        [self updateTableViewItem:TS("Intelligent_sensitivity") hidden:YES];
        [self updateTableViewItem:TS("TR_TimingLight") hidden:YES];
        [self updateTableViewItem:TS("start_time") hidden:YES];
        [self updateTableViewItem:TS("end_time") hidden:YES];
        [self updateTableViewItem:TS("TR_ConstantLight") hidden:YES];
    }
}
 
- (void)configWorkMode:(NSString *)workMode {
    if ([workMode isEqualToString:@"Auto"]) {
        [self updateTableViewItem:TS("TR_AutoLight") hidden:NO];
        if (self.SoftLedThr) {
            [self updateTableViewItem:TS("Intelligent_sensitivity") hidden:NO];
        } else {
            [self updateTableViewItem:TS("Intelligent_sensitivity") hidden:YES];
        }
        
        [self updateTableViewItem:TS("TR_TimingLight") hidden:NO];
        [self updateTableViewItem:TS("start_time") hidden:YES];
        [self updateTableViewItem:TS("end_time") hidden:YES];
//        [self updateTableViewItem:TS("TR_ConstantLight") hidden:YES];
    } else if ([workMode isEqualToString:@"KeepOpen"]) {
        [self updateTableViewItem:TS("TR_AutoLight") hidden:NO];
        [self updateTableViewItem:TS("Intelligent_sensitivity") hidden:YES];
        [self updateTableViewItem:TS("TR_TimingLight") hidden:NO];
        [self updateTableViewItem:TS("start_time") hidden:YES];
        [self updateTableViewItem:TS("end_time") hidden:YES];
//        [self updateTableViewItem:TS("TR_ConstantLight") hidden:YES];
    } else if ([workMode isEqualToString:@"Timing"]){
        [self updateTableViewItem:TS("TR_AutoLight") hidden:NO];
        [self updateTableViewItem:TS("Intelligent_sensitivity") hidden:YES];
        [self updateTableViewItem:TS("TR_TimingLight") hidden:NO];
        [self updateTableViewItem:TS("start_time") hidden:NO];
        [self updateTableViewItem:TS("end_time") hidden:NO];
//        [self updateTableViewItem:TS("TR_ConstantLight") hidden:YES];
    }
}
- (void)tapGRAction:(UITapGestureRecognizer *)tapGR{
    [self updateTableViewItem:TS("TR_ConstantLight") hidden:NO];
    
    [self.tbList reloadData];
}
- (void)setNeedShowStatusLed:(BOOL)needShowStatusLed{
    _needShowStatusLed = needShowStatusLed;
    if (needShowStatusLed) {
        [self updateTableViewItem:TS("TR_Setting_Device_Indicator_Light") hidden:NO];
    }else{
        [self updateTableViewItem:TS("TR_Setting_Device_Indicator_Light") hidden:YES];
    }
}

- (void)setSupportMicroFillLight:(BOOL)supportMicroFillLight{
    _supportMicroFillLight = supportMicroFillLight;
    if (supportMicroFillLight) {
        [self updateTableViewItem:TS("TR_Low_Light_Control") hidden:NO];
    }else{
        [self updateTableViewItem:TS("TR_Low_Light_Control") hidden:YES];
    }
}

/// 增减配置项
- (void)updateTableViewItem:(NSString *)title hidden:(BOOL)hidden{
    [self.dataSource removeAllObjects];
    for (int s = 0; s < self.cfgOrderList.count; s++) {
        NSMutableArray *section = [NSMutableArray arrayWithCapacity:0];
        NSArray <OrderListItem *>*arrayItems = [self.cfgOrderList objectAtIndex:s];
        for (int r = 0; r < arrayItems.count; r++) {
            OrderListItem *item = [arrayItems objectAtIndex:r];
            if ([item.titleName isEqualToString:title]) {
                item.hidden = hidden;
            }
            if (!item.hidden) {
                [section addObject:item];
            }
        }
        
        if (section.count > 0) {
            [self.dataSource addObject:section];
        }
    }
    
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

/// 更新列表
- (void)updateList{
    [self.tbList reloadData];
}

//MARK: 更新数据源
- (void)updateDataSourceUIRefresh:(BOOL)refresh{
    NSMutableArray *dataSource = [NSMutableArray arrayWithCapacity:0];
    for (int s = 0; s < self.cfgOrderList.count; s++) {
        NSMutableArray *section = [NSMutableArray arrayWithCapacity:0];
        NSArray <OrderListItem *>*arrayItems = [self.cfgOrderList objectAtIndex:s];
        for (int r = 0; r < arrayItems.count; r++) {
            OrderListItem *item = [arrayItems objectAtIndex:r];
            if (!item.hidden){
                [section addObject:item];
            }
        }
        [dataSource addObject:section];
    }
    
    self.dataSource = [dataSource mutableCopy];
    if (refresh){
        [self.tbList reloadData];
    }
}

//MARK: - Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSource.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSMutableArray * sectionData = [self.dataSource objectAtIndex:section];
    return sectionData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSMutableArray * sectionData = [self.dataSource objectAtIndex:indexPath.section];
    OrderListItem *item = [sectionData objectAtIndex:indexPath.row];
    __weak typeof(self) weakSelf = self;
    if ([item.titleName isEqualToString:TS("TR_White_Light_Switch")]) {
        //灯光开关
        TitleSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleSwitchCell];
        cell.titleLeftBorder = 0;
        [cell enterFilletMode];
        cell.titleLabel.text = item.titleName;
        cell.lbDetail.text = @"";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSString *workMode = [self.whiteLightManager getWordMode];
        if ([workMode isEqualToString:@"Close"]){
            cell.toggleSwitch.on = NO;
        } else {
            cell.toggleSwitch.on = YES;
        }
        cell.toggleSwitchStateChangedAction = ^(BOOL on) {
            if (on) {
                [weakSelf.whiteLightManager setWorkMode:@"Auto"];
            } else {
                [weakSelf.whiteLightManager setWorkMode:@"Close"];

            }
            
            if (weakSelf.saveBlock) {
                weakSelf.saveBlock();
            }
             
        };
        
        return cell;
    }else if ([item.titleName isEqualToString:TS("TR_Adjustment_Of_Brightness")]){
        //亮度调整
        JFNewAlarmSliderValueCell *cell = [tableView dequeueReusableCellWithIdentifier:kJFNewAlarmSliderValueCell];
        [cell enterFilletMode];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.minValue = 1;
        cell.maxValue = 100;
        cell.strLeftValue = @"1%";
        cell.strRightValue = @"100%";
        cell.valueSlider.bubbleUnit = @"%";
        int Brightness = [self.whiteLightManager getBrightness];
        cell.titleLabel.text = [NSString stringWithFormat:@"%@ (%i%%)",TS("Bright"),Brightness];
        cell.currentValue =Brightness;
        [cell updateSliderValue];
        //滑杆滑动的位置回调
        [cell setValueChangedBlock:^(CGFloat value) {
            [weakSelf.whiteLightManager setBrightness:value];
            if (weakSelf.saveBlock) {
                weakSelf.saveBlock();
            }
             
        }];
         
        return cell;
    }else if ([item.titleName isEqualToString:TS("TR_AutoLight")]){
        //自动灯光
        JFLeftTitleRightButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:kJFLeftTitleRightButtonCell];
        cell.style = JFLeftTitleRightButtonCellStyle_SubTitle;
        cell.lbTitle.text = item.titleName;
//        cell.lbSubTitle.text = item.subTitle;
        NSString *workMode = [self.whiteLightManager getWordMode];
        if ([workMode isEqualToString:@"Auto"]){
            cell.btnRight.selected = YES;
        }else{
            cell.btnRight.selected = NO;
        }

        return cell;
        
        
        
    }else if ([item.titleName isEqualToString:TS("Intelligent_sensitivity")]){
        //灵敏度调整
        JFBottomSliderCell *cell = [tableView dequeueReusableCellWithIdentifier:kJFBottomSliderCell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell resetSubViewsWithContentWidth:SCREEN_WIDTH - 30 titleLeftBorder:30 titleRightBorder:15];
        cell.slider.lblLeft.text = TS("TR_PIR_lowest");
        cell.slider.lblRight.text =  TS("TR_PIR_Hightext");
        NSArray *arrayValue = @[@1,@2,@3,@4,@5];
        NSMutableArray *arrayName = [NSMutableArray arrayWithCapacity:0];
        [arrayName addObject:TS("TR_PIR_lowest")];
        [arrayName addObject:TS("TR_PIR_Lower")];
        [arrayName addObject:TS("TR_PIR_Medium")];
        [arrayName addObject:TS("TR_PIR_Higher")];
        [arrayName addObject:TS("TR_PIR_Hightext")];
        cell.slider.arraySegmentValue = arrayValue;
        cell.slider.arraySegmentName = arrayName;
        
        int TrigLightLevel = [self.cameraParamExManager getSoftLedThr];
        NSString *levelStr = @"";
        switch (TrigLightLevel) {
            case 1:
                levelStr = TS("TR_PIR_lowest");
                break;
            case 2:
                levelStr = TS("TR_PIR_Lower");
                break;
            case 3:
                levelStr = TS("TR_PIR_Medium");
                break;
            case 4:
                levelStr = TS("TR_PIR_Higher");
                break;
            case 5:
                levelStr = TS("TR_PIR_Hightext");
                break;
            default:
                break;
        }
        cell.slider.realValue = TrigLightLevel;
        cell.slider.style = JFSliderStyle_Segmentation;
        [cell.slider updateSliderValue];
        
        [cell updateLeftTitle:[NSString stringWithFormat:@"%@ (%@)",TS("Intelligent_sensitivity"),levelStr]];
        
        WeakSelf(weakSelf);
        cell.slider.valueChangedBlock = ^(CGFloat value) {
            [weakSelf.cameraParamExManager setSoftLedThr:value];
            [weakSelf.tbList reloadData];
            if (weakSelf.saveBlock) {
                weakSelf.saveBlock();
            }
        };
        //控制是否显示下划线
        cell.underLine.hidden = NO;
         
        
        return cell;
        
    }else if ([item.titleName isEqualToString:TS("TR_TimingLight")]){
        //定时
        JFLeftTitleRightButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:kJFLeftTitleRightButtonCell];
        cell.style = JFLeftTitleRightButtonCellStyle_SubTitle;
        cell.lbTitle.text = item.titleName;
        //cell.lbSubTitle.text = item.subTitle;
        NSString *workMode = [self.whiteLightManager getWordMode];
        if ([workMode isEqualToString:@"Timing"]){
            cell.btnRight.selected = YES;
        }else{
            cell.btnRight.selected = NO;
        }
//        //控制是否显示下划线
//        cell.underLine.hidden = NO;
//        if (indexPath.row == self.dataSource.count -1) {
//            cell.underLine.hidden = YES;
//        }
        
        return cell;
        
        
        
    } else if ([item.titleName isEqualToString:TS("start_time")]){
        //开始时间
        JFLeftTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:kJFLeftTitleCell];
        cell.leftOffset = 15;
        NSString *startTime = [self.whiteLightManager getLightOpenTime];

        cell.lbTitle.text = [NSString stringWithFormat:@"%@: %@",item.titleName,startTime.length >= 8 ? [startTime substringWithRange:NSMakeRange(0, 5)] :startTime];
         
//        //控制是否显示下划线
//        cell.underLine.hidden = NO;
//        if (indexPath.row == self.dataSource.count -1) {
//            cell.underLine.hidden = YES;
//        }
//        
        return cell;
        
        
        
    } else if ([item.titleName isEqualToString:TS("end_time")]){
        //结束时间
        JFLeftTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:kJFLeftTitleCell];
        cell.leftOffset = 15;
        NSString *endTime = [self.whiteLightManager getLightCloseTime];

        cell.lbTitle.text = [NSString stringWithFormat:@"%@: %@",item.titleName,endTime.length >= 8 ? [endTime substringWithRange:NSMakeRange(0, 5)] : endTime];
        
//        //控制是否显示下划线
//        cell.underLine.hidden = NO;
//        if (indexPath.row == self.dataSource.count -1) {
//            cell.underLine.hidden = YES;
//        }
        
        return cell;
        
        
        
    }else if ([item.titleName isEqualToString:TS("TR_ConstantLight")]){
        //常亮灯光
        JFLeftTitleRightButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:kJFLeftTitleRightButtonCell];
        cell.style = JFLeftTitleRightButtonCellStyle_SubTitle;
        cell.lbTitle.text = item.titleName;
        cell.lbSubTitle.text = item.subTitle;
        NSString *workMode = [self.whiteLightManager getWordMode];
        if ([workMode isEqualToString:@"KeepOpen"]){
            cell.btnRight.selected = YES;
        }else{
            cell.btnRight.selected = NO;
        }
//        //控制是否显示下划线
//        cell.underLine.hidden = NO;
//        if (indexPath.row == self.dataSource.count -1) {
//            cell.underLine.hidden = YES;
//        }
        
        return cell;
    }else if ([item.titleName isEqualToString:TS("TR_Setting_Device_Indicator_Light")]){//AOV设备指示灯 使用特定cell
        TitleSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleSwitchCell];
        cell.titleLabel.text = item.titleName;
        cell.toggleSwitch.on = self.fbExtraStateCtrlManager.iStatueLed > 0 ? YES : NO;
        cell.bottomLineLeftBorder = 0;
        cell.titleLeftBorder = 0;
        cell.adjustSwitchBorder = -5;
        [cell enterFilletMode];
        cell.lbDetail.text = @"";
        WeakSelf(weakSelf);
        cell.toggleSwitchStateChangedAction = ^(BOOL on) {
            weakSelf.fbExtraStateCtrlManager.iStatueLed = on ? 1 : 0;
            if (weakSelf.AOVLightViewSaveLed) {
                weakSelf.AOVLightViewSaveLed();
            }
        };
         
         return cell;
    }else if ([item.titleName isEqualToString:TS("TR_Low_Light_Control")]){//AOV设备指示灯 使用特定cell
        TitleSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleSwitchCell];
        cell.autoAdjustAllTitleHeight = YES;
        cell.titleLabel.text = item.titleName;
        cell.toggleSwitch.on = self.microFillLightOpen;
        cell.bottomLineLeftBorder = 0;
        cell.titleLeftBorder = 0;
        cell.adjustSwitchBorder = -5;
        [cell enterFilletMode];
        cell.lbDetail.text = item.subTitle;
        WeakSelf(weakSelf);
        cell.toggleSwitchStateChangedAction = ^(BOOL on) {
            weakSelf.microFillLightOpen = on;
            if (weakSelf.AOVMicroLightSaveAction) {
                weakSelf.AOVMicroLightSaveAction(on);
            }
        };
         
         return cell;
    }
    
    return [tableView dequeueReusableCellWithIdentifier:kEmptyTableViewCell];;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray * sectionData = [self.dataSource objectAtIndex:indexPath.section];
     
    OrderListItem *item = [sectionData objectAtIndex:indexPath.row];
    return item.preCellHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSMutableArray * sectionData = [self.dataSource objectAtIndex:indexPath.section];
    OrderListItem *item = [sectionData objectAtIndex:indexPath.row];
    if ([item.titleName isEqualToString:TS("TR_AutoLight")]){
        [self.whiteLightManager setWorkMode:@"Auto"];
        if (self.saveBlock) {
            self.saveBlock();
        }
    } else if ([item.titleName isEqualToString:TS("TR_TimingLight")]){
        [self.whiteLightManager setWorkMode:@"Timing"];
        if (self.saveBlock) {
            self.saveBlock();
        }
    } else if ([item.titleName isEqualToString:TS("start_time")]){
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"HH:mm"];
        NSCalendar *calender = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:calender.locale.localeIdentifier]];
        NSDate *date = [format dateFromString:[self.whiteLightManager getLightOpenTime]];
        MyDatePickerView *pickerView = [[MyDatePickerView alloc] initWithFrame:self.frame];
        
         
        pickerView.tag = 0;
        pickerView.title = TS("TR_Alarm_Period_Select_Start_Time");
        pickerView.delegate = self;
        pickerView.tag = indexPath.row;
         
        //pickerView.compareDate = compareDate;
        pickerView.uiStyle = DatePickerUIStyleTopCircle;
        pickerView.curStyle = DatePickerStyleTime;
        self.pickerView = pickerView;
        [pickerView myShowInView:((AppDelegate *)([UIApplication sharedApplication].delegate)).window  showDate:date dismiss:^{
            
        }];
    } else if ([item.titleName isEqualToString:TS("end_time")]){
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"HH:mm"];
        NSCalendar *calender = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:calender.locale.localeIdentifier]];
        NSDate *date = [format dateFromString:[self.whiteLightManager getLightCloseTime]];
        
        
        MyDatePickerView *pickerView = [[MyDatePickerView alloc] initWithFrame:self.frame];
        pickerView.tag = 1;
         
        pickerView.title = TS("TR_Alarm_Period_Select_End_Time");
        pickerView.delegate = self;
        pickerView.tag = indexPath.row;
         
        //pickerView.compareDate = compareDate;
        pickerView.uiStyle = DatePickerUIStyleTopCircle;
        pickerView.curStyle = DatePickerStyleTime;
        self.pickerView = pickerView;
        [pickerView myShowInView:((AppDelegate *)([UIApplication sharedApplication].delegate)).window  showDate:date dismiss:^{
            
        }];
    } else if ([item.titleName isEqualToString:TS("TR_ConstantLight")]){
        [self.whiteLightManager setWorkMode:@"KeepOpen"];
        if (self.saveBlock) {
            self.saveBlock();
        }
    }
    
     
}

//MARK: - 时间选择器的代理事件
-(void)onSelectDate:(NSDate *)date sender:(id)sender{
    if (date) {
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"HH:mm"];
        [format setCalendar:gregorian];
        NSCalendar *calender = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:calender.locale.localeIdentifier]];
        NSString *dateTime = [format stringFromDate:date];
        if ([((MyDatePickerView *)sender).title isEqualToString:TS("TR_Alarm_Period_Select_Start_Time")]) {
            NSString *endTime = [self.whiteLightManager getLightCloseTime];

            if ([dateTime isEqualToString:endTime]) {
                [SVProgressHUD showErrorWithStatus:TS("Start_And_End_Time_Unable_Equal")];
                return;
            }
            [self.whiteLightManager setLightOpenTime:dateTime];
            
            if (self.saveBlock) {
                self.saveBlock();
            }
        }else{
            NSString *startTime = [self.whiteLightManager getLightOpenTime];

            if ([dateTime isEqualToString:startTime]) {
                [SVProgressHUD showErrorWithStatus:TS("Start_And_End_Time_Unable_Equal")];
                return;
            }
            [self.whiteLightManager setLightCloseTime:dateTime];
            
            if (self.saveBlock) {
                self.saveBlock();
            }
        }
    }
}

//MARK: - LazyLoad
- (UITableView *)tbList{
    if (!_tbList) {
        _tbList = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        [_tbList registerClass:[TitleSwitchCell class] forCellReuseIdentifier:kTitleSwitchCell];
        [_tbList registerClass:[JFLeftTitleRightButtonCell class] forCellReuseIdentifier:kJFLeftTitleRightButtonCell];
        [_tbList registerClass:[JFLeftTitleCell class] forCellReuseIdentifier:kJFLeftTitleCell];
        [_tbList registerClass:[JFBottomSliderCell class] forCellReuseIdentifier:kJFBottomSliderCell];
        [_tbList registerClass:[EmptyTableViewCell class] forCellReuseIdentifier:kEmptyTableViewCell];
        [_tbList registerClass:[JFNewAlarmSliderValueCell class] forCellReuseIdentifier:kJFNewAlarmSliderValueCell];

        _tbList.dataSource = self;
        _tbList.delegate = self;
//        [_tbList setCellSectionDefaultHeight];
        _tbList.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tbList.tableFooterView = [[UIView alloc] init];
    }
    
    return _tbList;
}

- (NSMutableArray *)cfgOrderList{
    if (!_cfgOrderList) {
         
        _cfgOrderList = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray *firstSection = [[NSMutableArray alloc] initWithCapacity:0];
        NSMutableArray *secondSection = [[NSMutableArray alloc] initWithCapacity:0];
        NSMutableArray *thirdSection = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray *forthSection = [NSMutableArray arrayWithCapacity:0];
        //灯光开关
        OrderListItem *itemLightSiwtch = [[OrderListItem alloc] init];
        itemLightSiwtch.titleName = TS("TR_White_Light_Switch");
        itemLightSiwtch.hidden = NO;
        itemLightSiwtch.preCellHeight = 50;
        [firstSection addObject:itemLightSiwtch];
        //亮度调整
        OrderListItem *itemBrightnessSetting = [[OrderListItem alloc] init];
        itemBrightnessSetting.titleName = TS("TR_Adjustment_Of_Brightness");
        itemBrightnessSetting.subTitle = @"";
        itemBrightnessSetting.hidden = YES;
         
        itemBrightnessSetting.preCellHeight = 115;
        [firstSection addObject:itemBrightnessSetting];
        
        //自动灯光
        OrderListItem *itemAutoLight = [[OrderListItem alloc] init];
        itemAutoLight.titleName = TS("TR_AutoLight");
        itemAutoLight.subTitle = TS("TR_AutoLightDetail");
        itemAutoLight.hidden = YES;
        itemAutoLight.preCellHeight = [self cellHeightWithTitle:itemAutoLight.titleName titleFont:JFFont(cTableViewFilletTitleFont) subTitle:itemAutoLight.subTitle subTitleFont:JFFont(cTableViewFilletSubTitleFont) maxWidht:SCREEN_WIDTH - 15 * 2 - 5 - 20 tbOffset:cTableViewFilletContentLRBorder];
        [secondSection addObject:itemAutoLight];
        
        //灵敏度
        OrderListItem *itemIntelligent = [[OrderListItem alloc] init];
        itemIntelligent.titleName = TS("Intelligent_sensitivity");
        itemIntelligent.hidden = YES;
//        itemIntelligent.tempValue = 2;
        itemIntelligent.preCellHeight = 115;
        [secondSection addObject:itemIntelligent];
        
        //定时灯光
        OrderListItem *itemTiming = [[OrderListItem alloc] init];
        itemTiming.titleName = TS("TR_TimingLight");
        itemTiming.subTitle = TS("TR_TimingLightDetail");
        itemTiming.hidden = YES;
        itemTiming.preCellHeight = [self cellHeightWithTitle:itemTiming.titleName titleFont:JFFont(cTableViewFilletTitleFont) subTitle:itemTiming.subTitle subTitleFont:JFFont(cTableViewFilletSubTitleFont) maxWidht:SCREEN_WIDTH - 15 * 2 - 5 - 20 tbOffset:cTableViewFilletContentLRBorder];
        [secondSection addObject:itemTiming];
        
        //开始时间
        OrderListItem *itemStartTime = [[OrderListItem alloc] init];
        itemStartTime.titleName = TS("start_time");
        itemStartTime.hidden = YES;
         
        itemStartTime.preCellHeight = 55;
        [secondSection addObject:itemStartTime];
        //结束时间
        OrderListItem *itemEndTime = [[OrderListItem alloc] init];
        itemEndTime.titleName = TS("end_time");
        itemEndTime.hidden = YES;
        itemEndTime.iMarker = 2;
        itemEndTime.preCellHeight = 55;
        [secondSection addObject:itemEndTime];
        
        //常亮灯光
        OrderListItem *itemKeepOpen = [[OrderListItem alloc] init];
        itemKeepOpen.titleName = TS("TR_ConstantLight");
        itemKeepOpen.subTitle = TS("TR_ConstantLightDetail");
        itemKeepOpen.hidden = YES;
        itemKeepOpen.preCellHeight = [self cellHeightWithTitle:itemKeepOpen.titleName titleFont:JFFont(cTableViewFilletTitleFont) subTitle:itemKeepOpen.subTitle subTitleFont:JFFont(cTableViewFilletSubTitleFont) maxWidht:SCREEN_WIDTH - 15 * 2 - 5 - 20 tbOffset:cTableViewFilletContentLRBorder];
        [secondSection addObject:itemKeepOpen];
        
        //状态灯
        OrderListItem *itemLed = [[OrderListItem alloc] init];
        itemLed.titleName = TS("TR_Setting_Device_Indicator_Light");
        itemLed.hidden = YES;
        itemLed.iMarker = 3;
        itemLed.preCellHeight = 50;
        [thirdSection addObject:itemLed];
        
        //微光控制
        OrderListItem *itemLowLight = [[OrderListItem alloc] init];
        itemLowLight.titleName = TS("TR_Low_Light_Control");
        itemLowLight.subTitle = TS("TR_Low_Light_Control_Tip");
        itemLowLight.hidden = YES;
        itemLowLight.iMarker = 3;
        CGFloat itemLowLightHeight = [self cellHeightWithTitle:itemAutoLight.titleName titleFont:JFFont(cTableViewFilletTitleFont) subTitle:itemAutoLight.subTitle subTitleFont:JFFont(cTableViewFilletSubTitleFont) maxWidht:SCREEN_WIDTH - 15 * 2 - 5 - 20 tbOffset:cTableViewFilletContentLRBorder] +15;
        itemLowLight.preCellHeight = itemLowLightHeight;
        [forthSection addObject:itemLowLight];
        
        [_cfgOrderList addObject:firstSection];
        [_cfgOrderList addObject:secondSection];
        [_cfgOrderList addObject:thirdSection];
        [_cfgOrderList addObject:forthSection];
    }
    
    return _cfgOrderList;
}

- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:0];
        [self updateDataSourceUIRefresh:NO];
    }
    
    return _dataSource;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
