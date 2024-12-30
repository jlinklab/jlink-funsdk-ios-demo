//
//  BlueToothManager.h
//  JLink
//
//  Created by 吴江波 on 2022/2/28.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef void(^BlueToothManagerGetAuthorizationStateCallBack)(int state);// APP蓝牙授权状态 state: -1:未授权 0:关闭 1:打开
typedef void(^BlueToothManagerGetPhoneStateCallBack)(CBManagerState state);// 手机蓝牙状态 CBManagerState

NS_ASSUME_NONNULL_BEGIN

@interface BlueToothManager : NSObject

@property (nonatomic,copy,nullable) BlueToothManagerGetAuthorizationStateCallBack blueToothManagerGetAuthorizationStateCallBack;
@property (nonatomic,copy,nullable) BlueToothManagerGetPhoneStateCallBack blueToothManagerGetPhoneStateCallBack;
//搜索发现设备回调
@property(nonatomic, copy) void(^blueToothFoundDevice)(NSMutableDictionary *dic,CBPeripheral *peripheral);
//蓝牙状态变化回调
@property(nonatomic, copy) void(^blueToothStateBlock)(CBCentralManager *manager);
//连接设备回调
@property(nonatomic, copy) void(^blueToothConnectBlock)(void);
//连接设备失败回调
@property(nonatomic, copy) void(^blueToothConnectFailedBlock)(NSError *error);
//蓝牙设备连接断开回调
@property(nonatomic, copy) void(^blueToothDisConnectBlock)(void);
//蓝牙设备返回数据回调
@property(nonatomic, copy) void(^blueToothResponseBlock)(NSData *data);
//是否需要蓝牙使用提示
@property (nonatomic, assign) BOOL needBlueTip;

-(void)initBlueTooth;           //初始化蓝牙
-(void)startSearch;             //开始搜索设备
-(void)stopSearch;              //停止搜索设备
-(void)cancelConnection;        //断开连接
-(void)writeDataIntoDevice:(NSString *)dataStr needBlueToothResponse:(BOOL)needResponse;  //写入数据 (是否需要蓝牙底层回复，升级的时候不需要回复)
-(void)connectPeripheral:(CBPeripheral *)peripheral; //连接设备
-(BOOL)getBlueToothOpenState; //获取蓝牙当前是否打开

/**
 * @brief 准确获取APP蓝牙授权状态 首次获取时会有延迟 初始化完成后需要等到回调managerDidUpdateState后再去取值才是准确的
 * @return void
 */
- (void)requestAuthorizationState:(BlueToothManagerGetAuthorizationStateCallBack)completed;
-(BOOL)isBlueToothUnauthorized;//获取蓝牙当权限是否打开

/**
 * @brief 获取手机蓝牙开关状态
 * 首次初始化后获取状态需要等到回调managerDidUpdateState后再去取值才是准确的
 */
- (void)requestPhoneState:(BlueToothManagerGetPhoneStateCallBack)completed;


- (void)jf_reqBluetoothStateCompletion:(void (^)(JFManagerAuthorization authState, JFManagerState switchState))competion;

//MARK: 获取APP的蓝牙开关授权状态 （除了iOS13.0版本 其他都不会触发蓝牙使用授权提示）-2:受限制 -1:未确定  0:关 1:开
- (int)appBlueToothState;
@end

NS_ASSUME_NONNULL_END
