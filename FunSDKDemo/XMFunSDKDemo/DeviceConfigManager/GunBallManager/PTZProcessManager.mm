//
//  PTZProcessManager.m
//   
//
//  Created by Megatron on 2022/8/29.
//  Copyright © 2022 xiongmaitech. All rights reserved.
//

#import "PTZProcessManager.h"

@implementation PTZProcessManager


//MARK: 请求云台处理需要的配置(在云台转化前需要获取完成 否则就是按照获取失败处理)
- (void)requestNecessaryConfig:(NSString *)devID channel:(int)channel useCache:(BOOL)useCache{
    /*
     如果是多通道设备 不能直接默认前端就是非消费类 如果是数字通道需要通过透传方式根据能力集和配置判断
     所以不管是单品还是多通道设备都要获取SystemInfo配置
     */
    __weak typeof(self) weakSelf = self;
    //获取SystemInfo配置
    [self requestSystemInfoCfg:devID useCache:useCache completed:^(int result, NSString * _Nonnull devID1, int channel1) {
        [weakSelf getSystemFunctionCallBack:devID channel:channel useCache:useCache];
    }];
}

- (void)getSystemFunctionCallBack:(NSString *)devID channel:(int)channel useCache:(BOOL)useCache{
    /*
     //获取云台配置之前 需要判断设备是传统类还是消费类 单品已经获取到能力集 多通道前端还需要根据能力判断是否获取前端IPC配置
     */
    [self requestUartPTZControlCmdCfg:devID channel:channel useCache:useCache];
}

//MARK: 请求UartPTZControlCmd配置 可配置是否使用缓存
- (void)requestUartPTZControlCmdCfg:(NSString *)devID channel:(int)channel useCache:(BOOL)useCache{
    UartPTZControlCmdManager *manager = [self uartPTZControlCmdManager:devID channel:channel];
    
    //要赋值判断是否是消费类产品
    manager.consumerProduct = ![self traditionalProduct:devID channel:channel];
    //如果使用缓存 判断是否存在缓存
    if (!useCache || ![manager cached]) {
        __weak typeof(self) weakSelf = self;
        //实时获取
        [manager requestGetUartPTZControlCmdConfig:devID channel:channel completed:^(int result,NSString *requestDevID,int requestChannel) {
        }];
    }
}

//MARK: 取出缓存UartPTZControlCmd配置对象
- (UartPTZControlCmdManager *)uartPTZControlCmdManager:(NSString *)devID channel:(int)channel{
    NSString *key = [NSString stringWithFormat:@"%@_%i",devID,channel];

    UartPTZControlCmdManager *manager = [self.dicUartPTZControlCmdManagers objectForKey:key];
    if (!manager) {
        manager = [[UartPTZControlCmdManager alloc] init];
        manager.devID = devID;
        manager.channelNumber = channel;
        [self.dicUartPTZControlCmdManagers setObject:manager forKey:key];
    }
    
    return manager;
}

//MARK: 请求SystemInfo配置
- (void)requestSystemInfoCfg:(NSString *)devID useCache:(BOOL)useCache completed:(void(^)(int result,NSString *devID,int channel))completion{
    NSString *key = [NSString stringWithFormat:@"%@_%i",devID,-1];

    SystemInfoManager *manager = [self.dicDeviceSystemInfoManagers objectForKey:key];
    if (!manager) {
        manager = [[SystemInfoManager alloc] init];
        manager.devID = devID;
        [self.dicDeviceSystemInfoManagers setObject:manager forKey:key];
    }
    
    if (useCache && manager.softWareVersionInfo.length > 0) {
        if (completion) {
            completion(1,devID,-1);
        }
    }else{
        //实时获取
        manager.devID = devID;
        [manager getSystemInfo: devID Completion:^(int result) {
            if (completion) {
                completion(result,devID,-1);
            }
        }];
    }
}


//MARK: 云台方向根据能力集转化
- (PTZ_Direction)convertPTZDrection:(PTZ_Direction)direction devID:(NSString *)devID channel:(int)channel{
    //判断配置是否获取成功
    NSString *key = [NSString stringWithFormat:@"%@_%i",devID,channel];

    UartPTZControlCmdManager *manager = [self.dicUartPTZControlCmdManagers objectForKey:key];
    if (!manager || manager.getConfigState != GetConfigState_Success) {
        //获取UartPTZControlCmd失败 判断是否是传统产品
        
        return [self changeDirectionIfTraditionalProduct:devID channel:channel PTZDrection:direction];
    }else{
        //获取UartPTZControlCmd成功 判断配置参数ModifyCfg
        if ([manager modifyCfg]) {//ModifyCfg == ture
            //根据具体配置判断是否反转
            if (direction == PTZ_Direction_UP || direction == PTZ_Direction_DOWN) {
                if ([manager flipOperation]) {
                    if (direction == PTZ_Direction_UP) {
                        direction = PTZ_Direction_DOWN;
                    }else if (direction == PTZ_Direction_DOWN){
                        direction = PTZ_Direction_UP;
                    }
                }
                
                return direction;
            }else if (direction == PTZ_Direction_LEFT || direction == PTZ_Direction_RIGHT){
                if ([manager mirrorOperation]) {
                    if (direction == PTZ_Direction_LEFT) {
                        direction = PTZ_Direction_RIGHT;
                    }else if (direction == PTZ_Direction_RIGHT){
                        direction = PTZ_Direction_LEFT;
                    }
                }
                
                return direction;
            }
        }else{//ModifyCfg == false
            //判断是否有SupportTraditionalPtzNormalDirect这个能力
            DeviceObject *device = [[DeviceControl getInstance] GetDeviceObjectBySN: devID];
                if (device.sysFunction.supportTraditionalPtzNormalDirect) {
                    //支持走常规命令
                    
                    return direction;
                }else{
                    //不支持 判断是否是传统产品
                    
                    return [self changeDirectionIfTraditionalProduct:devID channel:channel PTZDrection:direction];
                }
        }
    }
    
    return direction;
}

//MARK: 获取失败等情况下 判断是否是传统产品流程
- (PTZ_Direction)changeDirectionIfTraditionalProduct:(NSString *)devID channel:(int)channel PTZDrection:(PTZ_Direction)direction{
    if ([self traditionalProduct:devID channel:channel]) {
        //是传统设备就返回常规命令
        
        return direction;
    }else{
        //非传统设备 只做左右反转
        if (direction == PTZ_Direction_LEFT) {
            direction = PTZ_Direction_RIGHT;
        }else if (direction == PTZ_Direction_RIGHT){
            direction = PTZ_Direction_LEFT;
        }
        
        return direction;
    }
}

/**
 是否是传统设备
 APP判断是否是传统类产品
 符合下面几个条件中的任意一个，则为传统产品：
 A. 有能力级OtherFunction.SupportTraditionalPtzNormalDirect
 B. 没有能力级OtherFunction.SupportConsumerPtzMirrorDirect，并且 没有能力级NetServerFunction.NetWifi，并且 IPC版本号onvif服务端协议为1
 C. 通道数大于1
 */
- (BOOL)traditionalProduct:(NSString *)devID channel:(int)channel{
    DeviceObject *device = [[DeviceControl getInstance] GetDeviceObjectBySN: devID];
    NSString *key = [NSString stringWithFormat:@"%@_%i",devID,channel];
    SystemInfoManager *systemInfoManager = [self.dicDeviceSystemInfoManagers objectForKey:key];
        if (device.sysFunction.supportTraditionalPtzNormalDirect){
            return YES;
        }else if (!device.sysFunction.supportTraditionalPtzNormalDirect && !device.sysFunction.netWifi && [self onvifServerProtocol:systemInfoManager.softWareVersionInfo] == 1) {
            return YES;
        }
    
    return NO;
}

//MARK: 解析onvif服务端协议
- (int)onvifServerProtocol:(NSString *)softWareInfo{
    NSArray *array = [softWareInfo componentsSeparatedByString:@"."];
    if (array.count > 3) {
        //倒数第三个节点对应onvif所在字段
        NSString *content = [array objectAtIndex:(array.count - 3)];
        if (content.length > 4) {
            NSString *onvifServer = [content substringWithRange:NSMakeRange(3, 1)];
            
            return [onvifServer intValue];
        }
    }
    
    return 0;
}

//MARK: - LazyLoad
- (NSMutableDictionary <NSString *,UartPTZControlCmdManager *>*)dicUartPTZControlCmdManagers{
    if (!_dicUartPTZControlCmdManagers) {
        _dicUartPTZControlCmdManagers = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    
    return _dicUartPTZControlCmdManagers;
}

- (NSMutableDictionary *)dicDeviceSystemInfoManagers{
    if (!_dicDeviceSystemInfoManagers) {
        _dicDeviceSystemInfoManagers = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    
    return _dicDeviceSystemInfoManagers;
}

@end
