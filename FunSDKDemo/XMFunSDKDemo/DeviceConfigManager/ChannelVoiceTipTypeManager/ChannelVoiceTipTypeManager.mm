//
//  ChannelVoiceTipTypeManager.m
//   
//
//  Created by Tony Stark on 2021/7/22.
//  Copyright © 2021 xiongmaitech. All rights reserved.
//

#import "ChannelVoiceTipTypeManager.h"
#import <FunSDK/FunSDK.h>

@interface ChannelVoiceTipTypeManager ()

@property (nonatomic,strong) NSMutableDictionary *dicCfg;

@end
@implementation ChannelVoiceTipTypeManager

//MARK: 获取声音列表
- (void)getChannelVoiceTipType:(NSString *)devID channel:(int)channel completed:(GetChannelVoiceTipTypeCallBack)completion{
    self.devID = devID;
    self.channelNumber = channel;
    self.getChannelVoiceTipTypeCallBack = completion;
    
    FUN_DevGetConfig_Json(self.msgHandle, self.devID.UTF8String, "Ability.VoiceTipType", 1024,self.channelNumber);
}

//MARK: 设置警戒声音列表
- (void)setChannelVoiceTipType:(int)type completed:(SetChannelVoiceTipTypeCallBack)completion{
    self.setChannelVoiceTipTypeCallBack = completion;
}

//MARK: 获取警戒声音列表
- (NSArray *)getVoiceTypeList{
    NSMutableArray *VoiceTip = [[self.dicCfg objectForKey:@"VoiceTip"] mutableCopy];
    if (VoiceTip && [VoiceTip isKindOfClass:[NSMutableArray class]]) {
        [VoiceTip sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
            int voiceEnum1 = [[obj1 objectForKey:@"VoiceEnum"] intValue];
            int voiceEnum2 = [[obj2 objectForKey:@"VoiceEnum"] intValue];
            if (voiceEnum1 <= voiceEnum2) {
                return NSOrderedAscending;
            }else{
                return NSOrderedDescending;
            }
        }];
    
        return VoiceTip;
    }
    
    return @[];
}

- (void)sendGetResult:(int)result{
    if (self.getChannelVoiceTipTypeCallBack) {
        self.getChannelVoiceTipTypeCallBack(result,self.channelNumber);
    }
}

- (void)sendSetResult:(int)result{
    if (self.setChannelVoiceTipTypeCallBack) {
        self.setChannelVoiceTipTypeCallBack(result,self.channelNumber);
    }
}

//MARK: SDKCallBack
- (void)baseOnFunSDKResult:(MsgContent *)msg{
    switch (msg->id) {
        case EMSG_DEV_GET_CONFIG_JSON:
        {
            if (msg->param1 >= 0) {
                if (msg->pObject == NULL) {
                    [self sendGetResult:-1];
                    return;
                }
                NSData *jsonData = [NSData dataWithBytes:msg->pObject length:strlen(msg->pObject)];
                NSError *error;
                NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
                if(error){
                    [self sendGetResult:-1];
                    return;
                }
                
                self.cfgName = OCSTR(msg->szStr);
                if (self.channelNumber >= 0) {
                    self.cfgName = [NSString stringWithFormat:@"%@.[%i]",self.cfgName,self.channelNumber];
                }
                NSDictionary *dicCfg = [jsonDic objectForKey:self.cfgName];
                if (dicCfg && ![dicCfg isKindOfClass:[NSNull class]]) {
                    self.dicCfg = [dicCfg mutableCopy];
                    [self sendGetResult:msg->param1];
                }else{
                    [self sendGetResult:-1];
                }
            }else{
                [self sendGetResult:msg->param1];
            }
        }
            break;
        default:
            break;
    }
}

@end
