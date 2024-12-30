//
//  BlueToothToolManager.h
//  JLink
//
//  Created by 吴江波 on 2022/2/28.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BlueToothManager.h"
#import "JFNetPairingTranscation.h"


#define StringFormat(dataType,data) [NSString stringWithFormat:dataType, data]

NS_ASSUME_NONNULL_BEGIN
/* ************************************************ 音量 ************************************************ */
typedef NS_ENUM(NSInteger, JLinkDoorLockSound) {
    JLinkDoorLockSound_Unknow = -1,                 // 未知
    JLinkDoorLockSound_Lowest = 1,                  // 低
    JLinkDoorLockSound_Lower = 2,                   // 较低
    JLinkDoorLockSound_Middle = 4,                  // 中
    JLinkDoorLockSound_Higher = 6,                  // 较高
    JLinkDoorLockSound_Highest = 8,                 // 高
};
/* ************************************************ 固件升级类型 ************************************************ */
typedef NS_ENUM(NSInteger, JLinkDoorLockUpgradeType) {
    JLinkDoorLockUpgrade_Unknow = -1,               // 未知
    JLinkDoorLockUpgrade_ota = 81,                  // 主控
    JLinkDoorLockUpgrade_static = 82,               // static(配置)
    JLinkDoorLockUpgrade_ble = 83,                  // 蓝牙模组
    JLinkDoorLockUpgrade_motor = 84,                // 电机板
};

#pragma mark 手机开锁命令类型
typedef NS_ENUM(NSInteger, JLinkDoorLockOpenCloseCmdType) {
    JLinkDoorLockOpenCloseCmdType_Unknow = -1,                 // 未知
    JLinkDoorLockOpenCloseCmdType_Remote = 0,                  // 远程开锁
    JLinkDoorLockOpenCloseCmdType_Bluetooth = 1,                   // 蓝牙开锁
    JLinkDoorLockOpenCloseCmdType_Voice = 2,                  // 语音开锁
};

#pragma mark 设备状态
typedef NS_ENUM(NSInteger, JLinkDoorLockDevState) {
    JLinkDoorLockState_Sleep = 0,                  // 睡眠
    JLinkDoorLockState_WakeUp = 1,                 // 唤醒
};

@interface BlueToothToolManager : NSObject

@property (nonatomic,strong) BlueToothManager *blueToothManager;
@property(nonatomic,assign) BOOL isShowBluetoothTip;
@property(nonatomic, strong) NSMutableDictionary *devDic;
@property(nonatomic, copy) NSString *currentPid;
@property(nonatomic, assign) int currentMTU;//单次传输最大字节数
@property(nonatomic, copy) NSString *currentConnectDevId;
@property(nonatomic, copy) NSString *currentConnectMac;
@property(nonatomic, assign) BOOL needLog;//是否需要打印
@property(nonatomic, assign) BOOL needRetryConnect;//是否需要重连
@property(nonatomic, copy) NSString *currentBlueToothVersion;//当前配网设备的蓝牙协议版本
@property (nonatomic,assign) BOOL isGoConnect;                  //判断是否去连接
#pragma mark - 蓝牙状态变化回调（是否需要提示）
@property(nonatomic, copy) void(^blueToothStateBlock)(BOOL isShowBluetoothTip);
#pragma mark - 搜索发现当前连接设备回调
@property(nonatomic, copy) void(^foundCurrentConnectDevice)(void);
#pragma mark - 搜索发现设备回调
@property(nonatomic, copy) void(^blueToothFoundDevice)(NSString *pid,NSString *name,NSString *mac,NSString *sn,CBPeripheral *peripheral,NSDictionary *advertisementDic,NSString *version);

#pragma mark - 超时机制
#pragma mark - 操作开始
-(void)startSendDataWithTimeout:(int)timeout;
#pragma mark - 操作完成
-(void)sendDataComplete;
#pragma mark - 搜索超时
@property(nonatomic, copy) void(^searchTimeout)(void);
#pragma mark - 连接超时
@property(nonatomic, copy) void(^connectTimeout)(void);
#pragma mark - 发送超时
@property(nonatomic, copy) void(^sendTimeout)(void);
#pragma mark - 连接超过1分钟回调
@property(nonatomic, copy) void(^connectRetainTimeout)(void);

#pragma mark - 连接设备成功回调
@property(nonatomic, copy) void(^blueToothConnectSuccessBlock)(void);
#pragma mark - 连接设备成功回调
@property(nonatomic, copy) void(^blueConnectSuccessBlock)(void);
#pragma mark - 连接设备失败回调
@property(nonatomic, copy) void(^blueToothConnectFailedBlock)(NSError *error);
#pragma mark - 连接设备断开回调
@property(nonatomic, copy) void(^blueToothDisConnectBlock)(void);
#pragma mark - 蓝牙设备返回数据（不管成功失败）
@property(nonatomic, copy) void(^blueToothResponse)(void);
#pragma mark - 蓝牙设备返回数据回调
@property(nonatomic, copy) void(^blueToothResponseSuccessBlock)(NSString *userName,NSString *password,NSString *sn,NSString *ip,NSString *mac,NSString *token,BOOL result);
#pragma mark - 蓝牙设备返回数据回调
@property(nonatomic, copy) void(^blueToothResponseDataSuccessBlock)(NSString *responseStr);
#pragma mark - 蓝牙设备返回数据回调
@property(nonatomic, copy) void(^responseSuccessBlock)(NSString *responseStr);
#pragma mark - 蓝牙设备返回数据回调(带类型)
@property(nonatomic, copy) void(^blueToothResponseDataWithTypeSuccessBlock)(NSString *responseStr,NSString *responseType);
#pragma mark - 蓝牙设备激活失败
@property(nonatomic, copy) void(^blueToothResponseActiveFailedBlock)(void);
#pragma mark - 蓝牙设备未激活
@property(nonatomic, copy) void(^blueToothResponseNotActiveBlock)(void);
#pragma mark - 蓝牙设备配网失败
@property(nonatomic, copy) void(^blueToothResponseFailedBlock)(JFNetPairingTranscation *resultTransaction);
#pragma mark - 配网成功后app响应包
-(void)sendAPPResponse:(BOOL)addDeviceSuccess;
#pragma mark - 蓝牙设备状态上报
@property(nonatomic, copy) void(^blueToothDevStateChangeBlock)(JLinkDoorLockDevState state);
#pragma mark - 初始化蓝牙，蓝牙打开则开始搜索设备
-(void)initBlueTooth;
#pragma mark - 开始搜索设备
-(void)startSearch;
-(void)startSearchWithTimeOut:(int)timeout;
#pragma mark - 停止搜索设备
-(void)stopSearch;
#pragma mark - 判断设备是否可连接
-(BOOL)canConnectPeripheral:(NSString *)data;
#pragma mark - 开始连接设备 mac(或者序列号)+pid 发现无法连接则先搜索设备
-(void)connectBlueToothDeviceWithMac:(NSString *)mac sn:(NSString *)sn pid:(NSString *)pid timeOut:(int)timeout;
#pragma mark - 开始连接设备 mac(或者序列号)+pid （只负责连接）
-(void)connectPeripheral:(NSString *)mac;
-(void)connectPeripheral:(NSString *)mac timeOut:(int)timeout;
#pragma mark - 断开连接
-(void)cancelConnection;
#pragma mark - 开始配网
-(void)startAddBlueToothDevice:(NSString *)ssid password:(NSString *)password mac:(NSString *)Mac version:(NSString *)version;
+(instancetype)sharedBlueToothToolManager;
#pragma mark - 获取蓝牙是否打开状态
-(BOOL)getBlueToothOpenState;
#pragma mark - 获取蓝牙权限是否打开
-(BOOL)isBlueToothUnauthorized;
#pragma mark - 获取蓝牙是否连接
-(BOOL)getBlueToothIsConnect;
#pragma mark - 获取设备初始化信息
-(void)getBlueToothIinitializationInfo;

#pragma mark - 蓝牙门锁相关操作
#pragma mark - 开始获取设备序列号
-(void)getBlueDeviceSNWithPid:(NSString *)pid;
#pragma mark - 数据透传（一般用于透传主控的数据）
-(void)sendMessageToModelWithString:(NSString *)cmdData needBlueToothResponse:(BOOL)needResponse;
#pragma mark - 发送离线密钥组
-(void)sendKeyPair:(NSString *)cmdData;
#pragma mark - 将激活结果下发给设备
-(void)sendActiveDeviceResult:(NSString *)result;
#pragma mark - 获取锁时间
-(void)getDeviceTime;
#pragma mark - 同步时间
-(void)sysnDeviceTimeWithBaseYear:(NSString *)baseYear;
#pragma mark - 同步数据
-(void)sysnDeviceDataWithDoorLockType:(int)openType;
#pragma mark - 获取操作记录数据
-(void)sysnDeviceOperateRecorderData;
#pragma mark - 手机开锁
-(void)sendOpenDoorLockCmd:(JLinkDoorLockOpenCloseCmdType)cmdType memberId:(NSInteger)memberId;
#pragma mark - 手机关锁
-(void)sendCloseDoorLockCmd:(JLinkDoorLockOpenCloseCmdType)cmdType memberId:(NSInteger)memberId;
#pragma mark - 超级管理员(设置-基本信息-管理员开锁密码)(dp_data_len为0时表示获取锁内管理员密码,否则长度固定为5，长度为5时表示修改锁内管理员密码，dp_data_value：里要有6~9位密码)
-(void)sendAdminPwdInfo:(NSString *)cmdData;
#pragma mark - 删除门锁
-(void)deleteDoorLock;
#pragma mark - 获取设备版本
-(void)getDeviceVersion;
#pragma mark - 设置开门方向
-(void)setUnlockDirection:(NSString *)cmdData;
#pragma mark - 设置支持反锁
-(void)setSupportLockInside:(NSString *)cmdData;
#pragma mark - 设置常开模式
-(void)setNormalOpenMode:(NSString *)cmdData;
#pragma mark - 设置锁声音
-(void)setDoorLockSound:(JLinkDoorLockSound)sound isOpen:(BOOL)isOpen;
#pragma mark - 设置自动闭锁
-(void)setDoorLockAutoLock:(int)time isOpen:(BOOL)isOpen;
#pragma mark - 获取锁内所有数据
-(void)getAllDeviceSettings;
#pragma mark - 获取电量百分比
-(void)getDeviceBatteryPercentage;
#pragma mark - 升级请求命令
-(void)requestUpgradeDevice:(JLinkDoorLockUpgradeType)upgradeType flieSize:(float)size;
#pragma mark - 发送固件信息头
-(void)sendFirmwareHeader:(NSString *)header type:(JLinkDoorLockUpgradeType)upgradeType;
#pragma mark - 发送固件Body
-(void)sendFirmwareBody:(NSString *)body type:(JLinkDoorLockUpgradeType)upgradeType packageNum:(int)num needBack:(BOOL)needBack;
#pragma mark - 发送检测包
-(void)sendCheckPackageWithType:(JLinkDoorLockUpgradeType)upgradeType;
#pragma mark - 发送重启命令
-(void)sendReStartDeviceWithType:(JLinkDoorLockUpgradeType)upgradeType;
#pragma mark - 发送重启命令(带需要重启的模块数组)
-(void)sendReStartDeviceWithPartitionArray:(NSMutableArray *)array;

//MARK: 获取APP的蓝牙开关授权状态 （除了iOS13.0版本 其他都不会触发蓝牙使用授权提示）-2:受限制 -1:未确定  0:关 1:开
- (int)appBlueToothState;
//MARK: 获取手机蓝牙开关状态
- (void)requestPhoneState:( void(^)(CBManagerState state))completed;
@end

NS_ASSUME_NONNULL_END
