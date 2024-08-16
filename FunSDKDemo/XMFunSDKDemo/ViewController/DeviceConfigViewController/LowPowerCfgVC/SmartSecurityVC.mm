//
//  SmartSecurityVC.m
//   
//
//  Created by Tony Stark on 2022/5/19.
//  Copyright © 2022 xiongmaitech. All rights reserved.
//

#import "SmartSecurityVC.h"
#import <FunSDK/FunSDK.h>
#import "TitleComboBoxCell.h"
#import "TitleSwitchCell.h"
#import "CfgStatusManager.h"
#import "BaseJConfigController.h"
#import "SystemFunction.h"
#import "DeviceConfig.h"
#import "UIView+Layout.h"
#import "Alarm_PIR.h"
#import <FunSDK/Fun_MC.h>
#import "PirAlarmManager.h"
#import "IntellAlertAlarmMannager.h"
#import "ChannelVoiceTipTypeManager.h"
#import "VideoVolumeOutputManager.h"
#import "BaseStationSoundSettingCell.h"
#import "XMItemSelectViewController.h"
#import "PirTimeSectionViewController.h"
#import "NetCustomRecordVC.h"
#import "LocalSaveVideoEnableManager.h"
#import "BatteryInfoManager.h"
#import "JFLeftTitleRightTitleArrowCell.h"
#import "HumanDetectionForIPCViewController.h"
#import "HumanDetectManager.h"
#import "OrderListItem.h"
#import "HumanRuleLimitAbilityManager.h"

static NSString *const kTitleComboBoxCell = @"TitleComboBoxCell";
static NSString *const kTitleSwitchCell = @"TitleSwitchCell";
static NSString *const kBaseStationSoundSettingCell = @"BaseStationSoundSettingCell";
static NSString *const kLeftTextRightArrowTableViewCell = @"LeftTextRightArrowTableViewCell";

@interface SmartSecurityVC () <UITableViewDelegate,UITableViewDataSource,DeviceConfigDelegate,XMUIAlertVCDelegate>{
    SystemFunction jSystemFunction;
    JObjArray <Alarm_PIR> jAlarm_PIR; //徘徊检测相关配置
}

@property (nonatomic,strong) UIView *tbContainer;
@property (nonatomic,strong) UITableView *tbFunction;
@property (nonatomic,strong) NSMutableArray *cfgOrderList;              // 配置顺序列表 修改顺序或者分组 增加项目 都要先在这里确定配置位置
@property (nonatomic,strong) NSMutableArray *dataSource;

@property (nonatomic,assign) UI_HANDLE msgHandle;
//MARK: 配置状态管理者
@property (nonatomic,strong) CfgStatusManager *cfgStatusManager;

@property (nonatomic, unsafe_unretained) BOOL bWMessageAlarm;//是否开推送报警
@property (nonatomic,assign) BOOL ifSupportMessageAlarm;     // 是否支持推送报警

@property (nonatomic,assign) BOOL ifSupportPirAlarm;    //是否支持智能报警
@property (nonatomic,assign) BOOL ifSupportHidePirCheckTime;   //是否支持隐藏pir时间
@property (nonatomic,assign) BOOL ifSupportLowPowerSetAlarmLed;//是否支持红蓝报警灯开关
@property (nonatomic,assign) BOOL ifSupportPEAInHumanPed; // 是否支持人形检测
@property (nonatomic,assign) BOOL ifSupportLowPowerLongAlarmRecord; // 是否支持低功耗设备录像时间 10  20 30 设置
//PIR报警数据源
@property (nonatomic,strong) PirAlarmManager *pirAlarmManager;

//人形检测管理者
@property (nonatomic,strong) HumanDetectManager *humanDetectManager;

//MARK: 智能警戒管理者
@property (nonatomic,strong) IntellAlertAlarmMannager *intellAlertAlarmMannager;

//MARK: 警戒声音管理者
@property (nonatomic,strong) ChannelVoiceTipTypeManager *voiceTipTypeManager;

//MARK: 音量输出管理者
@property (nonatomic,strong) VideoVolumeOutputManager *volumeOutputManager;

//MARK: 本地录像开关管理者
@property (nonatomic,strong) LocalSaveVideoEnableManager *localSaveVideoEnableManager;

@property (nonatomic, strong) NSArray *arrayEnableTime; // 合法的设置时间段

//电池和工作模式管理类
@property (nonatomic, strong) BatteryInfoManager *batteryInfoManager;

//需要保存的配置项记录
@property (nonatomic,assign) SMARTSECURITYALARMTYPE chooseAlarmType;

@property (nonatomic,weak) BaseStationSoundSettingCell *pirDetectTimeCell;
//人行检测相关能力集管理者
@property (nonatomic,strong) HumanRuleLimitAbilityManager *humanRuleLimitAbilityManager;


@end

@implementation SmartSecurityVC

- (instancetype)init{
    self = [super init];
    if (self) {
        self.msgHandle = FUN_RegWnd((__bridge void*)self);
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self myLoadData];
    
    [self myConfigNav];
    
    [self myConfigSubview];
    
    [self wakeUpGetConfig];
}

//MARK: - ConfigNav
- (void)myConfigNav{
    self.navigationItem.title = TS("TR_Smart_Alarm");
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, 0, 32, 32);
    [leftBtn addTarget:self action:@selector(btnBackClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarBtn = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    
    self.navigationItem.leftBarButtonItem = leftBarBtn;
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setTitle:TS("finish") forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    rightBtn.frame = CGRectMake(0, 0, 48, 32);
    [rightBtn addTarget:self action:@selector(saveBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarBtn = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
}

//MARK: - ConfigSubview
- (void)myConfigSubview{
    [self.view addSubview:self.tbContainer];
    
    [self.tbContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)myLoadData{
    
}

//MARK: wake up to get config
- (void)wakeUpGetConfig{
    //低功耗先唤醒再操作
    DeviceObject *device = [[DeviceControl getInstance] GetDeviceObjectBySN: self.devID];
    self.bWMessageAlarm = device.eFunDevStateNotCode;
    
    if (device.nType == XM_DEV_CAT || device.nType == XM_DEV_DOORBELL || device.nType == CZ_DOORBELL || device.nType == XM_DEV_LOW_POWER || device.nType == XM_DEV_LOCK_CAT) {
        [SVProgressHUD showWithStatus:TS("Waking_up")];
        FUN_DevWakeUp(self.msgHandle, CSTR(self.devID), 0);
        return;
    }else{
        [SVProgressHUD show];
        [self requestGetAllAbility];
    }
}

#pragma mark -- 获取设备相关能力级
- (void)requestGetAllAbility{
    jSystemFunction.SetName(JK_SystemFunction);
    DeviceConfig* systemFunction = [[DeviceConfig alloc] initWithJObject:&jSystemFunction];
    systemFunction.devId = self.devID;
    systemFunction.channel = -1;
    systemFunction.isSet = NO;
    systemFunction.delegate = self;
    [self requestGetConfig:systemFunction];
    
    DeviceObject *device = [[DeviceControl getInstance] GetDeviceObjectBySN: self.devID];
    if ((device.ret != 0) || [[LoginShowControl getInstance] getLoginType] == loginTypeNone || [[LoginShowControl getInstance] getLoginType] == loginTypeLocal) {
        self.ifSupportMessageAlarm = NO;
        [self addTableViewItem:TS("App_Message_accept") hidden:YES];
    }else{
        //支持订阅的设备才获取是否支持微信报警推送
//        FUN_DevGetConfig_Json(self.msgHandle, [self.devID UTF8String], "SystemInfo", 1024);
//        
//        if ([LineNotifyManager supportLineNotify]) {
//            self.ifSupportLineAlarm = YES;
//            [self addTableViewItem:TS("open_line_alarm") hidden:NO];
//            
//            __weak typeof(self) weakSelf = self;
//            [self.lineNotifyManager checkState:self.devID completed:^(int result, BOOL open) {
//                [weakSelf.tbFunction reloadData];
//                if (result >= 0) {
//                    [SVProgressHUD dismiss];
//                }else{
//                    NSString *errorString = [SDKParser parseError:result];
//                    [SVProgressHUD showErrorWithStatus:errorString];
//                }
//            }];
//        }
    }
}

-(void)getConfig:(DeviceConfig *)config result:(int)result{
    if (result >= 0) {
        if ([config.name isEqualToString:OCSTR(JK_SystemFunction)]) {
            self.ifSupportLowPowerDoubleLightToLightingSwitch = jSystemFunction.mOtherFunction.SupportLowPowerDoubleLightToLightingSwitch.ToBool();
            self.ifSupportPirAlarm = jSystemFunction.mOtherFunction.SupportPirAlarm.ToBool();
            self.ifSupportHidePirCheckTime = jSystemFunction.mOtherFunction.SupportHidePirCheckTime.ToBool();
            self.ifSupportLowPowerSetAlarmLed = jSystemFunction.mOtherFunction.SupportLowPowerSetAlarmLed.ToBool();
            
            //SupportPirAlarm 需要特殊处理 如果没有该字段 默认是True
            if (![config.jLastStrCfg containsString:@"SupportPirAlarm"]){
                 self.ifSupportPirAlarm = YES;
            }
            
            //录像开关
            __weak typeof(self) weakSelf = self;
            [self.cfgStatusManager addCfgName:@"Local_Save_Vdeio_Enable_Cfg"];
            [self.localSaveVideoEnableManager requestLocalSaveVideoEnableDevice:self.devID completed:^(int result) {
                if (result < 0) {
                    [weakSelf getConfigFailed:result];
                }else{
                    [weakSelf.cfgStatusManager changeCfgStatus:XMCfgStatus_Success name:@"Local_Save_Vdeio_Enable_Cfg"];
                    if ([weakSelf.cfgStatusManager checkAllCfgFinishedRequest]) {
                        [SVProgressHUD dismiss];
                        [weakSelf.tbFunction reloadData];
                    }
                }
            }];
            
            //是否支持低功耗模式和常电模式
            DeviceObject *devInfo = [[DeviceControl getInstance] GetDeviceObjectBySN: self.devID];
            devInfo.sysFunction.iSupportLPWorkModeSwitchV2 = jSystemFunction.mOtherFunction.SupportLPWorkModeSwitchV2.ToBool() ? 1 : 0;
            
            if(devInfo.sysFunction.iSupportLPWorkModeSwitchV2){
                [self addTableViewItem:TS("TR_Working_Mode") hidden:NO];
                [self.tbFunction reloadData];
                
                [self.cfgStatusManager addCfgName:@"LPWorkModeSwitchV2_cfg"];
                [self.batteryInfoManager getLPWorkModeSwitchV2:self.devID Completion:^(int result) {
                    if (result < 0) {
                        [weakSelf getConfigFailed:result];
                    }else{
                        [weakSelf.cfgStatusManager changeCfgStatus:XMCfgStatus_Success name:@"LPWorkModeSwitchV2_cfg"];
                        [weakSelf.batteryInfoManager LPDevWorkMode:weakSelf.devID ActualTimeValue:NO Completion:^(LPDevWorkMode value) {
                            
                            if(value == LPDevWorkMode_LowConsumption ||
                               value == LPDevWorkMode_unkown){
                                [weakSelf configUIAboutPIRAlarm:NO];
                            }else{
                                //常电模式
                                
                                int WorkStateNow = [weakSelf.batteryInfoManager getWorkStateNow];
                                if (WorkStateNow == 0) {
                                    [weakSelf configUIAboutPIRAlarm:NO];
                                } else {
                                    [weakSelf configUIAboutPIRAlarm:YES];
                                }
                                [weakSelf updateList];
                            }
                            if ([weakSelf.cfgStatusManager checkAllCfgFinishedRequest]) {
                                [SVProgressHUD dismiss];
                                [weakSelf.tbFunction reloadData];
                            }
                        }];
                    }
                }];
                
                [self.cfgStatusManager addCfgName:@"MotionDetect_cfg"];
            }else{
                self.tbFunction.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
                [self configUIAboutPIRAlarm:NO];
            }
            
            //摄像机警戒设置相关模块
            if (jSystemFunction.mAlarmFunction.IntellAlertAlarm.ToBool()) {
                if ([self.pirAlarmManager getEnable]){
                    [self addTableViewItem:TS("TR_Camera_Alert_Setting") hidden:NO];
                }
                [self addTableViewItem:TS("TR_Continuous_alarm_time") hidden:NO];
                if (self.ifSupportLowPowerSetAlarmLed){
                    [self addTableViewItem:TS("TR_Alarm_Light_Switch") hidden:NO];
                }
                
                //获取智能警戒配置
                [self.cfgStatusManager addCfgName:@"IntellAlertAlarmMannager_cfg"];
                [self.intellAlertAlarmMannager getIntellAlertAlarm:self.devID channel:-1 completed:^(int result,int channel) {
                    if (result < 0) {
                        [weakSelf getConfigFailed:result];
                    }else{
                        [weakSelf.cfgStatusManager changeCfgStatus:XMCfgStatus_Success name:@"IntellAlertAlarmMannager_cfg"];
                        if ([weakSelf.cfgStatusManager checkAllCfgFinishedRequest]) {
                            [SVProgressHUD dismiss];
                            [weakSelf.tbFunction reloadData];
                        }
                    }
                }];
                
                [self.cfgStatusManager addCfgName:@"ChannelVoiceTipTypeManager"];
                [self.voiceTipTypeManager getChannelVoiceTipType:self.devID channel:-1 completed:^(int result, int channel) {
                    if (result < 0) {
                        if (result == -11406 || result == -400009) {
                            //不支持不显示，当获取成功
                            [weakSelf addTableViewItem:TS("TR_Alarm_Tones") hidden:YES];
                            [weakSelf.cfgStatusManager changeCfgStatus:XMCfgStatus_NotSupport name:@"ChannelVoiceTipTypeManager"];
                            
                            if ([weakSelf.cfgStatusManager checkAllCfgFinishedRequest]) {
                                [SVProgressHUD dismiss];
                                [weakSelf.tbFunction reloadData];
                            }
                            return;
                        }
                        
                        [weakSelf getConfigFailed:result];
                    }else{
                        [weakSelf.cfgStatusManager changeCfgStatus:XMCfgStatus_Success name:@"ChannelVoiceTipTypeManager"];
                        if ([weakSelf.cfgStatusManager checkAllCfgFinishedRequest]) {
                            [SVProgressHUD dismiss];
                            [weakSelf.tbFunction reloadData];
                        }
                    }
                }];
                
                //报警音量设置
                if (jSystemFunction.mOtherFunction.SupportSetVolume.ToBool()) {
                    [self addTableViewItem:TS("TR_Alarm_volume") hidden:NO];
                    
                    [self.cfgStatusManager addCfgName:@"VideoVolumeOutputManager_cfg"];
                    [self.volumeOutputManager getVideoVolumeOutput:self.devID channel:-1 completed:^(int result,int channel) {
                        if (result < 0) {
                            [weakSelf getConfigFailed:result];
                        }else{
                            [weakSelf.cfgStatusManager changeCfgStatus:XMCfgStatus_Success name:@"VideoVolumeOutputManager_cfg"];
                            
                            if ([weakSelf.cfgStatusManager checkAllCfgFinishedRequest]) {
                                [SVProgressHUD dismiss];
                                [weakSelf.tbFunction reloadData];
                            }
                        }
                    }];
                }
                
                [self addTableViewItem:TS("TR_Alarm_Tones") hidden:NO];
            }
            
            if ([self.cfgStatusManager checkAllCfgFinishedRequest]) {
                [SVProgressHUD dismiss];
                [self.tbFunction reloadData];
            }
        }
    }else if(result == EE_DVR_PASSWORD_NOT_VALID || result == EE_DVR_LOGIN_USER_NOEXIST){
        [SVProgressHUD showErrorWithStatus: [NSString stringWithFormat: @"%d", result]];
    }else{
        [self getConfigFailed:result];
   }
}

//支持PIR移动侦测
-(void)configUIAboutPIRAlarm:(BOOL)NoSleep{
    if (self.ifSupportPirAlarm) {
        if(NoSleep){
            [self addTableViewItem:TS("TR_PIR_Detection") hidden:NoSleep];
            [self addTableViewItem:TS("TR_Pir_duration") hidden:NoSleep];
            [self addTableViewItem:TS("TR_Pir_Sensitivity") hidden:NoSleep];
            [self addTableViewItem:TS("TR_Microwave_Detecion") hidden:NoSleep];
            [self addTableViewItem:TS("TR_Detection_Schedule") hidden:NoSleep];
        }else{
            [self addTableViewItem:TS("TR_PIR_Detection") hidden:NO];
            
            if (self.ifSupportHidePirCheckTime) {
                [self addTableViewItem:TS("TR_Pir_duration") hidden:YES];
            }else{
                [self addTableViewItem:TS("TR_Pir_duration") hidden:NO];
            }
            
            //PIR灵敏度
            if(jSystemFunction.mOtherFunction.SupportPirSensitive.Value()) {
                [self addTableViewItem:TS("TR_Pir_Sensitivity") hidden:NO];
            }
            
            //微波移动侦测
            if(jSystemFunction.mOtherFunction.SupportPIRMicrowaveAlarm.Value()) {
                [self addTableViewItem:TS("TR_Microwave_Detecion") hidden:NO];
            }
            
            //报警时间段
            if(jSystemFunction.mOtherFunction.SupportPirTimeSection.Value()) {
                [self addTableViewItem:TS("TR_Detection_Schedule") hidden:NO];
            }
        }

        //录像时间
        [self addTableViewItem:TS("TR_Recording_Duration") hidden:NO];
        //支持低功耗设备录像时间设置10 20  30
        if (jSystemFunction.mOtherFunction.SupportLowPowerLongAlarmRecord.Value()) {
            self.ifSupportLowPowerLongAlarmRecord = YES;
        } else {
            self.ifSupportLowPowerLongAlarmRecord = NO;
        }
        
        
        
        //人形侦测
        __weak typeof(self) weakSelf = self;
        if (jSystemFunction.mAlarmFunction.PEAInHumanPed.Value()) {
            self.ifSupportPEAInHumanPed = YES;
            [self addTableViewItem:TS("Human_Detection") hidden:NO];
            
            [self.cfgStatusManager addCfgName:@"Human_Detection_cfg"];
            [weakSelf.humanDetectManager request:^(int result) {
                if (result >= 0) {
                    [weakSelf.cfgStatusManager changeCfgStatus:XMCfgStatus_Success name:@"Human_Detection_cfg"];
                    if ([weakSelf.cfgStatusManager checkAllCfgFinishedRequest]) {
                        [SVProgressHUD dismiss];
                        [weakSelf.tbFunction reloadData];
                    }
                }else{
                    [weakSelf getConfigFailed:result];
                    return;
                }
            }];
        }
        
        //获取PIR相关配置
        [self.cfgStatusManager addCfgName:@"Alarm_PIR_cfg"];
        [self.pirAlarmManager getPirAlarm:self.devID channel:-1 completed:^(int result, int channel) {
            if (result >= 0) {
                if (jSystemFunction.mAlarmFunction.IntellAlertAlarm.ToBool()){
                    [weakSelf addTableViewItem:TS("TR_Camera_Alert_Setting") hidden:![weakSelf.pirAlarmManager getEnable]];
                }
                
                [weakSelf.cfgStatusManager changeCfgStatus:XMCfgStatus_Success name:@"Alarm_PIR_cfg"];
                if ([weakSelf.cfgStatusManager checkAllCfgFinishedRequest]) {
                    [SVProgressHUD dismiss];
                    [weakSelf.tbFunction reloadData];
                }
            }else{
                [weakSelf getConfigFailed:result];
            }
        }];
    }
}

//MARK: wake up to set config
- (void)wakeUpSetConfig{
    //低功耗先唤醒再操作
    DeviceObject *device = [[DeviceControl getInstance] GetDeviceObjectBySN: self.devID];
    if (device.nType == XM_DEV_CAT || device.nType == XM_DEV_DOORBELL || device.nType == CZ_DOORBELL || device.nType == XM_DEV_LOW_POWER || device.nType == XM_DEV_LOCK_CAT) {
        [SVProgressHUD show];
        FUN_DevWakeUp(self.msgHandle, CSTR(self.devID), 1);
        return;
    }else{
        [SVProgressHUD show];
        [self.cfgStatusManager resetAllCfgStatus];
        [self requestSetAllConfig];
    }
}

- (void)requestSetAllConfig{
    //下面三个配置只需获取即可,做参数判断，无需保存
    [self.cfgStatusManager changeCfgStatus:XMCfgStatus_Success name:@"humanRuleLimitAbility_cfg"];
    [self.cfgStatusManager changeCfgStatus:XMCfgStatus_Success name:@"LPWorkModeSwitchV2_cfg"];
    [self.cfgStatusManager changeCfgStatus:XMCfgStatus_Success name:@"MotionDetect_cfg"];
    
    switch (self.chooseAlarmType) {
        case SMARTSECURITYALARMTYPE_VideoEnable:
        {
            [self setVideoEnable];
        }
            break;
        case SMARTSECURITYALARMTYPE_PirAlarm:
        {
            [self setPirAlarm];
        }
            break;
        case SMARTSECURITYALARMTYPE_IntellAlertAlarmAndVideoVolumeOutput:
        {
            [self setIntellAlertAlarmAndVideoVolumeOutput];
        }
            break;

        case SMARTSECURITYALARMTYPE_MessageAlarm:
        {
            [self setSupportMessageAlarm];
        }
            break;
        default:
            break;
    }
}

//MARK: 本地录像是否保存
- (void)setVideoEnable {
    __weak typeof(self) weakSelf = self;

    [self.localSaveVideoEnableManager saveCompleted:^(int result) {
        if (result >= 0) {
            [weakSelf.cfgStatusManager changeCfgStatus:XMCfgStatus_Success name:@"Local_Save_Vdeio_Enable_Cfg"];
            [weakSelf checkRequestSetCompleted];
        }else{
            [weakSelf dealSetConfigFailed:result];
        }
    }];
}
//MARK: 人体感应报警配置
- (void)setPirAlarm {
    __weak typeof(self) weakSelf = self;
    if (self.ifSupportPirAlarm) {
        [self.pirAlarmManager setPirAlarmCompleted:^(int result, int channel) {
            if (result >= 0) {
                [weakSelf.cfgStatusManager changeCfgStatus:XMCfgStatus_Success name:@"Alarm_PIR_cfg"];
                [weakSelf checkRequestSetCompleted];
            }else{
                [weakSelf dealSetConfigFailed:result];
            }
        }];
        
        if (jSystemFunction.mAlarmFunction.PEAInHumanPed.Value()) {
            [self.humanDetectManager saveConfig:^(int result) {
                if (result >= 0) {
                    [weakSelf.cfgStatusManager changeCfgStatus:XMCfgStatus_Success name:@"Human_Detection_cfg"];
                    [weakSelf checkRequestSetCompleted];
                }else{
                    [weakSelf dealSetConfigFailed:result];
                }
            }];
        }
    }
}
//MARK: 报警音和智能报警一块保存
- (void)setIntellAlertAlarmAndVideoVolumeOutput {
    __weak typeof(self) weakSelf = self;

    if (jSystemFunction.mAlarmFunction.IntellAlertAlarm.ToBool()) {
        //报警音和智能报警一块保存
        [self.cfgStatusManager changeCfgStatus:XMCfgStatus_Success name:@"ChannelVoiceTipTypeManager"];
        [self.intellAlertAlarmMannager setIntellAlertAlarmCompleted:^(int result, int channel) {
            if (result >= 0) {
                [weakSelf.cfgStatusManager changeCfgStatus:XMCfgStatus_Success name:@"IntellAlertAlarmMannager_cfg"];
                [weakSelf checkRequestSetCompleted];
            }else{
                [weakSelf dealSetConfigFailed:result];
            }
        }];
        
        //报警音量设置
        if (jSystemFunction.mOtherFunction.SupportSetVolume.ToBool()) {
            [self.volumeOutputManager setVideoVolumeOutputCompleted:^(int result, int channel) {
                if (result >= 0) {
                    [weakSelf.cfgStatusManager changeCfgStatus:XMCfgStatus_Success name:@"VideoVolumeOutputManager_cfg"];
                    [weakSelf checkRequestSetCompleted];
                }else{
                    [weakSelf dealSetConfigFailed:result];
                }
            }];
        }
    }
}
////MARK: 微信报警设置
//- (void)setWXAlarm {
//    __weak typeof(self) weakSelf = self;
//
//    if (self.ifSupportWXAlarm) {
//        [self.cfgStatusManager addCfgName:@"WXAlarmListen_Cfg"];
//        if (self.bWXAlarm) {
//            //开启微信报警
//            FUN_SysOpenWXAlarmListen(weakSelf.msgHandle, CSTR(weakSelf.devID));
//        } else {
//            //关闭微信报警
//            FUN_SysCloseWXAlarmListen(weakSelf.msgHandle, CSTR(weakSelf.devID));
//        }
//    }
//}
//MARK: 是否支持推送报警
- (void)setSupportMessageAlarm {
    if (self.ifSupportMessageAlarm) {
        __weak typeof(self) weakSelf = self;
        [self.cfgStatusManager addCfgName:@"MessageAlarm_Cfg"];
        if (self.bWMessageAlarm) {
            //只订阅登录过的设备
            NSString *userName = [[LoginShowControl getInstance] getLoginUserName];
            NSString *psw = [[LoginShowControl getInstance] getLoginPassword];
            DeviceObject *dev = [[DeviceControl getInstance] GetDeviceObjectBySN: weakSelf.devID];
            MC_LinkDev(weakSelf.msgHandle, CSTR(weakSelf.devID), CSTR(userName), CSTR(psw), 0, CSTR(dev.deviceName));
            }
        }else {
            MC_UnlinkDev(self.msgHandle, CSTR(self.devID));
        }
}


- (void)dealSetConfigFailed:(int)result{
    [SVProgressHUD showErrorWithStatus: [NSString stringWithFormat: @"%d", result]];
}

- (void)checkRequestSetCompleted{
//   if ([self.cfgStatusManager checkAllCfgFinishedRequest]) {
//       [SVProgressHUD setMinimumDismissTimeInterval:1];
       [SVProgressHUD showSuccessWithStatus:TS("Save_Success")];
       
//       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//           [self btnBackClicked];
//       });
//    }
}

//MARK: - GetConfigRequest

//MARK: - SetConfigRequest

//MARK: EventAction
//MARK: 点击返回
- (void)btnBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

//MARK: 点击保存
- (void)saveBtnClicked{
    [self wakeUpSetConfig];
}

//MARK: 增加配置项
-(void)addTableViewItem:(NSString *)title hidden:(BOOL)hidden{
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

//MARK: - Delegate
//MARK: UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *sections = [self.dataSource objectAtIndex:section];
        
    return sections.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *sections = [self.dataSource objectAtIndex:indexPath.section];
    OrderListItem *item = [sections objectAtIndex:indexPath.row];
    
    if ([item.titleName isEqualToString:TS("TR_Alarm_volume")] ||
        [item.titleName isEqualToString:TS("TR_Pir_duration")]){
        return 100;
    }else if ([item.titleName isEqualToString:TS("App_Message_accept")]){
        return cTableViewCellHeight;
    }else if ([item.titleName isEqualToString:TS("Wechat_Message_accept")] ||
              [item.titleName isEqualToString:TS("open_line_alarm")]){
        return 75;
    }else if ([item.titleName isEqualToString:TS("Show_traces")]){
       
        return 30 + cTableViewCellHeight;
    }else if ([item.titleName isEqualToString:TS("TR_Rule_Setting")]){

        return 20 + cTableViewCellHeight;
    }
    
    return cTableViewCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    NSArray *sections = [self.dataSource objectAtIndex:section];
    if (sections.count == 0) {
        return 0;
    }
    return cTableViewFilletLFBorder * 0.5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    NSArray *sections = [self.dataSource objectAtIndex:section];
    if (sections.count == 0) {
        return 0;
    }
    return cTableViewFilletLFBorder * 0.5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *sections = [self.dataSource objectAtIndex:indexPath.section];
    OrderListItem *item = [sections objectAtIndex:indexPath.row];
    if([item.titleName isEqualToString:TS("TR_Working_Mode")]){
        TitleComboBoxCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleComboBoxCell];
        cell.titleLeftBorder = -10;
        [cell enterFilletMode];
        
        cell.titleLabel.text = TS("TR_Working_Mode");
        [cell makeArrowRotation:0 reset:YES animation:YES];
        cell.lbRight.hidden = NO;
        cell.lbRight.textColor = [UIColor orangeColor];
        cell.toggleLabel.hidden = YES;
        __weak typeof(self) weakSelf = self;

        [self.batteryInfoManager LPDevWorkMode:self.devID ActualTimeValue:NO Completion:^(LPDevWorkMode value) {
            //默认低功耗
            cell.lbRight.text = TS("TR_SuperPowerMode");
            
            if(value == LPDevWorkMode_NoSleep){
                //常电
                int WorkStateNow = [weakSelf.batteryInfoManager getWorkStateNow];
                if (WorkStateNow == 0) {
                    cell.lbRight.text = [NSString stringWithFormat:@"%@(%@)",TS("TR_SmartPowerMode"),TS("TR_Smart_PowerSaving")];
                } else if (WorkStateNow == 1) {
                    cell.lbRight.text = [NSString stringWithFormat:@"%@(%@)",TS("TR_SmartPowerMode"),TS("TR_Smart_PowerReal")];
                } else {
                    cell.lbRight.text = TS("TR_SmartPowerMode");
                }
                
            }
        }];
        
        [cell makeRightLableLarge:YES];
        [cell noDisplayArrow];
        [cell.lbRight mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(cell.accessoryImageView.mas_left);
            make.centerY.equalTo(self);
            make.height.equalTo(@35);
            make.width.equalTo(@140);
        }];
        return cell;
        
    }else if ([item.titleName isEqualToString:TS("App_Message_accept")]){//手机软件消息接受
        TitleSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleSwitchCell];
        cell.titleLabel.text = TS("App_Message_accept");
        cell.toggleSwitch.on = self.bWMessageAlarm;
        
        __weak typeof(self) weakSelf = self;
        cell.toggleSwitchStateChangedAction = ^(BOOL on) {
            if ([[LoginShowControl getInstance] getLoginType] == loginTypeLocal) {
                
                [SVProgressHUD showErrorWithStatus:TS("Local_Login_Alarm_Msg_Tip")];
                
                [weakSelf.tbFunction reloadData];
                return;
            }
            
            weakSelf.bWMessageAlarm = on;
            [weakSelf.tbFunction reloadData];
            weakSelf.chooseAlarmType = SMARTSECURITYALARMTYPE_MessageAlarm;
            [weakSelf wakeUpSetConfig];
            
        };
        
        return cell;
    }
//    else if ([item.titleName isEqualToString:TS("Wechat_Message_accept")]){
//        TitleSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleSwitchCell];
//        cell.titleLabel.text = TS("Wechat_Message_accept");
//        
//        cell.toggleSwitch.on = self.bWXAlarm;
//        __weak typeof(self) weakSelf = self;
//        cell.toggleSwitchStateChangedAction = ^(BOOL on) {
//            if (on) {
//                if(![[[NSUserDefaults standardUserDefaults]valueForKey:@"WeChatNoTip"] boolValue]) {
//                    XMWechatTipView *tipView = [[XMWechatTipView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
//                    [tipView show];
//                }
//            }
//            weakSelf.bWXAlarm = on;
//            [weakSelf.tbFunction reloadData];
//            weakSelf.chooseAlarmType = SMARTSECURITYALARMTYPE_WxAlarm;
//            [weakSelf wakeUpSetConfig];
//        };
//        
//        return cell;
//    }else if ([item.titleName isEqualToString:TS(@"open_line_alarm")]){
//        TitleSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleSwitchCell];
//        cell.titleLeftBorder = -5;
//        [cell enterFilletMode];
//        cell.titleLabel.text = TS(@"open_line_alarm");
//        [cell subTitleVisible:YES ContentRich:NO];
//        cell.lbDetail.numberOfLines = 2;
//        cell.lbDetail.text = TS(@"line_alarm_tip");
//        
//        cell.toggleSwitch.on = self.lineNotifyManager.open;
//        __weak typeof(self) weakSelf = self;
//        cell.toggleSwitchStateChangedAction = ^(BOOL on) {
//            weakSelf.bLineAlarm = on;
//            [weakSelf.tbFunction reloadData];
//            weakSelf.chooseAlarmType = SMARTSECURITYALARMTYPE_LineAlarm;
//            [weakSelf wakeUpSetConfig];
//        };
//        
//        return cell;
//    }
        else if ([item.titleName isEqualToString:TS("ad_record_mode")]){
        TitleSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleSwitchCell];
        cell.titleLeftBorder = -5;
        [cell enterFilletMode];
        cell.titleLabel.text = TS("ad_record_mode");
        [cell subTitleVisible:NO ContentRich:NO];
        
        cell.toggleSwitch.on = [self.localSaveVideoEnableManager getLocalVdeioEnable];
        __weak typeof(self) weakSelf = self;
        cell.toggleSwitchStateChangedAction = ^(BOOL on) {
            [weakSelf.localSaveVideoEnableManager setLocalVideoEnable:on];
            [weakSelf.tbFunction reloadData];
            weakSelf.chooseAlarmType = SMARTSECURITYALARMTYPE_VideoEnable;
            [weakSelf wakeUpSetConfig];
        };
        
        return cell;
    }else if ([item.titleName isEqualToString:TS("TR_PIR_Detection")]){
        TitleSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleSwitchCell];
        cell.titleLeftBorder = -5;
        [cell enterFilletMode];
        cell.titleLabel.text = TS("TR_PIR_Detection");
        [cell subTitleVisible:NO ContentRich:NO];
        cell.toggleSwitch.on = [self.pirAlarmManager getEnable];
        __weak typeof(self) weakSelf = self;
        cell.toggleSwitchStateChangedAction = ^(BOOL on) {
            [weakSelf.pirAlarmManager setEnable:on];
            if ((jSystemFunction.mAlarmFunction.IntellAlertAlarm.ToBool())){
                //和android统一
                [weakSelf addTableViewItem:TS("TR_Camera_Alert_Setting") hidden:!on];
            }
            [weakSelf.tbFunction reloadData];
            weakSelf.chooseAlarmType = SMARTSECURITYALARMTYPE_PirAlarm;
            [weakSelf wakeUpSetConfig];
        };
        
        return cell;
    }else if ([item.titleName isEqualToString:TS("TR_Pir_Sensitivity")]){
        TitleComboBoxCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleComboBoxCell];
        cell.titleLeftBorder = -10;
        [cell enterFilletMode];
        cell.titleLabel.text = TS("TR_Pir_Sensitivity");
        cell.toggleLabel.text = [self getSensitivityValue:[self.pirAlarmManager getPirSensitive]];
        
        //防止Cell复用
        [cell makeRightLableLarge:NO];
        cell.toggleLabel.hidden = NO;
        cell.lbRight.hidden = YES;
        [cell displayArrow];
        return cell;
    }else if ([item.titleName isEqualToString:TS("TR_Pir_duration")]){//PIR检测时长
        BaseStationSoundSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:kBaseStationSoundSettingCell];
        cell.titleLabel.text = TS("TR_Pir_duration");
        //只能设置下述25个值，所以slider的滑动范围是0~24
        NSArray* checkTimeArray = @[@(0.6),@1,@2,@3,@4,@5,@6,@7,@8,@9,@10,@15,@20,@25,@30,@40,@50,@60,@70,@80,@90,@100,@120,@140,@160,@180];
        cell.slider.minimumValue = 0;
        cell.slider.maximumValue = checkTimeArray.count - 1;
        
        float nowValue = [self.pirAlarmManager getPIRCheckTime];
        if (nowValue < 0.6) {
            nowValue = 0.6;
        }
        
        int value = 0;
        for (int i = 0; i < self.arrayEnableTime.count; i ++) {
            if (nowValue == [self.arrayEnableTime[i] floatValue]) {
                value = i;
                break;
            }
        }
        
        [cell setSliderValue:value];
        
        [cell.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@10);
        }];
        
        NSString *duringStr = [NSString stringWithFormat:@"%i%@",(int)nowValue,TS("s")];
        if (nowValue < 1) {
            duringStr = [NSString stringWithFormat:@"%0.1f%@",nowValue,TS("s")];
        }
        
        self.pirDetectTimeCell = cell;
        cell.lbLeftSlider.text = @"";
        cell.lbRightSlider.text = duringStr;
        cell.lbValue.hidden = YES;
        __weak typeof(self) weakSelf = self;
        cell.soundSettingCellSliderValueChanged = ^(CGFloat value) {
            int index = value;
            if (index < weakSelf.arrayEnableTime.count) {
                CGFloat PIRTime = [weakSelf.arrayEnableTime[index] floatValue];
                
                [weakSelf.pirAlarmManager setPIRCheckTime:PIRTime];
                float nowValue = [weakSelf.pirAlarmManager getPIRCheckTime];
                if (nowValue < 0.6) {
                    nowValue = 0.6;
                }
                NSString *duringStr = [NSString stringWithFormat:@"%i%@",(int)nowValue,TS("s")];
                if (nowValue < 1) {
                    duringStr = [NSString stringWithFormat:@"%0.1f%@",nowValue,TS("s")];
                }
                weakSelf.pirDetectTimeCell.lbRightSlider.text = duringStr;
            }
        };
        cell.soundSettingCellSliderTouchEndAction = ^(CGFloat value) {
            int index = value;
            if (index < weakSelf.arrayEnableTime.count) {
                CGFloat PIRTime = [weakSelf.arrayEnableTime[index] floatValue];
                
                [weakSelf.pirAlarmManager setPIRCheckTime:PIRTime];
                float nowValue = [weakSelf.pirAlarmManager getPIRCheckTime];
                if (nowValue < 0.6) {
                    nowValue = 0.6;
                }
                NSString *duringStr = [NSString stringWithFormat:@"%i%@",(int)nowValue,TS("s")];
                if (nowValue < 1) {
                    duringStr = [NSString stringWithFormat:@"%0.1f%@",nowValue,TS("s")];
                }
                weakSelf.pirDetectTimeCell.lbRightSlider.text = duringStr;
            }

            weakSelf.chooseAlarmType = SMARTSECURITYALARMTYPE_PirAlarm;
            [weakSelf wakeUpSetConfig];
            
            
        };
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if ([item.titleName isEqualToString:TS("TR_Microwave_Detecion")]){
        TitleComboBoxCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleComboBoxCell];
        cell.titleLeftBorder = -10;
        [cell enterFilletMode];
        cell.titleLabel.text = TS("TR_Microwave_Detecion");
        cell.toggleLabel.text = [self getAlarmTypeValue:[self.pirAlarmManager getPIRAlarmType]];
        
        //防止Cell复用
        [cell makeRightLableLarge:NO];
        cell.toggleLabel.hidden = NO;
        cell.lbRight.hidden = YES;
        return cell;
    }else if ([item.titleName isEqualToString:TS("Human_Detection")]){//人形侦测
        TitleSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleSwitchCell];
        cell.titleLeftBorder = -5;
        [cell enterFilletMode];
        cell.titleLabel.text = TS("Human_Detection");
        [cell subTitleVisible:NO ContentRich:NO];
        cell.toggleSwitch.on = [self.humanDetectManager getHumanDetectEnable];
        __weak typeof(self) weakSelf = self;
        cell.toggleSwitchStateChangedAction = ^(BOOL on) {
            [weakSelf.humanDetectManager setHumanDetectEnable:on];
            
            [weakSelf updateList];
            weakSelf.chooseAlarmType = SMARTSECURITYALARMTYPE_PirAlarm;
            [weakSelf wakeUpSetConfig];
        };
        
        return cell;
    }else if ([item.titleName isEqualToString:TS("TR_Detection_Schedule")]){//侦测时间段
        TitleComboBoxCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleComboBoxCell];
        cell.titleLeftBorder = -10;
        [cell enterFilletMode];
        cell.titleLabel.text = TS("TR_Detection_Schedule");
        
//        if ([self.pirAlarmManager getPirTimeSection]) {
//            [cell makeRightLableLarge:YES];
//            NSString *startTime = [self.pirAlarmManager getPirTimeSectionStartTime];
//            NSString *endTime = [self.pirAlarmManager getPirTimeSectionEndTime];
//            NSString *weekStr = [self getSelectedWeekStr:[self.pirAlarmManager getPirTimeSectionWeekMask]];
//
//            NSString *sectionInfo = [NSString stringWithFormat:@"%@~%@ \n%@",startTime,endTime,weekStr];
//            cell.lbRight.text = sectionInfo;
//            cell.lbRight.hidden = NO;
//            cell.toggleLabel.text = @"";
//        }else{
            [cell makeRightLableLarge:NO];
            cell.toggleLabel.text = @"";
            cell.toggleLabel.hidden = NO;
            cell.lbRight.hidden = YES;
        [cell displayArrow];
//        }
        return cell;
    }else if ([item.titleName isEqualToString:TS("TR_Recording_Duration")]){//录像时间
        TitleComboBoxCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleComboBoxCell];
        cell.titleLeftBorder = -10;
        [cell enterFilletMode];
        cell.titleLabel.text = TS("TR_Recording_Duration");
        
        cell.toggleLabel.text = [NSString stringWithFormat:@"%d%@",[self.pirAlarmManager getRecordLatch],TS("s")];
        
        
        //防止Cell复用
        [cell makeRightLableLarge:NO];
        cell.lbRight.hidden = YES;
        cell.toggleLabel.hidden = NO;
        [cell makeArrowRotation:0 reset:YES animation:YES];
        return cell;
    }else if ([item.titleName isEqualToString:TS("TR_Camera_Alert_Setting")]){//摄像机警戒设置
        TitleSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleSwitchCell];
        cell.titleLeftBorder = -5;
        [cell enterFilletMode];
        cell.titleLabel.text = TS("TR_Intelligent_Warning_Switch");
        
        [cell subTitleVisible:NO ContentRich:NO];
        cell.toggleSwitch.on = [self.intellAlertAlarmMannager getEnable];
        __weak typeof(self) weakSelf = self;
        cell.toggleSwitchStateChangedAction = ^(BOOL on) {
            [weakSelf.intellAlertAlarmMannager setEnable:on];
            [weakSelf.tbFunction reloadData];
            weakSelf.chooseAlarmType = SMARTSECURITYALARMTYPE_IntellAlertAlarmAndVideoVolumeOutput;
            [weakSelf wakeUpSetConfig];
        };
        
        return cell;
    }else if ([item.titleName isEqualToString:TS("TR_Continuous_alarm_time")]){//持续报警时间
        TitleComboBoxCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleComboBoxCell];
        cell.titleLeftBorder = -10;
        [cell enterFilletMode];
        cell.titleLabel.text = TS("TR_Continuous_alarm_time");
        
        int duration = [self.intellAlertAlarmMannager getDuration];
        cell.lbRight.text = [NSString stringWithFormat:@"%i%@",duration,TS("s")];
        cell.lbRight.hidden = NO;
        cell.toggleLabel.text = @"";
        [cell makeRightLableLarge:YES];
        [cell displayArrow];
//        cell.toggleLabel.text = [NSString stringWithFormat:@"%i%@",duration,TS(@"s")];
//        cell.toggleLabel.hidden = NO;
//        //防止Cell复用
//        [cell makeRightLableLarge:NO];
//        cell.lbRight.hidden = YES;
        
        return cell;
    }else if ([item.titleName isEqualToString:TS("TR_Alarm_volume")]){//报警音量设置
        BaseStationSoundSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:kBaseStationSoundSettingCell];
        cell.style = BaseStationSoundSettingCellStyle_LeftImage;
        cell.leftImageView.image = [UIImage imageNamed:@"voice_left_icon"];
        cell.titleLabel.text = TS("TR_Alarm_volume");
        cell.slider.maximumValue = 100;
        cell.slider.minimumValue = 1;
        cell.lbLeftSlider.text = TS("TR_Min");
        cell.lbRightSlider.text = TS("TR_Max");
        cell.lbValue.hidden = NO;
        
        [cell setSliderValue:[self.volumeOutputManager getLeftVolume]];
        [cell.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@10);
            make.right.equalTo(@-10);
        }];
        
        __weak typeof(self) weakSelf = self;
        cell.soundSettingCellSliderValueChanged = ^(CGFloat value) {
            [weakSelf.volumeOutputManager setLeftVolume:(int)value];
            [weakSelf.volumeOutputManager setRightVolume:(int)value];
        };
        cell.soundSettingCellSliderTouchEndAction  = ^(CGFloat value) {
            [weakSelf.volumeOutputManager setLeftVolume:(int)value];
            [weakSelf.volumeOutputManager setRightVolume:(int)value];
            weakSelf.chooseAlarmType = SMARTSECURITYALARMTYPE_IntellAlertAlarmAndVideoVolumeOutput;
            [weakSelf wakeUpSetConfig];
        };
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if ([item.titleName isEqualToString:TS("TR_Alarm_Tones")]){//报警铃声选择
        TitleComboBoxCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleComboBoxCell];
        [cell noDisplayDetailLabel];
        cell.titleLeftBorder = -10;
        
        cell.lbRight.text = @"";
        cell.lbRight.hidden = NO;
        cell.titleLabel.text = TS("TR_Alarm_Tones");
        
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
        
        cell.lbRight.text = name;
        cell.toggleLabel.hidden = YES;
        
        [cell enterFilletMode];
        [cell makeRightLableLarge:YES];
        
        [cell makeArrowRotation:0 reset:YES animation:YES];
        [cell displayArrow];
        return cell;
    }else if ([item.titleName isEqualToString:TS("TR_Alarm_Light_Switch")]){//报警灯开关
        TitleSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleSwitchCell];
        cell.titleLeftBorder = -5;
        [cell enterFilletMode];
        cell.titleLabel.text = TS("TR_Alarm_Light_Switch");
        [cell subTitleVisible:NO ContentRich:NO];
        cell.toggleSwitch.on = [self.intellAlertAlarmMannager getAlarmOutEnable];
        __weak typeof(self) weakSelf = self;
        cell.toggleSwitchStateChangedAction = ^(BOOL on) {
            [weakSelf.intellAlertAlarmMannager setAlarmOutEnable:on];
            [weakSelf.tbFunction reloadData];
            weakSelf.chooseAlarmType = SMARTSECURITYALARMTYPE_IntellAlertAlarmAndVideoVolumeOutput;
            [weakSelf wakeUpSetConfig];
        };
        
        return cell;
    }else if([item.titleName isEqualToString:TS("Show_traces")]){
        TitleSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleSwitchCell];
        cell.titleLeftBorder = -5;
        [cell enterFilletMode];
        cell.titleLabel.text = [NSString stringWithFormat:@"%@(%@)",item.titleName,TS("Human_Detection")];
        [cell subTitleVisible:YES ContentRich:NO];
        cell.lbDetail.text = TS("TR_Show_Traces_Tip");
        cell.lbDetail.numberOfLines = 2;
        cell.toggleSwitch.on = [self.humanDetectManager getShowTraceEnabled];
        
        __weak typeof(self) weakSelf = self;
        cell.toggleSwitchStateChangedAction = ^(BOOL on) {
            [SVProgressHUD show];
            [weakSelf.humanDetectManager setShowTraceEnable:on];
            [weakSelf.humanDetectManager saveConfig:^(int result) {
                [weakSelf updateList];
                if (result >= 0) {
                    [SVProgressHUD showSuccessWithStatus:TS("Save_Success")];
                }else{
//                    NSString *errorString = [SDKParser parseError:result];
//                    [SVProgressHUD showErrorWithStatus:errorString];
                    [SVProgressHUD dismiss];
                }
            }];
        };
        
        return cell;
    }else if([item.titleName isEqualToString:TS("TR_Rule_Setting")]){
        JFLeftTitleRightTitleArrowCell *cell = [tableView dequeueReusableCellWithIdentifier:kLeftTextRightArrowTableViewCell];
        
        cell.lbTitle.text = [NSString stringWithFormat:@"%@(%@)",item.titleName,TS("Human_Detection")];
        cell.lbTitle.textColor = cTableViewFilletTitleColor;
        
        cell.lbRight.text = @"";
        cell.lbDescription.text = TS("TR_Rule_Setting_Tip");

        return cell;
    }
    else{
        return [[UITableViewCell alloc] init];
    }
}

- (NSString *)getAlarmTypeValue:(int)value{
    if (value <= 1) {
        return TS("TR_PIR_Alarm");
    }else if (value <= 2) {
        return TS("TR_Microwave_Alarm");
    }else if (value <= 3) {
        return TS("TR_Sensitive_Trigger");
    }else{
        return TS("TR_Precise_Trigger");
    }
}

- (NSString *)getSensitivityValue:(int)value{
    if (value <= 1) {
        return TS("TR_PIR_lowest");
    }else if (value <= 2) {
        return TS("TR_PIR_Lower");
    }else if (value <= 3) {
        return TS("TR_PIR_Medium");
    }else if (value <= 4) {
        return TS("TR_PIR_Higher");
    }else{
        return TS("TR_PIR_Hightext");
    }
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

-(NSArray *)arrayEnableTime{
    if (!_arrayEnableTime) {
        _arrayEnableTime = [NSArray arrayWithObjects:@0.6,@1,@2,@3,@4,@5,@6,@7,@8,@9,@10,@15,@20,@25,@30,@40,@50,@60,@70,@80,@90,@100,@120,@140,@160,@180,nil];
    }
    
    return _arrayEnableTime;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *sections = [self.dataSource objectAtIndex:indexPath.section];
    OrderListItem *item = [sections objectAtIndex:indexPath.row];
    
    __weak typeof(self) weakSelf = self;
    if ([item.titleName isEqualToString:TS("TR_Pir_Sensitivity")]) {//徘徊检测灵敏度
        XMItemSelectViewController *itemSelectViewController = [[XMItemSelectViewController alloc] init];
        itemSelectViewController.title = TS("TR_Pir_Sensitivity");
        itemSelectViewController.needAutoBack = YES;
        itemSelectViewController.filletMode = NO;
        
        NSMutableArray *arrayItems = [NSMutableArray arrayWithCapacity:0];
        [arrayItems addObject:TS("TR_PIR_lowest")];
        [arrayItems addObject:TS("TR_PIR_Lower")];
        [arrayItems addObject:TS("TR_PIR_Medium")];
        [arrayItems addObject:TS("TR_PIR_Higher")];
        [arrayItems addObject:TS("TR_PIR_Hightext")];
        
        NSMutableArray *arrayValues = [NSMutableArray arrayWithCapacity:0];
        [arrayValues addObject:@1];
        [arrayValues addObject:@2];
        [arrayValues addObject:@3];
        [arrayValues addObject:@4];
        [arrayValues addObject:@5];
        int index = -1;
        for (int i = 0; i < arrayValues.count; i++) {
            if ([[arrayValues objectAtIndex:i] intValue] == [self.pirAlarmManager getPirSensitive]) {
                index = i;
                break;
            }
        }
        
        itemSelectViewController.arrItems = arrayItems;
        itemSelectViewController.lastIndex = index;
        
        itemSelectViewController.itemChangedAction = ^(int index) {
            [weakSelf.pirAlarmManager setPirSensitive:[[arrayValues objectAtIndex:index] intValue]];
            [weakSelf.tbFunction reloadData];
            weakSelf.chooseAlarmType = SMARTSECURITYALARMTYPE_PirAlarm;
            [weakSelf wakeUpSetConfig];
        };
        [self.navigationController pushViewController:itemSelectViewController animated:YES];
    }else if ([item.titleName isEqualToString:TS("TR_Detection_Schedule")]){//侦测时间段设置
        PirTimeSectionViewController *pirTimeSectionViewController = [[PirTimeSectionViewController alloc] init];
        pirTimeSectionViewController.PIRAlarmTimeSection = ^(PirAlarmManager *manager) {
            weakSelf.pirAlarmManager = manager;
            [weakSelf.tbFunction reloadData];
            weakSelf.chooseAlarmType = SMARTSECURITYALARMTYPE_PirAlarm;
            [weakSelf wakeUpSetConfig];
        };
        pirTimeSectionViewController.pirAlarmManager = self.pirAlarmManager;
        [self.navigationController pushViewController:pirTimeSectionViewController animated:YES];
    }else if ([item.titleName isEqualToString:TS("TR_Recording_Duration")]){
        XMItemSelectViewController *itemSelectViewController = [[XMItemSelectViewController alloc] init];
        itemSelectViewController.title =TS("TR_Recording_Duration");
        itemSelectViewController.needAutoBack = YES;
        itemSelectViewController.filletMode = NO;
        if (self.ifSupportLowPowerLongAlarmRecord) {
            itemSelectViewController.arrItems = @[[NSString stringWithFormat:@"10%@",TS("s")], [NSString stringWithFormat:@"20%@",TS("s")], [NSString stringWithFormat:@"30%@",TS("s")]];
            itemSelectViewController.lastIndex = [self.pirAlarmManager getRecordLatch] == 0?0:[self.pirAlarmManager getRecordLatch]/10-1;
        } else {
            itemSelectViewController.arrItems = @[[NSString stringWithFormat:@"5%@",TS("s")], [NSString stringWithFormat:@"10%@",TS("s")], [NSString stringWithFormat:@"15%@",TS("s")]];
            itemSelectViewController.lastIndex = [self.pirAlarmManager getRecordLatch] == 0?0:[self.pirAlarmManager getRecordLatch]/5-1;
        }
        
        
        __weak typeof(self) weakSelf = self;
        itemSelectViewController.itemChangedAction = ^(int index) {
            if (self.ifSupportLowPowerLongAlarmRecord) {
                [weakSelf.pirAlarmManager setRecordLatch:(index+1)*10];
            } else {
                [weakSelf.pirAlarmManager setRecordLatch:(index+1)*5];
            }
             
            [weakSelf.tbFunction reloadData];
            weakSelf.chooseAlarmType = SMARTSECURITYALARMTYPE_PirAlarm;
            [weakSelf wakeUpSetConfig];
        };
        [self.navigationController pushViewController:itemSelectViewController animated:YES];
    }else if ([item.titleName isEqualToString:TS("TR_Continuous_alarm_time")]){
        XMItemSelectViewController *itemSelectViewController = [[XMItemSelectViewController alloc] init];
        itemSelectViewController.title = TS("TR_Continuous_alarm_time");
        itemSelectViewController.needAutoBack = YES;
        itemSelectViewController.filletMode = NO;
        
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
            [weakSelf.intellAlertAlarmMannager setDuration:value];
            [weakSelf.tbFunction reloadData];
            weakSelf.chooseAlarmType = SMARTSECURITYALARMTYPE_IntellAlertAlarmAndVideoVolumeOutput;
            [weakSelf wakeUpSetConfig];
        };
        [self.navigationController pushViewController:itemSelectViewController animated:YES];
    }else if([item.titleName isEqualToString:TS("TR_Alarm_Tones")]){
        XMItemSelectViewController *itemSelectViewController = [[XMItemSelectViewController alloc] init];
        itemSelectViewController.title = TS("TR_Alarm_ringtone");
        itemSelectViewController.filletMode = NO;
        
        int type = [self.intellAlertAlarmMannager getVoiceType];
        
        NSMutableArray *list = [[self.voiceTipTypeManager getVoiceTypeList] mutableCopy];
        
        int lastIndex = 0;
        NSMutableArray *arrayItems = [NSMutableArray arrayWithCapacity:0];
        for (int i = 0; i < list.count; i++) {
            NSDictionary *dic = [list objectAtIndex:i];
            [arrayItems addObject:[dic objectForKey:@"VoiceText"]];
            int voiceEnum = [[dic objectForKey:@"VoiceEnum"] intValue];
            if (voiceEnum == type) {
                lastIndex = i;
            }
        }
        
        __weak typeof(XMItemSelectViewController) *weakVC = itemSelectViewController;
        itemSelectViewController.arrItems = arrayItems;
        itemSelectViewController.lastIndex = lastIndex;
        itemSelectViewController.itemChangedAction = ^(int index) {
            NSDictionary *dic = [list objectAtIndex:index];
            int selectedType = [[dic objectForKey:@"VoiceEnum"] intValue];
            [weakSelf.intellAlertAlarmMannager setVoiceType:selectedType];
            [weakSelf.tbFunction reloadData];
            if (selectedType == 550) {//选择自定义报警音 就跳转到上传报警音界面
                [weakVC    backViewControllerAnimated:NO];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    NetCustomRecordVC *vc = [[NetCustomRecordVC alloc] init];
                    vc.devID = weakSelf.devID;
                    vc.backForwardVCAction = ^{
                        weakSelf.chooseAlarmType = SMARTSECURITYALARMTYPE_IntellAlertAlarmAndVideoVolumeOutput;
                        [weakSelf wakeUpSetConfig];
                    };
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                });
            }else{
                [weakVC backViewControllerAnimated:YES];
                weakSelf.chooseAlarmType = SMARTSECURITYALARMTYPE_IntellAlertAlarmAndVideoVolumeOutput;
                [weakSelf wakeUpSetConfig];
            }
        };
        [self.navigationController pushViewController:itemSelectViewController animated:YES];
    }else if([item.titleName isEqualToString:TS("TR_Microwave_Detecion")]){
        XMItemSelectViewController *itemSelectViewController = [[XMItemSelectViewController alloc] init];
        itemSelectViewController.title = TS("TR_Microwave_Detecion");
        itemSelectViewController.needAutoBack = YES;
        itemSelectViewController.filletMode = NO;
        
        itemSelectViewController.arrItems = @[TS("TR_PIR_Alarm"),TS("TR_Microwave_Alarm"),TS("TR_Sensitive_Trigger"),TS("TR_Precise_Trigger")];
        itemSelectViewController.lastIndex = [self.pirAlarmManager getPIRAlarmType] - 1;
        __weak typeof(self) weakSelf = self;
        itemSelectViewController.itemChangedAction = ^(int index) {
            [weakSelf.pirAlarmManager setPIRAlarmType:index + 1];
            [weakSelf.tbFunction reloadData];
            weakSelf.chooseAlarmType = SMARTSECURITYALARMTYPE_PirAlarm;
            [weakSelf wakeUpSetConfig];
        };
        [self.navigationController pushViewController:itemSelectViewController animated:YES];
    }else if ([item.titleName isEqualToString:TS("TR_Rule_Setting")]){
        HumanDetectionForIPCViewController *controller = [[HumanDetectionForIPCViewController alloc]init];
        controller.devID = self.devID;
        controller.channelNum = 0;
        __weak typeof(self) weakSelf = self;
        controller.RequestHumanDetectConfigAction = ^{
            [weakSelf.humanDetectManager request:^(int result) {
                
            }];
        };
        
        [self.navigationController pushViewController:controller animated:YES];
    }
}

//MARK: 根据最新数据更新界面
- (void)updateList{
    [self updateDataSource];
    [self.tbFunction reloadData];
}

- (void)updateDataSource{
    LPDevWorkMode mode = [self.batteryInfoManager LPDevWorkModeFromLocal:self.devID];
    int workStateNow = [self.batteryInfoManager getWorkStateNow];
    if(((workStateNow == -1 && mode == LPDevWorkMode_NoSleep) || workStateNow == 1) && jSystemFunction.mAlarmFunction.PEAInHumanPed.Value()){
        //根据人形检测开关状态决定是否显示配置
        BOOL hidden = YES;
        if ([self.humanDetectManager getHumanDetectEnable]) {
            hidden = NO;
        }
        //支持踪迹能力才显示
        if ([self.humanRuleLimitAbilityManager supportShowTrack]) {
            [self addTableViewItem:TS("Show_traces") hidden:hidden];
        }
        //支持人形检测 且至少支持区域或者警戒线 才显示
        if (self.humanRuleLimitAbilityManager.supportLine || self.humanRuleLimitAbilityManager.supportArea) {
            [self addTableViewItem:TS("TR_Rule_Setting") hidden:hidden];
        }else{
            [self addTableViewItem:TS("TR_Rule_Setting") hidden:YES];
        }
        
        return;
    }
    
    [self addTableViewItem:TS("Show_traces") hidden:YES];
    [self addTableViewItem:TS("TR_Rule_Setting") hidden:YES];
}

#pragma mark -- OnFunSDKCallBack
//MARK: - OnFunSDKResult
- (void)baseOnFunSDKResult:(MsgContent *)msg{
    switch (msg->id) {
//MARK: 唤醒返回
        case EMSG_DEV_WAKE_UP:
        {
            if (msg->param1 >= 0) {
                [SVProgressHUD show];
                if (msg->seq == 0) {
                    //获取配置唤醒
                    [self requestGetAllAbility];
                }else{
                    //保存配置唤醒
                    [self.cfgStatusManager resetAllCfgStatus];
                    [self requestSetAllConfig];
                }
            }else{
                if (msg->seq == 0) {
                    [self getConfigFailed:msg->param1];
                }
                else
                {
                    
                }
            }
        }
            break;
        case EMSG_DEV_GET_CONFIG_JSON:{

        }
            break;
        case EMSG_MC_LinkDev:{
            if (msg->param1 < 0) {
              
                [self dealSetConfigFailed:msg->param1];
                
                self.bWMessageAlarm = NO;
                [self.tbFunction reloadData];
            }else{
                [self.cfgStatusManager changeCfgStatus:XMCfgStatus_Success name:@"MessageAlarm_Cfg"];
                
                DeviceObject *dev = [[DeviceControl getInstance] GetDeviceObjectBySN: self.devID];
                dev.eFunDevStateNotCode = 1;
                
                
                [self checkRequestSetCompleted];
            }
        }
            break;
        case EMSG_MC_UnlinkDev:
        {
            if (msg->param1 < 0) {
                [self dealSetConfigFailed:msg->param1];
                
                self.bWMessageAlarm = YES;
                [self.tbFunction reloadData];
            }
            else{
                [self.cfgStatusManager changeCfgStatus:XMCfgStatus_Success name:@"MessageAlarm_Cfg"];
                
                DeviceObject *dev = [[DeviceControl getInstance] GetDeviceObjectBySN: self.devID];
                dev.eFunDevStateNotCode = 0;
                
                [self checkRequestSetCompleted];
            }
        }
            break;
        default:
            break;
    }
}


- (void)getConfigFailed:(int)result{
    [SVProgressHUD showErrorWithStatus: [NSString stringWithFormat: @"%d", result]];
    [self.navigationController popViewControllerAnimated:YES];
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
            make.top.equalTo(_tbContainer).mas_offset(cTableViewFilletLFBorder);
            make.bottom.equalTo(_tbContainer);
        }];
    }
    
    return _tbContainer;
}

- (UITableView *)tbFunction{
     if (!_tbFunction) {
         _tbFunction = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
         _tbFunction.rowHeight = cTableViewCellHeight;
         [_tbFunction registerClass:[TitleComboBoxCell class] forCellReuseIdentifier:kTitleComboBoxCell];
         [_tbFunction registerClass:[TitleSwitchCell class] forCellReuseIdentifier:kTitleSwitchCell];
         [_tbFunction registerClass:[BaseStationSoundSettingCell class] forCellReuseIdentifier:kBaseStationSoundSettingCell];
         [_tbFunction registerClass:[JFLeftTitleRightTitleArrowCell class] forCellReuseIdentifier:kLeftTextRightArrowTableViewCell];
         _tbFunction.separatorStyle = UITableViewCellSeparatorStyleNone;
         _tbFunction.dataSource = self;
         _tbFunction.delegate = self;
         _tbFunction.showsVerticalScrollIndicator = NO;
         _tbFunction.sectionHeaderHeight = 0;
         _tbFunction.sectionFooterHeight = 0;
         _tbFunction.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
         _tbFunction.tableFooterView = [[UIView alloc] init];
     }
 
    return _tbFunction;
}

- (NSMutableArray *)cfgOrderList{
    if (!_cfgOrderList) {
        _cfgOrderList = [NSMutableArray arrayWithCapacity:0];
        
        //section0
        NSMutableArray *section0 = [NSMutableArray arrayWithCapacity:0];
        //手机软件消息接受
        OrderListItem *LPWorkMode = [[OrderListItem alloc] init];
        LPWorkMode.titleName = TS("TR_Working_Mode");
        LPWorkMode.hidden = YES;
        [section0 addObject:LPWorkMode];
        
        //section1
        NSMutableArray *section1 = [NSMutableArray arrayWithCapacity:0];
        //手机软件消息接受
        OrderListItem *AppMessageAccept = [[OrderListItem alloc] init];
        AppMessageAccept.titleName = TS("App_Message_accept");
        AppMessageAccept.hidden = NO;
        [section1 addObject:AppMessageAccept];
        self.ifSupportMessageAlarm = YES;
        
        //section2
        NSMutableArray *section2 = [NSMutableArray arrayWithCapacity:0];
        //PIR移动侦测
        OrderListItem *PIRMoveDetection = [[OrderListItem alloc] init];
        PIRMoveDetection.titleName = TS("TR_PIR_Detection");
        PIRMoveDetection.hidden = YES;
        [section2 addObject:PIRMoveDetection];
        
        //PIR灵敏度
        OrderListItem *PIRLevel = [[OrderListItem alloc] init];
        PIRLevel.titleName = TS("TR_Pir_Sensitivity");
        PIRLevel.hidden = YES;
        [section2 addObject:PIRLevel];
        
        //PIR检测时间
        OrderListItem *PIRDuring = [[OrderListItem alloc] init];
        PIRDuring.titleName = TS("TR_Pir_duration");
        PIRDuring.hidden = YES;
        [section2 addObject:PIRDuring];
        
        //微波移动侦测
        OrderListItem *MicroWave = [[OrderListItem alloc] init];
        MicroWave.titleName = TS("TR_Microwave_Detecion");
        MicroWave.hidden = YES;
        [section2 addObject:MicroWave];
        
        //侦测时间段设置
        OrderListItem *detectionSchedule = [[OrderListItem alloc] init];
        detectionSchedule.titleName = TS("TR_Detection_Schedule");
        detectionSchedule.hidden = YES;
        [section2 addObject:detectionSchedule];
        
        //摄像机警戒设置
        OrderListItem *alertSetting = [[OrderListItem alloc] init];
        alertSetting.titleName = TS("TR_Camera_Alert_Setting");
        alertSetting.hidden = YES;
        [section2 addObject:alertSetting];
        
        //人形侦测
        OrderListItem *humanDetection = [[OrderListItem alloc] init];
        humanDetection.titleName = TS("Human_Detection");
        humanDetection.hidden = YES;
        [section2 addObject:humanDetection];
        
        //显示踪迹
        OrderListItem *showTraces = [[OrderListItem alloc] init];
        showTraces.titleName = TS("Show_traces");
        showTraces.hidden = YES;
        [section2 addObject:showTraces];
        //规则设置
        OrderListItem *ruleSetting = [[OrderListItem alloc] init];
        ruleSetting.titleName = TS("TR_Rule_Setting");
        ruleSetting.hidden = YES;
        [section2 addObject:ruleSetting];
        
        //section3
        NSMutableArray *section3 = [NSMutableArray arrayWithCapacity:0];
        //录像开关
        OrderListItem *recordSwitch = [[OrderListItem alloc] init];
        recordSwitch.titleName = TS("ad_record_mode");
        recordSwitch.hidden = NO;
        [section3 addObject:recordSwitch];
        //录像时间
        OrderListItem *recordingDuration = [[OrderListItem alloc] init];
        recordingDuration.titleName = TS("TR_Recording_Duration");
        recordingDuration.hidden = YES;
        [section3 addObject:recordingDuration];
        
        //section3
        NSMutableArray *section4 = [NSMutableArray arrayWithCapacity:0];
        
        //持续报警时间
        OrderListItem *alarmTime = [[OrderListItem alloc] init];
        alarmTime.titleName = TS("TR_Continuous_alarm_time");
        alarmTime.hidden = YES;
        [section4 addObject:alarmTime];
        
        //报警音量设置
        OrderListItem *alarmVolume = [[OrderListItem alloc] init];
        alarmVolume.titleName = TS("TR_Alarm_volume");
        alarmVolume.hidden = YES;
        [section4 addObject:alarmVolume];
        
        //报警铃声选择
        OrderListItem *alarmTones = [[OrderListItem alloc] init];
        alarmTones.titleName = TS("TR_Alarm_Tones");
        alarmTones.hidden = YES;
        [section4 addObject:alarmTones];
        
        //报警灯开关
        OrderListItem *alarmSwitch = [[OrderListItem alloc] init];
        alarmSwitch.titleName = TS("TR_Alarm_Light_Switch");
        alarmSwitch.hidden = YES;
        [section4 addObject:alarmSwitch];
        
        [_cfgOrderList addObject:section0];
        [_cfgOrderList addObject:section1];
        [_cfgOrderList addObject:section2];
        [_cfgOrderList addObject:section3];
        [_cfgOrderList addObject:section4];
    }
    
    return _cfgOrderList;
}

- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:0];
        [self addTableViewItem:@"" hidden:NO];
    }
    
    return _dataSource;
}

- (CfgStatusManager *)cfgStatusManager{
    if (!_cfgStatusManager) {
        _cfgStatusManager = [[CfgStatusManager alloc] init];
    }
    
    return _cfgStatusManager;
}

-(PirAlarmManager *)pirAlarmManager{
    if (!_pirAlarmManager) {
        _pirAlarmManager = [[PirAlarmManager alloc] init];
    }
    return _pirAlarmManager;
}

- (HumanDetectManager *)humanDetectManager{
    if (!_humanDetectManager) {
        _humanDetectManager = [[HumanDetectManager alloc] init];
        _humanDetectManager.devID = self.devID;
    }
    
    return _humanDetectManager;
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

- (LocalSaveVideoEnableManager *)localSaveVideoEnableManager{
    if (!_localSaveVideoEnableManager) {
        _localSaveVideoEnableManager = [[LocalSaveVideoEnableManager alloc] init];
    }
    
    return _localSaveVideoEnableManager;
}

-(BatteryInfoManager *)batteryInfoManager{
    if(!_batteryInfoManager){
        _batteryInfoManager = [[BatteryInfoManager alloc] init];
    }
    return _batteryInfoManager;
}

- (void)dealloc{
    FUN_UnRegWnd(self.msgHandle);
    self.msgHandle = -1;
}

@end
