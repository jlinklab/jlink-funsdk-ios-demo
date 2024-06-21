//
//  SerialPortManager.h
//  FunSDKDemo
//
//  Created by zhang on 2024/6/20.
//  Copyright © 2024 zhang. All rights reserved.
//
/*
 串口协议接口
 郑重说明：串口协议接口属于通用接口。SDK只做透传。接口参数根据协议，有可能是多种格式，比如字符串数据、16进制数组数据等等，需要用户自己处理发送和接收，demo这里只做了16进制和字符串的示例
 串口协议，设备发送数据给APP时，一条数据有可能分多次返回，因此收到数据后需要判断数据完整性，如当前数据不完整，则需要和后续数据拼接在做完整性判断。
 */

@protocol SerialPortManagerDelegate <NSObject>

@optional
- (void)openSerialResult:(NSInteger)result;
-(void)closeSerialResult:(NSInteger)result;
-(void)sendSerialDataResult:(NSInteger)result;
-(void)deviceBackSerialDataResult:(NSInteger)result;

@end

#import "FunMsgListener.h"

NS_ASSUME_NONNULL_BEGIN

@interface SerialPortManager : FunMsgListener
@property (nonatomic, assign) id <SerialPortManagerDelegate> delegate;

/*
 //打开串口
 serialType 参数是串口数据类型，目前只有0和1
 */
- (void)open:(int)serialType;

- (void)close;

/*
 data 串口数据
 seq  上层传啥，最后回调的seq就是啥
 */
//发送串口消息
- (void)send:(NSString*)data seq:(int)seq;


/*
 读取设备回调的串口数据
 */
- (NSString*)readData;
@end

NS_ASSUME_NONNULL_END
