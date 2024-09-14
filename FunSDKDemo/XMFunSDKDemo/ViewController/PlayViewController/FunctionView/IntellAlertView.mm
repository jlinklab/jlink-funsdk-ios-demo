//
//  IntellAlertView.m
//
//
//  Created by Tony Stark on 2021/7/29.
//  Copyright © 2021 xiongmaitech. All rights reserved.
//

#import "IntellAlertView.h"
#import <Masonry/Masonry.h>
#import "IntellAlertAlarmMannager.h"
#import "CfgStatusManager.h"
#import "VideoVolumeOutputManager.h"
#import "ChannelVoiceTipTypeManager.h"
#import "AlarmSwitchCell.h"
#import "TitleComboBoxCell.h"
#import "SelectItemCell.h"
#import "PirAlarmManager.h"
#import "LightBulbConfig.h"
#import "AppDelegate.h"
#import "MyDatePickerView.h"
#import "LP4GDoubleLightSwitchCfgManager.h"
#import "BaseStationSoundSettingCell.h"
#import "BatteryInfoManager.h"
#import "SliderOnlyCell.h"

static NSString *const kTitleSwitchCell = @"kTitleSwitchCell";
static NSString *const kTitleComboBoxCell = @"kTitleComboBoxCell";
static NSString *const kSliderOnlyCell = @"kSliderOnlyCell";
static NSString *const kSelectItemCell = @"kSelectItemCell";
static NSString *const kBaseStationSoundSettingCell = @"kBaseStationSoundSettingCell";
/*
 智能警戒配置对象组
 */
@interface IntellAlertCfgObject : NSObject

//MARK: 低功耗灯光配置管理者
@property (nonatomic,strong) LP4GDoubleLightSwitchCfgManager *lp4GDoubleLightSwitchCfgManager;
//MARK: 基站智能警戒管理者
@property (nonatomic,strong) IntellAlertAlarmMannager *intellAlertManagerBase;
//MARK: 智能警戒管理者
@property (nonatomic,strong) IntellAlertAlarmMannager *intellAlertManager;
//MARK: 警戒声音能力管理者 针对通道
@property (nonatomic,strong) ChannelVoiceTipTypeManager *voiceTipTypeManager;
//MARK: 音量输出管理者
@property (nonatomic,strong) VideoVolumeOutputManager *volumeOutputManager;
//MARK: 人体感应报警配置管理者
@property (nonatomic,strong) PirAlarmManager *pirAlarmManager;

//MARK: 低功耗电池工作模式管理
@property (nonatomic,strong) BatteryInfoManager *batteryInfoManager;

@end

@implementation IntellAlertCfgObject

- (LP4GDoubleLightSwitchCfgManager *)lp4GDoubleLightSwitchCfgManager{
    if (!_lp4GDoubleLightSwitchCfgManager) {
        _lp4GDoubleLightSwitchCfgManager = [[LP4GDoubleLightSwitchCfgManager alloc] init];
        _lp4GDoubleLightSwitchCfgManager.needPenetrate = YES;
    }
    
    return _lp4GDoubleLightSwitchCfgManager;
}

- (IntellAlertAlarmMannager *)intellAlertManagerBase{
    if (!_intellAlertManagerBase) {
        _intellAlertManagerBase = [[IntellAlertAlarmMannager alloc] init];
    }
    
    return _intellAlertManagerBase;
}

- (IntellAlertAlarmMannager *)intellAlertManager{
    if (!_intellAlertManager) {
        _intellAlertManager = [[IntellAlertAlarmMannager alloc] init];
    }
    
    return _intellAlertManager;
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

- (PirAlarmManager *)pirAlarmManager{
    if (!_pirAlarmManager) {
        _pirAlarmManager = [[PirAlarmManager alloc] init];
    }
    
    return _pirAlarmManager;
}

-(BatteryInfoManager *)batteryInfoManager{
    if(!_batteryInfoManager){
        _batteryInfoManager = [[BatteryInfoManager alloc] init];
    }
    return _batteryInfoManager;
}

@end

@interface IntellAlertView () <UITableViewDelegate,UITableViewDataSource, WhiteLightConfigDelegate, MyDatePickerViewDelegate>

@property (nonatomic,strong) MyDatePickerView *tempPikcer;

@property (nonatomic,strong) UIView *tbContainer;
@property (nonatomic,strong) UITableView *tbFunction;
@property (nonatomic,strong) NSMutableArray *dataSource;
//MARK: 配置中的数据源
@property (nonatomic,strong) NSMutableArray *dataSourceCfg;
//MARK: 配置当前选中index
@property (nonatomic,assign) int selectedIndexCfg;
//MARK: 标记是否在选择配置状态
@property (nonatomic,assign) BOOL selectingCfg;

//MARK: 配置状态管理者
@property (nonatomic,strong) CfgStatusManager *cfgStatusManager;
//MARK: 配置管理对象
@property (nonatomic,strong) NSMutableArray <IntellAlertCfgObject *>*arrayManagers;

@property (nonatomic,strong) UIButton *closeBtn;
@property (nonatomic,strong) UIView *bottomBar;
@property (nonatomic,assign) BOOL legalMoving;
@property (nonatomic,assign) CGPoint startPoint;
//MARK: 白光灯配置管理者
@property (nonatomic,strong) LightBulbConfig *whiteLightManager;

@end
@implementation IntellAlertView

- (instancetype)initWithFrame:(CGRect)frame arrayDeviceID:(NSArray *)arrayID{
    self = [super initWithFrame:frame];
    if (self) {
        self.arrayID = [arrayID mutableCopy];
        self.channels = (int)arrayID.count;
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.tbContainer];
        [self addSubview:self.closeBtn];
        
        [self.tbContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.top.equalTo(self).offset(20);
            make.bottom.equalTo(self);
        }];
  
//        [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.width.equalTo(@30);
//            make.height.equalTo(@30);
//            make.right.equalTo(self).offset(-40);
//            make.top.equalTo(self);
//        }];
    }
    
    return self;
}


- (void)updateUIStyle{
        self.layer.cornerRadius = 0;
        self.layer.masksToBounds = NO;
        self.backgroundColor = [UIColor whiteColor];
        self.tbContainer.backgroundColor = [UIColor whiteColor];
    self.tbFunction.backgroundColor = UIColor.clearColor;
}

- (void)setBottomOffset:(CGFloat)bottomOffset{
    [self.tbContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.equalTo(self.closeBtn).offset(20);
        make.right.equalTo(self);
        make.bottom.equalTo(self).mas_offset(0);
    }];
}

//MARK: 根据设备和通道展示警戒界面
- (void)dispalyAlertView:(NSString *)devID channel:(int)channel index:(int)index{
    self.devID = devID;
    self.channel = channel;
    self.index = index;
    self.selectingCfg = NO;
    
    self.dataSource = nil;
    
    DeviceObject *device = [[DeviceControl getInstance] GetDeviceObjectBySN: devID];
    
    //根据能力集重新生成数据源
    //section0
    //是否支持低功耗双光转 白光红外切换
    if ( (device.sysFunction.iSupportLP4GSupportDoubleLightSwitch == 1 && self.channel == -1)) {
        if ( (device.sysFunction.iSupportLowPowerDoubleLightToLightingSwitch == 1 && self.channel == -1)) {//如果是支持低功耗双光转变成照明开关 显示开关
            [self updateLowPowerLightSectionDataSource:1];
        }else{
            [self updateLowPowerLightSectionDataSource:0];
        }
    }
    
    //section1
    //是否支持灯光配置
    if (( (device.sysFunction.iSupportCameraWhiteLight && self.channel == -1)) || ((device.sysFunction.iSupportLP4GSupportDoubleLightSwitch == 1 && self.channel == -1))) {
        [self updateLightSectionDataSource];
    }
    
    //section2
    //判断是否支持警戒 开关位置调整到和人体感应侦测一个section
    if (( (device.sysFunction.iIntellAlertAlarm == 1 && self.channel == -1))) {
        NSMutableArray *arraySection = [NSMutableArray arrayWithCapacity:0];
        //判断是否支持智能人体感应侦测
        if (device.sysFunction.iSupportLPWorkModeSwitchV2 != 1) {
            if ( (device.sysFunction.SupportPirAlarm && self.channel == -1)) {
                [arraySection addObject:@{@"name":TS("TR_PIR_Detection")}];
            }
        }
        [arraySection addObject:@{@"name":TS("Intelligent_Vigilance")}];
        [self.dataSource replaceObjectAtIndex:2 withObject:arraySection];
    }
    
    //判断是否支持警戒
    if (( (device.sysFunction.iIntellAlertAlarm == 1 && self.channel == -1))) {
        NSMutableArray *arraySection = [NSMutableArray arrayWithCapacity:0];
        if ( (device.sysFunction.iSupportLowPowerDoubleLightToLightingSwitch == 1 && self.channel == -1)) {//如果是庭院灯
            [arraySection addObject:@{@"name":TS("TR_Continuous_alarm_time"),@"select_parameter_list":@[@5,@10,@15,@20],@"parameter_name_list":@[@"5s", @"10s", @"15s", @"20s"]}];
            //判断是否支持音量设置
            if ((device.sysFunction.ifSupportSetVolume && self.channel == -1)) {
                [arraySection addObject:@{@"name":TS("TR_Alarm_volume")}];
            }
            [arraySection addObject:@{@"name":TS("TR_Alarm_ringtone")}];
            //判断是否支持报警灯开关
            if ( (device.sysFunction.iSupportLowPowerSetAlarmLed == 1 && self.channel == -1)){
                [arraySection addObject:@{@"name":TS("TR_Alarm_Light_Switch")}];
            }
        }else{
            [arraySection addObject:@{@"name":TS("TR_Continuous_alarm_time"),@"select_parameter_list":@[@5,@10,@15,@20],@"parameter_name_list":@[@"5s", @"10s", @"15s", @"20s"]}];
            //判断是否支持音量设置
            if ( (device.sysFunction.ifSupportSetVolume && self.channel == -1)) {
                [arraySection addObject:@{@"name":TS("TR_Alarm_volume")}];
            }
            [arraySection addObject:@{@"name":TS("TR_Alarm_ringtone")}];
        }
        
        [self.dataSource replaceObjectAtIndex:3 withObject:arraySection];
    }
    
    [self refreshList];
    
    //初始化配置管理者
    [self.cfgStatusManager addCfgName:@"LP4GDoubleLightSwitchCfgManager"];
    [self.cfgStatusManager addCfgName:@"WhiteLightManager"];
    [self.cfgStatusManager addCfgName:@"IntellAlertAlarmMannagerBase"];
    [self.cfgStatusManager addCfgName:@"IntellAlertAlarmMannager"];
    [self.cfgStatusManager addCfgName:@"ChannelVoiceTipTypeManager"];
    [self.cfgStatusManager addCfgName:@"VideoVolumeOutputManager"];
    [self.cfgStatusManager addCfgName:@"PirAlarmManager"];
    [self.cfgStatusManager addCfgName:@"batteryInfoManager"];
    [self.cfgStatusManager resetAllCfgStatus];
    
    //根据能力集判断是否需要请求相关配置
    __weak typeof(self) weakSelf = self;
    IntellAlertCfgObject *cfg = [self.arrayManagers objectAtIndex:index];
    
    //是否支持灯光配置
    if ( (device.sysFunction.iSupportCameraWhiteLight && self.channel == -1)) {
        [self.whiteLightManager getDeviceConfig];
    }else{
        [self.cfgStatusManager changeCfgStatus:XMCfgStatus_Success name:@"WhiteLightManager"];
        [self checkRequestCompleted];
    }
    
    //是否支持低功耗的灯光配置
    if ( (device.sysFunction.iSupportLP4GSupportDoubleLightSwitch == 1 && self.channel == -1)) {
        if (self.channel == -1) {
            cfg.lp4GDoubleLightSwitchCfgManager.needPenetrate = NO;
        }
        [cfg.lp4GDoubleLightSwitchCfgManager getLP4GDoubleLight:weakSelf.devID channel:weakSelf.channel completed:^(XM_REQ_STATE state, NSDictionary *info) {
            int result = [[info objectForKey:@"result"] intValue];
            int channel1 = [[info objectForKey:@"channel"] intValue];
            [weakSelf needDealGetCfg:@"LP4GDoubleLightSwitchCfgManager" channel:channel1 result:result];
            if (result >= 0) {
                [weakSelf intervalRefreshList];
            }
        }];
    }else{
        [self.cfgStatusManager changeCfgStatus:XMCfgStatus_Success name:@"LP4GDoubleLightSwitchCfgManager"];
        [self checkRequestCompleted];
    }
    
    //判断是否支持警戒
    if ( (device.sysFunction.iIntellAlertAlarm == 1 && self.channel == -1)) {
        [cfg.intellAlertManager getIntellAlertAlarm:self.devID channel:self.channel completed:^(int result,int channel1) {
            [weakSelf needDealGetCfg:@"IntellAlertAlarmMannager" channel:channel1 result:result];
        }];
        
        [cfg.voiceTipTypeManager getChannelVoiceTipType:self.devID channel:self.channel completed:^(int result,int channel1) {
            [weakSelf needDealGetCfg:@"ChannelVoiceTipTypeManager" channel:channel1 result:result];
        }];
        
        [cfg.intellAlertManagerBase getIntellAlertAlarm:self.devID channel:-1 completed:^(int result, int channel1) {
            [weakSelf needDealGetCfg:@"IntellAlertAlarmMannagerBase" channel:weakSelf.channel result:result];
        }];
    }else{
        [self.cfgStatusManager changeCfgStatus:XMCfgStatus_Success name:@"IntellAlertAlarmMannagerBase"];
        [self.cfgStatusManager changeCfgStatus:XMCfgStatus_Success name:@"IntellAlertAlarmMannager"];
        [self.cfgStatusManager changeCfgStatus:XMCfgStatus_Success name:@"ChannelVoiceTipTypeManager"];
        [self checkRequestCompleted];
    }
    
    if ( (device.sysFunction.iSupportLPWorkModeSwitchV2 && self.channel == -1)) {
        [cfg.batteryInfoManager getLPWorkModeSwitchV2:self.devID Completion:^(int result) {
            NSMutableArray *arraySection = [NSMutableArray arrayWithCapacity:0];
            [cfg.batteryInfoManager LPDevWorkMode:weakSelf.devID ActualTimeValue:NO Completion:^(LPDevWorkMode value) {
                if(value == LPDevWorkMode_NoSleep){//常电模式
                    int WorkStateNow = [cfg.batteryInfoManager getWorkStateNow];
                    if (WorkStateNow == 1) {//实时
                         
                    } else if (WorkStateNow == 0) {//省电
                        [arraySection addObject:@{@"name":TS("TR_PIR_Detection")}];
                    } else {
                        
                    }
                } else if (value == LPDevWorkMode_LowConsumption) {//低功耗模式
                    [arraySection addObject:@{@"name":TS("TR_PIR_Detection")}];
                }
                
                [arraySection addObject:@{@"name":TS("Intelligent_Vigilance")}];
                [weakSelf.dataSource replaceObjectAtIndex:2 withObject:arraySection];
                [weakSelf needDealGetCfg:@"batteryInfoManager" channel:self.channel result:result];
            }];
        }];
    }else{
        [self.cfgStatusManager changeCfgStatus:XMCfgStatus_Success name:@"batteryInfoManager"];
        [self checkRequestCompleted];
    }
    
    //判断是否支持音量设置
    if ( (device.sysFunction.ifSupportSetVolume && self.channel == -1)) {
        [cfg.volumeOutputManager getVideoVolumeOutput:self.devID channel:self.channel completed:^(int result,int channel1) {
            [weakSelf needDealGetCfg:@"VideoVolumeOutputManager" channel:channel1 result:result];
        }];
    }else{
        [self.cfgStatusManager changeCfgStatus:XMCfgStatus_Success name:@"VideoVolumeOutputManager"];
        [self checkRequestCompleted];
    }
    
    //判断是否支持智能人体感应侦测
    if ((device.sysFunction.SupportPirAlarm && self.channel == -1)) {
        [cfg.pirAlarmManager getPirAlarm:self.devID channel:self.channel completed:^(int result, int channel1) {
            [weakSelf needDealGetCfg:@"PirAlarmManager" channel:channel1 result:result];
        }];
    }else{
        [self.cfgStatusManager changeCfgStatus:XMCfgStatus_Success name:@"PirAlarmManager"];
        [self checkRequestCompleted];
    }
}

#pragma mark 获取配置代理回调
- (void)getWhiteLightConfigResult:(NSInteger)result {
    [self needDealGetCfg:@"WhiteLightManager" channel: self.channel result:result];
    if (result >= 0) {
        [self updateLightSectionDataSource];
        [self intervalRefreshList];
    }
}

//MARK: dataType: 0: 默认白光红外切换配置 1:照明灯配置
- (void)updateLowPowerLightSectionDataSource:(int)dataType{
    NSMutableArray *arraySection = [NSMutableArray arrayWithCapacity:0];
    if (dataType == 0) {
        DeviceObject *device = [[DeviceControl getInstance] GetDeviceObjectBySN: self.devID];
        if (device.sysFunction.iSupportLPDoubleLightAlert == 1) {//如果支持双光警戒的 就增加一项配置:Double_Light_Vision
            [arraySection  addObject:@{@"name":TS("TR_Light_Settings"),@"select_parameter_list":@[@1,@2,@3],@"parameter_name_list":@[TS("TR_Infrared_Light"),TS("TR_White_Light"),TS("Double_Light_Vision")]}];
        }else{
            [arraySection  addObject:@{@"name":TS("TR_Light_Settings"),@"select_parameter_list":@[@1,@2],@"parameter_name_list":@[TS("TR_Infrared_Light"),TS("TR_White_Light")]}];
        }
    }else if (dataType == 1){
        [arraySection addObject:@{@"name":TS("TR_Light_Up_Switch")}];
        [arraySection addObject:@{@"name":TS("TR_Adjustment_Of_Brightness")}];
    }
    
    [self.dataSource replaceObjectAtIndex:0 withObject:arraySection];
}

- (void)updateLightSectionDataSource{
    [self.dataSource replaceObjectAtIndex:1 withObject:[[self getLightSectionData] mutableCopy]];
}

- (NSMutableArray *)getLightSectionData{
    NSMutableArray *arraySection = [NSMutableArray arrayWithCapacity:0];
    
    IntellAlertCfgObject *cfg = [self.arrayManagers objectAtIndex:self.index];
    
    DeviceObject *device = [[DeviceControl getInstance] GetDeviceObjectBySN: self.devID];
    
    if (device.sysFunction.iSupportCameraWhiteLight && self.channel == -1) {
        if ( device.sysFunction.iNotSupportAutoAndIntelligent == 1 && self.channel == -1) {//白光灯仅支持开关配置
            [arraySection addObject:@{@"name":TS("bulb_switch"),@"select_parameter_list":@[@"KeepOpen",@"Close"],@"parameter_name_list":@[TS("open"),TS("close")]}];
        }
        else if ( device.sysFunction.iSupportMusicLightBulb && self.channel == -1) {//支持音乐灯
            [arraySection addObject:@{@"name":TS("bulb_switch"),@"select_parameter_list":@[@"Auto",@"KeepOpen",@"Close",@"Atmosphere",@"Glint",@"Timing"],@"parameter_name_list":@[TS("Auto_Color"),TS("open"),TS("close"),TS("lightAtmosphere"),TS("lightGlint"),TS("timing")]}];
            if ([[self.whiteLightManager getWorkMode] isEqualToString:@"Timing"]) {
                [arraySection addObject:@{@"name":TS("open_time")}];
                [arraySection addObject:@{@"name":TS("close_time")}];
            }
        }
        else if ( (device.sysFunction.iSupportDoubleLightBul && self.channel == -1)){//支持双光灯
            [arraySection addObject:@{@"name":TS("bulb_switch"),@"select_parameter_list":@[@"Auto",@"KeepOpen",@"Close",@"Intelligent",@"Timing"],@"parameter_name_list":@[TS("Auto_Color"),TS("open"),TS("close"),TS("Intelligent_switch"),TS("timing")]}];
            if ([[self.whiteLightManager getWorkMode] isEqualToString:@"Timing"]) {
                [arraySection addObject:@{@"name":TS("open_time")}];
                [arraySection addObject:@{@"name":TS("close_time")}];
            }else if ([[self.whiteLightManager getWorkMode] isEqualToString:@"Intelligent"]) {
                [arraySection addObject:@{@"name":TS("Intelligent_sensitivity"),@"select_parameter_list":@[@1,@3,@5],@"parameter_name_list":@[TS("Intelligent_level_Low"),TS("Intelligent_level_Middle"),TS("Intelligent_level_Height")]}];
                [arraySection addObject:@{@"name":TS("Intelligent_duration"),@"select_parameter_list":@[@5,@10,@30,@60,@90,@120],@"parameter_name_list":@[@"5s", @"10s", @"30s", @"60s", @"90s", @"120s"]}];
            }
        }
        else if ( device.sysFunction.iSupportDoubleLightBoxCamera && self.channel == -1){//支持双光枪击
                [arraySection addObject:@{@"name":TS("Control_Mode"),@"parameter_name_list":@[TS("Full_Color_Vision"),TS("General_Night_Vision"),TS("Double_Light_Vision")],@"select_parameter_list":@[@"Auto",@"Close",@"Intelligent"]}];
            if ([[self.whiteLightManager getWorkMode] isEqualToString:@"Intelligent"]) {
                [arraySection addObject:@{@"name":TS("Intelligent_sensitivity"),@"select_parameter_list":@[@1,@3,@5],@"parameter_name_list":@[TS("Intelligent_level_Low"),TS("Intelligent_level_Middle"),TS("Intelligent_level_Height")]}];
                [arraySection addObject:@{@"name":TS("Intelligent_duration"),@"select_parameter_list":@[@5,@10,@30,@60,@90,@120],@"parameter_name_list":@[@"5s", @"10s", @"30s", @"60s", @"90s", @"120s"]}];
                if (self.channel == -1 && device.sysFunction.PEAInHumanPed == 1) {//如果支持iPEAInHumanPed 要显示智能警戒
                    [arraySection addObject:@{@"name":TS("Intelligent_Vigilance")}];
                }
            }
        }
        else if ( device.sysFunction.iSupportBoxCameraBulb && self.channel == -1){//支持BoxCamera
            [arraySection addObject:@{@"name":TS("bulb_switch"),@"select_parameter_list":@[@"Auto",@"KeepOpen",@"Close",@"Timing",@"Intelligent"],@"parameter_name_list":@[TS("Auto_Color"),TS("TR_Turn_light_on"),TS("TR_Turn_light_off"),TS("timing"),TS("Intelligent_Vigilance")]}];
            if ([[self.whiteLightManager getWorkMode] isEqualToString:@"Timing"]) {
                [arraySection addObject:@{@"name":TS("open_time")}];
                [arraySection addObject:@{@"name":TS("close_time")}];
            }else if ([[self.whiteLightManager getWorkMode] isEqualToString:@"Intelligent"]){
                [arraySection addObject:@{@"name":TS("Intelligent_sensitivity"),@"select_parameter_list":@[@1,@3,@5],@"parameter_name_list":@[TS("Intelligent_level_Low"),TS("Intelligent_level_Middle"),TS("Intelligent_level_Height")]}];
                [arraySection addObject:@{@"name":TS("Intelligent_duration"),@"select_parameter_list":@[@5,@10,@30,@60,@90,@120],@"parameter_name_list":@[@"5s", @"10s", @"30s", @"60s", @"90s", @"120s"]}];
            }
            //暂时不处理 目前android都不显示这个配置
//            if ([self.channelSystemFunctionManager checkSupportAbility:kSupportSoftPhotosensitive channel:self.channel] || (device.iSupportSoftPhotosensitive && self.channel == -1)){//支持球机灯泡配置
//                [arraySection addObject:@{@"name":TS("bulb_switch"),@"select_parameter_list":@[@"Auto",@"KeepOpen",@"Close",@"Timing"],@"parameter_name_list":@[TS("Auto_Color"),TS("open"),TS("close"),TS("timing")]}];
//                if ([[cfg.whiteLightManager getWordMode] isEqualToString:@"Timing"]) {
//                    [arraySection addObject:@{@"name":TS("open_time")}];
//                    [arraySection addObject:@{@"name":TS("close_time")}];
//                }
//            }
        }else  {
            [arraySection addObject:@{@"name":TS("bulb_switch"),@"select_parameter_list":@[@"Auto",@"KeepOpen",@"Close",@"Timing"],@"parameter_name_list":@[TS("Auto_Color"),TS("open"),TS("close"),TS("timing")]}];
            if ([[self.whiteLightManager getWorkMode] isEqualToString:@"Timing"]) {
                [arraySection addObject:@{@"name":TS("open_time")}];
                [arraySection addObject:@{@"name":TS("close_time")}];
            }
        }
    }
    
    return arraySection;
}

- (void)needDealGetCfg:(NSString *)cfgName channel:(int)channel result:(int)result{
    if (channel == self.channel) {
        if (result < 0) {
            //[self dealGetConfigFailed:result];
        }else{
            [self.cfgStatusManager changeCfgStatus:XMCfgStatus_Success name:cfgName];
            [self checkRequestCompleted];
            [self intervalRefreshList];
        }
    }
}

- (void)dealGetConfigFailed:(int)result{
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat: @"%d", result]];
}

- (void)checkRequestCompleted{
    if ([self.cfgStatusManager checkAllCfgFinishedRequest]) {
        [self intervalRefreshList];
    }
}

//MARK: 刷新列表
- (void)intervalRefreshList{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(refreshList) withObject:nil afterDelay:0.2];
}

- (void)refreshList{
    [self.tbFunction reloadData];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //CGSize size = self.tbFunction.contentSize;
        if (self.refreshIntellAlertView) {
            self.refreshIntellAlertView([self hwRatioFromDataSource]);
        }
    });
}

- (void)dealSetConfigFailed:(int)result{
    if (result == -1) {
//        [SVProgressHUD setMinimumDismissTimeInterval:2];
        [SVProgressHUD showErrorWithStatus:TS("TR_Unable_save_getting_config_tips")];
    }else{
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat: @"%d", result]];
    }
}

//MARK: 根据数据源计算宽高比
- (float)hwRatioFromDataSource{
    float width = self.tbFunction.contentSize.width;
    float height = 0;
    if (!self.selectingCfg){
        for (int section = 0;section < self.dataSource.count;section++){
            NSArray *sectionArray =  [self.dataSource objectAtIndex:section];
            for (int row = 0; row < sectionArray.count;row++){
                height = height + [self tableView:self.tbFunction heightForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
            }
        }
    }else{
        for (int section = 0;section < self.dataSourceCfg.count;section++){
            NSArray *sectionArray =  [self.dataSourceCfg objectAtIndex:section];
            for (int row = 0; row < sectionArray.count;row++){
                height = height + [self tableView:self.tbFunction heightForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
            }
        }
    }
    
    if (width == 0){
        return 0.618;
    }
    return height / width;
}

//MARK: - Delegate
//MARK: - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.selectingCfg) {
        return self.dataSourceCfg.count;
    }else{
        return self.dataSource.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.selectingCfg) {
        NSArray *arraySection = [self.dataSourceCfg objectAtIndex:section];
        
        return arraySection.count;
    }else{
        NSArray *arraySection = [self.dataSource objectAtIndex:section];
        if(!arraySection || arraySection.count == 0){
            return 0;
        }
        NSDictionary *dic = [arraySection objectAtIndex:0];
        NSString *title = [dic objectForKey:@"name"];
        
        IntellAlertCfgObject *cfg = [self.arrayManagers objectAtIndex:self.index];
        
        DeviceObject *device = [[DeviceControl getInstance] GetDeviceObjectBySN: self.devID];
        
        BOOL supportLowPowerSetBrightness = NO;
        if (self.channel == -1) {
            supportLowPowerSetBrightness = device.sysFunction.iSupportLowPowerSetBrightness == 1? YES:NO;
        }
//        else{
//            supportLowPowerSetBrightness = [self.channelSystemFunctionManager checkSupportAbility:kSupportLowPowerSetBrightness channel:self.channel];
//        }
        
        if ([title isEqualToString:TS("TR_Light_Up_Switch")] &&
            ([cfg.lp4GDoubleLightSwitchCfgManager getLightType] != 2 ||
             supportLowPowerSetBrightness == NO)){//照明开关关闭时 只显示开关 不显示亮度调节
            return 1;
        }else if ([title isEqualToString:TS("TR_PIR_Detection")] && ![cfg.pirAlarmManager getEnable]){// pir关闭时不显示警戒开关
            return 1;
        }

        return arraySection.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
    if (self.selectingCfg) {
        NSArray *arraySection = [self.dataSourceCfg objectAtIndex:section];
        
        return arraySection.count > 0 ? 15 * 0.5 : 0;
    }else{
        NSArray *arraySection = [self.dataSource objectAtIndex:section];
        NSDictionary *dic = [arraySection objectAtIndex:0];
        NSString *title = [dic objectForKey:@"name"];
        
        IntellAlertCfgObject *cfg = [self.arrayManagers objectAtIndex:self.index];
        
        if ([title isEqualToString:TS("Intelligent_Vigilance")] && section == 2 && ![cfg.intellAlertManager getEnable]) {
            return 15 * 0.5;
        }
        
        return arraySection.count > 0 ? 15 * 0.5 : 0;
    }
}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//    return 0;
//    if (self.selectingCfg) {
//        NSArray *arraySection = [self.dataSourceCfg objectAtIndex:section];
//        
//        return arraySection.count > 0 ? 15 * 0.5 : 0;
//    }else{
//        NSArray *arraySection = [self.dataSource objectAtIndex:section];
//        NSDictionary *dic = [arraySection objectAtIndex:0];
//        NSString *title = [dic objectForKey:@"name"];
//        
//        IntellAlertCfgObject *cfg = [self.arrayManagers objectAtIndex:self.index];
//        
//        if ([title isEqualToString:TS("Intelligent_Vigilance")] && section == 2 && ![cfg.intellAlertManager getEnable]) {
//            return 15 * 0.5;
//        }
//        
//        return arraySection.count > 0 ? 15 * 0.5 : 0;
//    }
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!self.selectingCfg){
        NSArray *arraySection = [self.dataSource objectAtIndex:indexPath.section];
        NSDictionary *dic = [arraySection objectAtIndex:indexPath.row];
        NSString *title = [dic objectForKey:@"name"];
        
        if ([title isEqualToString:TS("TR_Adjustment_Of_Brightness")]) {
            return 100;
        }
    }
    
    return 50;
}



- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    UITableViewHeaderFooterView *headerFooterView = (UITableViewHeaderFooterView *)view;
    headerFooterView.backgroundColor = UIColor.clearColor;
    headerFooterView.contentView.backgroundColor = UIColor.clearColor;
    headerFooterView.tintColor = UIColor.clearColor;
    headerFooterView.hidden = YES;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section{
    UITableViewHeaderFooterView *headerFooterView = (UITableViewHeaderFooterView *)view;
    headerFooterView.backgroundColor = UIColor.clearColor;
    headerFooterView.contentView.backgroundColor = UIColor.clearColor;
    headerFooterView.tintColor = UIColor.clearColor;
    headerFooterView.hidden = YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IntellAlertCfgObject *cfg = [self.arrayManagers objectAtIndex:self.index];
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(IntellAlertCfgObject) *weakCfg = cfg;
    
    if (self.selectingCfg) {
        NSArray *arraySection = [self.dataSourceCfg objectAtIndex:indexPath.section];
        NSDictionary *dic = [arraySection objectAtIndex:indexPath.row];
        NSString *title = [dic objectForKey:@"name"];
        
        if (indexPath.row == 0) {
            TitleComboBoxCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleComboBoxCell];
            [cell showAutoAdjustAllTitleHeight:NO];
            
            cell.titleLabel.text = title;

            if ([title isEqualToString:TS("bulb_switch")] || [title isEqualToString:TS("Control_Mode")] || [title isEqualToString:TS("TR_Light_Settings")]) {
                NSArray *pamarNameArr = [dic objectForKey:@"parameter_name_list"];
                NSString *detailName = @"";
                for (int i = 0; i < pamarNameArr.count ; i++) {
                    NSString *pName = [pamarNameArr objectAtIndex:i];
                    if (detailName.length <= 0) {
                        detailName = pName;
                    }else{
                        detailName = [detailName stringByAppendingFormat:@"/%@",pName];
                    }
                }
            
                [cell displayDetailLabel:detailName];
                [cell showAutoAdjustAllTitleHeight:YES];
            }else{
                [cell noDisplayDetailLabel];
            }
            
            [cell makeArrowRotation:- M_PI * 0.5 reset:NO animation:YES];
            cell.lbRight.text = @"";
            cell.lbRight.hidden = NO;
            
            if ([title isEqualToString:TS("TR_Continuous_alarm_time")]) {//报警持续时间
                cell.lbRight.text = [NSString stringWithFormat:@"%is",[cfg.intellAlertManager getDuration]];
            }else if ([title isEqualToString:TS("TR_Alarm_volume")]) {//报警音量
                cell.lbRight.text = [NSString stringWithFormat:@"%i",[cfg.volumeOutputManager getLeftVolume]];
            }else if ([title isEqualToString:TS("bulb_switch")] || [title isEqualToString:TS("Control_Mode")]){//灯泡开关 或者 控制模式
                NSArray *pamarArr = [dic objectForKey:@"select_parameter_list"];
                NSArray *pamarNameArr = [dic objectForKey:@"parameter_name_list"];
                //当前描述序号
                int index = 0;
                //获取当前的模式
                NSString *workMode = [self.whiteLightManager getWorkMode];
                if (workMode.length > 0) {
                    index = (int)[pamarArr indexOfObject:workMode];
                }
                NSString *name = [pamarNameArr objectAtIndex:index];
                cell.lbRight.text = name;
            }else if ([title isEqualToString:TS("TR_Light_Settings")]){
                NSArray *pamarNameArr = [dic objectForKey:@"parameter_name_list"];
                //当前描述序号
                int index = 0;
                //获取当前的模式
                int type = [cfg.lp4GDoubleLightSwitchCfgManager getLightType];
                if (type == 2) {
                    index = 1;
                }else if (type == 3){
                    index = 2;
                }
                NSString *name = [pamarNameArr objectAtIndex:index];
                cell.lbRight.text = name;
            }
            [cell enterFilletMode];
            if ([title isEqualToString:TS("Intelligent_duration")]){
                 
                [cell makeRightLableLarge:NO];
                
            } else {
                [cell makeRightLableLarge:YES];
                
            }
            
            
            
            return cell;
        }else{
                if ([title isEqualToString:TS("TR_Alarm_volume")]) {//报警音量
                SliderOnlyCell *cell = [tableView dequeueReusableCellWithIdentifier:kSliderOnlyCell];
                cell.slider.minimumValue = 1;
                cell.slider.maximumValue = 100;
                cell.slider.value = [cfg.volumeOutputManager getLeftVolume];
                cell.SliderOnlyCellValueChanged = ^(CGFloat value) {
                    [weakCfg.volumeOutputManager setLeftVolume:value];
                    [weakCfg.volumeOutputManager setRightVolume:value];
                    [weakSelf.tbFunction reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    
                    [weakSelf setNeedsLayout];
                    [weakSelf layoutIfNeeded];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        CGSize size = weakSelf.tbFunction.contentSize;
                        if (weakSelf.refreshIntellAlertView) {
                            weakSelf.refreshIntellAlertView(size.height/size.width);
                        }
                    });
                };
                
                cell.SliderOnlyCellTouchUpInslide = ^(CGFloat value) {
                    [SVProgressHUD show];
                    [weakCfg.volumeOutputManager setVideoVolumeOutputCompleted:^(int result, int channel) {
                        if (result < 0) {
                            [weakSelf dealSetConfigFailed:result];
                        }else{
                            [SVProgressHUD dismiss];;
                            weakSelf.selectingCfg = NO;
                            [weakSelf intervalRefreshList];
                        }
                    }];
                };
                
                return cell;
            }
                else{
                SelectItemCell *cell = [tableView dequeueReusableCellWithIdentifier:kSelectItemCell];
                cell.lbTitle.text = title;
                
                if (indexPath.row == self.selectedIndexCfg + 1) {
                    cell.ifSelected = YES;
                }else{
                    cell.ifSelected = NO;
                }
                
                return cell;
            }
        }
    }else{
        NSArray *arraySection = [self.dataSource objectAtIndex:indexPath.section];
        NSDictionary *dic = [arraySection objectAtIndex:indexPath.row];
        NSString *title = [dic objectForKey:@"name"];
        if (indexPath.section == 0) {
            if ([title isEqualToString:TS("TR_Light_Settings")]) {
                NSArray *pamarNameArr = [dic objectForKey:@"parameter_name_list"];
                
                TitleComboBoxCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleComboBoxCell];
                [cell showAutoAdjustAllTitleHeight:NO];
                
                NSString *detailName = @"";
                for (int i = 0; i < pamarNameArr.count ; i++) {
                    NSString *pName = [pamarNameArr objectAtIndex:i];
                    if (detailName.length <= 0) {
                        detailName = pName;
                    }else{
                        detailName = [detailName stringByAppendingFormat:@"/%@",pName];
                    }
                }
                
                cell.titleLabel.text = title;
                [cell displayDetailLabel:detailName];
                [cell showAutoAdjustAllTitleHeight:YES];
                [cell makeArrowRotation:0 reset:YES animation:YES];
                cell.lbRight.text = @"";
                cell.lbRight.hidden = NO;
                
                //当前描述序号
                int index = 0;
                //获取当前的模式
                int type = [cfg.lp4GDoubleLightSwitchCfgManager getLightType];
                if (type == 2) {
                    index = 1;
                }else if (type == 3){
                    index = 2;
                }
                NSString *name = [pamarNameArr objectAtIndex:index];
                
                cell.lbRight.text = name;
                
                [cell enterFilletMode];
                [cell makeRightLableLarge:YES];
                

                return cell;
            }else if ([title isEqualToString:TS("TR_Light_Up_Switch")]) {//照明开关
                AlarmSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleSwitchCell];
                cell.titleLabel.text = title;
                cell.toggleSwitch.on = [cfg.lp4GDoubleLightSwitchCfgManager getLightType] == 2 ? YES : NO;
//                cell.bottomLineLeftBorder = 0;
//                cell.titleLeftBorder = 5;
//                [cell enterFilletMode];
                
                cell.toggleSwitchStateChangedAction = ^(BOOL on) {
                    [weakCfg.lp4GDoubleLightSwitchCfgManager setLightType:on ? 2 : 1];
                    [weakSelf intervalRefreshList];
                    
                    [SVProgressHUD show];
                    [weakCfg.lp4GDoubleLightSwitchCfgManager setLP4GDoubleLightCompleted:^(XM_REQ_STATE state, NSDictionary *info) {
                        int result = [[info objectForKey:@"result"] intValue];
                        if (result < 0) {
                            [weakSelf dealSetConfigFailed:result];
                        }else{
                            [SVProgressHUD dismiss];;
                        }
                        weakSelf.selectingCfg = NO;
                        [weakSelf updateLowPowerLightSectionDataSource:1];
                        [weakSelf refreshList];
                    }];
                };
                
                return cell;
            }
            else if ([title isEqualToString:TS("TR_Adjustment_Of_Brightness")]) {//亮度调整
                BaseStationSoundSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:kBaseStationSoundSettingCell];
                cell.style = BaseStationSoundSettingCellStyle_LeftImage;
                cell.titleLabel.text = TS("TR_Adjustment_Of_Brightness");
                cell.slider.maximumValue = 100;
                cell.slider.minimumValue = 1;
                cell.lbValue.hidden = YES;
                
                [cell setSliderValue:[cfg.lp4GDoubleLightSwitchCfgManager getLightBrightness]];
                [cell.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(@20);
                }];
                
                __weak typeof(self) weakSelf = self;
                cell.soundSettingCellSliderValueChanged = ^(CGFloat value) {
                    [weakCfg.lp4GDoubleLightSwitchCfgManager setLightBrightness:value];
                };
                
                cell.soundSettingCellSliderTouchEndAction = ^(CGFloat value) {
                    [weakCfg.lp4GDoubleLightSwitchCfgManager setLightBrightness:value];
                    [SVProgressHUD show];
                    [weakCfg.lp4GDoubleLightSwitchCfgManager setLP4GDoubleLightCompleted:^(XM_REQ_STATE state, NSDictionary *info) {
                        int result = [[info objectForKey:@"result"] intValue];
                        if (result < 0) {
                            [weakSelf dealSetConfigFailed:result];
                        }else{
                            [SVProgressHUD dismiss];;
                        }
                        weakSelf.selectingCfg = NO;
                        [weakSelf updateLowPowerLightSectionDataSource:1];
                        [weakSelf refreshList];
                    }];
                };
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
        }
        else if (indexPath.section == 1) {
            if ([title isEqualToString:TS("bulb_switch")] || [title isEqualToString:TS("Control_Mode")]){//灯泡开关 或者 控制模式
                NSArray *pamarArr = [dic objectForKey:@"select_parameter_list"];
                NSArray *pamarNameArr = [dic objectForKey:@"parameter_name_list"];
                
                TitleComboBoxCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleComboBoxCell];
                [cell showAutoAdjustAllTitleHeight:NO];
                
                NSString *detailName = @"";
                for (int i = 0; i < pamarNameArr.count ; i++) {
                    NSString *pName = [pamarNameArr objectAtIndex:i];
                    if (detailName.length <= 0) {
                        detailName = pName;
                    }else{
                        detailName = [detailName stringByAppendingFormat:@"/%@",pName];
                    }
                }
                
                cell.titleLabel.text = title;
                [cell displayDetailLabel:detailName];
                [cell showAutoAdjustAllTitleHeight:YES];
                [cell makeArrowRotation:0 reset:YES animation:YES];
                cell.lbRight.text = @"";
                cell.lbRight.hidden = NO;
                
                //当前描述序号
                int index = 0;
                //获取当前的模式
                NSString *workMode = [self.whiteLightManager getWorkMode];
                if (workMode.length > 0) {
                    index = (int)[pamarArr indexOfObject:workMode];
                }
                NSString *name = [pamarNameArr objectAtIndex:index];
                
                cell.lbRight.text = name;
                
                [cell enterFilletMode];
                [cell makeRightLableLarge:YES];

                return cell;
            }else if ([title isEqualToString:TS("open_time")]){//打开时间
                TitleComboBoxCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleComboBoxCell];
                [cell showAutoAdjustAllTitleHeight:NO];
                
                cell.titleLabel.text = title;
                [cell noDisplayDetailLabel];
                [cell makeArrowRotation:0 reset:YES animation:YES];
                cell.lbRight.text = @"";
                cell.lbRight.hidden = NO;
                cell.lbRight.text = [NSString stringWithFormat:@"%02d:%02d", [self.whiteLightManager getWorkPeriodSHour], [self.whiteLightManager getWorkPeriodSMinute]];
                
                [cell enterFilletMode];
                [cell makeRightLableLarge:YES];
                return cell;
            }else if ([title isEqualToString:TS("close_time")]){//关闭时间
                TitleComboBoxCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleComboBoxCell];
                [cell showAutoAdjustAllTitleHeight:NO];
                
                cell.titleLabel.text = title;
                [cell noDisplayDetailLabel];
                [cell makeArrowRotation:0 reset:YES animation:YES];
                cell.lbRight.text = @"";
                cell.lbRight.hidden = NO;
                cell.lbRight.text = [NSString stringWithFormat:@"%02d:%02d", [self.whiteLightManager getWorkPeriodEHour], [self.whiteLightManager getWorkPeriodEMinute]];
                
                [cell enterFilletMode];
                [cell makeRightLableLarge:YES];

                return cell;
            }else if ([title isEqualToString:TS("Intelligent_sensitivity")]){//报警亮灯灵敏度
                TitleComboBoxCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleComboBoxCell];
                [cell showAutoAdjustAllTitleHeight:NO];
                
                cell.titleLabel.text = title;
                [cell noDisplayDetailLabel];
                [cell makeArrowRotation:0 reset:YES animation:YES];
                cell.lbRight.text = @"";
                cell.lbRight.hidden = NO;
                int lightLevel = [self.whiteLightManager getMoveTrigLightLevel];
                NSString *levelName = @"";
                if (lightLevel >= 5) {
                    levelName = TS("Intelligent_level_Height");
                }else if (lightLevel >= 3){
                    levelName = TS("Intelligent_level_Middle");
                }else{
                    levelName = TS("Intelligent_level_Low");
                }
                
                cell.lbRight.text = levelName;
                
                [cell enterFilletMode];
                [cell makeRightLableLarge:NO];

                return cell;
            }else if ([title isEqualToString:TS("Intelligent_duration")]){//亮灯持续时间
                TitleComboBoxCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleComboBoxCell];
                [cell showAutoAdjustAllTitleHeight:NO];
                
                cell.titleLabel.text = title;
                [cell noDisplayDetailLabel];
                [cell makeArrowRotation:0 reset:YES animation:YES];
                cell.lbRight.text = @"";
                cell.lbRight.hidden = NO;
    
                cell.lbRight.text = [NSString stringWithFormat:@"%is",[self.whiteLightManager getMoveTrigLightDuration]];
                
                [cell enterFilletMode];
                [cell makeRightLableLarge:NO];
                
                return cell;
            }else if ([title isEqualToString:TS("Intelligent_Vigilance")]){
                //球技支持的智能警戒
                TitleComboBoxCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleComboBoxCell];
                [cell showAutoAdjustAllTitleHeight:NO];
                
                cell.titleLabel.text = title;
                [cell noDisplayDetailLabel];
                [cell makeArrowRotation:0 reset:YES animation:YES];
                cell.lbRight.text = @"";
                cell.lbRight.hidden = NO;
    
                [cell enterFilletMode];
                [cell makeRightLableLarge:NO];

                return cell;
            }
        }else if (indexPath.section == 2){
            if ([title isEqualToString:TS("TR_PIR_Detection")]){//人体感应报警
                TitleComboBoxCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleComboBoxCell];
                [cell showAutoAdjustAllTitleHeight:NO];
                
                DeviceObject *device = [[DeviceControl getInstance] GetDeviceObjectBySN: self.devID];
                if (( (device.sysFunction.iSupportLP4GSupportDoubleLightSwitch == 1 && self.channel == -1)) && ( (device.sysFunction.iSupportLowPowerDoubleLightToLightingSwitch == 1 && self.channel == -1))){//如果是庭院灯
                    cell.titleLabel.text = title;
                }else{
                    cell.titleLabel.text = TS("TR_Human_body_induction_alarm");
                    if (device.sysFunction.iSupportLPWorkModeSwitchV2) {
                        [cfg.batteryInfoManager LPDevWorkMode:self.devID ActualTimeValue:NO Completion:^(LPDevWorkMode value) {
                            if(value == LPDevWorkMode_NoSleep){
                                cell.titleLabel.text = TS("TR_Human_shape_induction_alarm");
                            }
                        }];
                    }
                }
                [cell noDisplayDetailLabel];
                [cell makeArrowRotation:0 reset:YES animation:YES];
                cell.lbRight.text = @"";
                cell.lbRight.hidden = NO;
                
                BOOL enable = [cfg.pirAlarmManager getEnable];
                
                cell.lbRight.text = enable ? TS("TR_Open_Alarm") : TS("close");
                
                [cell enterFilletMode];
                [cell makeRightLableLarge:NO];
                
                return cell;
            }else if ([title isEqualToString:TS("Intelligent_Vigilance")]){
                AlarmSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleSwitchCell];
                
                //如果是基站 名称特殊显示成 联动报警 2023-01-06单品名称改成智能警戒开关
                cell.titleLabel.text = TS("TR_Intelligent_Warning_Switch");
                cell.toggleSwitch.on = [cfg.intellAlertManager getEnable];
//                cell.bottomLineLeftBorder = 0;
//                cell.titleLeftBorder = 5;
//                [cell enterFilletMode];
                
                cell.toggleSwitchStateChangedAction = ^(BOOL on) {
                    [weakCfg.intellAlertManager setEnable:on];
                    [weakSelf intervalRefreshList];
                    
                    [SVProgressHUD show];
                    [weakCfg.intellAlertManager setIntellAlertAlarmCompleted:^(int result, int channel) {
                        if (result < 0) {
                            [weakSelf dealSetConfigFailed:result];
                        }else{
                            [SVProgressHUD dismiss];;
                        }
                    }];
                };
                
                return cell;
            }
        }else{
            if ([title isEqualToString:TS("TR_Alarm_Light_Switch")]) {//报警灯开关
                AlarmSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleSwitchCell];
                cell.titleLabel.text = TS("TR_Alarm_Light_Switch");
                cell.toggleSwitch.on = [cfg.intellAlertManager getAlarmOutEnable];
//                cell.bottomLineLeftBorder = 0;
//                cell.titleLeftBorder = 5;
//                [cell enterFilletMode];
                
                cell.toggleSwitchStateChangedAction = ^(BOOL on) {
                    [weakCfg.intellAlertManager setAlarmOutEnable:on];
                    [weakSelf intervalRefreshList];
                    
                    [SVProgressHUD show];
                    [weakCfg.intellAlertManager setIntellAlertAlarmCompleted:^(int result, int channel) {
                        if (result < 0) {
                            [weakSelf dealSetConfigFailed:result];
                        }else{
                            [SVProgressHUD dismiss];;
                        }
                    }];
                };
                
               
                return cell;
            }else if ([title isEqualToString:TS("TR_Linked_Alarm")]) {//联动报警
                AlarmSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleSwitchCell];

                cell.titleLabel.text = title;
                cell.toggleSwitch.on = [cfg.intellAlertManagerBase getRemoteEnableChannel:self.channel];
//                cell.bottomLineLeftBorder = 0;
//                cell.titleLeftBorder = 5;
//                [cell enterFilletMode];

                cell.toggleSwitchStateChangedAction = ^(BOOL on) {
                    [weakCfg.intellAlertManagerBase setRemoteEnable:on channel:weakSelf.channel];
                    [weakSelf intervalRefreshList];

                    [SVProgressHUD show];
                    [weakCfg.intellAlertManagerBase setIntellAlertAlarmCompleted:^(int result, int channel) {
                        if (result < 0) {
                            [weakSelf dealSetConfigFailed:result];
                        }else{
                            [SVProgressHUD dismiss];;
                        }
                    }];
                };

                return cell;
            }else if ([title isEqualToString:TS("TR_Continuous_alarm_time")]){//报警持续时间
                TitleComboBoxCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleComboBoxCell];
                [cell showAutoAdjustAllTitleHeight:NO];
                
                cell.titleLabel.text = title;
                [cell noDisplayDetailLabel];
                [cell makeArrowRotation:0 reset:YES animation:YES];
                cell.lbRight.text = @"";
                cell.lbRight.hidden = NO;
                cell.lbRight.text = [NSString stringWithFormat:@"%is",[cfg.intellAlertManager getDuration]];
                
                [cell enterFilletMode];
                [cell makeRightLableLarge:NO];
                
                return cell;
            }else if ([title isEqualToString:TS("TR_Alarm_volume")]){//报警音量
                TitleComboBoxCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleComboBoxCell];
                [cell showAutoAdjustAllTitleHeight:NO];
                
                cell.titleLabel.text = title;
                [cell noDisplayDetailLabel];
                [cell makeArrowRotation:0 reset:YES animation:YES];
                cell.lbRight.text = @"";
                cell.lbRight.hidden = NO;
                cell.lbRight.text = [NSString stringWithFormat:@"%i",[cfg.volumeOutputManager getLeftVolume]];
                
                [cell enterFilletMode];
                [cell makeRightLableLarge:NO];

                return cell;
            }else if ([title isEqualToString:TS("TR_Alarm_ringtone")]){//报警铃声
                TitleComboBoxCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleComboBoxCell];
                [cell showAutoAdjustAllTitleHeight:NO];
                
                cell.titleLabel.text = title;
                [cell noDisplayDetailLabel];
                [cell makeArrowRotation:0 reset:YES animation:YES];
                cell.lbRight.text = @"";
                cell.lbRight.hidden = NO;
                
                int type = [cfg.intellAlertManager getVoiceType];
                
                NSMutableArray *list = [[cfg.voiceTipTypeManager getVoiceTypeList] mutableCopy];
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
                
                [cell enterFilletMode];
                [cell makeRightLableLarge:YES];
                

                return cell;
            }else if ([title isEqualToString:TS("TR_PIR_Detection")]){//人体感应报警
                TitleComboBoxCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleComboBoxCell];
                [cell showAutoAdjustAllTitleHeight:NO];
                
                DeviceObject *device = [[DeviceControl getInstance] GetDeviceObjectBySN: self.devID];
                if (( (device.sysFunction.iSupportLP4GSupportDoubleLightSwitch == 1 && self.channel == -1)) && ( (device.sysFunction.iSupportLowPowerDoubleLightToLightingSwitch == 1 && self.channel == -1))){//如果是庭院灯
                    cell.titleLabel.text = title;
                }else{
                    cell.titleLabel.text = TS("TR_Human_body_induction_alarm");
                    if (device.sysFunction.iSupportLPWorkModeSwitchV2) {
                        [cfg.batteryInfoManager LPDevWorkMode:self.devID ActualTimeValue:NO Completion:^(LPDevWorkMode value) {
                            if(value == LPDevWorkMode_NoSleep){
                                cell.titleLabel.text = TS("TR_Human_shape_induction_alarm");
                            }
                        }];
                    }
                }
                [cell noDisplayDetailLabel];
                [cell makeArrowRotation:0 reset:YES animation:YES];
                cell.lbRight.text = @"";
                cell.lbRight.hidden = NO;
                
                BOOL enable = [cfg.pirAlarmManager getEnable];
                
                cell.lbRight.text = enable ? TS("TR_Open_Alarm") : TS("close");
                
                [cell enterFilletMode];
                [cell makeRightLableLarge:NO];
                

                return cell;
            }
        }
    }
    
    return [[UITableViewCell alloc] init];
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (self.curStyle == JFIAVS_T_BLACK) {
//        [tableView makeFilletTableViewCell:cell forRowAtIndexPath:indexPath transparent:YES];
//    }else{
//        
//    }
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    IntellAlertCfgObject *cfg = [self.arrayManagers objectAtIndex:self.index];
    
    __weak typeof(self) weakSelf = self;
    
    if (self.selectingCfg) {
        NSArray *arraySection = [self.dataSourceCfg objectAtIndex:indexPath.section];
        NSDictionary *dicHead = [arraySection objectAtIndex:0];
        
        if (indexPath.row == 0) {
            self.selectingCfg = NO;
            [self refreshList];
        }else{
            NSString *firstTitle = [[arraySection objectAtIndex:0] objectForKey:@"name"];
            if ([firstTitle isEqualToString:TS("TR_Alarm_ringtone")]) {
                NSMutableArray *list = [[cfg.voiceTipTypeManager getVoiceTypeList] mutableCopy];
//                //非单品自定义不显示
//                if (self.channel >= 0) {
//                    for (int i = 0; i < list.count; i ++) {
//                        NSDictionary *dic = [list objectAtIndex:i];
//                        int voiceEnum = [[dic objectForKey:@"VoiceEnum"] intValue];
//                        if (voiceEnum == 550) {
//                            [list removeObjectAtIndex:i];
//                            break;
//                        }
//                    }
//                }
                
                NSDictionary *dic = [list objectAtIndex:indexPath.row - 1];
                int selectedType = [[dic objectForKey:@"VoiceEnum"] intValue];
                [cfg.intellAlertManager setVoiceType:selectedType];
                [SVProgressHUD show];
                [cfg.intellAlertManager setIntellAlertAlarmCompleted:^(int result, int channel) {
                    if (result < 0) {
                        [weakSelf dealSetConfigFailed:result];
                    }else{
                        //如果选中的是自定义报警音 进入编辑界面
                        if (selectedType == 550) {
                            [SVProgressHUD dismiss];
                            if (weakSelf.ClickJumpVCSign) {
                                weakSelf.ClickJumpVCSign(@"NetCustomRecordVC");
                            }
                        }else{
                            [SVProgressHUD dismiss];;
                        }
                    }
                    
                    weakSelf.selectingCfg = NO;
                    [weakSelf intervalRefreshList];
                    [weakSelf jumpToTop];
                }];
            }else if ([firstTitle isEqualToString:TS("TR_Light_Settings")]){//低功耗灯光配置
                NSArray *pamarArr = [dicHead objectForKey:@"select_parameter_list"];
                int type = [[pamarArr objectAtIndex:indexPath.row - 1] intValue];
                [SVProgressHUD show];
                [cfg.lp4GDoubleLightSwitchCfgManager setLightType:type];
                [cfg.lp4GDoubleLightSwitchCfgManager setLP4GDoubleLightCompleted:^(XM_REQ_STATE state, NSDictionary *info) {
                    int result = [[info objectForKey:@"result"] intValue];
                    if (result < 0) {
                        [weakSelf dealSetConfigFailed:result];
                    }else{
                        [SVProgressHUD dismiss];;
                    }
                    weakSelf.selectingCfg = NO;
                    [weakSelf updateLowPowerLightSectionDataSource:0];
                    [weakSelf refreshList];
                    [weakSelf jumpToTop];
                }];
            }else if ([firstTitle isEqualToString:TS("bulb_switch")] || [firstTitle isEqualToString:TS("Control_Mode")]){//灯泡开关 或者 控制模式
                NSArray *pamarArr = [dicHead objectForKey:@"select_parameter_list"];
                NSString *workMode = [pamarArr objectAtIndex:indexPath.row - 1];
                if (workMode) {
                    [self.whiteLightManager setWorkMode:workMode];
                    [SVProgressHUD show];
                    [self.whiteLightManager setDeviceConfig];
//                    [cfg.whiteLightManager setWhiteLight:^(WhiteLightManagerRequestType requestType, int result,int channel) {
//                        if (result < 0) {
//                            [weakSelf dealSetConfigFailed:result];
//                        }else{
//                            [SVProgressHUD dismiss];;
//                            [weakSelf updateLightSectionDataSource];
//                        }
//                        
//                        weakSelf.selectingCfg = NO;
//                        [weakSelf refreshList];
//                        [weakSelf jumpToTop];
//                    }];
                }
            }else if ([firstTitle isEqualToString:TS("Intelligent_sensitivity")]){//报警亮灯灵敏度
                NSArray *pamarArr = [dicHead objectForKey:@"select_parameter_list"];
                NSNumber *level = [pamarArr objectAtIndex:indexPath.row - 1];
                if (level) {
                    [self.whiteLightManager setMoveTrigLightLevel:[level intValue]];
                    [SVProgressHUD show];
                    [self.whiteLightManager setDeviceConfig];
//                    [cfg.whiteLightManager setWhiteLight:^(WhiteLightManagerRequestType requestType, int result,int channel) {
//                        if (result < 0) {
//                            [weakSelf dealSetConfigFailed:result];
//                        }else{
//                            [SVProgressHUD dismiss];;
//                            [weakSelf updateLightSectionDataSource];
//                        }
//                        
//                        weakSelf.selectingCfg = NO;
//                        [weakSelf refreshList];
//                        [weakSelf jumpToTop];
//                    }];
                }
            }else if ([firstTitle isEqualToString:TS("Intelligent_duration")]){//亮灯持续时间
                NSArray *pamarArr = [dicHead objectForKey:@"select_parameter_list"];
                NSNumber *duration = [pamarArr objectAtIndex:indexPath.row - 1];
                if (duration) {
                    [self.whiteLightManager setMoveTrigLightDuration:[duration intValue]];
                    [SVProgressHUD show];
//                    [cfg.whiteLightManager setWhiteLight:^(WhiteLightManagerRequestType requestType, int result,int channel) {
//                        if (result < 0) {
//                            [weakSelf dealSetConfigFailed:result];
//                        }else{
//                            [SVProgressHUD dismiss];;
//                            [weakSelf updateLightSectionDataSource];
//                        }
//                        
//                        weakSelf.selectingCfg = NO;
//                        [weakSelf refreshList];
//                        [weakSelf jumpToTop];
//                    }];
                    [self.whiteLightManager setDeviceConfig];
                }
            }else if ([firstTitle isEqualToString:TS("TR_Continuous_alarm_time")]){//持续报警时间
                NSArray *pamarArr = [dicHead objectForKey:@"select_parameter_list"];
                NSNumber *duration = [pamarArr objectAtIndex:indexPath.row - 1];
                if (duration) {
                    [cfg.intellAlertManager setDuration:[duration intValue]];
                    [SVProgressHUD show];
                    [cfg.intellAlertManager setIntellAlertAlarmCompleted:^(int result, int channel) {
                        if (result < 0) {
                            [weakSelf dealSetConfigFailed:result];
                        }else{
                            [SVProgressHUD dismiss];;
                        }
                        
                        weakSelf.selectingCfg = NO;
                        [weakSelf refreshList];
                        [weakSelf jumpToTop];
                    }];
                }
            }
        }
    }else{
        NSArray *arraySection = [self.dataSource objectAtIndex:indexPath.section];
        NSDictionary *dic = [arraySection objectAtIndex:indexPath.row];
        NSString *title = [dic objectForKey:@"name"];
        if (indexPath.section == 0) {
            if ([title isEqualToString:TS("TR_Light_Settings")]){
                [self.dataSourceCfg removeAllObjects];
                NSMutableArray *arraySection = [NSMutableArray arrayWithCapacity:0];
                NSArray *pamarArr = [dic objectForKey:@"select_parameter_list"];
                NSArray *pamarNameArr = [dic objectForKey:@"parameter_name_list"];
                if (pamarArr && pamarNameArr) {
                    [arraySection addObject:@{@"name":title,@"select_parameter_list":pamarArr,@"parameter_name_list":pamarNameArr}];
                }
                
                for (int i = 0; i < pamarNameArr.count; i++) {
                    [arraySection addObject:@{@"name":[pamarNameArr objectAtIndex:i]}];
                }
                
                //当前描述序号
                int index = 0;
                //获取当前的模式
                int type = [cfg.lp4GDoubleLightSwitchCfgManager getLightType];
                if (type == 2) {
                    index = 1;
                }else if (type == 3){
                    index = 2;
                }
                self.selectedIndexCfg = index;
                
                [self.dataSourceCfg addObject:arraySection];
                self.selectingCfg = YES;
                [self refreshList];
                [self jumpToTop];
            }
        }
        else if (indexPath.section == 1) {
            if ([title isEqualToString:TS("bulb_switch")] || [title isEqualToString:TS("Control_Mode")]){//灯泡开关 或者 控制模式
                [self.dataSourceCfg removeAllObjects];
                NSMutableArray *arraySection = [NSMutableArray arrayWithCapacity:0];
                NSArray *pamarArr = [dic objectForKey:@"select_parameter_list"];
                NSArray *pamarNameArr = [dic objectForKey:@"parameter_name_list"];
                if (pamarArr && pamarNameArr) {
                    [arraySection addObject:@{@"name":title,@"select_parameter_list":pamarArr,@"parameter_name_list":pamarNameArr}];
                }
                
                for (int i = 0; i < pamarNameArr.count; i++) {
                    [arraySection addObject:@{@"name":[pamarNameArr objectAtIndex:i]}];
                }
                
                //当前描述序号
                int index = 0;
                //获取当前的模式
                NSString *workMode = [self.whiteLightManager getWorkMode];
                if (workMode.length > 0) {
                    index = (int)[pamarArr indexOfObject:workMode];
                }
                self.selectedIndexCfg = index;
                
                [self.dataSourceCfg addObject:arraySection];
                self.selectingCfg = YES;
                [self refreshList];
                [self jumpToTop];
            }else if ([title isEqualToString:TS("open_time")]){//打开时间
                NSDateFormatter *format = [[NSDateFormatter alloc] init];
                [format setDateFormat:@"HH:mm"];
                NSCalendar *calender = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
                [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:calender.locale.localeIdentifier]];
                NSDate *date = [format dateFromString:[NSString stringWithFormat:@"%02d:%02d", [self.whiteLightManager getWorkPeriodSHour], [self.whiteLightManager getWorkPeriodSMinute]]];
                MyDatePickerView *datePicker = [[MyDatePickerView alloc]init];
                datePicker.tag = indexPath.row;
                datePicker.action = @"open_time";
                datePicker.delegate = self;
                datePicker.curStyle = DatePickerStyleTime;
                self.tempPikcer = datePicker;
                [datePicker myShowInView:((AppDelegate *)([UIApplication sharedApplication].delegate)).window showDate:date dismiss:^{
                    
                }];
            }else if ([title isEqualToString:TS("close_time")]){//关闭时间
                NSDateFormatter *format = [[NSDateFormatter alloc] init];
                [format setDateFormat:@"HH:mm"];
                NSCalendar *calender = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
                [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:calender.locale.localeIdentifier]];
                NSDate *date = [format dateFromString:[NSString stringWithFormat:@"%02d:%02d", [self.whiteLightManager getWorkPeriodEHour], [self.whiteLightManager getWorkPeriodEMinute]]];
                MyDatePickerView *datePicker = [[MyDatePickerView alloc]init];
                datePicker.tag = indexPath.row;
                datePicker.action = @"close_time";
                datePicker.delegate = self;
                datePicker.curStyle = DatePickerStyleTime;
                self.tempPikcer = datePicker;
                [datePicker myShowInView:((AppDelegate *)([UIApplication sharedApplication].delegate)).window showDate:date dismiss:^{
                    
                }];
            }else if ([title isEqualToString:TS("Intelligent_sensitivity")]){//报警亮灯灵敏度
                [self.dataSourceCfg removeAllObjects];
                NSMutableArray *arraySection = [NSMutableArray arrayWithCapacity:0];
                NSArray *pamarArr = [dic objectForKey:@"select_parameter_list"];
                NSArray *pamarNameArr = [dic objectForKey:@"parameter_name_list"];
                if (pamarArr && pamarNameArr) {
                    [arraySection addObject:@{@"name":title,@"select_parameter_list":pamarArr,@"parameter_name_list":pamarNameArr}];
                }
                
                for (int i = 0; i < pamarNameArr.count; i++) {
                    [arraySection addObject:@{@"name":[pamarNameArr objectAtIndex:i]}];
                }
                
                //当前描述序号
                int index = 0;
                //获取当前的灵敏度
                int lightLevel = [self.whiteLightManager getMoveTrigLightLevel];
                if (lightLevel >= 5) {
                    index = 2;
                }else if (lightLevel >= 3){
                    index = 1;
                }else{
                    index = 0;
                }
                
                self.selectedIndexCfg = index;
                
                [self.dataSourceCfg addObject:arraySection];
                self.selectingCfg = YES;
                [self refreshList];
                [self jumpToTop];
            }else if ([title isEqualToString:TS("Intelligent_duration")]){//亮灯持续时间
                [self.dataSourceCfg removeAllObjects];
                NSMutableArray *arraySection = [NSMutableArray arrayWithCapacity:0];
                NSArray *pamarArr = [dic objectForKey:@"select_parameter_list"];
                NSArray *pamarNameArr = [dic objectForKey:@"parameter_name_list"];
                if (pamarArr && pamarNameArr) {
                    [arraySection addObject:@{@"name":title,@"select_parameter_list":pamarArr,@"parameter_name_list":pamarNameArr}];
                }
                
                for (int i = 0; i < pamarNameArr.count; i++) {
                    [arraySection addObject:@{@"name":[pamarNameArr objectAtIndex:i]}];
                }
                
                //当前描述序号
                int index = 0;
                //获取当前的持续时间
                int duration = [self.whiteLightManager getMoveTrigLightDuration];
                for (int i = 0; i < pamarArr.count; i++) {
                    if ([[pamarArr objectAtIndex:i] intValue] == duration) {
                        index = i;
                        break;
                    }
                }
                
                self.selectedIndexCfg = index;
                
                [self.dataSourceCfg addObject:arraySection];
                self.selectingCfg = YES;
                [self refreshList];
                [self jumpToTop];
            }else if ([title isEqualToString:TS("Intelligent_Vigilance")]){//跳转智能警戒
                if (self.ClickJumpVCSign) {
                    self.ClickJumpVCSign(@"HumanDetectionForIPCViewController");
                }
            }else if ([title isEqualToString:TS("TR_PIR_Detection")]){//人体感应侦测
                if (self.ClickJumpVCSign) {
                    self.ClickJumpVCSign(@"BaseStationPirAlarmViewController");
                }
            }
        }else{
            if ([title isEqualToString:TS("TR_Alarm_volume")]) {//报警音量
                [self.dataSourceCfg removeAllObjects];
                NSMutableArray *arraySection = [NSMutableArray arrayWithCapacity:0];
                [arraySection addObject:@{@"name":TS("TR_Alarm_volume")}];
                [arraySection addObject:@{@"name":TS("TR_Alarm_volume")}];
                [self.dataSourceCfg addObject:arraySection];
                self.selectingCfg = YES;
                [self refreshList];
            }else if ([title isEqualToString:TS("TR_Continuous_alarm_time")]){//持续报警时间
                int duration = [cfg.intellAlertManager getDuration];
                
                NSArray *pamarArr = [dic objectForKey:@"select_parameter_list"];
                NSArray *pamarNameArr = [dic objectForKey:@"parameter_name_list"];
                
                int lastIndex = 0;
                for (int i = 0; i < pamarArr.count; i++) {
                    NSNumber *time = [pamarArr objectAtIndex:i];
                    if ([time intValue] == duration) {
                        lastIndex = i;
                    }
                }
                
                self.selectedIndexCfg = lastIndex;
                
                [self.dataSourceCfg removeAllObjects];
                NSMutableArray *arraySection = [NSMutableArray arrayWithCapacity:0];
                if (pamarArr && pamarNameArr) {
                    [arraySection addObject:@{@"name":title,@"select_parameter_list":pamarArr,@"parameter_name_list":pamarNameArr}];
                }else{
                    [arraySection addObject:@{@"name":title}];
                }
                for (int i = 0; i < pamarNameArr.count; i++) {
                    [arraySection addObject:@{@"name":[pamarNameArr objectAtIndex:i]}];
                }
                [self.dataSourceCfg addObject:arraySection];
                self.selectingCfg = YES;
                [self refreshList];
                [self jumpToTop];
            }else if ([title isEqualToString:TS("TR_Alarm_ringtone")]){//报警铃声
                int type = [cfg.intellAlertManager getVoiceType];
                
                NSMutableArray *list = [[cfg.voiceTipTypeManager getVoiceTypeList] mutableCopy];
//                //非单品自定义不显示
//                if (self.channel >= 0) {
//                    for (int i = 0; i < list.count; i ++) {
//                        NSDictionary *dic = [list objectAtIndex:i];
//                        int voiceEnum = [[dic objectForKey:@"VoiceEnum"] intValue];
//                        if (voiceEnum == 550) {
//                            [list removeObjectAtIndex:i];
//                            break;
//                        }
//                    }
//                }
                
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
                
                self.selectedIndexCfg = lastIndex;
                
                [self.dataSourceCfg removeAllObjects];
                NSMutableArray *arraySection = [NSMutableArray arrayWithCapacity:0];
                [arraySection addObject:@{@"name":TS("TR_Alarm_ringtone")}];
                for (int i = 0; i < arrayItems.count; i++) {
                    [arraySection addObject:@{@"name":[arrayItems objectAtIndex:i]}];
                }
                [self.dataSourceCfg addObject:arraySection];
                self.selectingCfg = YES;
                [self refreshList];
                [self jumpToTop];
            }else if ([title isEqualToString:TS("TR_PIR_Detection")]){//人体感应侦测
                if (self.ClickJumpVCSign) {
                    self.ClickJumpVCSign(@"BaseStationPirAlarmViewController");
                }
            }
        }
        
    }
    
}

- (void)setWhiteLightConfigResult:(int) result{
    if (result < 0) {
        [self dealSetConfigFailed:result];
    }else{
        [SVProgressHUD dismiss];;
        [self updateLightSectionDataSource];
    }
    
    self.selectingCfg = NO;
    [self refreshList];
    [self jumpToTop];
}

- (void)jumpToTop{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tbFunction setContentOffset:CGPointMake(0, 0) animated:YES];
    });
}

//MARK: - 时间选择器的代理事件
-(void)onSelectDate:(NSDate *)date sender:(id)sender{
    if (date) {
        __weak typeof(self) weakSelf = self;
        if ([((MyDatePickerView *)sender).action isEqualToString:@"open_time"]) {
            //最好对时间进行判断
//            if ([CYCalenderManager getSecondsFromTime:[cfg.whiteLightManager getLightCloseTime] style:CY_TIME_STRING_STYLE_HM] == [CYCalenderManager getSecondsFromTime:dateTime style:CY_TIME_STRING_STYLE_HM]) {
//                
//                [SVProgressHUD showErrorText:TS("Start_And_End_Time_Unable_Equal")];
//                return;
//            }
//            else
//            {
            [self.whiteLightManager setWorkPeriodSHour: [[NSDate datestrFromDate:date withDateFormat:@"HH"] intValue]];
            [self.whiteLightManager setWorkPeriodSMinute: [[NSDate datestrFromDate:date withDateFormat:@"mm"] intValue]];
            [SVProgressHUD show];
            [self.whiteLightManager setDeviceConfig];
//            }
        }
        
        if ([((MyDatePickerView *)sender).action isEqualToString:@"close_time"]) {
            [self.whiteLightManager setWorkPeriodEHour: [[NSDate datestrFromDate:date withDateFormat:@"HH"] intValue]];
            [self.whiteLightManager setWorkPeriodEMinute: [[NSDate datestrFromDate:date withDateFormat:@"mm"] intValue]];
            [SVProgressHUD show];
            [self.whiteLightManager setDeviceConfig];
        }
    }
}


-(void)removeTheView:(UIButton *)sender{
    [self removeFromSuperview];
}

//MARK: - LazyLoad
- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:0];
        [_dataSource addObject:@[]];//低功耗灯光配置 目前只有白光红外切换
        [_dataSource addObject:@[]];//灯光配置
        [_dataSource addObject:@[]];//智能人体感应侦测入口和智能警戒开关
        [_dataSource addObject:@[]];//警戒
    }
    
    return _dataSource;
}

- (NSMutableArray *)dataSourceCfg{
    if (!_dataSourceCfg) {
        _dataSourceCfg = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _dataSourceCfg;
}

- (NSMutableArray <IntellAlertCfgObject *>*)arrayManagers{
    if (!_arrayManagers) {
        _arrayManagers = [NSMutableArray arrayWithCapacity:0];
        for (int i = 0; i < self.channels; i++) {
            [_arrayManagers addObject:[[IntellAlertCfgObject alloc] init]];
        }
    }
    
    return _arrayManagers;
}

- (UIView *)tbContainer{
    if (!_tbContainer) {
        _tbContainer = [[UIView alloc] init];
        _tbContainer.backgroundColor = UIColor.whiteColor;
        
        [_tbContainer addSubview:self.tbFunction];
        [self.tbFunction mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_tbContainer);
            make.right.equalTo(_tbContainer);
            make.top.equalTo(_tbContainer);
            make.bottom.equalTo(_tbContainer);
        }];
    }
    
    return _tbContainer;
}

- (UITableView *)tbFunction{
     if (!_tbFunction) {
         _tbFunction = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
         [_tbFunction registerClass:[AlarmSwitchCell class] forCellReuseIdentifier:kTitleSwitchCell];
         [_tbFunction registerClass:[TitleComboBoxCell class] forCellReuseIdentifier:kTitleComboBoxCell];
         [_tbFunction registerClass:[SliderOnlyCell class] forCellReuseIdentifier:kSliderOnlyCell];
         [_tbFunction registerClass:[SelectItemCell class] forCellReuseIdentifier:kSelectItemCell];
         [_tbFunction registerClass:[BaseStationSoundSettingCell class] forCellReuseIdentifier:kBaseStationSoundSettingCell];
         _tbFunction.rowHeight = 50;
         _tbFunction.separatorStyle = UITableViewCellSeparatorStyleNone;
         _tbFunction.dataSource = self;
         _tbFunction.delegate = self;
         _tbFunction.showsVerticalScrollIndicator = NO;
         _tbFunction.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
         _tbFunction.sectionHeaderHeight = 0;
         _tbFunction.sectionFooterHeight = 0;
         _tbFunction.backgroundColor = UIColor.whiteColor;
//         _tbFunction.tableFooterView = [[UIView alloc] init];
     }
 
    return _tbFunction;
}

- (CfgStatusManager *)cfgStatusManager{
    if (!_cfgStatusManager) {
        _cfgStatusManager = [[CfgStatusManager alloc] init];
    }
    
    return _cfgStatusManager;
}

-(UIButton *)closeBtn{
    if (!_closeBtn) {
        _closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 50,0 , 40, 40)];
        [_closeBtn setBackgroundImage:[UIImage imageNamed:@"icon_close"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(removeTheView:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

- (LightBulbConfig *)whiteLightManager{
    if (!_whiteLightManager) {
        _whiteLightManager = [[LightBulbConfig alloc] init];
        _whiteLightManager.delegate = self;
    }
    
    return _whiteLightManager;
}
@end
