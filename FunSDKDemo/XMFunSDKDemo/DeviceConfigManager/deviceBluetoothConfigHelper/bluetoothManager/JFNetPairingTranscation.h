//
//  JFNetPairingTranscation.h
//   iCSee
//
//  Created by Megatron on 2024/10/18.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>

/**配网类型定义**/
typedef NS_ENUM(NSInteger,JFNetPairingType) {
    //未设置 默认值
    JFNetPairing_None,
    //蓝牙配网
    JFNetPairing_BlueTooth,
    //Wi-Fi配网
    JFNetPairing_WiFi,
};

NS_ASSUME_NONNULL_BEGIN

/**配网事务**/
@interface JFNetPairingTranscation : NSObject

- (instancetype)initWithType:(JFNetPairingType)type result:(NSString *)result;

/**配网类型**/
@property (nonatomic,assign) JFNetPairingType netPairingType;
/**配网结果 用于判断成功失败或者特殊错误**/
@property (nonatomic,copy) NSString *result;
/**Wi-Fi密码错误是否可以不重启直接发送新的Wi-Fi信息进行配网**/
@property (nonatomic,assign) BOOL passwordErrorNeedRestart;

@end

NS_ASSUME_NONNULL_END
