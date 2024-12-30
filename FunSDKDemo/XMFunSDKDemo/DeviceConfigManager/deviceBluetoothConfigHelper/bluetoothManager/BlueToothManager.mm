//
//  BlueToothManager.m
//  JLink
//
//  Created by 吴江波 on 2022/2/28.
//

#import "BlueToothManager.h"
#import "FunSDK/FunSDK.h"


typedef void(^JFBluetoothStateCompletion)(JFManagerAuthorization authState, JFManagerState switchState);

@interface BlueToothManager()<CBCentralManagerDelegate,CBPeripheralManagerDelegate,CBPeripheralDelegate>{
    NSMutableArray *peripherals;
    CBPeripheral *Periph;
    CBCharacteristic *WriteCharacter;
    CBCharacteristic *NotifyCharacter;
    CBCharacteristic *Character;
    CBService *Service;
    CBPeripheralManager *peripheralManager;
    NSMutableDictionary *dataDic;
}
@property (nonatomic,strong) CBCentralManager *centralManager;
@property (nonatomic,strong) CBPeripheralManager *peripheralManager;

@property (nonatomic,assign) BOOL centralManagerDidUpdateState;//蓝牙中央服务是否回调过状态 回调过后才能获取

@property (nonatomic, copy) JFBluetoothStateCompletion bluetoothStateCompletion;

@end

@implementation BlueToothManager

- (instancetype)init{
    self = [super init];
    if (self) {

    }
    
    return self;
}

-(void)initBlueTooth{
    if (self.centralManager == nil) {
        self.centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:dispatch_get_main_queue()];
    }
}


//开始写入数据
-(void)writeDataIntoDevice:(NSString *)dataStr needBlueToothResponse:(BOOL)needResponse
{
    NSData *data = [self convertHexStrToData:dataStr];
    //NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    if (Periph && WriteCharacter) {
        //NSUInteger maxinum = [Periph maximumWriteValueLengthForType:CBCharacteristicWriteWithResponse];
        //NSLog(@"开始写入时间 = %@",[NSDate date]);
        Periph.delegate = self;
        if(needResponse){
            [Periph writeValue:data forCharacteristic:WriteCharacter type:CBCharacteristicWriteWithResponse];
        }else{
            [Periph writeValue:data forCharacteristic:WriteCharacter type:CBCharacteristicWriteWithoutResponse];
        }
    }
}

/**
 将16进制类型的字符串转成16进制的NSData类型
 @param str 字符串
 @return nsdata
 */
- (NSData *)convertHexStrToData:(NSString *)str{
    if (!str || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
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

//开始搜索设备
-(void)startSearch{
    [self.centralManager scanForPeripheralsWithServices:nil options:nil];
}

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *, id> *)dict
{
    NSLog(@"");
}

// MARK: 获取蓝牙权限
- (void)jf_reqBluetoothStateCompletion:(void (^)(JFManagerAuthorization authState, JFManagerState switchState))competion{
    // iOS13增加了属性CBManagerAuthorization，来获取蓝牙的授权状态.
    // 属性CBManagerState获取的是“控制中心”的蓝牙状态。
    self.bluetoothStateCompletion = competion;
    NSInteger authorState = 0;
    // 蓝牙权限
    if (@available(iOS 13.0, *)){
        // CBManagerAuthorization
        authorState = self.centralManager.authorization;
    }
    // 蓝牙开关状态
    CBManagerState onOffState = self.centralManager.state;
    XMLog(@"authorState:%ld, onOffState:%ld", authorState, onOffState);
}

-(BOOL)getBlueToothOpenState{
    if (@available(iOS 10.0, *)) {
//        [self initBlueTooth];
        CBManagerState state = self.centralManager.state;
        if (state == CBManagerStatePoweredOn) {
            return YES;
        }else{
            return NO;
        }
    } else {
        return NO;
    }
}

//MARK: 获取APP蓝牙授权状态
- (void)requestAuthorizationState:(BlueToothManagerGetAuthorizationStateCallBack)completed{
    self.blueToothManagerGetAuthorizationStateCallBack = completed;
    
    //iOS13以上才需要获取
    if (@available(iOS 13.0, *)){
        CBManagerAuthorization authorization = self.centralManager.authorization;
        if (self.centralManagerDidUpdateState){
            [self trySendGetAuthorizationStateResult:(int)authorization];
        }
    }else{
        [self trySendGetAuthorizationStateResult:3];
    }
}

//MARK: 获取APP的蓝牙开关授权状态 （除了iOS13.0版本 其他都不会触发蓝牙使用授权提示）-2:受限制 -1:未确定  0:关 1:开
- (int)appBlueToothState{
    int state = -1;
   
    if (@available(iOS 13.1, *)) {
        CBManagerAuthorization authStatus = CBManager.authorization;
        switch (authStatus) {
            case CBManagerAuthorizationNotDetermined:
                NSLog(@"用户尚未选择是否授权访问蓝牙功能");
                break;
            case CBManagerAuthorizationRestricted:
                state = -2;
                NSLog(@"应用程序未被授权访问蓝牙功能，例如由于家长控制等");
                break;
            case CBManagerAuthorizationDenied:
                state = 0;
                NSLog(@"用户拒绝了应用程序访问蓝牙功能");
                break;
            case CBManagerAuthorizationAllowedAlways:
                state = 1;
                NSLog(@"用户允许应用程序始终访问蓝牙功能");
                break;
            default:
                break;
        }
    }else{
        if (@available(iOS 13.0, *)){
            CBManagerAuthorization authStatus = self.peripheralManager.authorization;
            switch (authStatus) {
                case CBManagerAuthorizationNotDetermined:
                    NSLog(@"用户尚未选择是否授权访问蓝牙功能");
                    break;
                case CBManagerAuthorizationRestricted:
                    state = -2;
                    NSLog(@"应用程序未被授权访问蓝牙功能，例如由于家长控制等");
                    break;
                case CBManagerAuthorizationDenied:
                    state = 0;
                    NSLog(@"用户拒绝了应用程序访问蓝牙功能");
                    break;
                case CBManagerAuthorizationAllowedAlways:
                    state = 1;
                    NSLog(@"用户允许应用程序始终访问蓝牙功能");
                    break;
                default:
                    break;
            }
        }else{
            //iOS13以下 不需要授权
            state = 1;
        }
        
    }
    
    return state;
}

//MARK: 回调请求APP蓝牙授权状态结果
- (void)trySendGetAuthorizationStateResult:(int)state{
    if (self.blueToothManagerGetAuthorizationStateCallBack){
        self.blueToothManagerGetAuthorizationStateCallBack(state);
        self.blueToothManagerGetAuthorizationStateCallBack = nil;
    }
}

//MARK: 获取手机蓝牙开关状态
- (void)requestPhoneState:(BlueToothManagerGetPhoneStateCallBack)completed{
    self.blueToothManagerGetPhoneStateCallBack = completed;
    
    if (@available(iOS 10.0, *)) {
        CBManagerState state = self.centralManager.state;
        if (self.centralManagerDidUpdateState){
            [self trySendGetPhoneStateResult:state];
        }
    } else {
        return [self trySendGetPhoneStateResult:CBManagerStateUnsupported];
    }
}

- (void)trySendGetPhoneStateResult:(CBManagerState)state{
    if (self.blueToothManagerGetPhoneStateCallBack){
        self.blueToothManagerGetPhoneStateCallBack(state);
        self.blueToothManagerGetPhoneStateCallBack = nil;
    }
}

- (CBManagerState)iphoneBluetoothOpenState{
    if (@available(iOS 10.0, *)) {
        [self initBlueTooth];
        CBManagerState state = self.centralManager.state;
        return state;
    } else {
        return CBManagerStateUnsupported;
    }
}

-(BOOL)isBlueToothUnauthorized{
    if (@available(iOS 13.0, *)) {
        CBManagerAuthorization authorization = self.centralManager.authorization;
        if (authorization == CBManagerAuthorizationAllowedAlways) {
            return YES;
        }
    }
    else if (@available(iOS 10.0, *)) {
        [self initBlueTooth];
        CBManagerState state = self.centralManager.state;
        if (state == CBManagerStatePoweredOn) {
            return YES;
        }else{
            return NO;
        }
    }
    return NO;
}

//每次蓝牙状态改变都会回调这个函数
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    dispatch_async(dispatch_get_main_queue(), ^{
    switch (central.state) {
        case CBManagerStateUnknown:
            NSLog(@">>>CBCentralManagerStateUnknown");
            break;
        case CBManagerStateResetting:
            NSLog(@">>>CBCentralManagerStateResetting");
            break;
        case CBManagerStateUnsupported:
            NSLog(@">>>CBCentralManagerStateUnsupported");
            break;
        case CBManagerStateUnauthorized:
            NSLog(@"CBCentralManagerStateUnauthorized");
            break;
        case CBManagerStatePoweredOff:
            NSLog(@"CBCentralManagerStatePoweredOff");
            break;
        case CBManagerStatePoweredOn:
            NSLog(@"CBCentralManagerStatePoweredOn");
            
            //开始扫描周围的外设
            /*
             第一个参数nil就是扫描周围所有的外设，扫描到外设后会进入
             - (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;
             第二个参数可以添加一些option,来增加精确的查找范围, 如 :
             NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
             [NSNumber numberWithBool:YES], CBCentralManagerScanOptionAllowDuplicatesKey,
             nil];
             [manager scanForPeripheralsWithServices:nil options:options];
             
             */
            [self.centralManager scanForPeripheralsWithServices:nil options:nil];
            //[self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"1827"]] options:nil];
            
            break;
        default:
            break;
    }
        CBManagerState state = self.centralManager.state;
        CBManagerAuthorization authorization = self.centralManager.authorization;
    
        self.centralManagerDidUpdateState = YES;
        if (@available(iOS 13.0,*)){
            if (self.centralManagerDidUpdateState){
                [self trySendGetAuthorizationStateResult:(int)authorization];
            }
        }
        
        if (@available(iOS 10.0,*)){
            if (self.centralManagerDidUpdateState){
                [self trySendGetPhoneStateResult:state];
            }
        }
        
        if (self.blueToothStateBlock) {
            self.blueToothStateBlock(central);
        }
        dispatch_main_async_safe(^{
            if(!self.bluetoothStateCompletion) return;
            self.bluetoothStateCompletion((JFManagerAuthorization)authorization, state);
        });
    });
    
}

int writetimes = 0;
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    if (error) {
        NSLog(@"%@",error);
    }
    writetimes ++;

    //NSLog(@"完成时间 = %@",[NSDate date]);
}


// 1.3 设置主设备的委托,CBCentralManagerDelegate
// 1.4  必须实现的： //主设备状态改变的委托，在初始化CBCentralManager的适合会打开设备，只有当设备正确打开后才能使用

//其他选择实现的委托中比较重要的：找到外设的委托
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    
    //可以使用app lightbule 模拟一个设备
    //这里自己去设置下连接规则
//    if ([peripheral.name hasPrefix:@"XM"]){
    dataDic = [advertisementData mutableCopy];
    id kCBAdvDataManufacturerData = [dataDic objectForKey:@"kCBAdvDataManufacturerData"];
    NSString *newStr = [NSString xm_hexStringWithData:kCBAdvDataManufacturerData];
//    if(![peripheral.name isEqualToString:@"XM"]){
//        return;
//    }
    if ([newStr containsString:@"8b8b"]) {
        Fun_Log([NSString stringWithFormat:@"蓝牙配网:kCBAdvDataManufacturerData %@ \n",newStr].UTF8String);
        //找到的设备必须持有它，否则CBCentralManager中也不会保存peripheral，那么CBPeripheralDelegate中的方法也不会被调用！！
        if (self.blueToothFoundDevice) {
            self.blueToothFoundDevice(dataDic,peripheral);
        }
//        if (!Periph) {
//            Periph = peripheral;
//            [peripherals addObject:peripheral];
//            //连接设备
//            [self.centralManager connectPeripheral:peripheral options:nil];
//        }
    }

//    }
}

//连接设备
-(void)connectPeripheral:(CBPeripheral *)peripheral{
    if (peripheral) {
        Periph = peripheral;
        Character = nil;
        [peripherals addObject:peripheral];
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}

//连接到Peripherals-成功回调
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    Fun_Log([NSString stringWithFormat:@"快速配置流程:连接到名称为（%@）的设备-成功 \n",peripheral.name].UTF8String);
    //设置的peripheral委托CBPeripheralDelegate
    //@interface ViewController : UIViewController<CBCentralManagerDelegate,CBPeripheralDelegate>
    [peripheral setDelegate:self];
    //扫描外设Services，成功后会进入方法：
    //-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    
    // 获取service时候也可以设置option 如:
    //    NSMutableArray *serviceUUIDs = [NSMutableArray array ];
    //    CBUUID *cbuuid = [CBUUID UUIDWithString:[NSString stringWithFormat:@"%x",Ble_Device_Service]];
    //    [serviceUUIDs addObject:cbuuid];
    //   [peripheral discoverServices:serviceUUIDs];
    // 添加指定条件可以 提高效率
    
    [peripheral discoverServices:nil];
    
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    Fun_Log([NSString stringWithFormat:@"快速配置流程:名称为（%@）的设备 连接断开 \n",peripheral.name].UTF8String);
    if(self.blueToothDisConnectBlock){
        self.blueToothDisConnectBlock();
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    Fun_Log([NSString stringWithFormat:@"快速配置流程:名称为（%@）的设备 连接失败 \n",peripheral.name].UTF8String);
    if (self.blueToothConnectFailedBlock) {
        self.blueToothConnectFailedBlock(error);
    }
    NSLog(@"%@",error);
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral timestamp:(CFAbsoluteTime)timestamp isReconnecting:(BOOL)isReconnecting error:(nullable NSError *)error{
    Fun_Log([NSString stringWithFormat:@"快速配置流程:名称为（%@）的设备 连接断开2 \n",peripheral.name].UTF8String);
}

//扫描到Services
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    //  NSLog(@"扫描到服务：%@",peripheral.services);
    if (error)
    {
        NSLog(@"Discovered services for %@ with error: %@", peripheral.name, [error localizedDescription]);
        return;
    }
    
    for (CBService *service in peripheral.services) {
        NSLog(@"%@",service.UUID);
        //扫描每个service的Characteristics，扫描到后会进入方法： -(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
        [peripheral discoverCharacteristics:nil forService:service];
    }
    
}


// ==========获取外设的Characteristics,获取Characteristics的值，获取Characteristics的Descriptor和Descriptor的值============//

//扫描到Characteristics
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (error)
    {
        NSLog(@"error Discovered characteristics for %@ with error: %@", service.UUID, [error localizedDescription]);
        return;
    }
    
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        NSLog(@"service:%@ 的 Characteristic: %@",service.UUID,characteristic.UUID);
        NSString *UUID = [NSString stringWithFormat:@"%@",characteristic.UUID];
        if ([UUID containsString:@"2B11"]) {
            WriteCharacter = characteristic;
//            if (self.blueToothConnectBlock) {
//                self.blueToothConnectBlock();
//            }
            //[peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }else if ([UUID containsString:@"2B10"]){
            NotifyCharacter = characteristic;
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }

    //获取Characteristic的值，读到数据会进入方法：-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
//    for (CBCharacteristic *characteristic in service.characteristics){
//        {
//            [peripheral readValueForCharacteristic:characteristic];
//        }
//    }
    
    //搜索Characteristic的Descriptors，读到数据会进入方法：-(void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
//    for (CBCharacteristic *characteristic in service.characteristics){
//        [peripheral discoverDescriptorsForCharacteristic:characteristic];
//    }
    
    
}

/** 订阅状态的改变 */
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {

    if (error == nil) {
        if (characteristic.isNotifying) {
            if (self.blueToothConnectBlock) {
                self.blueToothConnectBlock();
            }
        }
    }
}

//获取的charateristic的值
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    //打印出characteristic的UUID和值
    //!注意，value的类型是NSData，具体开发时，会根据外设协议制定的方式去解析数据
    NSLog(@"characteristic uuid:%@  value:%@",characteristic.UUID,characteristic.value);
    if (self.blueToothResponseBlock) {
        self.blueToothResponseBlock(characteristic.value);
    }
    if (!Character) {
        Character = characteristic;
        Periph = peripheral;
//        if (self.blueToothConnectBlock) {
//            self.blueToothConnectBlock();
//        }
    }
}

//搜索到Characteristic的Descriptors
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    //打印出Characteristic和他的Descriptors
    NSLog(@"characteristic uuid:%@",characteristic.UUID);
    for (CBDescriptor *d in characteristic.descriptors) {
        NSLog(@"Descriptor uuid:%@",d.UUID);
    }
}
//获取到Descriptors的值
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error{
    //打印出DescriptorsUUID 和value
    //这个descriptor都是对于characteristic的描述，一般都是字符串，所以这里我们转换成字符串去解析
    NSLog(@"characteristic uuid:%@  value:%@",[NSString stringWithFormat:@"%@",descriptor.UUID],descriptor.value);
}

//停止扫描并断开连接
-(void)disconnectPeripheral:(CBCentralManager *)centralManager
                 peripheral:(CBPeripheral *)peripheral{
    //停止扫描
    [centralManager stopScan];
    //断开连接
    [centralManager cancelPeripheralConnection:peripheral];
}

-(void)stopSearch{
    if (self.centralManager) {
        [self.centralManager stopScan];
    }
}

-(void)cancelConnection{
    //断开连接
    if (self.centralManager && Periph) {
        [self.centralManager cancelPeripheralConnection:Periph];
//        self.centralManager = nil;
    }
}

#pragma  mark - 外设
//外设

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    // 在这里判断蓝牙的状态, 因为蓝牙打开成功后才能配置service和characteristics
    [self config];
}
-(void)config{
    
    //特征字段描述
    CBUUID *CBUUIDCharacteristicUserDescriptionStringUUID = [CBUUID UUIDWithString:CBUUIDCharacteristicUserDescriptionString];
    
    /*
     可以通知的Characteristic
     properties：CBCharacteristicPropertyNotify
     permissions CBAttributePermissionsReadable
     */
    CBMutableCharacteristic *notiyCharacteristic = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:@"notiyCharacteristicUUID"] properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    
    /*
     可读写的characteristics
     properties：CBCharacteristicPropertyWrite | CBCharacteristicPropertyRead
     permissions CBAttributePermissionsReadable | CBAttributePermissionsWriteable
     */
    CBMutableCharacteristic *readwriteCharacteristic = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:@"readwriteCharacteristicUUID"] properties:CBCharacteristicPropertyWrite | CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable | CBAttributePermissionsWriteable];
    //设置description
    CBMutableDescriptor *readwriteCharacteristicDescription1 = [[CBMutableDescriptor alloc]initWithType: CBUUIDCharacteristicUserDescriptionStringUUID value:@"name"];
    [readwriteCharacteristic setDescriptors:@[readwriteCharacteristicDescription1]];
    /*
     只读的Characteristic
     properties：CBCharacteristicPropertyRead
     permissions CBAttributePermissionsReadable
     */
    CBMutableCharacteristic *readCharacteristic = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:@"readCharacteristicUUID"] properties:CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable];
    
    //service1初始化并加入两个characteristics
    CBMutableService *service1 = [[CBMutableService alloc]initWithType:[CBUUID UUIDWithString:@"ServiceUUID1"] primary:YES];
    [service1 setCharacteristics:@[notiyCharacteristic,readwriteCharacteristic]];
    
    //service2初始化并加入一个characteristics
    CBMutableService *service2 = [[CBMutableService alloc]initWithType:[CBUUID UUIDWithString:@"ServiceUUID2"] primary:YES];
    [service2 setCharacteristics:@[readCharacteristic]];
    
    //添加后就会调用代理的- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
    [peripheralManager addService:service1];
    [peripheralManager addService:service2];
}

int serviceNum = 0;
//perihpheral添加了service
- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error{
    if (error == nil) {
        serviceNum++;
    }
    //因为我们添加了2个服务，所以想两次都添加完成后才去发送广播
    if (serviceNum==2) {
        //添加服务后可以在此向外界发出通告 调用完这个方法后会调用代理的
        //(void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
        [peripheralManager startAdvertising:@{
            CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:@"ServiceUUID1"],[CBUUID UUIDWithString:@"ServiceUUID2"]],
            CBAdvertisementDataLocalNameKey : @"LocalNameKey"}
        ];
    }
}
//peripheral开始发送advertising
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error{
    NSLog(@"in peripheralManagerDidStartAdvertisiong");
}

- (CBCentralManager *)centralManager{
    if (!_centralManager){
        if (self.needBlueTip) {
            _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
        }else{
            _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue() options:nil];
        }
    }
    
    return _centralManager;
}

- (CBPeripheralManager *)peripheralManager{
    if (!_peripheralManager){
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:nil queue:nil];
    }
    
    return _peripheralManager;
}
@end
