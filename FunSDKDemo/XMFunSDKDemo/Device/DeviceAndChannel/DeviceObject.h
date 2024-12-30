//
//  DeviceObject.h
//  XMEye
//
//  Created by XM on 2018/4/13.
//  Copyright © 2018年 Megatron. All rights reserved.
//
/***
 
设备对象类
 
 *****/
#import "ObjectCoder.h"
#import "ChannelObject.h"

#import "ObSysteminfo.h"
#import "ObSystemFunction.h"

typedef enum device_type {
    DEVICE_TYPE_UnKnow, //没有获取过设备类型
    DEVICE_TYPE_DVR, //普通DVR设备
    DEVICE_TYPE_NVS, ///< NVS设备
    DEVICE_TYPE_IPC, ///< IPC设备
    DEVICE_TYPE_HVR, ///<混合dvr
    DEVICE_TYPE_IVR, ///<智能dvr
    DEVICE_TYPE_MVR,  ///<车载dvr
    DEVICE_TYPE_NR,
} device_type;

@interface DeviceObject : ObjectCoder

@property (nonatomic, copy) NSString *deviceMac; //设备序列号 16位或者20位字母+数字
@property (nonatomic, copy) NSString *deviceName; //设备名称
@property (nonatomic, copy) NSString *loginName; //登录名
@property (nonatomic, copy) NSString *loginPsw; //登录密码
@property (nonatomic, copy) NSString *deviceIp;  //设备的IP
/**  */
@property (nonatomic, assign) BOOL devTokenEnable;
@property (nonatomic) int state;     //在线状态
@property (nonatomic) int nPort;     //端口号
@property (nonatomic) int nType;     //设备类型
@property (nonatomic) int nID;      //扩展

@property (nonatomic) int ret;      //是否是被分享设备 0为未处理 1为已接受 2为拒绝


@property (nonatomic, strong) ObSysteminfo *info; //设备信息
@property (nonatomic, strong) ObSystemFunction *sysFunction; //设备能力级

@property (nonatomic, strong) NSMutableArray *channelArray; //通道数组

@property (nonatomic,assign) int eFunDevStateNotCode;              //其他设备状态 eFunDevStateNotCode 0 未知 1 唤醒 2 睡眠 3 不能被唤醒的休眠 4正在准备休眠
@property (nonatomic,assign) enum device_type deviceType;

@property (nonatomic, assign) int iCodecType;//编解码类型
@property (nonatomic, assign) int iSceneType;//场景
@property (nonatomic, assign) int imageWidth;
@property (nonatomic, assign) int imageHeight;
@property (nonatomic, assign) int centerOffsetY;  //Y轴偏移量
@property (nonatomic, assign) int centerOffsetX;  //X轴偏移量
@property (nonatomic, assign) int imgradius; //半径
@property (nonatomic, assign) BOOL enableEpitomeRecord;

/**设备云台反转配置缓存 key="channel" value="0:0:0" 左往右第一位表示上下 第二位表示左右 第三位表示ModifyCfg */
@property (nonatomic,copy) NSString *sPTZReverseCfg;

//MARK: 设备厂家信息 服务器接口可能会用到
@property (nonatomic,copy) NSString *sPid;

//MARK: PID属性
///是否支持APP裁剪多目效果
@property (nonatomic,copy) NSString *threeScreen;
///是否支持APP端变倍
@property (nonatomic, assign) int iSupportAPPZoomScreen;
///APP端变倍的最大实际倍数
@property (nonatomic, assign) int iAPPZoomScreenMaxNum;
///APP端变倍的最大显示倍数
@property (nonatomic, assign) int iAPPZoomScreenMaxDisplayNum;



///是否为低功耗设备
-(BOOL)getDeviceTypeLowPowerConsumption;

/**缓存的上下反转配置 -1:未缓存 0:关闭 1:开启*/
- (int)PTZUpsideDown:(int)channel;
/**缓存的左右反转配置 -1:未缓存 0:关闭 1:开启*/
- (int)PTZLeftRightReverse:(int)channel;
/**缓存的是否修改配置 -1:未缓存 0:否 1:是*/
- (int)PTZModifyCfgReverse:(int)channel;
/**缓存上下左右反转配置*/
- (void)setPTZUpsideDownValue:(int)valueUD leftRightReverseValue:(int)valueLR modifyCfg:(int)valueModify channel:(int)channel;

//MARK: - 是否蓝牙配网设备
- (BOOL)isMeshBLE;
+ (BOOL)isMeshBLE:(NSString*)pid;

@end
