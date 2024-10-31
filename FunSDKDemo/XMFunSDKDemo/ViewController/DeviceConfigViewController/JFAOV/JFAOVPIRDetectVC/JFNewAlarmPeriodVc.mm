//
//  JFNewAlarmPeriodVc.m
//   iCSee
//
//  Created by kevin on 2023/9/26.
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import "JFNewAlarmPeriodVc.h"
#import <Masonry/Masonry.h>
#import "DeviceConfig.h"
#import "UIView+Layout.h"
#import <FunSDK/FunSDK.h>
#import "UIColor+Util.h"
#import "XMTriggerCell.h"
#import "XMbottomTableViewCell.h"
#import "XMAlarmPeriodDetailController.h"
#import "XMAlarmPeriodModel.h"
//#import "XMFailAlertManager.h"
#import "JFLeftTitleRightTitleArrowCell.h"
static NSString *const kXMTriggerCell = @"XMTriggerCell";
static NSString *const kXMbottomTableViewCell = @"XMbottomTableViewCell";
static NSString *const kJFLeftTitleRightTitleArrowCell = @"JFLeftTitleRightTitleArrowCell";
@interface JFNewAlarmPeriodVc ()<UITableViewDelegate,UITableViewDataSource, DeviceConfigDelegate>

@property (nonatomic, strong) NSMutableArray <XMAlarmPeriodModel *>*periodList;

@property (nonatomic, assign) BOOL isCustomPeriod;//是否自定义报警

@property (nonatomic, strong) UITableView *triggerListView;

@end

@implementation JFNewAlarmPeriodVc

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.triggerListView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;

    self.navigationItem.title = TS("alarm_time");
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, 0, 32, 32);
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(leftBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarBtn = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];

    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, 60, 32);
    [rightBtn setTitle:TS("finish") forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(onConfirm) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarBtn = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    
    
    self.navigationItem.leftBarButtonItem = leftBarBtn;
//    self.navigationItem.rightBarButtonItem = rightBarBtn;
    
    [self.view addSubview:self.tb_Container];
    [self.tb_Container addSubview:self.triggerListView];
    [self.tb_Container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.triggerListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.tb_Container).mas_offset(cTableViewFilletLFBorder);
        make.right.equalTo(self.tb_Container).mas_offset(-cTableViewFilletLFBorder);
        make.top.equalTo(self.tb_Container);
        make.bottom.equalTo(self.tb_Container);
    }];
    
    

    [self updatePeriodList];
}

#pragma mark - **************** request set get ****************

-(void)updatePeriodList {
    _isCustomPeriod = YES;
    NSString *sData = [[[self timeSection] objectAtIndex:0] objectAtIndex:0];

//    NSString *sData = OCSTR(self.jDetect_MotionDetect->mEventHandler.TimeSection[0][0].Value());
    if ( sData.length ) {
        if ([[sData substringWithRange:NSMakeRange(0, 1)] boolValue]) {
            _isCustomPeriod = NO;
        }
    }
    
    if (!_periodList) {
        _periodList = [[NSMutableArray alloc] init];
    } else {
        [_periodList removeAllObjects];
    }
    //读取二维数组中周日后五段时间确定开始时间、结束时间。
    for (int i = 1; i < 6; i++) {
        NSString *sData = [[[self timeSection] objectAtIndex:0] objectAtIndex:i];

//        NSString *sData = OCSTR(self.jDetect_MotionDetect->mEventHandler.TimeSection[0][i].Value());
        
        XMAlarmPeriodModel *alarmPeriodModel = [[XMAlarmPeriodModel alloc] init];

        if ( sData.length ) {
            
            BOOL isValid = NO;
            NSString *startTime = [sData substringWithRange:NSMakeRange(2, 5)];
            NSString *endTime = [sData substringWithRange:NSMakeRange(11, 5)];
//            if ([startTime isEqualToString:@"24:00"]) {
//                startTime = @"23:59";
//            }
//            if ([endTime isEqualToString:@"24:00"]) {
//                endTime = @"23:59";
//            }
            
            NSInteger weekBit = 0;
            if ([[sData substringWithRange:NSMakeRange(0, 1)] boolValue]) {
                isValid = YES;
                weekBit = 1<<6;
            }
            
            alarmPeriodModel.startTime = startTime;
            alarmPeriodModel.endTime = endTime;
            alarmPeriodModel.isValid = isValid;
            alarmPeriodModel.weekBit = weekBit;
            
            [self.periodList addObject:alarmPeriodModel];
        } else {
            alarmPeriodModel.startTime = @"00:00";
            alarmPeriodModel.endTime = @"24:00";
            alarmPeriodModel.isValid = NO;
            alarmPeriodModel.weekBit = 0;
            
            [self.periodList addObject:alarmPeriodModel];
        
        
        
        }
    }
    //设置后五段时间开启报警的是星期几
    for (int i = 1; i < 7; i++) {
        for (int j = 1; j < 6; j++) {
            NSString *sData = [[[self timeSection] objectAtIndex:i] objectAtIndex:j];

//            NSString *sData = OCSTR(self.jDetect_MotionDetect->mEventHandler.TimeSection[i][j].Value());
            if ( sData.length ) {
                XMAlarmPeriodModel *alarmPeriodModel = self.periodList[j-1];
                if ([[sData substringWithRange:NSMakeRange(0, 1)] boolValue]) {
                    alarmPeriodModel.isValid = YES;
                    NSInteger weekBit = alarmPeriodModel.weekBit;
                    alarmPeriodModel.weekBit = (weekBit |(1<<(i-1)));
                }
            }
        }
    }
}
-(void)onConfirm{
    [SVProgressHUD show];
    //全天报警时设置报警时段
    NSMutableArray *arrayTime = [[NSMutableArray alloc] initWithArray:[self timeSection]];

    if (!self.isCustomPeriod) {
        for (int i = 0; i < 7; i++) {
            NSString *dataStr = @"1 00:00:00-23:59:59";
            NSMutableArray *arrayTimeSub = [[NSMutableArray alloc] initWithArray:[arrayTime objectAtIndex:i]];
            [arrayTimeSub replaceObjectAtIndex:0 withObject:dataStr];
            [arrayTime replaceObjectAtIndex:i withObject:arrayTimeSub];

//            self.jDetect_MotionDetect->mEventHandler.TimeSection[i][0].SetValue(CSTR(dataStr));
        }
    }else {
        for (int i = 0; i < 7; i++) {
            NSString *dataStr = @"0 00:00:00-23:59:59";
            NSMutableArray *arrayTimeSub = [[NSMutableArray alloc] initWithArray:[arrayTime objectAtIndex:i]];
            [arrayTimeSub replaceObjectAtIndex:0 withObject:dataStr];
            [arrayTime replaceObjectAtIndex:i withObject:arrayTimeSub];
//            self.jDetect_MotionDetect->mEventHandler.TimeSection[i][0].SetValue(CSTR(dataStr));
        }
        //自定义报警时设置后五段报警时段
        for (int i = 1; i < 6; i++) {
            if (self.periodList.count >= i) {
                XMAlarmPeriodModel *period = self.periodList[i-1];
                NSInteger weekBit = period.weekBit;
                NSString *sData = @"";
                BOOL isValid = period.isValid;
                
                for (int j=0; j<7; j++) {
                    int num = j ? j - 1 : 6;
                    
                    if ((weekBit &(1<<num)) && isValid) {
                        sData = [NSString stringWithFormat:@"1 %@:00-%@:00", period.startTime, period.endTime];
                    } else {
                        sData = [NSString stringWithFormat:@"0 %@:00-%@:00", period.startTime, period.endTime];
                    }
                    NSMutableArray *arrayTimeSub = [[NSMutableArray alloc] initWithArray:[arrayTime objectAtIndex:j]];
                    [arrayTimeSub replaceObjectAtIndex:i withObject:sData];
                    [arrayTime replaceObjectAtIndex:j withObject:arrayTimeSub];
                    
                    
//                    self.jDetect_MotionDetect->mEventHandler.TimeSection[j][i].SetValue(CSTR(sData));
                    
                }
            }
        }
    }
    [self setTimeSection:arrayTime];
    
    
}


- (void)changeAlarmPriedOpen:(BOOL)open index:(NSInteger)index{
    XMAlarmPeriodModel *period = [self.periodList objectAtIndex:index];
    period.isValid = open;
    [self onConfirm];
}
#pragma mark - **************** data config ****************
- (NSArray *)timeSection {
    NSArray *array;
    switch (self.periodKind) {
        case NewAlarmPeriodKind_AbnormalSound:
        {
            array = [self.detectVolumeDetectionManager timeSection];
        }
            break;
        case NewAlarmPeriodKind_Car:
        {
            array = [self.detectCarShapeDetectionManager timeSection];
        }
            break;
        case NewAlarmPeriodKind_Pet:
        {
            array = [self.detectPetDetectionManager timeSection];
        }
            break;
        case NewAlarmPeriodKind_Cry:
        {
            array = [self.detectCryDetectionManager timeSection];
        }
            break;
        case NewAlarmPeriodKink_Intelligent:
        {
            array = [self.intellAlertAlarmMannager timeSection];
        }
        default:
            break;
    }
    return array;
    
    
}

- (void)setTimeSection:(NSArray *)arrayTime {
    switch (self.periodKind) {
        case NewAlarmPeriodKind_AbnormalSound:
        {
            [self.detectVolumeDetectionManager setTimeSection:arrayTime];
            [SVProgressHUD show];
            [self.detectVolumeDetectionManager requestSaveDetectVolumeDetectionCompleted:^(int result) {
                if (result > 0) {
                    [SVProgressHUD showSuccessWithStatus:TS("Save_Success")];
                     
                }else{
                    [MessageUI ShowErrorInt:result];
                }
                 
            }];
        }
            break;
        case NewAlarmPeriodKind_Car:
        {
            [self.detectCarShapeDetectionManager setTimeSection:arrayTime];
            [SVProgressHUD show];
            [self.detectCarShapeDetectionManager requestSaveDetectCarShapeDetectionCompleted:^(int result) {
                if (result > 0) {
                    [SVProgressHUD showSuccessWithStatus:TS("Save_Success")];
                     
                }else{
                    [MessageUI ShowErrorInt:result];
                }
                 
            }];
        }
            break;
        case NewAlarmPeriodKind_Pet:
        {
            [self.detectPetDetectionManager setTimeSection:arrayTime];
            [SVProgressHUD show];
            [self.detectPetDetectionManager requestSaveDetectPetDetectionCompleted:^(int result) {
                if (result > 0) {
                    [SVProgressHUD showSuccessWithStatus:TS("Save_Success")];
                     
                }else{
                    [MessageUI ShowErrorInt:result];
                }
                 
            }];
             
        }
            break;
        case NewAlarmPeriodKind_Cry:
        {
            [self.detectCryDetectionManager setTimeSection:arrayTime];
            [SVProgressHUD show];
            [self.detectCryDetectionManager requestSaveDetectCryDetectionCompleted:^(int result) {
                if (result > 0) {
                    [SVProgressHUD showSuccessWithStatus:TS("Save_Success")];
                     
                }else{
                    [MessageUI ShowErrorInt:result];
                }
                 
            }];
        }
            break;
        case NewAlarmPeriodKink_Intelligent:
        {
            [self.intellAlertAlarmMannager setTimeSection:arrayTime];
            [SVProgressHUD show];
            [self.intellAlertAlarmMannager setIntellAlertAlarmCompleted:^(int result, int channel)  {
                if (result > 0) {
                    [SVProgressHUD showSuccessWithStatus:TS("Save_Success")];
                }else{
                    [MessageUI ShowErrorInt:result];
                }
                 
            }];
        }
            break;
        default:
            break;
    }
}

#pragma mark - **************** tableview delegate ****************


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1 && indexPath.row > 0){
        NSInteger index = indexPath.row - 1;
        XMAlarmPeriodModel *period = [self.periodList objectAtIndex:index];;
        NSString *startTime = period.startTime;
        NSString *endTime = period.endTime;
        NSInteger weekBit = period.weekBit;
        NSArray *array = @[TS("Monday"), TS("Tuesday"), TS("Wednesday"), TS("Thursday"), TS("Friday"), TS("Saturday"), TS("Sunday")];
        
        NSString *sWeekBit = @"";
        NSString *title = @"";
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
            sWeekBit = TS("every_day");
        }
        
        CGSize sizeDescription = [sWeekBit sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:cTableViewFilletSubTitleFont]}];
        CGFloat numDescription = sizeDescription.width / (SCREEN_WIDTH - 122);
        if (numDescription < 1){
            numDescription = 1;
        }else{
            if (((int)(numDescription * 100)) % 100 > 0){
                numDescription++;
            }
        }
        CGFloat heightDescription = numDescription * sizeDescription.height;
        
        title = [NSString stringWithFormat:@"%@-%@", startTime, endTime];
        CGSize sizeTitle = [title sizeWithAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:cTableViewFilletTitleFont]}];
        CGFloat numTitle = sizeTitle.width / (SCREEN_WIDTH - 122);
        if (numTitle < 1){
            numTitle = 1;
        }else{
            if (((int)(numTitle * 100)) % 100 > 0){
                numTitle++;
            }
        }
        CGFloat heightTitle = numTitle * sizeTitle.height;
        
        if (heightTitle + heightDescription + cTableViewFilletContentTBBorder * 2 + cTableViewFilletTitleAndSubTitleBorder > cTableViewCellHeight){
            return heightTitle + heightDescription + cTableViewFilletContentTBBorder * 2 + cTableViewFilletTitleAndSubTitleBorder;
        }
    }
    
    return cTableViewCellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    __weak typeof(self) weakSelf = self;

    switch (section) {
        case 0:
        {
            XMTriggerCell *cell = [tableView dequeueReusableCellWithIdentifier:kXMTriggerCell];
      
            cell.titleLabel.text = TS("time_day");
            [cell enterFilletMode];
            [cell showSubTitle:NO needSelectTitleButton:YES];
            [cell updateExtroLeftBorder:-5];
            if (!_isCustomPeriod) {
                cell.selectBtn.selected = YES;
            } else {
                cell.selectBtn.selected = NO;
            }
            
            cell.toggleBtnClickedAction = ^(XMTriggerCell *cell){
                if (cell.selectBtn.selected) {
                    weakSelf.isCustomPeriod = NO;
                } else {
                    weakSelf.isCustomPeriod = YES;
                }
                
                [weakSelf.triggerListView reloadData];
                [weakSelf onConfirm];
            };
            
            return cell;
        }
            break;
        case 1:
        {
            if (row == 0) {
                XMTriggerCell *cell = [tableView dequeueReusableCellWithIdentifier:kXMTriggerCell];
                [cell enterFilletMode];
                [cell showSubTitle:NO needSelectTitleButton:YES];
                [cell updateExtroLeftBorder:-5];
                cell.titleLabel.text = TS("time_diy");
                if (_isCustomPeriod) {
                    cell.selectBtn.selected = YES;
                } else {
                    cell.selectBtn.selected = NO;
                }
                cell.toggleBtnClickedAction = ^(XMTriggerCell *cell){
                    if (cell.selectBtn.selected) {
                        weakSelf.isCustomPeriod = YES;
                    } else {
                        weakSelf.isCustomPeriod = NO;
                    }
                    
                    [weakSelf.triggerListView reloadData];
                    [weakSelf onConfirm];

                };
                
                return cell;
            } else {
                JFLeftTitleRightTitleArrowCell *cell = [tableView dequeueReusableCellWithIdentifier:kJFLeftTitleRightTitleArrowCell];

                NSInteger index = row - 1;
                XMAlarmPeriodModel *period = [self.periodList objectAtIndex:index];
                NSString *startTime = period.startTime;
                NSString *endTime = period.endTime;
                BOOL isValid = period.isValid;
                NSInteger weekBit = period.weekBit;
                NSArray *array = @[TS("Monday"), TS("Tuesday"), TS("Wednesday"), TS("Thursday"), TS("Friday"), TS("Saturday"), TS("Sunday")];
                
                NSString *sWeekBit = @"";
                int selectedDyaNum = 0;
                for (NSInteger i=0; i<array.count; i++) {
                    if ((weekBit &(1<<i)) > 0) {
                        if (sWeekBit.length != 0 && i != 6) {
                            sWeekBit = [sWeekBit stringByAppendingString:@" "];
                        }
                        
                        if (i == 6 && sWeekBit.length > 0){
                            sWeekBit = [NSString stringWithFormat:@"%@ %@",sWeekBit,array[i]];
                        }else{
                            sWeekBit = [sWeekBit stringByAppendingString:array[i]];
                        }
                        selectedDyaNum++;
                    }
                }
                
                if (selectedDyaNum == 7) {
                    sWeekBit = TS("every_day");
                }else if ([sWeekBit isEqualToString:[NSString stringWithFormat:@"%@ %@",TS("Saturday"),TS("Sunday")]]){
                    sWeekBit = TS("TR_Alarm_Weekend");
                }else if ([sWeekBit isEqualToString:[NSString stringWithFormat:@"%@ %@ %@ %@ %@",TS("Monday"), TS("Tuesday"), TS("Wednesday"), TS("Thursday"), TS("Friday")]]){
                    sWeekBit = TS("TR_Alarm_Workday");
                }
                
                cell.lbTitle.font = [UIFont boldSystemFontOfSize:cTableViewFilletTitleFont];
                [cell showTitle:[NSString stringWithFormat:@"%@-%@", startTime, endTime] description:sWeekBit rightTitle:isValid?TS("Already_Open"):TS("Not_Open")];
                cell.bottomLine.hidden = index == self.periodList.count - 1 ? YES : NO;
                
                return cell;
            }
        }
            break;
            
        default:
        {
            return [[UITableViewCell alloc] initWithFrame:CGRectZero];
        }
            break;
    }

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return _isCustomPeriod?6:1;
    } else {
            return 1;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    switch (section) {
        case 0:
        {
//            if (self.isCustomPeriod) {
                self.isCustomPeriod = NO;
//            }else{
//                self.isCustomPeriod = YES;
//            }
            [tableView reloadData];
            [self onConfirm];
        }
            break;
        case 1:
        {
            if (row != 0) {
                NSInteger index = row - 1;
                XMAlarmPeriodModel *period = self.periodList[index];
                XMAlarmPeriodDetailController *alarmPeriodDetailController = [[XMAlarmPeriodDetailController alloc] init];
//                if (period.weekBit == 0) {
//                    period.weekBit = 1;
//                }
                alarmPeriodDetailController.alarmPeriod = period;
                __weak typeof(self) weakSelf = self;

                [alarmPeriodDetailController setBackRefreshBlock:^{
                    [weakSelf onConfirm];
                }];
                [self.navigationController pushViewController:alarmPeriodDetailController animated:YES];
            }else{
//                if (self.isCustomPeriod) {
//                    self.isCustomPeriod = NO;
//                }else{
                    self.isCustomPeriod = YES;
//                }
                [tableView reloadData];
                [self onConfirm];
            }
        }
            break;
        default:
            break;
    }
    
}



#pragma mark - delegate


-(void)leftBtnClicked {
    if (self.AlarmPeriodBack) {
        self.AlarmPeriodBack();
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}
#pragma mark - **************** lazyload ****************
-(UITableView *)triggerListView {
    if (!_triggerListView) {
        _triggerListView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _triggerListView.rowHeight = cTableViewCellHeight;
        _triggerListView.delegate = self;
        _triggerListView.dataSource = self;
        [_triggerListView registerClass:[XMTriggerCell class] forCellReuseIdentifier:kXMTriggerCell];
        [_triggerListView registerClass:[XMbottomTableViewCell class] forCellReuseIdentifier:kXMbottomTableViewCell];
        [_triggerListView registerClass:[JFLeftTitleRightTitleArrowCell class] forCellReuseIdentifier:kJFLeftTitleRightTitleArrowCell];
        //test //注释
//        [_triggerListView setCellSectionDefaultHeight];
        _triggerListView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        _triggerListView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    
    return _triggerListView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    NSLog(@"");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
