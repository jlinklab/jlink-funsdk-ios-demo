//
//  BlueToothToolManager.m
//  JLink
//
//  Created by 吴江波 on 2022/2/28.
//

#import "BlueToothToolManager.h"
#import "TransferModel.h"
#import <FunSDK/FunSDK.h>
#import "XMSecurity/Security.h"
#import "NSString+Utils.h"

@interface BlueToothToolManager()

@property (nonatomic) NSTimer *timer;//搜索倒计时定时器
@property (nonatomic) NSTimer *connectTimer;//连接超时倒计时定时器
@property (nonatomic) NSTimer *sendTimer;//发送数据倒计时定时器
@property (nonatomic) NSTimer *connectRetainTimer;//连接时常限制定时器，超过1分钟与设备无蓝牙通信则断开蓝牙，有操作则刷新倒计时。
@property (nonatomic,assign) int timeRemain;
@property (nonatomic,assign) int connectTime;
@property (nonatomic,assign) int connectRetainTime;
@property (nonatomic,assign) int sendTimeRemain;
@property (nonatomic) TransferModel *tranModel;                 //ip地址的表达方式转换
@property (nonatomic,assign) BOOL isConnect;                    //判断是否已连接
@property (nonatomic,copy) NSString *bufferData;
@property (nonatomic,strong) NSMutableArray *needRestartPartitionArray; // 升级完成需要重启的模块数组
@end

@implementation BlueToothToolManager

- (instancetype)init{
    self = [super init];
    if (self) {
        self.isShowBluetoothTip = NO;
        self.isConnect = NO;
        self.needLog = YES;
        self.currentMTU = 182 * 2;
        self.needRestartPartitionArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

+(instancetype)sharedBlueToothToolManager{
    static BlueToothToolManager *sharedBlueToothToolManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedBlueToothToolManager = [[BlueToothToolManager alloc] init];
        [sharedBlueToothToolManager initBlueTooth];
    });
    return sharedBlueToothToolManager;
}

-(void)initBlueTooth{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    if (self.connectTimer) {
        [self.connectTimer invalidate];
        self.connectTimer = nil;
    }
    [self.blueToothManager initBlueTooth];
}

-(BOOL)getBlueToothOpenState{
    return [self.blueToothManager getBlueToothOpenState];
}

-(BOOL)isBlueToothUnauthorized{
    return [self.blueToothManager isBlueToothUnauthorized];
}

-(BOOL)getBlueToothIsConnect{
    return self.isConnect;
}

//MARK: 获取APP的蓝牙开关授权状态 （除了iOS13.0版本 其他都不会触发蓝牙使用授权提示）-2:受限制 -1:未确定  0:关 1:开
- (int)appBlueToothState{
    return [self.blueToothManager appBlueToothState];
}

//MARK: 获取手机蓝牙开关状态
- (void)requestPhoneState:( void(^)(CBManagerState state))completed{
    [self.blueToothManager requestPhoneState:completed];
}
#pragma mark - 开始搜索设备
-(void)startSearch{
    [self.blueToothManager startSearch];
}

-(void)startSearchWithTimeOut:(int)timeout{
    [self.blueToothManager startSearch];
    if (timeout > 0) {
        if (self.timer == nil) {
            self.timeRemain = timeout;
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
            
            [self.timer fire];
        }else
        {
            NSLog(@"");
        }
    }
}

-(void)onTimer:(NSTimer*)time
{
    if (self.timeRemain > 0) {
        self.timeRemain --;
    }else{
        //超时了
        if (self.timer) {
            [self.timer invalidate];
            self.timer = nil;
        }
        self.isGoConnect = NO;
        if(self.searchTimeout){
            self.searchTimeout();
        }
        [self stopSearch];
    }
}

#pragma mark - 开始连接设备计时
-(void)onConnectTimer:(NSTimer*)time{
    if (self.connectTime > 0) {
        self.connectTime --;
    }else{
        //超时了
        if(self.needRetryConnect == YES){
            self.isGoConnect = NO;
            [self connectBlueToothDeviceWithMac:self.currentConnectMac sn:self.currentConnectDevId pid:self.currentPid timeOut:15];
            self.needRetryConnect = NO;
            return;
        }
        if (self.connectTimer) {
            [self.connectTimer invalidate];
            self.connectTimer = nil;
        }
        self.isGoConnect = NO;
        if(self.connectTimeout){
            self.connectTimeout();
        }
        [self cancelConnection];
    }
}

#pragma mark - 连接设备累计时长计时
-(void)checkConnectRetainTime{
    if (self.connectRetainTimer != nil) {
        self.connectRetainTime = 180;
    }else{
        [self startTimerConnectRetain];
    }
}

-(void)connectRetainTimer:(NSTimer*)time{
    if (self.connectRetainTime > 0) {
        self.connectRetainTime --;
        if (self.connectRetainTime == 3) {
            if(self.connectRetainTimeout){
                self.connectRetainTimeout();
            }
        }
    }else{
        //累计时长达1分钟
        if (self.connectRetainTimer) {
            [self.connectRetainTimer invalidate];
            self.connectRetainTimer = nil;
        }
        [self cancelConnection];
    }
}

-(void)stopTimerConnectRetain{
    if (self.connectRetainTimer != nil) {
        [self.connectRetainTimer invalidate];
        self.connectRetainTimer = nil;
    }
}

-(void)startTimerConnectRetain{
    if (self.connectRetainTimer != nil) {
        [self.connectRetainTimer invalidate];
        self.connectRetainTimer = nil;
    }
    
    self.connectRetainTime = 180; //和界面保持一致180倒计时
    self.connectRetainTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(connectRetainTimer:) userInfo:nil repeats:YES];
    [self.connectRetainTimer fire];
}

#pragma mark - 发送数据超时处理
-(void)startSendDataWithTimeout:(int)timeout{
    if (self.sendTimer != nil) {
        [self.sendTimer invalidate];
        self.sendTimer = nil;
    }
    
    self.sendTimeRemain = timeout;
    self.sendTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onSendTimer:) userInfo:nil repeats:YES];
    [self.sendTimer fire];
}
    
-(void)onSendTimer:(NSTimer*)time{
    if (self.sendTimeRemain > 0) {
        self.sendTimeRemain --;
    }else{
        //超时了
        if (self.sendTimer) {
            [self.sendTimer invalidate];
            self.sendTimer = nil;
        }
        if(self.sendTimeout){
            self.sendTimeout();
        }
    }
}

-(void)sendDataComplete{
    if (self.sendTimer) {
        [self.sendTimer invalidate];
        self.sendTimer = nil;
        self.sendTimeRemain = 0;
    }
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

#pragma mark - 判断设备是否可连接
-(BOOL)canConnectPeripheral:(NSString *)data{
    CBPeripheral *peripheral = [self.devDic objectForKey:data];
    if (peripheral != nil) {
        return YES;
    }else{
        return NO;
    }
}

#pragma mark - 开始连接设备 mac(或者序列号)+pid 发现无法连接则先初始化并搜索设备
-(void)connectBlueToothDeviceWithMac:(NSString *)mac sn:(NSString *)sn pid:(NSString *)pid timeOut:(int)timeout{
    if(self.isGoConnect){
        Fun_Log("快速配置流程:已有设备在连接\n");
        return;
    }
    self.currentPid = pid;
    self.currentConnectDevId = sn;
    self.currentConnectMac = mac;
    self.isGoConnect = YES;
    if([self canConnectPeripheral:[NSString stringWithFormat:@"%@%@",sn,pid]]){
        [self connectPeripheral:[NSString stringWithFormat:@"%@%@",sn,pid] timeOut:15];
    }
    else if([self canConnectPeripheral:[NSString stringWithFormat:@"%@%@",mac,pid]]){
        [self connectPeripheral:[NSString stringWithFormat:@"%@%@",mac,pid] timeOut:15];
    }else{
        [self initBlueTooth];
        [self startSearchWithTimeOut:15];
    }
}

#pragma mark - 连接设备
-(void)connectPeripheral:(NSString *)mac{
    CBPeripheral *peripheral = [self.devDic objectForKey:mac];
    [self.blueToothManager connectPeripheral:peripheral];
    if (!peripheral) {
        NSLog(@"");
    }
}

#pragma mark - 连接设备
-(void)connectPeripheral:(NSString *)mac timeOut:(int)timeout{
    CBPeripheral *peripheral = [self.devDic objectForKey:mac];
    [self.blueToothManager connectPeripheral:peripheral];
    if (timeout > 0) {
        if (self.connectTimer != nil) {
            [self.connectTimer invalidate];
            self.connectTimer = nil;
        }
        self.connectTime = timeout;
        self.connectTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onConnectTimer:) userInfo:nil repeats:YES];
        
        [self.connectTimer fire];
    }
}

#pragma mark - 停止搜索设备
-(void)stopSearch{
    [self.blueToothManager stopSearch];
}

-(void)cancelConnection{
    [self stopTimerConnectRetain];
    [self.blueToothManager cancelConnection];
    self.isGoConnect = NO;
    self.isConnect = NO;
    if (self.sendTimer != nil) {
        [self.sendTimer invalidate];
        self.sendTimer = nil;
    }
    
    if (self.connectTimer != nil) {
        [self.connectTimer invalidate];
        self.connectTimer = nil;
    }
    
    if (self.timer != nil) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    if (self.connectRetainTimer != nil) {
        [self.connectRetainTimer invalidate];
        self.connectRetainTimer = nil;
    }
}

#pragma mark - 获取设备初始化信息
-(void)getBlueToothIinitializationInfo{
    NSString *version = @"02";
    int endH = [self decimalStringFromHexString:@"8b8b"] + [self decimalStringFromHexString:version] + [self decimalStringFromHexString:@"01"] + [self decimalStringFromHexString:@"0009"]  + [self decimalStringFromHexString:@"00"] + [self decimalStringFromHexString:@"0000"];
    NSString *endHexStr = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",endH % 256]];
    endHexStr = [self supplement:endHexStr length:2];

    NSString *totalData = [NSString stringWithFormat:@"%@%@%@%@%@%@%@",@"8B8B",version,@"01",@"0009",@"00",@"0000",endHexStr];
    NSString *logStr = [NSString stringWithFormat:@"快速配置流程:SDK_LOG:[APP_BLE][%@]获取设备初始化信息info=%@\n",[[NSDate date] xm_string],totalData];
    Fun_Log([logStr UTF8String]);

    [self.blueToothManager writeDataIntoDevice:totalData needBlueToothResponse:YES];
}

#pragma mark - 配网成功后app响应包
-(void)sendAPPResponse:(BOOL)addDeviceSuccess
{
    NSString *result = addDeviceSuccess == YES ? @"01" : @"00";
    NSString *version = @"02";
    int endH = [self decimalStringFromHexString:@"8b8b"] + [self decimalStringFromHexString:version] + [self decimalStringFromHexString:@"04"] + [self decimalStringFromHexString:@"0002"]  + [self decimalStringFromHexString:@"00"] + [self decimalStringFromHexString:@"0001"] +  [self decimalStringFromHexString:result];
    NSString *endHexStr = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",endH % 256]];
    endHexStr = [self supplement:endHexStr length:2];

    NSString *totalData = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@",@"8B8B",version,@"04",@"0002",@"00",@"0001",result,endHexStr];
    NSString *logStr = [NSString stringWithFormat:@"快速配置流程:SDK_LOG:[APP_BLE][%@]配网成功后app响应包info=%@\n",[[NSDate date] xm_string],totalData];
    Fun_Log([logStr UTF8String]);
    [self.blueToothManager writeDataIntoDevice:totalData needBlueToothResponse:YES];
}

#pragma mark - 开始配网添加设备之前的数据处理
-(void)startAddBlueToothDevice:(NSString *)ssid password:(NSString *)password mac:(NSString *)Mac version:(NSString *)version{
    NSData *wifiData = [ssid dataUsingEncoding:NSUTF8StringEncoding];
    NSString *wifiDataHexStr = [NSString xm_hexStringWithData:wifiData];
    int wifiLength = (int)wifiData.length;
    NSString *wifiLengthHexString = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",wifiLength]];
    wifiLengthHexString = [self supplement:wifiLengthHexString length:2];
    
    NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    NSString *passwordDataHexStr = [NSString xm_hexStringWithData:passwordData];
    int passLength = (int)passwordData.length;
    NSString *passLengthHexString = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",passLength]];
    passLengthHexString = [self supplement:passLengthHexString length:2];

    //wifi信息部分长度
    NSString *wifiInfoHexLength = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",passLength + wifiLength + 3]];
    wifiInfoHexLength = [self supplement:wifiInfoHexLength length:4];
    
    NSString *wifiStr= [NSString stringWithFormat:@"%@%@%@%@%@",wifiLengthHexString,wifiDataHexStr,passLengthHexString,passwordDataHexStr,@"00"];

    int endH = [self decimalStringFromHexString:@"8b8b"] + [self decimalStringFromHexString:@"02"] + [self decimalStringFromHexString:@"01"] + [self decimalStringFromHexString:@"0002"]  + [self decimalStringFromHexString:wifiInfoHexLength] + wifiLength +  [self decimalStringFromHexString:wifiDataHexStr] + passLength +[self decimalStringFromHexString:passwordDataHexStr];
    NSString *endHexStr = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",endH % 256]];
    endHexStr = [self supplement:endHexStr length:2];
    NSString *totalData = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@",@"8B8B",@"02",@"01",@"0002",@"00",wifiInfoHexLength,wifiStr,endHexStr];
    NSString *logStr = [NSString stringWithFormat:@"快速配置流程：SDK_LOG:[APP_BLE][%@]开始配网ssid=%@password=%@info=%@\n",[[NSDate date] xm_string],ssid,password,totalData];
    self.currentBlueToothVersion = version;
    Fun_Log([logStr UTF8String]);
    [self writeBlueToothData:totalData needResponse:YES];
}

#pragma mark - GATT连接设备成功后直接获取设备序列号（请求激活设备）
-(void)getBlueDeviceSNWithPid:(NSString *)pid{
    int endH = [self decimalStringFromHexString:@"8b8b"] + [self decimalStringFromHexString:@"01"] + [self decimalStringFromHexString:@"01"] + [self decimalStringFromHexString:@"0010"]+ [self decimalStringFromHexString:@"00"]+ [self decimalStringFromHexString:@"0000"];
    NSString *endHexStr = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",endH % 256]];
    endHexStr = [self supplement:endHexStr length:2];
    NSString *totalData = [NSString stringWithFormat:@"%@%@%@%@%@%@%@",@"8B8B",@"01",@"01",@"0010",@"00",@"0000",endHexStr];
    NSString *logStr = [NSString stringWithFormat:@"快速配置流程:SDK_LOG:[APP_BLE][%@]请求激活设备info=%@\n",[[NSDate date] xm_string],totalData];
    Fun_Log([logStr UTF8String]);
    self.currentPid = pid;
    [self writeBlueToothData:totalData needResponse:YES];
}

#pragma mark - 将激活结果下发给设备
-(void)sendActiveDeviceResult:(NSString *)result{
    int endH = [self decimalStringFromHexString:@"8b8b"] + [self decimalStringFromHexString:@"01"] + [self decimalStringFromHexString:@"01"] + [self decimalStringFromHexString:@"0011"]+ [self decimalStringFromHexString:@"00"]+ [self decimalStringFromHexString:@"0001"] + [self decimalStringFromHexString:result];
    NSString *endHexStr = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",endH % 256]];
    endHexStr = [self supplement:endHexStr length:2];
    NSString *totalData = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@",@"8B8B",@"01",@"01",@"0011",@"00",@"0001",result,endHexStr];
    NSString *logStr = [NSString stringWithFormat:@"快速配置流程:SDK_LOG:[APP_BLE][%@]激活结果info=%@\n",[[NSDate date] xm_string],totalData];
    Fun_Log([logStr UTF8String]);
    [self.blueToothManager writeDataIntoDevice:totalData needBlueToothResponse:YES];
}

#pragma mark - 设置开门方向
-(void)setUnlockDirection:(NSString *)cmdData{
    int dataLen = (int)cmdData.length / 2 ;
    NSString *dataLengthHexString = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",dataLen]];
    dataLengthHexString = [self supplement:dataLengthHexString length:2];
    NSString *data = [NSString stringWithFormat:@"22%@%@",dataLengthHexString,cmdData];
    [self sendMessageToModelWithString:data needBlueToothResponse:YES];
}

#pragma mark - 设置支持反锁
-(void)setSupportLockInside:(NSString *)cmdData{
    int dataLen = (int)cmdData.length / 2 ;
    NSString *dataLengthHexString = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",dataLen]];
    dataLengthHexString = [self supplement:dataLengthHexString length:2];
    NSString *data = [NSString stringWithFormat:@"20%@%@",dataLengthHexString,cmdData];
    [self sendMessageToModelWithString:data needBlueToothResponse:YES];
}

#pragma mark - 设置常开模式
-(void)setNormalOpenMode:(NSString *)cmdData{
    int dataLen = (int)cmdData.length / 2 ;
    NSString *dataLengthHexString = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",dataLen]];
    dataLengthHexString = [self supplement:dataLengthHexString length:2];
    NSString *data = [NSString stringWithFormat:@"14%@%@",dataLengthHexString,cmdData];
    [self sendMessageToModelWithString:data needBlueToothResponse:YES];
}

#pragma mark - 设置锁声音
-(void)setDoorLockSound:(JLinkDoorLockSound)sound isOpen:(BOOL)isOpen{
    NSString *cmdData = [NSString stringWithFormat:@"%d%d",(int)sound,isOpen];
    int dataLen = (int)cmdData.length / 2 ;
    NSString *dataLengthHexString = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",dataLen]];
    dataLengthHexString = [self supplement:dataLengthHexString length:2];
    NSString *data = [NSString stringWithFormat:@"1D%@%@",dataLengthHexString,cmdData];
    [self sendMessageToModelWithString:data needBlueToothResponse:YES];
}

#pragma mark - 设置自动闭锁
-(void)setDoorLockAutoLock:(int)time isOpen:(BOOL)isOpen{
    NSString *timeStr = @"";
    if(isOpen){
        timeStr = [NSString hexStringFromNum:time fill:NO len:4];
        timeStr = [self supplement:timeStr length:4];
    }else{
        timeStr = @"0000";
    }
    NSString *cmdData = [NSString stringWithFormat:@"%@",timeStr];
   
    int dataLen = (int)cmdData.length / 2 ;
    NSString *dataLengthHexString = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",dataLen]];
    dataLengthHexString = [self supplement:dataLengthHexString length:2];
    NSString *data = [NSString stringWithFormat:@"17%@%@",dataLengthHexString,cmdData];
    [self sendMessageToModelWithString:data needBlueToothResponse:YES];
}

#pragma mark - 发送离线密钥组
-(void)sendKeyPair:(NSString *)cmdData{
    int dataLen = (int)cmdData.length / 2 ;
    NSString *dataLengthHexString = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",dataLen]];
    dataLengthHexString = [self supplement:dataLengthHexString length:2];
    NSString *data = [NSString stringWithFormat:@"3D%@%@",dataLengthHexString,cmdData];
    [self sendMessageToModelWithString:data needBlueToothResponse:YES];
}

#pragma mark - 获取锁时间
-(void)getDeviceTime{
    NSString *cmdData = @"01";
    int dataLen = (int)cmdData.length / 2 ;
    NSString *dataLengthHexString = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",dataLen]];
    dataLengthHexString = [self supplement:dataLengthHexString length:2];
    NSString *data = [NSString stringWithFormat:@"16%@%@",dataLengthHexString,cmdData];
    [self sendMessageToModelWithString:data needBlueToothResponse:YES];
}

#pragma mark - 同步时间
-(void)sysnDeviceTimeWithBaseYear:(NSString *)baseYear{
    NSMutableString *cmdContent = [NSMutableString string];
    [cmdContent appendString:@"15"]; // dp_id 21
    [cmdContent appendString:@"0c"]; // dp_data_len 13
    [cmdContent appendString:@"01"]; // dp_type 0x01：格式1-获取7字节时间时间类型+2字节时区
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSCalendar *calender = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:calender.locale.localeIdentifier]];
    //获取当前时间日期展示字符串 如：2019-05-23-13:58:59

    //下面是单独获取每项的值
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitYear |NSCalendarUnitMonth |NSCalendarUnitDay |NSCalendarUnitWeekday |NSCalendarUnitHour |NSCalendarUnitMinute |NSCalendarUnitSecond;
    comps = [calendar components:unitFlags fromDate:date];
        //星期 注意星期是从周日开始计算
    NSInteger week = [comps weekday] - 1;
    NSString *weekStr  = StringFormat(@"%02lx", (long)week);
        //年
    NSInteger year = [comps year] - [baseYear intValue];
    NSString *yearStr  = StringFormat(@"%02lx", (long)year);
        //月
    NSInteger month = [comps month];
    NSString *monthStr  = StringFormat(@"%02lx", (long)month);
        //日
    NSInteger day = [comps day];
    NSString *dayStr  = StringFormat(@"%02lx", (long)day);
        //时
    NSInteger hour = [comps hour];
    NSString *hourStr  = StringFormat(@"%02lx", (long)hour);
        //分
    NSInteger minute = [comps minute];
    NSString *minuteStr  = StringFormat(@"%02lx", (long)minute);
        //秒
    NSInteger second = [comps second];
    NSString *secondStr  = StringFormat(@"%02lx", (long)second);
    
    //zone为当前时区信息  在我的程序中打印的是@"Asia/Shanghai"
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    //所在地区时间与协调世界时差距
    NSInteger interval = [zone secondsFromGMTForDate: date] / 36;
    NSString *timeZoneStr  = StringFormat(@"%02lx", (long)interval);
    if(timeZoneStr.length == 3){
        timeZoneStr = [NSString stringWithFormat:@"0%@",timeZoneStr];
    }else if (timeZoneStr.length == 2){
        timeZoneStr = [NSString stringWithFormat:@"00%@",timeZoneStr];
    }else if (timeZoneStr.length == 1){
        timeZoneStr = [NSString stringWithFormat:@"000%@",timeZoneStr];
    }
    
    [cmdContent appendString:yearStr];
    [cmdContent appendString:monthStr];
    [cmdContent appendString:dayStr];
    [cmdContent appendString:hourStr];
    [cmdContent appendString:minuteStr];
    [cmdContent appendString:secondStr];
    [cmdContent appendString:weekStr];
    [cmdContent appendString:timeZoneStr];
    NSString *baseYearStr  = StringFormat(@"%02lx", (long) [comps year]);
    baseYearStr = [self supplement:baseYearStr length:4];
    [cmdContent appendString:baseYearStr];
    
    [self sendMessageToModelWithString:cmdContent needBlueToothResponse:YES];
}

#pragma mark - 同步数据
-(void)sysnDeviceDataWithDoorLockType:(int)openType{
    NSMutableString *cmdContent = [NSMutableString string];
    [cmdContent appendString:@"40"]; //
    [cmdContent appendString:@"01"]; // 
    // 数据进制转换
    NSString *type = StringFormat(@"%02lx", (long)openType);
    [cmdContent appendString:type];
    [self sendMessageToModelWithString:[cmdContent copy] needBlueToothResponse:YES];
}

#pragma mark - 获取操作记录数据
-(void)sysnDeviceOperateRecorderData{
    NSMutableString *cmdContent = [NSMutableString string];
    [cmdContent appendString:@"41"]; //
    [cmdContent appendString:@"0106"]; //
    [self sendMessageToModelWithString:[cmdContent copy] needBlueToothResponse:YES];
}

#pragma mark - 手机开锁
-(void)sendOpenDoorLockCmd:(JLinkDoorLockOpenCloseCmdType)cmdType memberId:(NSInteger)memberId{
    if (memberId < 0) {
        NSString* logString = [NSString stringWithFormat:@"手机开锁失败 memberId=%ld", (long)memberId];
        Fun_Log([logString UTF8String]);
        return;
    }
    NSMutableString *cmdContent = [NSMutableString string];
    [cmdContent appendString:@"04"]; //
    [cmdContent appendString:@"03"]; //
    [cmdContent appendString:@"01"]; //
//    [cmdContent appendString:@"81"]; //
    [cmdContent appendString:[NSString stringWithFormat:@"%02lx", (long)memberId]]; //
    [cmdContent appendString:[[NSString alloc] initWithFormat:@"%02x",(int)cmdType]]; //
    [self sendMessageToModelWithString:[cmdContent copy] needBlueToothResponse:YES];
}

#pragma mark - 手机关锁
-(void)sendCloseDoorLockCmd:(JLinkDoorLockOpenCloseCmdType)cmdType memberId:(NSInteger)memberId{
    if (memberId < 0) {
        NSString* logString = [NSString stringWithFormat:@"手机关锁失败 memberId=%ld", (long)memberId];
        Fun_Log([logString UTF8String]);
        return;
    }
    NSMutableString *cmdContent = [NSMutableString string];
    [cmdContent appendString:@"04"]; //
    [cmdContent appendString:@"03"]; //
    [cmdContent appendString:@"00"]; //
//    [cmdContent appendString:@"81"]; //
    [cmdContent appendString:[NSString stringWithFormat:@"%02lx", (long)memberId]]; //
    [cmdContent appendString:[[NSString alloc] initWithFormat:@"%02x",(int)cmdType]]; //
    [self sendMessageToModelWithString:[cmdContent copy] needBlueToothResponse:YES];
}

#pragma mark - 删除锁
-(void)deleteDoorLock{
    NSMutableString *cmdContent = [NSMutableString string];
    [cmdContent appendString:@"46"];
    [cmdContent appendString:@"00"];
    [self sendMessageToModelWithString:[cmdContent copy] needBlueToothResponse:YES];
}

#pragma mark - 超级管理员(设置-基本信息-管理员开锁密码)(dp_data_len为0时表示获取锁内管理员密码,否则长度固定为5，长度为5时表示修改锁内管理员密码，dp_data_value：里要有6~9位密码)
-(void)sendAdminPwdInfo:(NSString *)cmdData{
    if([cmdData isEqualToString:@"00"]){
        [self sendMessageToModelWithString:@"1200" needBlueToothResponse:YES];
    }else{
        NSMutableString *cmdContent = [NSMutableString string];
        int f = 10 - (int)cmdData.length;
        for(int i = 0; i < f; i++){
            [cmdContent appendString:@"F"];
        }
        int dataLen = (int)cmdData.length / 2 ;
        NSString *dataLengthHexString = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",dataLen]];
        dataLengthHexString = [self supplement:dataLengthHexString length:2];
        NSString *data = [NSString stringWithFormat:@"1205%@%@",cmdData,cmdContent];
        [self sendMessageToModelWithString:data needBlueToothResponse:YES];
    }
}

#pragma mark - 获取锁内所有数据
-(void)getAllDeviceSettings{
    NSMutableString *cmdContent = [NSMutableString string];
    [cmdContent appendString:@"42"];
    [cmdContent appendString:@"0110"];
    [self sendMessageToModelWithString:[cmdContent copy] needBlueToothResponse:YES];
}

#pragma mark - 获取设备电量百分比
-(void)getDeviceBatteryPercentage{
    NSMutableString *cmdContent = [NSMutableString string];
    [cmdContent appendString:@"08"];
    [cmdContent appendString:@"00"];
    [self sendMessageToModelWithString:[cmdContent copy] needBlueToothResponse:YES];
}

#pragma mark - 查询设备版本
-(void)getDeviceVersion{
    NSMutableString *cmdContent = [NSMutableString string];
    [cmdContent appendString:@"50"];
    [cmdContent appendString:@"00"];
   
    [self sendMessageToModelWithString:[cmdContent copy] needBlueToothResponse:YES];
}

#pragma mark - 升级请求命令
-(void)requestUpgradeDevice:(JLinkDoorLockUpgradeType)upgradeType flieSize:(float)size{
    NSMutableString *cmdContent = [NSMutableString string];
    [cmdContent appendString:[self getDPidByUpgrageType:upgradeType]];
    [cmdContent appendString:@"14"];
    [cmdContent appendString:@"04"];
    NSString *lenStr = [NSString xm_hexStringWithDecimalNum:size fill:NO];
    lenStr = [self supplement:lenStr length:8];
    [cmdContent appendString:lenStr];
    [self sendMessageToModelWithString:[cmdContent copy] needBlueToothResponse:YES];
    NSString *logStr = [NSString stringWithFormat:@"升级请求命令%@\n",cmdContent];
    Fun_Log([logStr UTF8String]);
}

#pragma mark - 发送固件信息头
-(void)sendFirmwareHeader:(NSString *)header type:(JLinkDoorLockUpgradeType)upgradeType{
    NSMutableString *cmdContent = [NSMutableString string];
    [cmdContent appendString:[self getDPidByUpgrageType:upgradeType]];
    [cmdContent appendString:@"15"];
    NSString *lenStr = [NSString xm_hexStringWithDecimalNum:(int)header.length/2 fill:NO];
    [cmdContent appendString:lenStr];
    [cmdContent appendString:header];
    [self sendMessageToModelWithString:[cmdContent copy] needBlueToothResponse:YES];
    NSString *logStr = [NSString stringWithFormat:@"发送固件信息头%@\n",cmdContent];
    Fun_Log([logStr UTF8String]);
}

#pragma mark - 发送固件Body
-(void)sendFirmwareBody:(NSString *)body type:(JLinkDoorLockUpgradeType)upgradeType packageNum:(int)num needBack:(BOOL)needBack{
    NSMutableString *cmdContent = [NSMutableString string];
    [cmdContent appendString:[self getDPidByUpgrageType:upgradeType]];
    if (needBack) {
        [cmdContent appendString:@"96"];//需要回包
    }else{
        [cmdContent appendString:@"16"];//不需要回包
    }
    NSString *numStr = [NSString xm_hexStringWithDecimalNum:(int)num fill:NO];
    numStr = [self supplement:numStr length:4];
    NSString *lenStr = [NSString xm_hexStringWithDecimalNum:(int)(body.length + numStr.length)/2 fill:NO];
    lenStr = [self supplement:lenStr length:4];
    [cmdContent appendString:lenStr];

    [cmdContent appendString:numStr];
    [cmdContent appendString:body];
    [self sendMessageToModelWithString:[cmdContent copy] needBlueToothResponse:NO];
    NSString *logStr = [NSString stringWithFormat:@"发送固件Body%@包序%d\n",cmdContent,num];
    //Fun_Log([logStr UTF8String]);
}

#pragma mark - 发送检测包
-(void)sendCheckPackageWithType:(JLinkDoorLockUpgradeType)upgradeType{
    NSMutableString *cmdContent = [NSMutableString string];
    [cmdContent appendString:[self getDPidByUpgrageType:upgradeType]];
    [cmdContent appendString:@"9B"];
    [cmdContent appendString:@"00"];
    [self sendMessageToModelWithString:[cmdContent copy] needBlueToothResponse:NO];
}

#pragma mark - 发送重启命令
-(void)sendReStartDeviceWithType:(JLinkDoorLockUpgradeType)upgradeType{
    NSMutableString *cmdContent = [NSMutableString string];
    [cmdContent appendString:[self getDPidByUpgrageType:upgradeType]];
    [cmdContent appendString:@"1C"];
    [cmdContent appendString:@"00"];
    NSString *logStr = [NSString stringWithFormat:@"%ld开始重启",(long)upgradeType];
    Fun_Log([logStr UTF8String]);
    [self sendMessageToModelWithString:[cmdContent copy] needBlueToothResponse:NO];
}

#pragma mark - 发送重启命令(带需要重启的模块数组)如果主控和static(配置)都升级的情况下，只需要发一个重启命令，dp_ip可发0x51也可发0x52
-(void)sendReStartDeviceWithPartitionArray:(NSMutableArray *)array
{
    self.needRestartPartitionArray = [array mutableCopy];
    if([array containsObject:@"ota_mcu"]){
        [self sendReStartDeviceWithType:JLinkDoorLockUpgrade_motor];
    }
    else if ([array containsObject:@"ota_0"]){
        [self sendReStartDeviceWithType:JLinkDoorLockUpgrade_ota];
    }
    else if ([array containsObject:@"static0"]){
        [self sendReStartDeviceWithType:JLinkDoorLockUpgrade_static];
    }else if ([array containsObject:@"ota_ble"]){
        [self sendReStartDeviceWithType:JLinkDoorLockUpgrade_ble];
    }
}

-(void)checkNeedSendRestart:(int)type{
    if(type == 81){//主控
        Fun_Log("主控重启成功");
        [self.needRestartPartitionArray removeObject:@"ota_0"];
        if([self.needRestartPartitionArray containsObject:@"static0"]){
            [self.needRestartPartitionArray removeObject:@"static0"];
        }
      
    }
    else if(type == 82){//static(配置)
        Fun_Log("static(配置)重启成功");
        [self.needRestartPartitionArray removeObject:@"static0"];
    }
    else if(type == 83){//蓝牙模组
        Fun_Log("蓝牙模组重启成功");
        [self.needRestartPartitionArray removeObject:@"ota_ble"];
    }
    else if(type == 84){//电机板
        Fun_Log("电机板重启成功");
        [self.needRestartPartitionArray removeObject:@"ota_mcu"];
    }
    [self sendReStartDeviceWithPartitionArray:self.needRestartPartitionArray];
}

#pragma mark - 根据设备升级类型确认发送命令
-(NSString *)getDPidByUpgrageType:(JLinkDoorLockUpgradeType)upgradeType{
    if(upgradeType == JLinkDoorLockUpgrade_ota){
        return @"51";
    }else if(upgradeType == JLinkDoorLockUpgrade_static){
        return @"52";
    }else if(upgradeType == JLinkDoorLockUpgrade_ble){
        return @"53";
    }else if(upgradeType == JLinkDoorLockUpgrade_motor){
        return @"54";
    }else{
        return nil;
    }
}

#pragma mark - 数据透传（一般用于透传主控的数据）
-(void)sendMessageToModelWithString:(NSString *)cmdData needBlueToothResponse:(BOOL)needResponse{
    int dataLen = (int)cmdData.length / 2 ;
    NSString *dataLengthHexString = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",dataLen]];
    dataLengthHexString = [self supplement:dataLengthHexString length:4];
    
    int endH = [self decimalStringFromHexString:@"8b8b"] + [self decimalStringFromHexString:@"01"] + [self decimalStringFromHexString:@"01"] + [self decimalStringFromHexString:@"0030"]+ [self decimalStringFromHexString:@"00"]+ [self decimalStringFromHexString:dataLengthHexString]+[self decimalStringFromHexString:cmdData];
    NSString *endHexStr = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",endH % 256]];
    endHexStr = [self supplement:endHexStr length:2];
    NSString *totalData = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@",@"8B8B",@"01",@"01",@"0030",@"00",dataLengthHexString,cmdData,endHexStr];
    if(self.needLog){
        NSString *logStr = [NSString stringWithFormat:@"快速配置流程：SDK_LOG:[APP_BLE][%@]数据透传=%@\n",[[NSDate date] xm_string],totalData];
        Fun_Log([logStr UTF8String]);
    }
    [self checkConnectRetainTime];
    [self writeBlueToothData:totalData needResponse:needResponse];
}

#pragma mark - 补0
- (NSString *)supplement:(NSString *)str length:(int)len{
    NSString *resultStr = str;
    int addNum = len - (int)str.length;
    for (int i = 0; i < addNum ; i++) {
        resultStr = [NSString stringWithFormat:@"0%@",resultStr];
    }
    return resultStr;
}

- (int)decimalStringFromHexString:(NSString *)string{
    int stringLength = (int)string.length;
    int length = 0;
    if (string.length == 1) {
        length = [[NSString stringWithFormat:@"%lu",strtoul([string UTF8String],0,16)] intValue];
    }else{
        for(int i = 0 ; i < stringLength / 2;i ++){
            NSString *curStr = [string substringWithRange:NSMakeRange(i * 2, 2)];
            NSString *decimalStr = [NSString stringWithFormat:@"%lu",strtoul([curStr UTF8String],0,16)];
            length = length + [decimalStr intValue];
        }
    }
    return length;
}

#pragma mark - 蓝牙状态改变
-(void)blueToothStateChanged:(CBCentralManager *)central{
    if (@available(iOS 10.0, *)) {
        if(central.state == CBManagerStatePoweredOn)
        {
            NSLog(@"蓝牙设备开着");
            self.isShowBluetoothTip = NO;
        }
        else if (central.state == CBManagerStatePoweredOff)
        {
            NSLog(@"蓝牙设备关着");
            self.isShowBluetoothTip = YES;
            self.isConnect = NO;
        }else {
            NSLog(@"该设备蓝牙未授权或者不支持蓝牙功能");
            self.isShowBluetoothTip = YES;
        }
    } else {
        // Fallback on earlier versions
        self.isShowBluetoothTip = NO;
    }
    
    if (self.blueToothStateBlock) {
        self.blueToothStateBlock(self.isShowBluetoothTip);
    }
}

#pragma mark - 搜索到设备
- (void)foundDev:(NSMutableDictionary *)dic peripheral:(CBPeripheral *)peripheral {
    if (dic) {
        id kCBAdvDataManufacturerData = [dic objectForKey:@"kCBAdvDataManufacturerData"];
        NSString *newStr = [NSString xm_hexStringWithData:kCBAdvDataManufacturerData];
        if ([newStr containsString:@"8b8b8b8b"]) {
            NSMutableDictionary *serviceData = [dic objectForKey:@"kCBAdvDataServiceData"];
            NSString *name = [dic objectForKey:@"kCBAdvDataLocalName"];
            if (serviceData) {
                NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
                NSString *strPid = [[NSString alloc]initWithData:[[serviceData allValues] objectAtIndex:0] encoding:enc];
                
                NSString *macStr = [self getMacAddressStringWithPid:strPid ManufacturerData:newStr ServiceData:serviceData];
                NSString *sn = @"";
                BOOL needShow = YES;
                if (newStr.length > 52){ // 00表示未配网 01 表示已配网
                    NSString *needShowStr = [newStr substringWithRange:NSMakeRange(52, 2)];
                    NSString *curVersion = @"";
                    if(newStr.length > 54){
                        curVersion = [newStr substringWithRange:NSMakeRange(54, 2)];
                        //02初始版本
                        //03连上蓝牙后先从设备端获取设备初始信息（包括MTU信息）
                        //04呆锁，和海外锁单独立一个版本，用于判断先配对，扩展。
                    }
                    if([curVersion isEqualToString:TS("04")]){
                        if([needShowStr isEqualToString:@"02"]){
                            needShow = NO;
                        }
                    }
                    else{
                        //跟安卓统一，版本号不存在且是01的情况才不显示
                        if([needShowStr isEqualToString:@"01"] && curVersion.length <= 0){
                            needShow = NO;
                        }
                    }
                }
                if (macStr.length == 40) {
                    NSData *snData = [self convertHexStrToData:macStr];
                    sn = [[ NSString alloc] initWithData:snData encoding:NSUTF8StringEncoding];
                    signed char encryNewMac[64] = {0};
                    MD5Encrypt(encryNewMac,(unsigned char *)CSTR(sn));
                    encryNewMac[8]='\0';
                    NSString *macString = [NSString stringWithFormat:@"%s",encryNewMac];
                    macStr = macString;

                }
                if(sn.length > 0){
                    if(strPid.length <= 0){
                        Fun_Log("快速配置流程:SDK_LOG:[APP_BLE]搜索到的设备有序列号没pid\n");
                    }
                    
                    [self.devDic setObject:peripheral forKey:[NSString stringWithFormat:@"%@%@",sn,strPid]];
                }else{
                    [self.devDic setObject:peripheral forKey:[NSString stringWithFormat:@"%@%@",macStr,strPid]];
                }
                
        
                NSString *logStr = [NSString stringWithFormat:@"快速配置流程:SDK_LOG:[APP_BLE][%@]搜索到设备%@Pid=%@name=%@mac=%@\n",[[NSDate date] xm_string],dic,strPid,name,macStr];
                Fun_Log([logStr UTF8String]);
                
                if([sn isEqualToString:self.currentConnectDevId]){
                    if (self.foundCurrentConnectDevice) {
                        self.foundCurrentConnectDevice();
                    }
                    if(self.isGoConnect){
                        self.isGoConnect = NO;
                        [self connectBlueToothDeviceWithMac:self.currentConnectMac sn:self.currentConnectDevId pid:self.currentPid timeOut:15];
                    }
                }
                if (needShow == NO) {
                    NSLog(@"");
                }
                if (macStr.length > 0 && self.blueToothFoundDevice && needShow == YES) {
                    self.blueToothFoundDevice(strPid,name,macStr,sn,peripheral,dic,@"01");

                }
            }
        }else{
            if(newStr.length >= 48){
                NSMutableDictionary *serviceData = [dic objectForKey:@"kCBAdvDataServiceData"];
                NSString *name = [dic objectForKey:@"kCBAdvDataLocalName"];
                if (serviceData) {
                    if ([[newStr substringToIndex:4] isEqualToString:@"8b8b"]) {
                        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
                        NSString *strPid = [[NSString alloc]initWithData:[[serviceData allValues] objectAtIndex:0] encoding:enc];
                        NSString *snStr = [newStr substringWithRange:NSMakeRange(4, 40)];
                        NSData *snData = [self convertHexStrToData:snStr];
                        NSString *sn = [[ NSString alloc] initWithData:snData encoding:NSUTF8StringEncoding];
                        signed char encryNewMac[64] = {0};
                        MD5Encrypt(encryNewMac,(unsigned char *)CSTR(sn));
                        encryNewMac[8]='\0';
                        NSString *macString = [NSString stringWithFormat:@"%s",encryNewMac];
                        NSString *macStr = macString;
                        if(sn.length > 0){
                            [self.devDic setObject:peripheral forKey:[NSString stringWithFormat:@"%@%@",sn,strPid]];
                        }else{
                            [self.devDic setObject:peripheral forKey:[NSString stringWithFormat:@"%@%@",macStr,strPid]];
                        }
                        
                        if([sn isEqualToString:self.currentConnectDevId]){
                            if (self.foundCurrentConnectDevice) {
                                self.foundCurrentConnectDevice();
                            }
                            if(self.isGoConnect){
                                self.isGoConnect = NO;
                                [self connectBlueToothDeviceWithMac:self.currentConnectMac sn:self.currentConnectDevId pid:self.currentPid timeOut:15];
                            }
                        }
                        NSString *versionStr = [newStr substringWithRange:NSMakeRange(46, 2)];
                        
                        BOOL needShow = YES;
                        NSString *needShowStr = [newStr substringWithRange:NSMakeRange(44, 2)];
                        NSString *logStr = [NSString stringWithFormat:@"快速配置流程:SDK_LOG:[APP_BLE][%@]搜索到设备%@Pid=%@name=%@mac=%@version=%@needShowVer=%@\n",[[NSDate date] xm_string],dic,strPid,name,macStr,versionStr,needShowStr];
                        Fun_Log([logStr UTF8String]);
                        if([versionStr isEqualToString:TS("04")]){
                            if([needShowStr isEqualToString:@"02"]){
                                needShow = NO;
                            }
                        }else{
                            //跟安卓统一，版本号0或者不存在且needShowStr是01的情况才不显示
                            if([needShowStr isEqualToString:@"01"] && [versionStr isEqualToString:@"00"]){
                                needShow = NO;
                            }
                        }
                        if (needShow == NO) {
                            NSLog(@"");
                        }
                        if (macStr.length > 0 && self.blueToothFoundDevice && needShow) {
                            self.blueToothFoundDevice(strPid,name,macStr,sn,peripheral,dic,versionStr);

                        }
                    }
                }
            }

        }
    }
}

#pragma mark - 获取mac地址
-(NSString *)getMacAddressStringWithPid:(NSString *)pidStr ManufacturerData:(NSString *)dataStr ServiceData:(NSMutableDictionary *)serviceData{
    //蓝牙门锁
    NSString *macStr = @"";
    if ([DeviceObject isMeshBLE:pidStr]) {
        CBUUID *key = [CBUUID UUIDWithString:@"1827"];
        NSData *data = [serviceData objectForKey:key];
        if (data) {
            if (data.length < 16) {
                return macStr;
            }
            CBUUID *UUID = [CBUUID UUIDWithData:[data subdataWithRange:NSMakeRange(0, 16)]];
            macStr = UUID.UUIDString;
        }else{
            if (dataStr.length < 12) {
                return macStr;
            }
            NSString *subStr = [dataStr substringWithRange:NSMakeRange(4, 8)];
            if ([subStr isEqualToString:@"8b8b8b8b"]) {
                if (dataStr.length >= 52) {
                    macStr = [dataStr substringWithRange:NSMakeRange(12, 40)];
                }
            }else{
                if (dataStr.length >= 16) {
                    macStr = [dataStr substringWithRange:NSMakeRange(4, 12)];
                }
            }
        }
    }else{
        if (dataStr.length < 12) {
            return macStr;
        }
        NSString *subStr = [dataStr substringWithRange:NSMakeRange(4, 8)];
        if ([subStr isEqualToString:@"8b8b8b8b"]) {
            if (dataStr.length >= 52) {
                macStr = [dataStr substringWithRange:NSMakeRange(12, 20)];
            }
        }else{
            if (dataStr.length >= 16) {
                macStr = [dataStr substringWithRange:NSMakeRange(4, 12)];
            }
        }
    }
    
    return macStr;
}

#pragma mark - writeDataIntoDevice
-(void)writeBlueToothData:(NSString *)totalData needResponse:(BOOL)needResponse{
    if(totalData.length > self.currentMTU){
        NSMutableArray *array = [self seperateStr:totalData byLength:self.currentMTU];
        for(int i = 0;i < array.count; i++){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * i * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSString *sendStr = [array objectAtIndex:i];
                NSString *str = [NSString stringWithFormat:@"\n蓝牙分包发送的数据 = %@,当前MTU = %d\n",sendStr,self.currentMTU];
                Fun_Log([str UTF8String]);
                [self.blueToothManager writeDataIntoDevice:sendStr needBlueToothResponse:needResponse];
            });
        }
    }else{
        [self.blueToothManager writeDataIntoDevice:totalData needBlueToothResponse:needResponse];
    }
}

-(NSMutableArray *)seperateStr:(NSString *)str byLength:(int)length{
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < str.length / length + 1; i ++) {
        NSString *elementStr = @"";
        if(str.length - i * length >= length){
            elementStr = [str substringWithRange:NSMakeRange(i * length , length)];
        }
        else{
            elementStr =  [str substringWithRange:NSMakeRange(i * length , str.length - i * length)];
        }
        [returnArray addObject:elementStr];
    }

    return returnArray;
}

#pragma mark - 处理返回的数据
-(void)dealWithResponseData:(NSData *)data{
    NSString *responseDataStr = [NSString xm_hexStringWithData:data];
    NSString *logStr = [NSString stringWithFormat:@"快速配置流程：SDK_LOG:[APP_BLE][%@]蓝牙回调dealWithResponseData=%@\n",[[NSDate date] xm_string],responseDataStr];
    Fun_Log([logStr UTF8String]);
//    if (responseDataStr.length >= 22) {
//        [self dealWithResponseStr:responseDataStr];
//    }else{
    if ([DeviceObject isMeshBLE:self.currentPid] && responseDataStr.length >= 22) {
        [self dealWithGattResponseData:responseDataStr];
        NSString *logStr = [NSString stringWithFormat:@"快速配置流程：SDK_LOG:[APP_BLE][%@]蓝牙回调GATTresponse=%@\n",[[NSDate date] xm_string],responseDataStr];
        Fun_Log([logStr UTF8String]);
        return;
    }
    if(self.bufferData == nil){
        self.bufferData = @"";
    }
//    1.检验返回长度是否大于头长度（9个字节）
//    如果大于，判断是否为头（8B8B开头）
//    2.取出数据长度 （即第8,9字节）
//    计算整个数据包长度是否等于 取出长度 + 9 + 1 或者v1版本不用加1的，或者特殊pid不做校验的就直接认定为完整的，否则就是等待拼接，把当前长度记录下去准备后续添加
    if(responseDataStr.length >= 18){
        NSString *dataLen = [responseDataStr substringWithRange:NSMakeRange(14, 4)];
        int lenNum = [self decimalStringFromHexString:dataLen];
        int curLen = 18 + lenNum * 2 + 2;
        //兼容01蓝牙协议版本
        if([self.currentBlueToothVersion isEqualToString:@"01"]){
            curLen = 18 + lenNum * 2;
        }
        NSString *headStr = [responseDataStr substringToIndex:4];
        if(curLen <= responseDataStr.length && [headStr isEqualToString:@"8b8b"]){
            self.bufferData = responseDataStr;
        }else{
            self.bufferData = [self.bufferData stringByAppendingString:responseDataStr];
        }
    }else{
        self.bufferData = [self.bufferData stringByAppendingString:responseDataStr];
    }
    
    if(![self.bufferData containsString:@"8b8b"]){
        self.bufferData = @"";
    }
    if(self.bufferData.length >= 18){
        //指令：指令说明
        /*指令类型
         说明
         0x0003
         AP配网
         0x000A
         中断/退出蓝牙配网
         0x0006
         数据透传（一般用于透传主控的数据）
         0x0001
         获取网络状态
         0x0009
         获取设备初始信息（包括 MTU信息）
         0x0004
         蓝牙设备激活
         0x0008
         蓝牙设备激活完成
         0x0002
         蓝牙配网
         0x0007
         设备升级请求
         0x0005
         设备登录*/
        NSString *type = [self.bufferData substringWithRange:NSMakeRange(8, 4)];
        //协议版本
        NSString *version = [self.bufferData substringWithRange:NSMakeRange(4, 2)];
        //命令字：命令字值说明 0x01=APP下发 0x02=设备响应 0x03=设备上报 0x04==APP响应
        NSString *cmd = [self.bufferData substringWithRange:NSMakeRange(6, 2)];
        NSString *dataLen = [self.bufferData substringWithRange:NSMakeRange(14, 4)];
        int lenNum = [self decimalStringFromHexString:dataLen];
        
        NSString *typeStr = [NSString stringWithFormat:@"快速配置流程：self.bufferData = %@ ver=%@ cmd=%@ type=%@\n",self.bufferData,version,cmd,type];
        Fun_Log([typeStr UTF8String]);
        if([type isEqualToString:@"0009"]){//设备初始化信息
            if(self.bufferData.length >= 18 + lenNum){
                NSString *data = [self.bufferData substringWithRange:NSMakeRange(18, [dataLen intValue] * 2)];
                NSString *result = [data substringWithRange:NSMakeRange(0, 2)];
                if([result isEqualToString:@"01"]){
                    NSString *currentMTUStr = [data substringWithRange:NSMakeRange(2, lenNum * 2 - 2)];
                    self.currentMTU = [self decimalStringFromHexString:currentMTUStr] * 2;
                    self.bufferData = @"";
                    if(self.blueToothResponseDataWithTypeSuccessBlock){
                        self.blueToothResponseDataWithTypeSuccessBlock(currentMTUStr, type);
                    }
                }else{
                    self.bufferData = @"";
                    self.currentMTU = 182 * 2;
                }
            }
        }
        else if([type isEqualToString:@"0002"]){//设备配网结果回调
            if(self.bufferData.length >= 22){
                int minLen = 18 + lenNum * 2 + 2;
                //兼容01蓝牙协议版本
                if([self.currentBlueToothVersion isEqualToString:@"01"]){
                    minLen = 18 + lenNum * 2;
                }
                if(self.bufferData.length >= minLen){
                    if ([cmd isEqualToString:@"03"]) {
                        NSLog(@"蓝牙配网步骤：cmd03");
                       
                    } else if ([cmd isEqualToString:@"02"]) {
                        NSLog(@"蓝牙配网步骤：cmd02");
    
                    }
                    [self dealWithResponseStr:self.bufferData];
                    self.bufferData = @"";
                }
            }
        }
    }
}

-(void)dealWithResponseStr:(NSString *)responseDataStr{
    if ([DeviceObject isMeshBLE:self.currentPid]) {
        [self dealWithGattResponseData:responseDataStr];
        NSString *logStr = [NSString stringWithFormat:@"快速配置流程：SDK_LOG:[APP_BLE][%@]蓝牙回调GATTresponse=%@\n",[[NSDate date] xm_string],responseDataStr];
        Fun_Log([logStr UTF8String]);
        return;
    }
    
    Fun_Log([responseDataStr UTF8String]);
    
    //指令：指令说明
    /*指令类型
     说明
     0x0003
     AP配网
     0x000A
     中断/退出蓝牙配网
     0x0006
     数据透传（一般用于透传主控的数据）
     0x0001
     获取网络状态
     0x0009
     获取设备初始信息（包括 MTU信息）
     0x0004
     蓝牙设备激活
     0x0008
     蓝牙设备激活完成
     0x0002
     蓝牙配网
     0x0007
     设备升级请求
     0x0005
     设备登录*/
    //指令类型
    NSString *type = [responseDataStr substringWithRange:NSMakeRange(8, 4)];
    //协议版本
    NSString *version = [responseDataStr substringWithRange:NSMakeRange(4, 2)];
    //命令字：命令字值说明 0x01=APP下发 0x02=设备响应 0x03=设备上报 0x04==APP响应
    NSString *cmd = [responseDataStr substringWithRange:NSMakeRange(6, 2)];
    NSString *dataLen = [responseDataStr substringWithRange:NSMakeRange(14, 4)];
    //配网结果
    NSString *result = [responseDataStr substringWithRange:NSMakeRange(18, 2)];
    
    JFNetPairingTranscation *transcation = [[JFNetPairingTranscation alloc] initWithType:JFNetPairing_BlueTooth result:result];
    if ([cmd isEqualToString:@"03"] || [cmd isEqualToString:@"02"]) {
        //如果是蓝牙配网设备
        if ([type isEqualToString:@"0002"]) {
            //如果是密码错误的
            if ([result isEqualToString:@"53"]) {
                int operationLocation = (9 + 1) * 2;
                //随机用户名长度
                int randomUserLength = [[self dataStringWithLocation:operationLocation length:2 data:responseDataStr] intValue];
                operationLocation = operationLocation + (randomUserLength + 1) * 2;
                //随机用户名密码长度
                int randomPasswordLength = [[self dataStringWithLocation:operationLocation length:2 data:responseDataStr] intValue];
                operationLocation = operationLocation + (randomPasswordLength + 1) * 2;
                //序列号长度
                int snLength = [[self dataStringWithLocation:operationLocation length:2 data:responseDataStr] intValue];
                operationLocation = operationLocation + (snLength + 1) * 2;
                //IP地址和Mac地址
                operationLocation = operationLocation + (4 + 6) * 2;
                //Token长度
                int tokenLength = [[self dataStringWithLocation:operationLocation length:2 data:responseDataStr] intValue];
                operationLocation = operationLocation + (tokenLength + 1) * 2;
                //PID长度
                int pidLength = [[self dataStringWithLocation:operationLocation length:2 data:responseDataStr] intValue];
                operationLocation = operationLocation + (pidLength + 1) * 2;
                //重置标识
                int resetSign = [[self dataStringWithLocation:operationLocation length:2 data:responseDataStr] intValue];
                if (resetSign == 1) {
                    transcation.passwordErrorNeedRestart = NO;
                }
                //校验和
//                int v = [[self dataStringWithLocation:operationLocation + 2 length:2 data:responseDataStr] intValue];
                NSLog(@"");
            }
        }
    }
    
    NSString *logStr = [NSString stringWithFormat:@"快速配置流程：SDK_LOG:[APP_BLE][%@]蓝牙回调 response=%@ result=%@\n",[[NSDate date] xm_string],responseDataStr,result];
    Fun_Log([logStr UTF8String]);
   
    if (responseDataStr.length == 22) {
        if ([result isEqualToString:@"01"]) {
            if(self.blueToothResponse){
                self.blueToothResponse();
            }
        }else{
            
            if (self.blueToothResponseFailedBlock) {
                self.blueToothResponseFailedBlock(transcation);
            }
        }
        return;
    }

    
    if ([result isEqualToString:@"00"]) {
        @try {
            NSString *nameLenStr = [responseDataStr substringWithRange:NSMakeRange(20, 2)];
            int nameLen = [self decimalStringFromHexString:nameLenStr];
            NSString *nameStr = [responseDataStr substringWithRange:NSMakeRange(22, nameLen * 2)];
            NSData *namedata = [self convertHexStrToData:nameStr];
            NSString *useName = [[ NSString alloc] initWithData:namedata encoding:NSUTF8StringEncoding];
            NSLog(@"useName = %@",useName);
            
            NSString *passLenStr = [responseDataStr substringWithRange:NSMakeRange(22 + nameLen * 2, 2)];
            int passLen = [self decimalStringFromHexString:passLenStr];
            NSString *passStr = [responseDataStr substringWithRange:NSMakeRange(22 + nameLen * 2 + 2, passLen * 2)];
            NSData *passdata = [self convertHexStrToData:passStr];
            NSString *password = [[ NSString alloc] initWithData:passdata encoding:NSUTF8StringEncoding];
            NSLog(@"password = %@",password);
            
            NSString *snLenStr = [responseDataStr substringWithRange:NSMakeRange(22 + nameLen * 2 + 2 + passLen * 2, 2)];
            int snLen = [self decimalStringFromHexString:snLenStr];
            NSString *snStr = [responseDataStr substringWithRange:NSMakeRange(22 + nameLen * 2 + 2 + passLen * 2 + 2, snLen * 2)];
            NSData *snData = [self convertHexStrToData:snStr];
            NSString *sn = [[ NSString alloc] initWithData:snData encoding:NSUTF8StringEncoding];
            NSLog(@"sn = %@",sn);
            
            NSString *ipStr =  [responseDataStr substringWithRange:NSMakeRange(22 + nameLen * 2 + 2 + passLen * 2 + 2 + snLen * 2 , 8)];
            NSString *ip = [self.tranModel transferString:[NSString stringWithFormat:@"0x%@",ipStr]];
            
            NSString *macStr = [responseDataStr substringWithRange:NSMakeRange(22 + nameLen * 2 + 2 + passLen * 2 + 2 + snLen * 2 + 8 , 12)];
            NSString *mac = [self.tranModel dealWithMacString:macStr];
            
            NSString *token = @"";
            int totalLenth = 22 + nameLen * 2 + 2 + passLen * 2 + 2 + snLen * 2 + 8 + 12 + 2;
            if (responseDataStr.length > totalLenth + 2) {  //返回了token
                Fun_Log("快速配置流程:蓝牙配网返回token\n");
                NSString *tokenLenStr = [responseDataStr substringWithRange:NSMakeRange(totalLenth - 2, 2)];
                int tokenlen = [self decimalStringFromHexString:tokenLenStr];
                NSString *tokenStr = [responseDataStr substringWithRange:NSMakeRange(totalLenth, tokenlen * 2)];
                NSData *tokenData = [self convertHexStrToData:tokenStr];
                token = [[ NSString alloc] initWithData:tokenData encoding:NSUTF8StringEncoding];
            }
            if (self.blueToothResponseSuccessBlock) {
                self.blueToothResponseSuccessBlock(useName, password, sn,ip ,mac,token,YES);
            }
        }
        @catch (NSException *exception) {
        }
    }
    else{
//        if (50 == [result integerValue] || 51 == [result integerValue] || 52 == [result integerValue] || 55 == [result intValue]) {
//            //50:未知错误 51:未找到热点 52:握手失败 53:路由器密码错误  55:V3版本未知错误
//            //说明：部分设备密码失败后，可以马上重发密码给设备，设备会立即重新配网
            if (self.blueToothResponseFailedBlock) {
                self.blueToothResponseFailedBlock(transcation);
            }
//        }
    }
}

- (NSString *)dataStringWithLocation:(int)location length:(int)lenght data:(NSString *)dataStr{
    if (dataStr.length < (location + lenght)) {
        return @"";
    }
    
    return [NSString decimalStringFromHexString:[dataStr substringWithRange:NSMakeRange(location, lenght)]];
}


#pragma mark - gatt数据返回处理
-(void)dealWithGattResponseData:(NSString *)data{
    NSString *type = [data substringWithRange:NSMakeRange(8, 4)];
    NSString *responseData = [data substringWithRange:NSMakeRange(18, data.length - 20)];
    if([type isEqualToString:@"00ff"]){//获取设备序列号
        NSData *snData = [self convertHexStrToData:responseData];
        NSString *sn = [[ NSString alloc] initWithData:snData encoding:NSUTF8StringEncoding];
        NSLog(@"sn = %@",sn);
        if (self.blueToothResponseSuccessBlock) {
            self.blueToothResponseSuccessBlock(@"", @"", sn,@"" ,@"",@"",YES);
        }
    }else if([type isEqualToString:@"0010"]){//设备激活
        NSString *len = [data substringWithRange:NSMakeRange(14, 4)];
        int lenNum = [self decimalStringFromHexString:len];
        NSString *activeData = [data substringWithRange:NSMakeRange(18, lenNum * 2)];
        if(self.blueToothResponseDataWithTypeSuccessBlock){
            self.blueToothResponseDataWithTypeSuccessBlock(activeData, type);
        }
    }else if([type isEqualToString:@"0015"]){//设备激活异常
        //        NSString *len = [data substringWithRange:NSMakeRange(14, 4)];
        //        int lenNum = [self decimalStringFromHexString:len];
        //        NSString *activeData = [data substringWithRange:NSMakeRange(18, lenNum * 2)];
        if(self.blueToothResponseActiveFailedBlock){
            self.blueToothResponseActiveFailedBlock();
        }
    }else if([type isEqualToString:@"0030"]){//数据透传
        NSString *responceTypeStr = [NSString decimalStringFromHexString:[responseData substringWithRange:NSMakeRange(2, 2)]];
        if([responceTypeStr intValue] == 28){
            NSString *modelTypeStr = [NSString decimalStringFromHexString:[responseData substringWithRange:NSMakeRange(0, 2)]];
            [self checkNeedSendRestart:[modelTypeStr intValue]];
        }
        if (self.blueToothResponseDataSuccessBlock) {
            self.blueToothResponseDataSuccessBlock(responseData);
        }
        if(self.responseSuccessBlock){
            self.responseSuccessBlock(responseData);
        }
    }else if([type isEqualToString:@"0038"]){//下发异常返回，设备未激活
        if (self.blueToothResponseNotActiveBlock) {
            self.blueToothResponseNotActiveBlock();
        }
    }else if([type isEqualToString:@"0040"]){//设备状态上报
        NSString *len = [data substringWithRange:NSMakeRange(14, 4)];
        int lenNum = [self decimalStringFromHexString:len];
        NSString *stateData = [data substringWithRange:NSMakeRange(18, lenNum * 2)];
        int stateValue = [stateData intValue];
        JLinkDoorLockDevState state = stateValue == 1 ?   JLinkDoorLockState_WakeUp:JLinkDoorLockState_Sleep;
        if (self.blueToothDevStateChangeBlock) {
            self.blueToothDevStateChangeBlock(state);
        }
    }
}

- (NSData *)convertHexStrToData:(NSString *)str
{
    if (!str || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:20];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    return hexData;
}

#pragma mark - lazyload
-(BlueToothManager *)blueToothManager{
    if (!_blueToothManager) {
        _blueToothManager = [[BlueToothManager alloc] init];
        WeakSelf(weakSelf);
        _blueToothManager.blueToothStateBlock = ^(CBCentralManager * central) {
            [weakSelf blueToothStateChanged:central];
        };
        _blueToothManager.blueToothFoundDevice = ^(NSMutableDictionary * _Nonnull dic, CBPeripheral * _Nonnull peripheral) {
            [weakSelf foundDev:dic peripheral:peripheral];
        };
        _blueToothManager.blueToothConnectBlock = ^{
            if (weakSelf.connectTimer) {
                [weakSelf.connectTimer invalidate];
                weakSelf.connectTimer = nil;
                weakSelf.connectTime = 0;
            }
            weakSelf.isConnect = YES;
            weakSelf.isGoConnect = NO;
            [weakSelf startTimerConnectRetain];
            if (weakSelf.blueToothConnectSuccessBlock) {
                weakSelf.blueToothConnectSuccessBlock();
            }
            if (weakSelf.blueConnectSuccessBlock) {
                weakSelf.blueConnectSuccessBlock();
            }
        };
        _blueToothManager.blueToothResponseBlock = ^(NSData * _Nonnull data) {
            [weakSelf dealWithResponseData:data];
        };
        _blueToothManager.blueToothConnectFailedBlock = ^(NSError * _Nonnull error) {
            if(weakSelf.needRetryConnect == YES){
                weakSelf.isGoConnect = NO;
                [weakSelf connectBlueToothDeviceWithMac:weakSelf.currentConnectMac sn:weakSelf.currentConnectDevId pid:weakSelf.currentPid timeOut:15];
                weakSelf.needRetryConnect = NO;
                return;
            }
            weakSelf.isConnect = NO;
            weakSelf.isGoConnect = NO;
            if (weakSelf.blueToothConnectFailedBlock) {
                weakSelf.blueToothConnectFailedBlock(error);
            }
        };
        _blueToothManager.blueToothDisConnectBlock = ^{
            weakSelf.isConnect = NO;
            [weakSelf stopTimerConnectRetain];
            if(weakSelf.blueToothDisConnectBlock){
                weakSelf.blueToothDisConnectBlock();
            }
        };
    }
    
    return _blueToothManager;
}

-(NSMutableDictionary *)devDic{
    if (!_devDic) {
        _devDic = [[NSMutableDictionary alloc] init];
    }
    
    return _devDic;
}

-(TransferModel *)tranModel{
    if (!_tranModel) {
        _tranModel = [[TransferModel alloc] init];
    }
    return _tranModel;
}

@end
