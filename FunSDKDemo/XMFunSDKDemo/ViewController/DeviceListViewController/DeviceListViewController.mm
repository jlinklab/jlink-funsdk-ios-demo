//
//  DeviceListViewController.m
//  FunSDKDemo
//
//  Created by Levi on 2018/5/18.
//  Copyright © 2018年 Levi. All rights reserved.
//

#import "DeviceListTableViewCell.h"
#import "DeviceListViewController.h"
#import "PlayViewController.h"
#import "DeviceManager.h"
#import "DeviceInfoEditViewController.h"
#import "DeviceChannelView.h"
#import "ShareToMeVC.h"
#import "DoorBellModel.h"
#import "ShadowServicesViewController.h"

@interface DeviceListViewController ()<UITableViewDelegate,UITableViewDataSource,DeviceManagerDelegate>
{
    NSMutableArray *deviceArray; //设备信息数组
    int selectNum;               //当前选择的设置
}
@property (nonatomic, strong) UIBarButtonItem *rightBarBtn;

@property (nonatomic, strong) UITableView *devListTableView;

@property (nonatomic, strong) DeviceChannelView *channelView;
@property (nonatomic,strong) dispatch_queue_t socketMsgQueue;
@property (nonatomic, strong) NSMutableDictionary* webSocketDataInfo;//长连接数据
@property (nonatomic, strong) NSMutableDictionary* deviceActionDataInfo;

@end

@implementation DeviceListViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [_devListTableView reloadData];
}

- (UITableView *)devListTableView {
    if (!_devListTableView) {
        _devListTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) style:UITableViewStylePlain];
        _devListTableView.delegate = self;
        _devListTableView.dataSource = self;
        _devListTableView.rowHeight = 50;
        [_devListTableView registerClass:[DeviceListTableViewCell class] forCellReuseIdentifier:@"cell"];
        UILongPressGestureRecognizer *longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToDo:)];
        longPressGr.minimumPressDuration = 0.5;
        [_devListTableView addGestureRecognizer:longPressGr];
        
        _devListTableView.estimatedRowHeight = 0;
        _devListTableView.estimatedSectionHeaderHeight = 0;
        _devListTableView.estimatedSectionFooterHeight = 0;
    }
    return _devListTableView;
}

-(DeviceChannelView *)channelView{
    if (!_channelView) {
        _channelView = [[DeviceChannelView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _channelView.layer.borderWidth = 1;
        _channelView.layer.borderColor = [UIColor blackColor].CGColor;
        _channelView.center = self.view.center;
        _channelView.hidden = YES;
        
        __weak typeof(self) weakSelf = self;
//        _channelView.confirmBtnClicked = ^(NSMutableArray * _Nonnull selectArray, NSString * _Nonnull devID) {
//            for (int i = 0; i < selectArray.count; i++) {
//                [[DeviceControl getInstance] setSelectChannel:[selectArray objectAtIndex:i]];
//            }
//            //进入预览界面
//            PlayViewController *playVC = [[PlayViewController alloc] init];
//            [self.navigationController pushViewController:playVC animated:YES];
//        };
        
        //点击通道进行播放
        _channelView.channelClicked = ^(ChannelObject * _Nonnull channel, NSString * _Nonnull devID) {
            [[DeviceControl getInstance] setSelectChannel:channel];
            //进入预览界面
            PlayViewController *playVC = [[PlayViewController alloc] init];
            [self.navigationController pushViewController:playVC animated:YES];
        };
        //不再显示
        _channelView.noTipsBtnClicked = ^{
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NOT_SHOW_CHANNEL_LIST"];
            weakSelf.channelView.hidden = YES;
        };
    }
    
    return _channelView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //读取设备数据
    [self getDevicelist];
    //刷新读取到的设备的在线状态
    [self getdeviceState:nil];
    //设置导航栏样式
    [self setNaviStyle];
    //配置子试图
    [self configSubView];
    
    WeakSelf(weakSelf);
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    [center addObserverForName: @"WebSocketUpdate" object:nil  queue:queue usingBlock: ^(NSNotification *notification) {
        [weakSelf refreshDeviceStateWithDeviceDataInfo: notification.object];
    }];
    
}

- (void)getDevicelist {
    deviceArray = [[DeviceControl getInstance] currentDeviceArray];
    if (deviceArray == nil) {
        deviceArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
}
-(void)getdeviceState:(NSString*)deviceMac {
    //刷新读取到的设备状态
    DeviceManager *manager = [DeviceManager getInstance];
    manager.delegate = self;
    [manager getDeviceState:deviceMac];
}
- (void)setNaviStyle {
    self.title = TS("DeviceList");
    self.navigationItem.titleView = [[UILabel alloc] initWithTitle:self.title name:NSStringFromClass([self class])];
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"new_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController)];
    self.navigationItem.leftBarButtonItem = leftBtn;
    self.rightBarBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshDeviceList)];
    self.navigationItem.rightBarButtonItem = self.rightBarBtn;
    self.rightBarBtn.width = 15;
    self.rightBarBtn.tintColor = [UIColor whiteColor];
}

- (void)configSubView {
    [self.view addSubview:self.devListTableView];
    [self.view addSubview:self.channelView];
}

-(void)popViewController{
    if([SVProgressHUD isVisible]){
        [SVProgressHUD dismiss];
    }
    [self.navigationController popViewControllerAnimated:YES];
    DeviceManager *manager = [DeviceManager getInstance];
    manager.delegate = nil;
}
    
#pragma mark - tableview长按手势响应,删除和编辑设备
-(void)longPressToDo:(UILongPressGestureRecognizer *)gesture{
    if(gesture.state != UIGestureRecognizerStateBegan){
        return;
    }
    NSIndexPath *indexPath ;

    CGPoint point = [gesture locationInView:self.devListTableView];
    indexPath = [self.devListTableView indexPathForRowAtPoint:point];
    if(indexPath == nil){
        return;
    }
    NSLog(@"%ld",(long)indexPath.row);
    DeviceObject *devObject = [deviceArray objectAtIndex:indexPath.section];
    
    NSString *title = [NSString stringWithFormat:@"%@%@",TS(""), devObject.deviceName];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:TS("Cancel") style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *deleteBtn = [UIAlertAction actionWithTitle:TS("Delete") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:TS("warning") message:TS("Are_you_sure_to_delete_device2") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:TS("Cancel") style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *deleteButton = [UIAlertAction actionWithTitle:TS("OK") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            //发送删除命令
            DeviceManager *manager = [DeviceManager getInstance];
            [manager deleteDeviceWithDevMac:devObject.deviceMac];
        }];
       
        [alertController addAction:cancelButton];
        [alertController addAction:deleteButton];
        [self presentViewController:alertController animated:YES completion:nil];
    }];
    UIAlertAction *settingBtn = [UIAlertAction actionWithTitle:TS("Edit") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //跳转到编辑界面
        DeviceInfoEditViewController *editVC = [[DeviceInfoEditViewController alloc] init];
        editVC.devObject = devObject;
        editVC.editSuccess = ^{
            //编辑成功，刷新界面
            deviceArray = [[DeviceControl getInstance] currentDeviceArray];
            [self.devListTableView reloadData];
        };
        [self.navigationController pushViewController:editVC animated:YES];
    }];
    UIAlertAction *shadowServicesBtn = [UIAlertAction actionWithTitle:TS("TR_ShadowServices") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //跳转到影子服务界面
        ShadowServicesViewController *shadowServicesVC = [[ShadowServicesViewController alloc] init];
        shadowServicesVC.devID = devObject.deviceMac;
        [self.navigationController pushViewController:shadowServicesVC animated:YES];
    }];
    [alert addAction:cancel];
    [alert addAction:deleteBtn];
    [alert addAction:settingBtn];
    [alert addAction:shadowServicesBtn];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [alert setModalPresentationStyle:UIModalPresentationPopover];
        UIPopoverPresentationController *popPresenter = [alert
                                                         popoverPresentationController];
        popPresenter.sourceView = self.view;
        popPresenter.sourceRect = CGRectMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height, 1.0, 1.0);
        popPresenter.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -- UiTableViewDelegate/DataSource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    ShareToMeVC * vc = [ShareToMeVC new];
//    [self.navigationController pushViewController:vc animated:YES];
//    return;
//
    DeviceObject *devObject = [deviceArray objectAtIndex:indexPath.section];
    if (devObject == nil) {
        return;
    }
    if (devObject.state <=0 ) {
        //提示设备不在线
        [SVProgressHUD showErrorWithStatus:TS("EE_DVR_CONNECT_DEVICE_ERROR") duration:2.0];
        //刷新当前设备状态，如果是门铃的话，可能已经处于休眠状态而没有实时刷新
        [[DeviceManager getInstance] getDeviceState:devObject.deviceMac];
        return;
    }
    if (devObject.eFunDevStateNotCode == 4) {//正准备休眠
        [self getdeviceState:devObject.deviceMac];
        [SVProgressHUD showWithStatus:TS("Refresh_State")];
        return;
        //获取设备状态和门铃睡眠状态，然后return
    }else if (devObject.eFunDevStateNotCode == 3) {//深度睡眠
        //直接return，深度睡眠需要设备端唤醒
        [SVProgressHUD showErrorWithStatus:TS("DEV_SLEEP_AND_CAN_NOT_WAKE_UP") duration:3.0];
        return;
    }else if (devObject.eFunDevStateNotCode == 2) {//睡眠
        //唤醒睡眠，然后继续其他处理
        [SVProgressHUD showWithStatus:TS("Waking_up")];
        [[DeviceManager getInstance] deviceWeakUp:devObject.deviceMac];
        
        return;
    }
    
    [SVProgressHUD showWithStatus:TS("Get_Channle")];
    //现获取设备通道信息，多通道预览时需要。如果不需要支持多通道预览，则可以不获取通道信息，直接打开0通道
    selectNum = (int)indexPath.section;
    [[DeviceManager getInstance] getDeviceChannel:devObject.deviceMac];
    //获取成功之后，在回调接口中进入预览界面   - (void)getDeviceChannel:(NSString *)sId result:(int)result
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [deviceArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 110;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DeviceListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    DeviceObject *devObject = [deviceArray objectAtIndex:indexPath.section];
    if (devObject != nil) {
        cell.devSNLab.text = devObject.deviceMac;
        cell.devName.text = devObject.deviceName;
        if (devObject.ret) {
            cell.devName.text = [NSString stringWithFormat:@"%@(分享)",devObject.deviceName];
        }
        [cell setDeviceStatus:[self cellDeviceState:devObject]];
//        [cell setDeviceState:devObject.state];
//        [cell setSleepType:devObject.eFunDevStateNotCode];
        cell.devTypeLab.text = [NSString getDeviceType:devObject.nType];
        cell.devImageV.image = [UIImage imageNamed:[NSString getDeviceImageType:devObject.nType]];
        NSString *path = [NSString devThumbnailFile:devObject.deviceMac andChannle:0];
        [cell.btnThumbnail setBackgroundImage:[UIImage imageWithContentsOfFile:path] forState:UIControlStateNormal];
    }
    return cell;
}

- (XMDeviceStatus)cellDeviceState:(DeviceObject *)devObject {
    
    //设备在线状态。。(低功耗在线显示休眠状态。。其他设备显示在线离线状态)
    if ([devObject getDeviceTypeLowPowerConsumption]) {
        if (devObject.state > 0) {
            if (devObject.sysFunction.AovMode) {
                //AOV设备，显示在线、AOV模式等状态（APP上层显示逻辑）
                if (devObject.eFunDevStateNotCode == 0 || devObject.eFunDevStateNotCode == 1){
                    //唤醒中或者未知状态 ，显示在线
                    return XMDeviceStatusOnline;
                }else{
                    //demo这里简单处理，非在线时就显示AOV。（可以按 eFunDevStateNotCode 状态继续细分）
                    return XMDeviceStatusAOV;
                }
            }else{
                //非AOV设备，显示在线、休眠等状态
                if (devObject.eFunDevStateNotCode == 2){
                    // 设备睡眠
                    return XMDeviceStatusSleep;
                }else if (devObject.eFunDevStateNotCode == 3){
                    //深度休眠
                    return XMDeviceStatusDeepSleep;
                }else if (devObject.eFunDevStateNotCode == 4){
                    //准备休眠
                    return XMDeviceStatusPrepareSleep;
                }else{
                    return XMDeviceStatusOnline;
                }
            }
        }else{
            return XMDeviceStatusOffline;
        }
        
    }else{
        if (devObject.state > 0) {
            return XMDeviceStatusOnline;
        }else {
            return XMDeviceStatusOffline;
        }
    }
}

#pragma - mark -- 刷新设备列表
- (void)refreshDeviceList {
    [self getdeviceState:nil];
}
#pragma - mark 获取设备在线状态结果
- (void)getDeviceState:(NSString *)sId result:(int)result {
    [self.devListTableView reloadData];
}
#pragma - mark 设备唤醒结果
- (void)deviceWeakUp:(NSString *)sId result:(int)result {
    if (result < 0) {
        [MessageUI ShowErrorInt:result];
        return;
    }
     [SVProgressHUD dismiss];
    DeviceObject *object = [[DeviceControl getInstance] GetDeviceObjectBySN:sId];
    object.eFunDevStateNotCode = 1;
    [self.devListTableView reloadData];
    [self lowPowerConsumptionCountDownWithDev:object];
}

- (void)xmAlertVCClickIndex:(int)index tag:(int)tag content:(NSString *)content msg:(NSString *)msg name:(NSString *)name
{
    DeviceObject *devObject = [[DeviceControl getInstance] GetDeviceObjectBySN:devObjectMac];
    
    if (index == 0) {
    }else if (index == 1){
        if (content.length > 64) {
            content = [content substringToIndex:64];
        }
        
        devObject.loginName = name;
        
        //修改设备名称和设备密码
        [[DeviceManager getInstance] changeDevicePsw:devObject.deviceMac loginName:devObject.loginName password:content];
    }
}

#pragma mark 获取设备通道结果
static NSString * devObjectMac = @"";
- (void)getDeviceChannel:(NSString *)sId result:(int)result {
    //部分低功耗设备获取通道会返回不支持，需要排除在外
    if (result <= 0 && result != -400009) {
        
        if (result == EE_DVR_PASSWORD_NOT_VALID || result == -11318 || result == EE_DVR_LOGIN_USER_NOEXIST) //密码错误，弹出密码修改框
        {
            [SVProgressHUD dismiss];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                devObjectMac = sId;
                int tag = result == EE_DVR_PASSWORD_NOT_VALID?-1:-2;
                //弹出密码输入框
                [UIView showUserOrPasswordErrorTips:result delegate:self presentedVC:self tag:tag devID:sId changePwd:NO];
            });
            
            return;
        }
        [MessageUI ShowErrorInt:result];
        return;
    }
    else
    {
        if (result == -400009) {
            result = 1;
        }
        [SVProgressHUD dismiss];
        //获取通道信息成功，进入预览界面
        
        [[DoorBellModel shareInstance] cancelCountDown];
        
        [[DeviceControl getInstance] setAllChannelNum:result];
        
        [[DeviceControl getInstance] cleanSelectChannel];
        
        DeviceObject *object = [[DeviceControl getInstance] GetDeviceObjectBySN:sId];
        
        if (object.channelArray.count >= 4) {
            //超过4个通道的设备，这里添加进去4个通道，做多通道预览的示例
            for (int i =0; i< 4; i++) {
                [[DeviceControl getInstance] setSelectChannel:[object.channelArray objectAtIndex:i]]; //添加前四个通道的信息，可以需求选择通道添加
            }
        }else{
            [[DeviceControl getInstance] setSelectChannel:[object.channelArray firstObject]];
        }
        PlayViewController *playVC = [[PlayViewController alloc] init];
        [self.navigationController pushViewController:playVC animated:YES];
        return;
        
        
        //如果要自己选择通道播放，请取消下列代码注释
//        Bool notShow = [[[NSUserDefaults standardUserDefaults] objectForKey:@"NOT_SHOW_CHANNEL_LIST"] boolValue];
//        
//        if (!notShow && object.channelArray.count > 1) {
//            self.channelView.hidden = NO;
//            self.channelView.devID = sId;
//            self.channelView.channelArray = [object.channelArray mutableCopy];
//            [self.channelView.channelTableV reloadData];
//        }else{
//            //设置当前要播放的设备通道信息
//            [[DeviceControl getInstance] setSelectChannel:[object.channelArray firstObject]];
//            //进入预览界面
//            PlayViewController *playVC = [[PlayViewController alloc] init];
//            [self.navigationController pushViewController:playVC animated:YES];
//        }
    }
    
}

#pragma mark 删除设备结果
- (void)deleteDevice:(NSString *)sId result:(int)result{
    if (result >= 0) {
        [SVProgressHUD showSuccessWithStatus:TS("Success")];
        deviceArray = [[DeviceControl getInstance] currentDeviceArray];
        [self.devListTableView reloadData];
        // 清除设备配网缓存的配置数据
        [JFDevConfigService jf_clearDevConfigCacheWithDevId:sId];
    }else{
        [MessageUI ShowErrorInt:result];
    }
}

- (void)lowPowerConsumptionCountDownWithDev:(DeviceObject *)devObject {
    //如果是低功耗设备准备进入休眠计时
    if ([devObject getDeviceTypeLowPowerConsumption]) {
        [[DoorBellModel shareInstance] addDormantPlanDevice:devObject.deviceMac];
        [[DoorBellModel shareInstance] beginCountDown];
        [[DoorBellModel shareInstance] removeAllWorkingDevice];
    }
}

#pragma mark MQTT数据解析——实时设备状态
-(void)refreshDeviceStateWithDeviceDataInfo:(NSDictionary*)deviceDataInfo{
    dispatch_async(self.socketMsgQueue, ^{
        if (deviceDataInfo) {
            @try {
                if ([self checkIsRepeatWebSocketMsg:deviceDataInfo]) {
                    return;
                }
                
                NSString* dateTimeString = [deviceDataInfo objectForKey:@"time"];
                if ([dateTimeString isKindOfClass:[NSString class]]) {
                    [self.webSocketDataInfo setObject:deviceDataInfo forKey:dateTimeString];
                }
                
                long long websocketInterval = 0;
                if ([deviceDataInfo objectForKey:@"timeStamp"]) {
                    websocketInterval = [[deviceDataInfo objectForKey:@"timeStamp"] longLongValue];
                    NSLog(@"debug:webSocket-interval=%lld", websocketInterval);
                }
                
                BOOL isExisted = NO;
                DeviceObject *deviceModel;
                NSString* deviceIdString = [deviceDataInfo objectForKey:@"sn"];
                if ([deviceIdString isKindOfClass:[NSString class]]) {
                    for (int m = 0; m < deviceArray.count; m++) {
                        deviceModel = deviceArray[m];
                        if ([deviceModel.deviceMac isEqualToString:deviceIdString]) {
                            isExisted = YES;
                            break;
                        }
                        else{
                            deviceModel = nil;
                        }
                    }
                }
                NSMutableDictionary* tempDataInfo = [NSMutableDictionary dictionaryWithDictionary:deviceDataInfo];
                NSLog(@"debug:webSocket-data%@", (NSMutableDictionary*)tempDataInfo);

                    BOOL stateChanged = NO;
                    if ([deviceIdString isKindOfClass:[NSString class]] && deviceIdString.length) {
                        DeviceObject *device = [[DeviceControl getInstance] GetDeviceObjectBySN: deviceIdString];
                        NSArray* propsArray = [deviceDataInfo objectForKey:@"props"];
                        NSString *serverName = @"";
                        if([deviceDataInfo.allKeys containsObject:@"serverName"]){
                            serverName = [deviceDataInfo objectForKey:@"serverName"];
                        }
                        if ([propsArray isKindOfClass:[NSArray class]]) {
                            for (int m = 0; m < propsArray.count; m++) {
                                NSDictionary* propInfo = propsArray[m];
                                if ([propInfo isKindOfClass:[NSDictionary class]]) {
                                    NSString *propCodeString = [propInfo objectForKey:@"propCode"];
                                    if ([propCodeString isKindOfClass:[NSString class]] == NO) {
                                        continue;
                                    }
                                             

                                        if ([propCodeString isEqualToString: @"sleepState"] && device && ![serverName isEqualToString:@"RPS"]) { //低功耗且不是rps状态才处理
                                            stateChanged = YES;
                                            [self handleSleepState:device deviceIdString:deviceIdString propInfo:propInfo];
                                        }
                                   
                                        }
                                  
                                    
                                }
                            }
                        }
                    }
                 @catch (NSException *exception) {
                NSLog(@"%@", exception);
            }
        }
    });
}

#pragma mark 处理长连接收到的设备休眠状态改变事件
-(void)handleSleepState:(DeviceObject*)device deviceIdString:(NSString*)deviceIdString propInfo:(NSDictionary*)propInfo{
    NSString *stateString = [propInfo objectForKey: @"propValue"];
    if ([stateString isKindOfClass:[NSString class]] && device) {
        BOOL needSetReconnectEnable = NO;
        if ([stateString isEqualToString:@"WakeUp"]) {//0 未知 1 唤醒 2 睡眠 3 不能被唤醒的休眠 4正在准备休眠
            device.state = 1;
        }
        else if ([stateString isEqualToString:@"LightSleep"]) {
            device.state = 2;
            needSetReconnectEnable = YES;
        }
        else if ([stateString isEqualToString:@"DeepSleep"]) {
            device.state = 3;
            needSetReconnectEnable = YES;
        }
        else if ([stateString isEqualToString:@"PreSleep"]) {
            device.state = 4;
            needSetReconnectEnable = YES;
        }
        //浅休眠/深度休眠/准备休眠中 就发送禁止重连
        if(device && needSetReconnectEnable ){
            Fun_DevIsReconnectEnable([device.deviceMac UTF8String], 0);
        }
        NSLog(@"eFunDevState %@ %i socket",device.deviceMac,device.state);
    }
}

-(BOOL)checkIsRepeatWebSocketMsg:(NSDictionary*)messageDataInfo{
    @try {
        if ([messageDataInfo isKindOfClass:[NSDictionary class]]) {
            NSString* dateTimeString = [messageDataInfo objectForKey:@"time"];
            if ([dateTimeString isKindOfClass:[NSString class]]) {
                id objectValue = [self.webSocketDataInfo objectForKey:dateTimeString];
                if ([objectValue isKindOfClass:[NSDictionary class]]) {
                    NSDictionary* existedDataInfo = (NSDictionary*)objectValue;
                    if ([existedDataInfo isEqualToDictionary:messageDataInfo] ) {
                        return YES;
                    }
                }
            }
        }
        return NO;
    } @catch (NSException *exception) {
        return NO;
    }
}

-(NSMutableDictionary*)webSocketDataInfo{
    if (_webSocketDataInfo == nil) {
        _webSocketDataInfo = [NSMutableDictionary new];
    }
    return _webSocketDataInfo;
}

-(dispatch_queue_t)socketMsgQueue{
    if (_socketMsgQueue == nil) {
        _socketMsgQueue=dispatch_queue_create("com.socketMsgQueue", NULL);
    }
    return _socketMsgQueue;
}

@end
