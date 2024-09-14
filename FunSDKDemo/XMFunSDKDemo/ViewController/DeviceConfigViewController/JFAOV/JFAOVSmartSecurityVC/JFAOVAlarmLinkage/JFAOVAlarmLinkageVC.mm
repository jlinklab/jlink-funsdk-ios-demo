//
//  JFAOVAlarmLinkageVC.m
//   iCSee
//
//  Created by kevin on 2024/4/29.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import "JFAOVAlarmLinkageVC.h"
#import "OrderListItem.h"
#import "JFLeftTitleRightButtonCell.h"
#import "TitleSwitchCell.h"
#import "JFLeftTitleCell.h"
#import "JFBottomSliderCell.h"
#import "EmptyTableViewCell.h"
#import "JFNewAlarmSliderValueCell.h"
#import "TitleComboBoxCell.h"
#import <FunSDK/FunSDK.h>

#import "CfgStatusManager.h"
#import "IntellAlertAlarmMannager.h"
#import "ChannelVoiceTipTypeManager.h"
#import "VideoVolumeOutputManager.h"
#import "XMItemSelectViewController.h"
#import "NetCustomRecordVC.h"
#import "AlarmVoiceChoseVC.h"
static NSString *const kTitleSwitchCell = @"TitleSwitchCell";
static NSString *const kJFLeftTitleRightButtonCell = @"kJFLeftTitleRightButtonCell";
static NSString *const kJFLeftTitleCell = @"kJFLeftTitleCell";
static NSString *const kJFBottomSliderCell = @"kJFBottomSliderCell";
static NSString *const kEmptyTableViewCell = @"kEmptyTableViewCell";
static NSString *const kJFNewAlarmSliderValueCell = @"kJFNewAlarmSliderValueCell";
static NSString *const kTitleComboBoxCell = @"kTitleComboBoxCell";

@interface JFAOVAlarmLinkageVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UIButton *btnNavBack;
@property (nonatomic,assign) UI_HANDLE msgHandle;
@property (nonatomic, strong) UITableView *tbList;
// 配置顺序列表 修改顺序或者分组 增加项目 都要先在这里确定配置位置
@property (nonatomic,strong) NSMutableArray *cfgOrderList;
// 配置列表数据源
@property (nonatomic,strong) NSMutableArray *dataSource;

//MARK: 配置状态管理器
@property (nonatomic,strong) CfgStatusManager *cfgStatusManager;

//MARK: 智能警戒管理器
@property (nonatomic,strong) IntellAlertAlarmMannager *intellAlertAlarmMannager;

//MARK: 音量输出管理器
@property (nonatomic,strong) VideoVolumeOutputManager *volumeOutputManager;

//MARK: 警戒声音管理器
@property (nonatomic,strong) ChannelVoiceTipTypeManager *voiceTipTypeManager;

@property (nonatomic,assign) BOOL supportSetting_Device_Ring;

@end

@implementation JFAOVAlarmLinkageVC
- (void)dealloc
{
    FUN_UnRegWnd(self.msgHandle);
    self.msgHandle = -1;
}
- (instancetype)init{
    self = [super init];
    if (self) {
        self.msgHandle = FUN_RegWnd((__bridge void*)self);
    }
    
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildUI];
    [self wakeUpGetConfig];
    // Do any additional setup after loading the view.
}
- (void)buildUI {
    [self.view addSubview:self.tbList];
    CGFloat safeBottom = [PhoneInfoManager safeAreaLength:SafeArea_Bottom];
    [self.tbList mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).mas_offset(cTableViewFilletLFBorder);
        make.right.equalTo(self).mas_offset(-cTableViewFilletLFBorder);
        make.top.equalTo(self);
        make.bottom.equalTo(self).mas_offset(-cTableViewFilletLFBorder);
        make.bottom.equalTo(self).mas_offset(-safeBottom);
    }];
     
}
#pragma mark - **************** request ****************
//MARK: wake up to get config
- (void)wakeUpGetConfig{
    //低功耗先唤醒再操作
    [SVProgressHUD showWithStatus:TS("Waking_up")];
    FUN_DevWakeUp(self.msgHandle, CSTR(self.devID), 0);
        
}
- (void)wakeUpSetConfig{
    [SVProgressHUD show];
    FUN_DevWakeUp(self.msgHandle, CSTR(self.devID), 1);
        
}

///获取配置
- (void)requestCfg {
    [SVProgressHUD show];
   
    WeakSelf(weakSelf);
     
    [self.intellAlertAlarmMannager getIntellAlertAlarm:self.devID channel:-1 completed:^(int result, int channel) {
        if (result >= 0) {
            [weakSelf getConfigSuccess:@"IntellAlertAlarmMannager"];
        }else{
            [weakSelf getConfigFailed:result];
        }
    }];
   
    [self.voiceTipTypeManager getChannelVoiceTipType:self.devID channel:-1 completed:^(int result, int channel) {
        if (result >= 0) {
            weakSelf.supportSetting_Device_Ring = YES;
            [weakSelf getConfigSuccess:@"ChannelVoiceTipTypeManager"];
        }else{
            if (result == -11406 || result == -400009) {
                weakSelf.supportSetting_Device_Ring = NO;
            }
            [weakSelf getConfigFailed:result];
        }
    }];
    
    [self.volumeOutputManager getVideoVolumeOutput:self.devID channel:-1 completed:^(int result, int channel) {
        if (result >= 0) {
            [weakSelf getConfigSuccess:@"VideoVolumeOutputManager"];
        }else{
            [weakSelf getConfigFailed:result];
        }
    }];
}
    
///配置获取成功时 调用一次
- (void)getConfigSuccess:(NSString *)cfgName{
     
    [self.cfgStatusManager changeCfgStatus:XMCfgStatus_Success name:cfgName];
    if([self.cfgStatusManager checkAllCfgFinishedRequest]){
        [SVProgressHUD dismiss];
        //通知UI刷新
        [self AlarmLinkageSwitchON:[self.intellAlertAlarmMannager getEnable]];
        
    }
}
- (void)configData {

    //声音报警
    [self updateTableViewItem:TS("TR_Setting_Sound_Alarm") hidden:NO];
    
    //时间设置
    [self updateTableViewItem:TS("TR_Sound_Duration") hidden:NO];

    //音量设置
    if (self.iSupportSetVolume) {
        [self updateTableViewItem:TS("TR_Setting_Volume_Setting") hidden:NO];
    }
    
    //设备铃声
    if (self.supportSetting_Device_Ring) {
        [self updateTableViewItem:TS("TR_Setting_Device_Ring_Tone") hidden:NO];
    }
    
    [self.tbList reloadData];
}

- (void)AlarmLinkageSwitchON:(BOOL)isOn {
    if (isOn) {
        [self configData];
    } else {
         
        [self updateTableViewItem:TS("TR_Setting_Sound_Alarm") hidden:YES];
        [self updateTableViewItem:TS("TR_Sound_Duration") hidden:YES];
        [self updateTableViewItem:TS("TR_Setting_Volume_Setting") hidden:YES];
        [self updateTableViewItem:TS("TR_Setting_Device_Ring_Tone") hidden:YES];
        
        [self.tbList reloadData];
    }
}




///配置回去失败时 调用
- (void)getConfigFailed:(int)result{
    [MessageUI ShowErrorInt:result];
    [self.navigationController popViewControllerAnimated:YES];
}


//MARK: - OnFunSDKResult
- (void)baseOnFunSDKResult:(MsgContent *)msg{
    switch (msg->id) {
//MARK: 唤醒返回
        case EMSG_DEV_WAKE_UP:
        {
            if (msg->param1 >= 0) {
                [SVProgressHUD dismiss];
                if (msg->seq == 0) {
                    [self requestCfg];
                    
                }else{
//                    [self setLightConfig];
                }
            }else{
                if (msg->seq == 0) {
                    [self getSDKConfigFailed:msg->param1];
                } else {
                    [MessageUI ShowErrorInt:msg->param1];
                }
            }
        }
            break;
        
        default:
            break;
    }
}

- (void)getSDKConfigFailed:(int)result{
    [MessageUI ShowErrorInt:result];
    [self.navigationController popViewControllerAnimated:YES];
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
        [self.dataSource addObject:section];
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
    if ([item.titleName isEqualToString:TS("TR_AlarmLinkage")]) {
        //报警联动开关
        TitleSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleSwitchCell];
        cell.titleLeftBorder = 0;
        [cell enterFilletMode];
        cell.titleLabel.text = item.titleName;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.toggleSwitch.on = [self.intellAlertAlarmMannager getEnable];
        cell.toggleSwitchStateChangedAction = ^(BOOL on) {
            [SVProgressHUD show];
            [weakSelf.intellAlertAlarmMannager setEnable:on];
            [weakSelf.intellAlertAlarmMannager setIntellAlertAlarmCompleted:^(int result, int channel) {
                if (result < 0) {
                    [MessageUI ShowErrorInt:result];
                }else{
                    [weakSelf AlarmLinkageSwitchON:on];
                    [SVProgressHUD showSuccessWithStatus:TS("Save_Success")];
                }
            }];
             
        };
        
        return cell;
    } else if ([item.titleName isEqualToString:TS("TR_Setting_Sound_Alarm")]){
        //声音报警
        TitleSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleSwitchCell];
        cell.titleLeftBorder = 0;
        [cell enterFilletMode];
        cell.titleLabel.text = item.titleName;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.toggleSwitch.on = [self.intellAlertAlarmMannager getVoiceEnable];
        cell.toggleSwitchStateChangedAction = ^(BOOL on) {
            [SVProgressHUD show];
            [weakSelf.intellAlertAlarmMannager setVoiceEnable:on];
            [weakSelf.intellAlertAlarmMannager setIntellAlertAlarmCompleted:^(int result, int channel) {
                if (result < 0) {
                    [MessageUI ShowErrorInt:result];
                }else{
                    
                    [SVProgressHUD showSuccessWithStatus:TS("Save_Success")];
                }
            }];
            
        };
        
        return cell;
        
        
    }else if ([item.titleName isEqualToString:TS("TR_Sound_Duration")]){
        //时间设置
        TitleComboBoxCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleComboBoxCell];
        cell.titleLeftBorder = -5;
        [cell enterFilletMode];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.titleLabel.text = TS("TR_Sound_Duration");
        int duration = [self.intellAlertAlarmMannager getDuration];
         
//        cell.lbRight.hidden = NO;
        cell.toggleLabel.text =[NSString stringWithFormat:@"%i%@",duration,TS("s")];;
        
        return cell;
    }else if ([item.titleName isEqualToString:TS("TR_Setting_Volume_Setting")]){
        
        //音量设置
        JFNewAlarmSliderValueCell *cell = [tableView dequeueReusableCellWithIdentifier:kJFNewAlarmSliderValueCell];
        [cell enterFilletMode];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.minValue = 1;
        cell.maxValue = 100;
        cell.strLeftValue = @"1";
        cell.strRightValue = @"100";
        int Volume = [self.volumeOutputManager getLeftVolume];
        cell.titleLabel.text = [NSString stringWithFormat:@"%@ (%d)",TS("TR_Setting_Volume_Setting"),Volume];
        cell.currentValue =Volume;
        [cell updateSliderValue];
        //滑杆滑动的位置回调
        [cell setValueChangedBlock:^(CGFloat value) {
            [SVProgressHUD show];
            [weakSelf.volumeOutputManager setLeftVolume:(int)value];
            [weakSelf.volumeOutputManager setRightVolume:(int)value];
            [weakSelf.volumeOutputManager setVideoVolumeOutputCompleted:^(int result, int channel) {
                if (result < 0) {
                    [MessageUI ShowErrorInt:result];
                }else{
                    [weakSelf.tbList reloadData];
                    [SVProgressHUD showSuccessWithStatus:TS("Save_Success")];
                }
            }];
        }];
         
        return cell;
    }else if ([item.titleName isEqualToString:TS("TR_Setting_Device_Ring_Tone")]){
        //设备铃声
        TitleComboBoxCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleComboBoxCell];
        cell.titleLeftBorder = -5;
        [cell enterFilletMode];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.titleLabel.text = TS("TR_Setting_Device_Ring_Tone");
         
        int type = [self.intellAlertAlarmMannager getVoiceType];
        NSMutableArray *list = [[self.voiceTipTypeManager getVoiceTypeList] mutableCopy];
        NSString *name = @"";
        for (int i = 0; i < list.count; i ++) {
            NSDictionary *dic = [list objectAtIndex:i];
            int voiceEnum = [[dic objectForKey:@"VoiceEnum"] intValue];
            if (voiceEnum == type) {
                name = [dic objectForKey:@"VoiceText"];
                break;
            }
        }
        
        cell.toggleLabel.text = name;
        
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
    WeakSelf(weakSelf);
    if ([item.titleName isEqualToString:TS("TR_Sound_Duration")]){
        XMItemSelectViewController *itemSelectViewController = [[XMItemSelectViewController alloc] init];
        itemSelectViewController.title = TS("TR_Sound_Duration");
        itemSelectViewController.needAutoBack = YES;
        itemSelectViewController.filletMode = YES;
        
        int duration = [self.intellAlertAlarmMannager getDuration];
        
        NSArray *arrayItems = @[[NSString stringWithFormat:@"5%@",TS("s")], [NSString stringWithFormat:@"10%@",TS("s")], [NSString stringWithFormat:@"15%@",TS("s")], [NSString stringWithFormat:@"20%@",TS("s")]];
        NSArray *pamarArr = @[@5,@10,@15,@20];
        int lastIndex = 0;
        
        for (int i = 0; i < pamarArr.count; i++) {
            if ([[pamarArr objectAtIndex:i] intValue] == duration) {
                lastIndex = i;
                break;
            }
        }
        
        itemSelectViewController.arrItems = arrayItems;
        itemSelectViewController.lastIndex = lastIndex;
        itemSelectViewController.itemChangedAction = ^(int index) {
            int value = [[pamarArr objectAtIndex:index] intValue];
            [SVProgressHUD show];
            [weakSelf.intellAlertAlarmMannager setDuration:value];
            [weakSelf.tbList reloadData];
            
            [weakSelf.intellAlertAlarmMannager setIntellAlertAlarmCompleted:^(int result, int channel) {
                if (result < 0) {
                    [MessageUI ShowErrorInt:result];
                }else{
                    
                    [SVProgressHUD showSuccessWithStatus:TS("Save_Success")];
                }
            }];
        };
        [self.navigationController pushViewController:itemSelectViewController animated:YES];
    } else if ([item.titleName isEqualToString:TS("TR_Setting_Device_Ring_Tone")]){
        AlarmVoiceChoseVC *vc = [[AlarmVoiceChoseVC alloc] init];
        vc.devID = self.devID;
        NSMutableArray *dataSource = [NSMutableArray arrayWithCapacity:0];
        
        [dataSource addObject:[[self.voiceTipTypeManager getVoiceTypeList] mutableCopy]];
        vc.arrayDataSource = dataSource;
        int type = [self.intellAlertAlarmMannager getVoiceType];
        int lastIndex = 0;
        NSMutableArray *arrayItems = [NSMutableArray arrayWithCapacity:0];
        for (int i = 0; i < [self.voiceTipTypeManager getVoiceTypeList].count; i++) {
            NSDictionary *dic = [[self.voiceTipTypeManager getVoiceTypeList] objectAtIndex:i];
            [arrayItems addObject:[dic objectForKey:@"VoiceText"]];
            int voiceEnum = [[dic objectForKey:@"VoiceEnum"] intValue];
            if (voiceEnum == type) {
                lastIndex = i;
            }
        }
        vc.selectedVoiceTypeIndex = lastIndex;
        vc.AlarmVoiceChoseVoiceTypeAction = ^(int voiceType) {
//            NSDictionary *dic = [[self.voiceTipTypeManager getVoiceTypeList] objectAtIndex:voiceType];
//            int selectedType = [[dic objectForKey:@"VoiceEnum"] intValue];
            [weakSelf.intellAlertAlarmMannager setVoiceType:voiceType];
            [weakSelf.tbList reloadData];
            [SVProgressHUD show];
            [weakSelf.intellAlertAlarmMannager setIntellAlertAlarmCompleted:^(int result, int channel) {
                if (result < 0) {
                    [MessageUI ShowErrorInt:result];
                }else{
                    
                    [SVProgressHUD showSuccessWithStatus:TS("Save_Success")];
                }
            }];
//            weakSelf.voiceEnable = YES;
//            weakSelf.selectedVoiceType = voiceType;
//            [weakSelf getSelectedInfo];
//            [weakSelf saveAlarmVoiceConfig];
        };
        
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    
     
}




//MARK: - EventAction
//MARK: 点击返回
- (void)btnNavBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}


//MARK: - LazyLoad
- (UIButton *)btnNavBack{
    if (!_btnNavBack) {
        _btnNavBack = [UIButton buttonWithType:UIButtonTypeSystem];
        _btnNavBack.frame = CGRectMake(0, 0, 32, 32);
        [_btnNavBack setBackgroundImage:[UIImage imageNamed:@"UserLoginView-back-nor"] forState:UIControlStateNormal];
        [_btnNavBack addTarget:self action:@selector(btnNavBackClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _btnNavBack;
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
        [_tbList registerClass:[TitleComboBoxCell class] forCellReuseIdentifier:kTitleComboBoxCell];

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
        //报警联动
        OrderListItem *itemAlarmLink = [[OrderListItem alloc] init];
        itemAlarmLink.titleName = TS("TR_AlarmLinkage");
        itemAlarmLink.hidden = NO;
        itemAlarmLink.preCellHeight = 50;
        [firstSection addObject:itemAlarmLink];
        
        //声音报警
        OrderListItem *itemAlarmVoice = [[OrderListItem alloc] init];
        itemAlarmVoice.titleName = TS("TR_Setting_Sound_Alarm");
        itemAlarmVoice.hidden = YES;
        itemAlarmVoice.preCellHeight = 50;
        [secondSection addObject:itemAlarmVoice];
        
        //时间设置
        OrderListItem *itemAlarmTime = [[OrderListItem alloc] init];
        itemAlarmTime.titleName = TS("TR_Sound_Duration");
        itemAlarmTime.hidden = YES;
        itemAlarmTime.preCellHeight = 50;
        [secondSection addObject:itemAlarmTime];
        
        //音量设置
        OrderListItem *itemVolumeSettings = [[OrderListItem alloc] init];
        itemVolumeSettings.titleName = TS("TR_Setting_Volume_Setting");
        itemVolumeSettings.hidden = YES;
        itemVolumeSettings.preCellHeight =  115;
        [secondSection addObject:itemVolumeSettings];
        
        //设备铃声
        OrderListItem *itemDevice_Ring = [[OrderListItem alloc] init];
        itemDevice_Ring.titleName = TS("TR_Setting_Device_Ring_Tone");
        itemDevice_Ring.hidden = YES;
         
        itemDevice_Ring.preCellHeight =50;
        [secondSection addObject:itemDevice_Ring];
        
        
        [_cfgOrderList addObject:firstSection];
        [_cfgOrderList addObject:secondSection];
        
        
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
- (CfgStatusManager *)cfgStatusManager{
    if (!_cfgStatusManager) {
        _cfgStatusManager = [[CfgStatusManager alloc] init];
        [_cfgStatusManager addCfgName:@"IntellAlertAlarmMannager"];
        [_cfgStatusManager addCfgName:@"ChannelVoiceTipTypeManager"];
        [_cfgStatusManager addCfgName:@"VideoVolumeOutputManager"];
        [_cfgStatusManager addCfgName:@"DeviceSystemInfoManger"];
    }
    
    return _cfgStatusManager;
}
- (IntellAlertAlarmMannager *)intellAlertAlarmMannager{
    if (!_intellAlertAlarmMannager) {
        _intellAlertAlarmMannager = [[IntellAlertAlarmMannager alloc] init];
    }
    
    return _intellAlertAlarmMannager;
}

- (ChannelVoiceTipTypeManager *)voiceTipTypeManager{
    if (!_voiceTipTypeManager) {
        _voiceTipTypeManager = [[ChannelVoiceTipTypeManager alloc] init];
    }
    
    return _voiceTipTypeManager;
}

- (VideoVolumeOutputManager *)volumeOutputManager{
    if (!_volumeOutputManager) {
        _volumeOutputManager = [[VideoVolumeOutputManager alloc] init];
    }
    
    return _volumeOutputManager;
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
