//
//  PirTimeSectionViewController.m
//   
//
//  Created by 杨翔 on 2022/5/20.
//  Copyright © 2022 xiongmaitech. All rights reserved.
//

#import "PirTimeSectionViewController.h"
#import "TitleComboBoxCell.h"
#import "JFLeftTitleRightTitleArrowCell.h"
#import "PirAlarmManager.h"
#import "XMAlarmPeriodModel.h"
#import "XMAlarmPeriodDetailController.h"
static NSString *const kTitleComboBoxCell = @"TitleComboBoxCell";
static NSString *const kJFLeftTitleRightTitleArrowCell = @"JFLeftTitleRightTitleArrowCell";

@interface PirTimeSectionViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UIView *tbContainer;
@property (nonatomic,strong) UITableView *tbFunction;

//@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation PirTimeSectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = cTableViewFilletGroupedBackgroudColor;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self myConfigNav];
    
    [self myConfigSubview];
    
     
    
    
}

//MARK: - ConfigNav
- (void)myConfigNav{
    self.navigationItem.title = TS("TR_Detection_Schedule");
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, 0, 32, 32);
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(btnBackClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarBtn = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    
    self.navigationItem.leftBarButtonItem = leftBarBtn;
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setTitle:TS("finish") forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    rightBtn.frame = CGRectMake(0, 0, 48, 32);
    [rightBtn addTarget:self action:@selector(saveBtnClicked) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *rightBarBtn = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
//    self.navigationItem.rightBarButtonItems = @[rightBarBtn];
}

//-(void)myLoadData{
//    self.dataSource =[@[TS("PIR_Detect_Time_Period"),TS("Start_End_Time"),TS("Repeat")] mutableCopy];
//}

//MARK: - ConfigSubview
- (void)myConfigSubview{
    [self.view addSubview:self.tbContainer];
    
    [self.tbContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

//MARK: - Delegate
//MARK: UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return cTableViewFilletLFBorder * 0.5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return cTableViewFilletLFBorder * 0.5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    JFLeftTitleRightTitleArrowCell *cell = [tableView dequeueReusableCellWithIdentifier:kJFLeftTitleRightTitleArrowCell];
    //是否开启
    BOOL isValid = [self.pirAlarmManager getPirTimeSection:indexPath.row];
    //开始时间结束时间
    NSString *beginTime = [self.pirAlarmManager getPirTimeSectionStartTime:indexPath.row];
    NSString *endTime = [self.pirAlarmManager getPirTimeSectionEndTime:indexPath.row];
    //重复时间
    int weekMask = [self.pirAlarmManager getPirTimeSectionWeekMask:indexPath.row];
    NSString *strWeekMask = [self getSelectedWeekStr:weekMask];
     if ([strWeekMask isEqualToString:[NSString stringWithFormat:@"%@ %@",TS("Saturday"),TS("Sunday")]]){
         strWeekMask = TS("TR_Alarm_Weekend");
    }else if ([strWeekMask isEqualToString:[NSString stringWithFormat:@"%@ %@ %@ %@ %@",TS("Monday"), TS("Tuesday"), TS("Wednesday"), TS("Thursday"), TS("Friday")]]){
        strWeekMask = TS("TR_Alarm_Workday");
    }
    
    [cell showTitle:[NSString stringWithFormat:@"%@-%@", beginTime, endTime] description:strWeekMask rightTitle:isValid?TS("Already_Open"):TS("Not_Open")];
    cell.bottomLine.hidden = indexPath.row == 1? YES : NO;
    
    return cell;
    
}

-(NSString *)getSelectedWeekStr:(int)mask{
    NSString *result = @"";
    
    int selectedNum = 0;
    if (mask & 0x01) {
        result = [result stringByAppendingFormat:@"%@%@",result.length > 0 ? @"、" : @"",TS("Sunday")];
        selectedNum++;
    }
    
    if (mask & 0x02) {
        result = [result stringByAppendingFormat:@"%@%@",result.length > 0 ? @"、" : @"",TS("Monday")];
        selectedNum++;
    }
    
    if (mask & 0x04) {
        result = [result stringByAppendingFormat:@"%@%@",result.length > 0 ? @"、" : @"",TS("Tuesday")];
        selectedNum++;
    }
    
    if (mask & 0x08) {
        result = [result stringByAppendingFormat:@"%@%@",result.length > 0 ? @"、" : @"",TS("Wednesday")];
        selectedNum++;
    }
    
    if (mask & 0x10) {
        result = [result stringByAppendingFormat:@"%@%@",result.length > 0 ? @"、" : @"",TS("Thursday")];
        selectedNum++;
    }
    
    if (mask & 0x20) {
        result = [result stringByAppendingFormat:@"%@%@",result.length > 0 ? @"、" : @"",TS("Friday")];
        selectedNum++;
    }
    
    if (mask & 0x40) {
        result = [result stringByAppendingFormat:@"%@%@",result.length > 0 ? @"、" : @"",TS("Saturday")];
        selectedNum++;
    }
    
    if (selectedNum == 7) {
        return TS("every_day");
    } 
    else{
        return result.length == 0 ? TS("Never") : result;
    }
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BOOL isValid = [self.pirAlarmManager getPirTimeSection:indexPath.row];
    //开始时间结束时间
    NSString *beginTime = [self.pirAlarmManager getPirTimeSectionStartTime:indexPath.row];
    NSString *endTime = [self.pirAlarmManager getPirTimeSectionEndTime:indexPath.row];
    //重复时间
    int weekMask = [self.pirAlarmManager getPirTimeSectionWeekMask:indexPath.row];
    
    
    XMAlarmPeriodModel *period = [[XMAlarmPeriodModel alloc] init];
    period.isValid = isValid;
    period.startTime = beginTime;
    period.endTime = endTime;
    period.weekBit = [self convertWeekBitStandard:weekMask];

    XMAlarmPeriodDetailController *alarmPeriodDetailController = [[XMAlarmPeriodDetailController alloc] init];
    alarmPeriodDetailController.alarmPeriod = period;
    __weak typeof(self) weakSelf = self;

    [alarmPeriodDetailController setBackRefreshBlock:^{
        [weakSelf.pirAlarmManager setPirTimeSection:period.isValid sectionNum:indexPath.row];
        [weakSelf.pirAlarmManager setPirTimeSectionStartTime:period.startTime sectionNum:indexPath.row];
        [weakSelf.pirAlarmManager setPirTimeSectionEndTime:period.endTime sectionNum:indexPath.row];
        [weakSelf.pirAlarmManager setPirTimeSectionWeekMask:[weakSelf convertWeekBitSpecial:period.weekBit] sectionNum:indexPath.row];
        [weakSelf.tbFunction reloadData];
        [weakSelf saveBtnClicked];
        
        
    }];
    [self.navigationController pushViewController:alarmPeriodDetailController animated:YES];
}


/**将特殊星期选中数据转换成普通的*/
- (int)convertWeekBitStandard:(int)weekBit{
    //先取出第一位
    int moveValue = weekBit & 1;
    //整体右移一位
    weekBit = weekBit>>1;
    //左边补上取出的那位数据
    weekBit = weekBit | (moveValue << 6);
    
    return weekBit;
}

/**将普通的星期选中数据转换成特殊的**/
- (int)convertWeekBitSpecial:(int)weekBit{
    //先取出第7位
    int moveValue = weekBit & (1<<6);
    //整体左移一位
    weekBit = weekBit<<1;
    //右边补上取出的那位数据
    weekBit = weekBit | (moveValue>>6);
    
    return weekBit;
}



//MARK: - LazyLoad
- (UIView *)tbContainer{
    if (!_tbContainer) {
        _tbContainer = [[UIView alloc] init];
        _tbContainer.backgroundColor = cTableViewFilletGroupedBackgroudColor;
        [_tbContainer addSubview:self.tbFunction];
        [self.tbFunction mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_tbContainer).mas_offset(cTableViewFilletLFBorder);
            make.right.equalTo(_tbContainer).mas_offset(-cTableViewFilletLFBorder);
            make.top.equalTo(_tbContainer);
            make.bottom.equalTo(_tbContainer);
        }];
    }
    
    return _tbContainer;
}

- (UITableView *)tbFunction{
     if (!_tbFunction) {
         _tbFunction = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
         _tbFunction.rowHeight = cTableViewCellHeight;
         [_tbFunction registerClass:[JFLeftTitleRightTitleArrowCell class] forCellReuseIdentifier:kJFLeftTitleRightTitleArrowCell];
         _tbFunction.separatorStyle = UITableViewCellSeparatorStyleNone;
         _tbFunction.dataSource = self;
         _tbFunction.delegate = self;
         _tbFunction.showsVerticalScrollIndicator = NO;
         _tbFunction.contentInset = UIEdgeInsetsMake(cTableViewFilletLFBorder * 0.5, 0, 0, 0);
         _tbFunction.sectionHeaderHeight = 0;
         _tbFunction.sectionFooterHeight = 0;
         _tbFunction.tableFooterView = [[UIView alloc] init];
     }
 
    return _tbFunction;
}


//MARK: EventAction
//MARK: 点击返回
- (void)btnBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

//MARK: 点击保存
- (void)saveBtnClicked{
    if (self.pirAlarmManager) {
        self.PIRAlarmTimeSection(self.pirAlarmManager);
    }
//    [self btnBackClicked];
}

@end
