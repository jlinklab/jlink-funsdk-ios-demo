//
//  PTZProcessManager.h

//  Created by Megatron on 2022/8/29.
//  Copyright © 2022 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UartPTZControlCmdManager.h"
#import "SystemInfoManager.h"

typedef NS_ENUM(NSInteger,PTZ_Direction){
    PTZ_Direction_UP = 0,               // 上
    PTZ_Direction_DOWN,                 // 下
    PTZ_Direction_LEFT,                 // 左
    PTZ_Direction_RIGHT,                // 右
};

NS_ASSUME_NONNULL_BEGIN

/*
 云台处理逻辑管理者
 解决云台方向和传统的球机方向不一致
 */
@interface PTZProcessManager : NSObject

/**持有的UartPTZControlCmd管理者 对应key是（序列号_通道号）*/
@property (nonatomic,strong) NSMutableDictionary <NSString *,UartPTZControlCmdManager *>*dicUartPTZControlCmdManagers;
/**系统信息管理者 对应key是（序列号_通道号）*/
@property (nonatomic,strong) NSMutableDictionary <NSString *,SystemInfoManager *>*dicDeviceSystemInfoManagers;

//MARK: 请求云台处理需要的配置(在云台转化前需要获取完成 否则就是按照获取失败处理)
- (void)requestNecessaryConfig:(NSString *)devID channel:(int)channel useCache:(BOOL)useCache;
//MARK: 云台方向根据能力集转化
- (PTZ_Direction)convertPTZDrection:(PTZ_Direction)direction devID:(NSString *)devID channel:(int)channel;

@end

NS_ASSUME_NONNULL_END
