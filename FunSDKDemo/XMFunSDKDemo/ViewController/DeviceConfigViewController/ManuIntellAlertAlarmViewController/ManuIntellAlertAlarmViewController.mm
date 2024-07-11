//
//  ManuIntellAlertAlarmViewController.m
//  FunSDKDemo
//
//  Created by plf on 2024/6/21.
//  Copyright © 2024 plf. All rights reserved.
//

#import "ManuIntellAlertAlarmViewController.h"
#import "ManuIntelAlarmManager.h"
#import "DeviceManager.h"
#import <Masonry/Masonry.h>

@interface ManuIntellAlertAlarmViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UITableView *listTB;
@property(nonatomic,strong)NSArray *listArray;
@property (nonatomic,strong) ManuIntelAlarmManager *manuIntelAlarmManager;

@end

@implementation ManuIntellAlertAlarmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = TS("ManualAlert");
    self.navigationItem.titleView = [[UILabel alloc] initWithTitle:self.navigationItem.title name:NSStringFromClass([self class])];
    
    [self initData];
    [self creatView];
}

-(void)initData
{
    self.listArray = @[TS("ManualAlert_Open"),TS("ManualAlert_Close")];
}

-(void)creatView
{
    [self.view addSubview:self.listTB];
    [self.listTB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}

#pragma mark -- UITableViewDelegate/dataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.text = self.listArray[indexPath.row] ;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[DeviceManager getInstance] devWakeUp:^(int result) {
        
        if (result>=0) {
            
            if (indexPath.row == 0) {
                
                [self.manuIntelAlarmManager startManuIntelAlarm:self.devID completed:^(int result) {
                    if (result >= 0) {
                        [SVProgressHUD showSuccessWithStatus:TS("Success") duration:1.5];
                    }
                    else{
                        [MessageUI ShowErrorInt:result];
                    }
                }];
            }
            else
            {
                [self.manuIntelAlarmManager stopManuIntelAlarm:self.devID completed:^(int result) {
                    if (result >= 0) {
                        [SVProgressHUD showSuccessWithStatus:TS("Success") duration:1.5];
                    }
                    else{
                        [MessageUI ShowErrorInt:result];
                    }
                }];
            }
        }else
        {
            [MessageUI ShowErrorInt:result];
        }
    }];
}


-(UITableView *)listTB
{
    if(!_listTB)
    {
        _listTB = [[UITableView alloc]init];
        _listTB.delegate = self;
        _listTB.dataSource = self;
        [_listTB registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
        _listTB.tableFooterView = [UIView new];
    }
    return _listTB;
}

- (ManuIntelAlarmManager *)manuIntelAlarmManager{
    if (!_manuIntelAlarmManager) {
        _manuIntelAlarmManager = [[ManuIntelAlarmManager alloc] init];
    }
    
    return _manuIntelAlarmManager;
}


@end
