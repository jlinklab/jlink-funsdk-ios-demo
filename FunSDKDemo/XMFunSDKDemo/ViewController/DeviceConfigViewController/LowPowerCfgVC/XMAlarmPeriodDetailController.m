//
//  XMAlarmPeriodDetailController.m
//  XWorld
//
//  Created by dinglin on 2017/3/20.
//  Copyright © 2017年 xiongmaitech. All rights reserved.
//

#import "XMAlarmPeriodDetailController.h"
#import <Masonry/Masonry.h>
#import "NSDate+Ex.h"
#import "UIColor+Util.h"
#import "AlarmSwitchCell.h"
#import "TitleComboBoxCell.h"
#import "MyDatePickerView.h"
#import "AppDelegate.h"
#import "CircleWeekChoseCell.h"

static NSString *const kTitleSwitchCell = @"TitleSwitchCell";
static NSString *const kTitleComboBoxCell = @"TitleComboBoxCell";
static NSString *const kCircleWeekChoseCell = @"CircleWeekChoseCell";


@interface XMAlarmPeriodDetailController ()<UITableViewDelegate,UITableViewDataSource,MyDatePickerViewDelegate>

@property (nonatomic, strong) UITableView *triggerListView;
@property (nonatomic,strong) UIView *tbContainer;
@property (nonatomic,strong) XMAlarmPeriodModel *originModel;

@property (nonatomic,assign) BOOL clickBack;
@property (nonatomic,strong) MyDatePickerView *pickerView;
@end

@implementation XMAlarmPeriodDetailController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;

    
    
    self.navigationItem.title = TS(@"time_diy");
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, 0, 32, 32);
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"UserLoginView-back-nor"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(leftBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarBtn = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    
    self.navigationItem.leftBarButtonItem = leftBarBtn;
    
    
    [self.view addSubview:self.tbContainer];
    [self.tbContainer addSubview:self.triggerListView];
    [self.tbContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.triggerListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.tbContainer).mas_offset(cTableViewFilletLFBorder);
        make.right.equalTo(self.tbContainer).mas_offset(-cTableViewFilletLFBorder);
        make.top.equalTo(self.tbContainer);
        make.bottom.equalTo(self.tbContainer);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)setAlarmPeriod:(XMAlarmPeriodModel *)alarmPeriod{
    _alarmPeriod = alarmPeriod;
    
    self.originModel = [[XMAlarmPeriodModel alloc] init];
    self.originModel.isValid = self.alarmPeriod.isValid;
    self.originModel.startTime = self.alarmPeriod.startTime;
    self.originModel.endTime = self.alarmPeriod.endTime;
    self.originModel.weekBit = self.alarmPeriod.weekBit;
}

-(UITableView *)triggerListView {
    if (!_triggerListView) {
        _triggerListView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _triggerListView.rowHeight = cTableViewCellHeight;
        _triggerListView.delegate = self;
        _triggerListView.dataSource = self;
        [_triggerListView registerClass:[AlarmSwitchCell class] forCellReuseIdentifier:kTitleSwitchCell];
        [_triggerListView registerClass:[TitleComboBoxCell class] forCellReuseIdentifier:kTitleComboBoxCell];
        [_triggerListView registerClass:[CircleWeekChoseCell class] forCellReuseIdentifier:kCircleWeekChoseCell];
        _triggerListView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _triggerListView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    
    return _triggerListView;
}

- (UIView *)tbContainer{
    if (!_tbContainer) {
        _tbContainer = [[UIView alloc] init];
        _tbContainer.backgroundColor = cTableViewFilletGroupedBackgroudColor;
    }
    
    return _tbContainer;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0){
        return 1;
    }else if (section == 1){
        return 2;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 2){
        return [CircleWeekChoseCell cellHeight];
    }
    
    return cTableViewCellHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    switch (section) {
        case 0:
        {
            AlarmSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleSwitchCell];
            cell.titleLabel.text = TS(@"set_open");
            cell.toggleSwitch.on = self.alarmPeriod.isValid;
            __weak typeof(self) weakSelf = self;
            cell.toggleSwitchStateChangedAction = ^(BOOL switchOn){
                weakSelf.alarmPeriod.isValid = switchOn;
            };
            return cell;
        }
            break;
        case 1:
        {
            if (row == 0){
                TitleComboBoxCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleComboBoxCell];
                cell.titleLeftBorder = -5;
                [cell enterFilletMode];
                [cell noDisplayArrow];
                NSString *titleLeft = [NSString stringWithFormat:@"%@:   ",TS(@"set_start")];
                NSString *titleRight = self.alarmPeriod.startTime;
                NSString *title = [NSString stringWithFormat:@"%@%@",titleLeft,titleRight];
                NSMutableAttributedString *maStr = [[NSMutableAttributedString alloc] initWithString:title];
                NSRange range = NSMakeRange(titleLeft.length, titleRight.length);
                [maStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexStr:@"#444444"] range:range];
                [maStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:cTableViewFilletTitleFont] range:range];
                [maStr addAttribute:NSForegroundColorAttributeName value:cTableViewFilletTitleColor range:NSMakeRange(0, titleLeft.length)];
                cell.titleLabel.attributedText = maStr;
                
                return cell;
            }else if (row == 1){
                TitleComboBoxCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleComboBoxCell];
                cell.titleLeftBorder = -5;
                [cell enterFilletMode];
                [cell noDisplayArrow];
                NSString *titleLeft = [NSString stringWithFormat:@"%@:   ",TS(@"set_finish")];
                NSString *titleRight = self.alarmPeriod.endTime;
                NSString *title = [NSString stringWithFormat:@"%@%@",titleLeft,titleRight];
                NSMutableAttributedString *maStr = [[NSMutableAttributedString alloc] initWithString:title];
                NSRange range = NSMakeRange(titleLeft.length, titleRight.length);
                [maStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexStr:@"#444444"] range:range];
                [maStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:cTableViewFilletTitleFont] range:range];
                [maStr addAttribute:NSForegroundColorAttributeName value:cTableViewFilletTitleColor range:NSMakeRange(0, titleLeft.length)];
                cell.titleLabel.attributedText = maStr;
                return cell;
            }
            TitleComboBoxCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleComboBoxCell];
            [cell enterFilletMode];
            cell.titleLabel.text = TS(@"set_week");
            
            NSInteger weekBit = self.alarmPeriod.weekBit;
            
            NSArray *array = @[TS(@"Monday"), TS(@"Tuesday"), TS(@"Wednesday"), TS(@"Thursday"), TS(@"Friday"), TS(@"Saturday"), TS(@"Sunday")];
            
            NSString *sWeekBit = @"";
            int selectedDyaNum = 0;
            for (NSInteger i=0; i<array.count; i++) {
                if ((weekBit &(1<<i)) > 0) {
                    if (sWeekBit.length != 0 && i != 6) {
                        sWeekBit = [sWeekBit stringByAppendingString:@"、"];
                    }
                    
                    if (i == 6 && sWeekBit.length > 0){
                        sWeekBit = [NSString stringWithFormat:@"%@、%@",array[i],sWeekBit];
                    }else{
                        sWeekBit = [sWeekBit stringByAppendingString:array[i]];
                    }
                    selectedDyaNum++;
                }
            }
            
            if (selectedDyaNum == 7) {
                sWeekBit = TS(@"every_day");
            }
            
            cell.toggleLabel.text = sWeekBit;

            return cell;
        }
            break;
        case 2:
        {
            CircleWeekChoseCell *cell = [tableView dequeueReusableCellWithIdentifier:kCircleWeekChoseCell];
            cell.lbLeft.text = TS(@"TR_Alarm_Period_Repeat_Time");
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            NSMutableArray *state = [NSMutableArray arrayWithCapacity:0];
            for (int i = 0;i < 7;i++){
                [state addObject:[self checkWeekIndexSelected:i] ? @1 : @0];
            }
            [cell updateSelectedState:state];
            WeakSelf(weakSelf);
            cell.ClickWeekIndex = ^(int index) {
                [weakSelf clickWeekAtIndex:index];
            };
            
            return cell;
        }
            break;
        default:
        {
            return [[UITableViewCell alloc] initWithFrame:CGRectZero];
        }
            break;
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1){
        MyDatePickerView *pickerView = [[MyDatePickerView alloc]initWithFrame:self.view.frame];
        pickerView.delegate = self;
        pickerView.weekBit = self.alarmPeriod.weekBit;
        pickerView.tag = indexPath.row;
        NSString *timeStr = [NSString stringWithFormat:@"%@:00",indexPath.row == 0 ? self.alarmPeriod.startTime : self.alarmPeriod.endTime];
        if (indexPath.row == 0 && [timeStr isEqualToString:@"24:00:00"]) {
            timeStr = @"00:00:00";
        }
        pickerView.ifChoseStart = indexPath.row == 0 ? YES : NO;
        pickerView.title = indexPath.row == 0 ? TS(@"TR_Alarm_Period_Select_Start_Time") : TS(@"TR_Alarm_Period_Select_End_Time");
        
        if ([timeStr isEqualToString:@"24:00:00"]){
            timeStr = @"00:00:00";
        }
        
        NSString *compareDateStr = [NSString stringWithFormat:@"%@:00",indexPath.row == 1 ? self.alarmPeriod.startTime : self.alarmPeriod.endTime];
        if ([compareDateStr isEqualToString:@"24:00:00"]){
            compareDateStr = @"23:59:59";
        }
        NSDate *compareDate = [NSDate dateWithTimeString:compareDateStr];
        
        NSDate *date = [NSDate dateWithTimeString:timeStr];
        pickerView.compareDate = compareDate;
        pickerView.uiStyle = DatePickerUIStyleTopCircle;
        pickerView.curStyle = DatePickerStyleTime;
        self.pickerView = pickerView;
        [pickerView myShowInView:((AppDelegate *)([UIApplication sharedApplication].delegate)).window  showDate:date dismiss:^{
            
        }];
    }
}

-(void)leftBtnClicked {
    if (self.alarmPeriod.isValid && self.alarmPeriod.weekBit <= 0) {
        [SVProgressHUD showErrorWithStatus:TS(@"please_select_week")];
        return;
    }
    self.clickBack = YES;
    if (self.backRefreshBlock) {
        self.backRefreshBlock();
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (!self.clickBack){
        self.alarmPeriod.isValid = self.originModel.isValid;
        self.alarmPeriod.startTime = self.originModel.startTime;
        self.alarmPeriod.endTime = self.originModel.endTime;
        self.alarmPeriod.weekBit = self.originModel.weekBit;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - **************** 监听键盘 ****************
- (void)keyboardWillShow:(NSNotification *)notification {
    NSValue *keyboardFrameValue = [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [keyboardFrameValue CGRectValue];
     
    
    CGFloat keyboardHeight = keyboardFrame.size.height;
        
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat viewHeight = self.pickerView.frame.size.height;
    
    // 计算需要移动的距离
    CGFloat offset = viewHeight - (screenHeight - keyboardHeight);
    
    // 调整视图的frame，使其上移
    if (offset > 0) {
        CGRect frame = self.pickerView.frame;
        frame.origin.y = -offset;
        self.pickerView.frame = frame;
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
     
    
    CGRect frame = self.pickerView.frame;
        frame.origin.y = 0;
    self.pickerView.frame = frame;
}

#pragma mark -时间选择器的代理事件
-(void)onSelectDate:(NSDate *)date sender:(id)sender{
    if (date) {
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setCalendar:gregorian];
        [format setDateFormat:@"HH:mm"];
        NSCalendar *calender = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:calender.locale.localeIdentifier]];
        
        NSString *dateTime = [format stringFromDate:date];
        if (((MyDatePickerView *)sender).tag == 0) {
            
            //最好判断下时间
//            if ([CYCalenderManager getSecondsFromTime:self.alarmPeriod.endTime style:CY_TIME_STRING_STYLE_HM] <= [CYCalenderManager getSecondsFromTime:dateTime style:CY_TIME_STRING_STYLE_HM]) {
//                
//                [SVProgressHUD showErrorText:TS(@"End_Time_Greater_Than_Begin_Time")];
//                return;
//            }
//            else
//            {
                self.alarmPeriod.startTime = dateTime;
//            }
        }
        
        if (((MyDatePickerView *)sender).tag == 1) {
            if ([dateTime isEqualToString:@"00:00"]) {
                dateTime = @"24:00";
            }
            //最好判断下时间
//            if ([CYCalenderManager getSecondsFromTime:dateTime style:CY_TIME_STRING_STYLE_HM] <= [CYCalenderManager getSecondsFromTime:self.alarmPeriod.startTime style:CY_TIME_STRING_STYLE_HM]) {
//                
//                [SVProgressHUD showErrorText:TS(@"End_Time_Greater_Than_Begin_Time")];
//                return;
//            }
//            else
//            {
                self.alarmPeriod.endTime = dateTime;
//            }
        }
        
        [self.triggerListView reloadData];
    }
}

- (void)clickWeekAtIndex:(int)index{
    BOOL needOpen = NO;
    if (![self checkWeekIndexSelected:index]){
        needOpen = YES;
    }
    
    [self makeWeekSelected:needOpen index:index];
    [self.triggerListView reloadData];
}

//MARK: 检查当前序号对应的礼拜是否选中 index从0-6 表示礼拜-到礼拜天
- (BOOL)checkWeekIndexSelected:(int)index{
    if ((self.alarmPeriod.weekBit &(1<<index)) > 0) {
        return YES;
    }
    return NO;
}

- (void)makeWeekSelected:(BOOL)selected index:(int)index{
    if (selected){
        self.alarmPeriod.weekBit = self.alarmPeriod.weekBit | (1<<index);
    }else{
        self.alarmPeriod.weekBit = ~((~self.alarmPeriod.weekBit) | (1<<index));
    }
}

-(void)onSelectWeek:(NSInteger)weekBit sender:(id)sender{
    self.alarmPeriod.weekBit = weekBit;
    [self.triggerListView reloadData];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
@end
