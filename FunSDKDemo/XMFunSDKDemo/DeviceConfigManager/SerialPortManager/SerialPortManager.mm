//
//  SerialPortManager.m
//  FunSDKDemo
//
//  Created by zhang on 2024/6/20.
//  Copyright © 2024 zhang. All rights reserved.
//

#import "SerialPortManager.h"
#import "FunSDK/FunSDK.h"

@interface SerialPortManager ()
{
    int type;
    NSString *serialString;
    
}
@end

@implementation SerialPortManager

/*
 //打开串口
 serialType 参数是串口数据类型，目前只有0和1
 */
- (void)open:(int)serialType {
    
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    type = serialType;
    FUN_DevOption(self.msgHandle,[channel.deviceMac UTF8String], EDA_DEV_OPEN_TANSPORT_COM,  0,8, type, self.msgHandle,0,"",222);
}

- (void)close{
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    FUN_DevOption(self.msgHandle, [channel.deviceMac UTF8String], EDA_DEV_CLOSE_TANSPORT_COM,NULL, 0,0, type, 0, "",333);
}

/*
 data 串口数据
 seq  上层传啥，最后回调的seq就是啥
 郑重说明：串口数据属于通用接口。接口参数数据根据协议，有可能是多种格式，比如字符串数据、16进制数组数据等等，需要用户自己处理
 */
//发送串口消息
- (void)send:(NSString*)data seq:(int)seq {
    //16进制格式数据发送
    NSData *temp = [self stringToByte:data];
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    const char *str = [data UTF8String];
    FUN_DevOption(self.msgHandle,[channel.deviceMac UTF8String], EDA_DEV_TANSPORT_COM_WRITE,(char *)temp.bytes, temp.length, type, self.msgHandle,0,"", seq);
    
    //字符串格式数据发送：
//    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
//    FUN_DevOption(self.msgHandle,[channel.deviceMac UTF8String], EDA_DEV_TANSPORT_COM_WRITE,(void *)[data UTF8String], data.length, type, self.msgHandle,0,"", seq);
}


/*
 读取设备回调的串口数据
 */
- (NSString*)readData{
    return serialString;
}

/*
 设备回调
 */
- (void)OnFunSDKResult:(NSNumber *) pParam{
    NSInteger data = [pParam integerValue];
    MsgContent *msg = (MsgContent *)data;
    switch (msg->id) {
            //串口命令回调接口
        case EMSG_DEV_OPTION:{
            if (msg->param1 == -11502) {
                [self open:type];
            }
            if (msg->seq == 222) {
                if ([self.delegate respondsToSelector:@selector(openSerialResult:)]) {
                    [self.delegate openSerialResult:msg->param1];
                }
            }else if (msg->seq == 333) {
                if ([self.delegate respondsToSelector:@selector(closeSerialResult:)]) {
                    [self.delegate closeSerialResult:msg->param1];
                }
            }else{
                //发送串口数据回调
                if ([self.delegate respondsToSelector:@selector(sendSerialDataResult:)]) {
                    [self.delegate sendSerialDataResult:msg->param1];
                }
            }
        }
            break;
        case EMSG_DEV_ON_TRANSPORT_COM_DATA: {
            //MARK:APP接收设备串口数据回调，也就是设备发送给APP的数据回调
            //说明：回调数据在msg->pObject中，回调数据的格式和具体的协议有关，这里是取string数据的示例，实际协议数据不一定是string，需要自己取出。另外同一个命令的数据回调，有可能分多次回调，需要自己判断数据是否完整。如果当前接收的数据不完整，则需要拼接数据
            NSString *tmpOption = [NSString stringWithUTF8String:msg->pObject];
            if (tmpOption == nil || tmpOption.length == 0) {
                //回调数据为空
                serialString = @"";
            }
            serialString = tmpOption;
            if ([self.delegate respondsToSelector:@selector(deviceBackSerialDataResult:)]) {
                [self.delegate deviceBackSerialDataResult:msg->param1];
            }
        }
            
            break;
            default:
            break;
    }
}

//工具函数，转16进制，最好单独封装工具类
-(NSData*)stringToByte:(NSString*)string
{
    NSString *hexString=[[string uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([hexString length]%2!=0) {
        return nil;
    }
    Byte tempbyt[1]={0};
    NSMutableData* bytes=[NSMutableData data];
    for(int i=0;i<[hexString length];i++)
    {
        unichar hex_char1 = [hexString characterAtIndex:i]; //两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;    //0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16;  //A 的Ascll - 65
        else
            return nil;
        i++;
        
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); // 0 的Ascll - 48
        else if(hex_char2 >= 'A' && hex_char2 <='F')
            int_ch2 = hex_char2-55;  //A 的Ascll - 65
        else
            return nil;
        
        tempbyt[0] = int_ch1+int_ch2;  ///将转化后的数放入Byte数组里
        [bytes appendBytes:tempbyt length:1];
    }
    return bytes;
    
}

@end
