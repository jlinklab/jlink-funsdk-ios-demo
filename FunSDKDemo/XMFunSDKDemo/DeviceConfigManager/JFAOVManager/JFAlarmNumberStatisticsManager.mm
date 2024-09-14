//
//  JFAlarmNumberStatisticsManager.m
//   iCSee
//
//  Created by Megatron on 2024/5/20.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import "JFAlarmNumberStatisticsManager.h"
#import <FunSDK/FunSDK.h>
#import "FunSDK/Fun_AS.h"
#import "NSString+Utils.h"

@implementation JFAlarmNumberStatisticsManager

///@brief 请求开始时间和结束时间之内 某个设备 某些报警类型的报警数目
///@param devID 设备序列号
///@param channel 通道
///@param startTime 开始时间
///@param endTime 结束时间
///@param events 报警类型 "events":["appEventHumanDetectAlarm"],   ///< 查询报警类型【可选】
- (void)requestAlarmNumberWithDeviceID:(NSString *)devID channel:(int)channel startTime:(NSString *)startTime endTime:(NSString *)endTime eventS:(NSArray *)events label:(NSArray *)label completed:(GetAlarmNumberCallBack)completion{
    self.devID = devID;
    self.channelNumber = channel;
    self.getAlarmNumberCallBack = completion;
    
    if (!devID || !startTime || !endTime) {
        if (self.getAlarmNumberCallBack) {
            self.getAlarmNumberCallBack(-1);
        }
        return;
    }
    
    NSMutableDictionary *dicList = [NSMutableDictionary dictionaryWithCapacity:0];
    if (!label) {
        label = @[];
    }
    [dicList setObject:devID forKey:@"sn"];
    [dicList setObject:@"or" forKey:@"lf"];///<【可选】针对报警标签的过滤方式，and为与判断，or为或判断，不传则默认为and，传则只允许值为and和or
    [dicList setObject:@"or" forKey:@"fttp"];///<【可选】仅当event与label过滤方式同时使用时起作用，不传则默认为and方式（即与判断），传则只允许值为and和or（即或判断），此字段针对于event与label的过滤规则
    if (label.count > 0) {
        [dicList setObject:label forKey:@"labels"];///<【可选】报警标签，即ai检测类型
    }
    if (channel >= 0) {
        [dicList setObject:[NSNumber numberWithInt:channel] forKey:@"ch"];
    }
    if (events.count > 0) {
        [dicList setObject:events forKey:@"events"];
    }
    
    NSDictionary *dicReq = @{@"msg":@"get_storage_count", ///< 接口标识
                             @"timeout": @(16000),
                             @"st" :startTime, ///< 开始时间 格式必须为年-月-日 时:分:秒
                             @"et" :endTime, ///< 结束时间 格式必须为年-月-日 时:分:秒
                             @"type" :@"MSG", ///< 查询消息类型 消息为MSG，视频为VIDEO
                             @"snlist": @[dicList]};
    NSString *strReq = [NSString convertToJSONData:dicReq];
    
    AS_GetStorageInfoCount(self.msgHandle, strReq.UTF8String);
}

//MARK: - OnFunSDKResult
- (void)baseOnFunSDKResult:(MsgContent *)msg{
    switch (msg->id) {
        case EMSG_AS_GET_STORAGE_INFO_COUNT:
        {
            if (msg->param1 < 0) {
                if (self.getAlarmNumberCallBack) {
                    self.getAlarmNumberCallBack(msg->param1);
                }
            }else{
                if (msg->szStr == NULL) {
                    if (self.getAlarmNumberCallBack) {
                        self.getAlarmNumberCallBack(-1);
                    }
                    return;
                }
                
                NSString *jsonStr = OCSTR(msg->szStr);
                NSDictionary *dic = [NSString dictionaryWithJsonString:jsonStr];
                NSArray *arrayList = JFSafeDictionary(dic, @"dt");
                if (arrayList.count > 0) {
                    NSArray *numberList = JFSafeDictionary([arrayList objectAtIndex:0], @"numlist");
                    if ([numberList isKindOfClass:[NSArray class]]) {
                        int count = 0;
                        for (int i = 0; i < numberList.count; i++) {
                            NSDictionary *dicNumList = [numberList objectAtIndex:i];
                            NSNumber *num = JFSafeDictionary(dicNumList, @"count");
                            if (num) {
                                count = count + [num intValue];
                            }
                        }
                        self.arrayAlarm = [[NSArray alloc] initWithArray:numberList];
                        self.alarmNumber = count;
                        if (self.getAlarmNumberCallBack) {
                            self.getAlarmNumberCallBack(msg->param1);
                        }
                        return;
                    }
                }
                
                if (self.getAlarmNumberCallBack) {
                    self.getAlarmNumberCallBack(-1);
                }
            }
        }
            break;
        default:
            break;
    }
}

@end
