//
//  LowPowerRecordConfigViewController.m
//  FunSDKDemo
//
//  Created by plf on 2024/6/25.
//  Copyright © 2024 plf. All rights reserved.
//

#import "LowPowerRecordConfigViewController.h"
#import "AlarmConfigTableViewCell.h"
#import <Masonry/Masonry.h>
#import "LowPowerRecordConfigManager.h"
#import "DeviceManager.h"

@interface LowPowerRecordConfigViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UITableView *listTB;
@property(nonatomic,strong)NSArray *listArray;
@property(nonatomic,strong)UISwitch *openSwitch;
@property (nonatomic,strong) LowPowerRecordConfigManager *lowPowerRecordConfigManager;

@end

@implementation LowPowerRecordConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = TS("Record_config_LowPower");
    self.navigationItem.titleView = [[UILabel alloc] initWithTitle:self.navigationItem.title name:NSStringFromClass([self class])];
    
    [self initData];
    [self creatView];
}

-(void)initData
{
    self.listArray = @[TS("Record_Config_Switch")];
    
    //避免设备休眠，先唤醒一下设备
    [[DeviceManager getInstance] devWakeUp:^(int result) {
        if (result>=0) {
            [self.lowPowerRecordConfigManager getLowPowerRecordConfig:^(NSDictionary *dic) {
                if ([[dic allKeys] count]>0) {
                    if ([[dic[@"NetWork.SetEnableVideo"] allKeys] containsObject:@"Enable"]) {
                        self.openSwitch.on = [dic[@"NetWork.SetEnableVideo"][@"Enable"] boolValue];
                        [self.listTB reloadData];
                    }
                }
            }];
        }
        else
        {
            [MessageUI ShowErrorInt:result];
        }
    }];
    
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

- (void)switchValueChange:(UISwitch*)alarmSwitch{
    //避免设备休眠，先唤醒一下设备
    [[DeviceManager getInstance] devWakeUp:^(int result) {
        if (result>=0) {
            [self.lowPowerRecordConfigManager setLowPowerRecordConfig:alarmSwitch.on completed:^(int result) {
            }];
        }
        else
        {
            [MessageUI ShowErrorInt:result];
        }
    }];
}

#pragma mark -- UITableViewDelegate/dataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AlarmConfigTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = TS([[self.listArray objectAtIndex:indexPath.row] UTF8String]);
    cell.mySwitch.on = self.openSwitch.on;
    [cell.mySwitch addTarget:self action:@selector(switchValueChange:) forControlEvents:UIControlEventValueChanged];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}


-(UITableView *)listTB
{
    if(!_listTB)
    {
        _listTB = [[UITableView alloc]init];
        _listTB.delegate = self;
        _listTB.dataSource = self;
        [_listTB registerClass:[AlarmConfigTableViewCell class] forCellReuseIdentifier:@"Cell"];
        _listTB.tableFooterView = [UIView new];
    }
    return _listTB;
}

- (LowPowerRecordConfigManager *)lowPowerRecordConfigManager{
    if (!_lowPowerRecordConfigManager) {
        _lowPowerRecordConfigManager = [[LowPowerRecordConfigManager alloc] init];
        _lowPowerRecordConfigManager.devID = self.devID;
    }
    
    return _lowPowerRecordConfigManager;
}

-(UISwitch *)openSwitch
{
    if (!_openSwitch) {
        _openSwitch = [[UISwitch alloc]init];
    }
    
    return _openSwitch;
}

@end
