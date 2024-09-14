//
//  WorkModelViewController.m
//  FunSDKDemo
//
//  Created by zhang on 2024/9/13.
//  Copyright © 2024 zhang. All rights reserved.
//

#import "WorkModelViewController.h"
#import "EncodeConfig.h"
#import "EncodeConfigTableviewCell.h"
#import "EncodeItemViewController.h"

#import "JFAOVModeOfWorkAffairManager.h"

@interface WorkModelViewController () <UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_tableView;
    NSArray *titleArray;
    EncodeConfig *config;
    int selectModel;
    
    int fps; //帧率
    int recordLength; //最大录像时长
    int interval; //间隔
    int recordLatch; //录像延迟
    
}

///工作模式事务管理器
@property (nonatomic, strong) JFAOVModeOfWorkAffairManager *affairManager;
@end

@implementation WorkModelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化数据和界面
    [self initDataSource];
    [self configSubView];
    //获取配置参数
    [self getConfig];
}

- (void)viewWillDisappear:(BOOL)animated{
    //有加载状态、则取消加载
    if ([SVProgressHUD isVisible]){
        [SVProgressHUD dismiss];
    }
}

#pragma mark - 获取编码配置
- (void)getConfig {
    [SVProgressHUD showWithStatus:TS("")];
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    [self.affairManager requestCfgWithDeviceID:channel.deviceMac];
}

- (JFAOVModeOfWorkAffairManager *)affairManager{
    if (!_affairManager) {
        _affairManager = [[JFAOVModeOfWorkAffairManager alloc] init];
        WeakSelf(weakSelf);
        _affairManager.AllConfigRequestedCallBack = ^{
            [weakSelf updateContentView];
        };
        _affairManager.ConfigRequestFailedCallBack = ^{
            //[weakSelf btnNavBackClicked];
        };
        _affairManager.BatteryLevelChanged = ^(int percentage) {
            //weakSelf.contentView.batteryLevel = percentage;
            //[weakSelf.contentView configBatterValueTips];
        };
        _affairManager.BatteryChargingChanged = ^(BOOL ifCharging) {
            //weakSelf.contentView.ifCharging = ifCharging;
            //[weakSelf.contentView configBatterValueTips];
        };
    }
    
    return _affairManager;
}

#pragma mark 获取编码配置代理回调
- (void)getEncodeConfigResult:(NSInteger)result {
    if (result >0) {
        //成功，刷新界面数据
        [self.tableView reloadData];
        [SVProgressHUD dismiss];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}
#pragma mark - 保存编码配置,这一步才真正的把配置保存到设备
-(void)saveConfig{
    [SVProgressHUD show];
    [config setEncodeConfig];
}
#pragma mark 保存编码配置代理回调
- (void)setEncodeConfigResult:(NSInteger)result {
    if (result >0) {
        //成功
        [SVProgressHUD dismissWithSuccess:TS("Success")];
    }else{
         [MessageUI ShowErrorInt:(int)result];
    }
}


#pragma mark - tableView代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WorkModelTableviewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WorkModelTableviewCell"];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    NSString *title = [titleArray objectAtIndex:indexPath.row];
    cell.textLabel.text = title;
    if (indexPath.row == selectModel) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    if ([title isEqualToString:TS("main_resolution")]) {
        cell.textLabel.text = [config getMainResolution];
    }else if ([title isEqualToString:TS("main_fps")]) {
        cell.textLabel.text = [NSString stringWithFormat:@"%ld",(long)[config getMainFPS]];
    }else if ([title isEqualToString:TS("main_quality")]) {
        cell.textLabel.text = [config getMainQuality];
    }else if ([title isEqualToString:TS("mian_audio")]) {
        cell.textLabel.text = [config getMainAudioEnable];
    }else if ([title isEqualToString:TS("main_format")]) {
        cell.textLabel.text = [config getMainCompressionEnable];
    }else if ([title isEqualToString:TS("extra_resolution")]) {
        cell.textLabel.text = [config getExtraResolution];
    }else if ([title isEqualToString:TS("extra_fps")]) {
        cell.textLabel.text = [NSString stringWithFormat:@"%ld",(long)[config getExtraFPS]];
    }else if ([title isEqualToString:TS("extra_quality")]) {
        cell.textLabel.text = [config getExtraQuality];
    }else if ([title isEqualToString:TS("extra_audio")]) {
        cell.textLabel.text = [config getExtraAudioEnable];
    }else if ([title isEqualToString:TS("extra_video")]) {
        cell.textLabel.text = [config getExtraVideoEnable];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([config checkEncodeAbility] == NO) {
        return; //编码配置能力级数据异常，无法进行配置
    }
    NSString *titleStr = titleArray[indexPath.row];
    //初始化各个配置的item单元格
    EncodeItemViewController *itemVC = [[EncodeItemViewController alloc] init];
    [itemVC setTitle:titleStr];
    
    __weak typeof(self) weakSelf = self;
    itemVC.itemSelectStringBlock = ^(NSString *encodeString) {
        //itemVC的单元格点击回调,设置各种属性
        EncodeConfigTableviewCell *cell = [weakSelf.tableView cellForRowAtIndexPath:indexPath];
        cell.Labeltext.text = encodeString;
        if ([cell.textLabel.text isEqualToString:TS("main_resolution")]) {
            [config setMainResolution:encodeString];
        }else if ([cell.textLabel.text isEqualToString:TS("main_fps")]){
            [config setMainFPS:[encodeString integerValue]];
        }else if ([cell.textLabel.text isEqualToString:TS("main_quality")]){
            [config setMainQuality:encodeString];
        }else if ([cell.textLabel.text isEqualToString:TS("mian_audio")]){
            [config setMainAudioEnable:encodeString];
        }else if ([cell.textLabel.text isEqualToString:TS("extra_resolution")]){
            [config setExtraResolution:encodeString];
        }else if ([cell.textLabel.text isEqualToString:TS("extra_fps")]){
             [config setExtraFPS:[encodeString integerValue]];
        }else if ([cell.textLabel.text isEqualToString:TS("extra_quality")]){
             [config setExtraQuality:encodeString];
        }else if ([cell.textLabel.text isEqualToString:TS("extra_audio")]){
             [config setExtraAudioEnable:encodeString];
        }else if ([cell.textLabel.text isEqualToString:TS("extra_video")]){
             [config setExtraVideoEnable:encodeString];
        }else{
            return;
        }
    };
    //点击单元格之后进行分别赋值
    if ([titleStr isEqualToString:TS("main_resolution")]) {
        NSMutableArray *array = [[config getMainResolutionArray] mutableCopy];
        [itemVC setValueArray:array];
    }else if ([titleStr isEqualToString:TS("main_fps")]){
        NSMutableArray *array = [[config getMainFpsArray] mutableCopy];
        [itemVC setValueArray:array];
    }else if ([titleStr isEqualToString:TS("main_quality")]){
        NSMutableArray *array = [[config getMainQualityArray] mutableCopy];
        [itemVC setValueArray:array];
    }else if ([titleStr isEqualToString:TS("mian_audio")]){
        NSMutableArray *array = [[config getEnableArray] mutableCopy];
        [itemVC setValueArray:array];
    }else if ([titleStr isEqualToString:TS("extra_resolution")]){
        NSMutableArray *array = [[config getExtraResolutionArray] mutableCopy];
        [itemVC setValueArray:array];
    }else if ([titleStr isEqualToString:TS("extra_fps")]){
        NSMutableArray *array = [[config getExtraFpsArray] mutableCopy];
        [itemVC setValueArray:array];
    }else if ([titleStr isEqualToString:TS("extra_quality")]){
        NSMutableArray *array = [[config getExtraQualityArray] mutableCopy];
        [itemVC setValueArray:array];
    }else if ([titleStr isEqualToString:TS("extra_audio")]){
        NSMutableArray *array = [[config getEnableArray] mutableCopy];
        [itemVC setValueArray:array];
    }else if ([titleStr isEqualToString:TS("extra_video")]){
        NSMutableArray *array = [[config getEnableArray] mutableCopy];
        [itemVC setValueArray:array];
    }else{
        return;
    }
    //如果赋值成功，跳转到下一级界面
    [self.navigationController pushViewController:itemVC animated:YES];
}

- (void)updateContentView {
    NSString *mode = [self.affairManager.workModeManager mode];
    if ([mode isEqualToString:@"Balance"]) { //省电
        selectModel = 0;
    }else if ([mode isEqualToString:@"Performance"]) { //性能
        selectModel = 1;
    }else if ([mode isEqualToString:@"Custom"]) { // 自定义
        selectModel = 2;
    }else{
        selectModel = -1;
    }
    
    
    
    
    
    
    [self.tableView reloadData];
}

#pragma mark - 界面和数据初始化
-(void)initDataSource {
    titleArray=@[TS("TR_Setting_Power_Saving_Mode"),TS("TR_Setting_Performance"),TS("mode_customize")];
    selectModel = -1;
}
- (void)updateDataSource:(BOOL)showFPS{
    
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    DeviceObject *device = [[DeviceControl getInstance] GetDeviceObjectBySN:channel.deviceMac];
    if (showFPS) {
        if (!device.sysFunction.AovWorkModeIndieControl) {
            titleArray=@[TS("TR_Setting_Power_Saving_Mode"),TS("TR_Setting_Performance"),TS("mode_customize"),TS("TR_Setting_Event_Record_Delay"),TS("ad_fps")];
        }else{
            titleArray=@[TS("TR_Setting_Power_Saving_Mode"),TS("TR_Setting_Performance"),TS("mode_customize"),TS("Alarm_interval"),TS("ad_fps"),TS("Record_length")];
        }
    }else{
        titleArray=@[TS("TR_Setting_Power_Saving_Mode"),TS("TR_Setting_Performance"),TS("mode_customize")];
    }
}
- (void)configSubView {
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave  target:self action:@selector(saveConfig)];
    self.navigationItem.rightBarButtonItem = rightButton;
    [self.view addSubview:self.tableView];
}
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight ) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
