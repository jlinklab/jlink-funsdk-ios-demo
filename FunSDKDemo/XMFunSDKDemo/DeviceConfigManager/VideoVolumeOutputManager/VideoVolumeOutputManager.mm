//
//  VideoVolumeOutputManager.m
//   
//
//  Created by Tony Stark on 2021/7/22.
//  Copyright © 2021 xiongmaitech. All rights reserved.
//

#import "VideoVolumeOutputManager.h"
#import <FunSDK/FunSDK.h>

@interface VideoVolumeOutputManager ()

@property (nonatomic,strong) NSMutableArray *arrayCfg;

@end
@implementation VideoVolumeOutputManager

//MARK: 获取音量输出
- (void)getVideoVolumeOutput:(NSString *)devID channel:(int)channel completed:(GetVideoVolumeOutputCallBack)completion{
    self.devID = devID;
    self.channelNumber = channel;
    self.getVideoVolumeOutputCallBack = completion;
    
    FUN_DevGetConfig_Json(self.msgHandle, self.devID.UTF8String, "fVideo.Volume", 1024,self.channelNumber);
}

//MARK: 设置音量输出
- (void)setVideoVolumeOutputCompleted:(SetVideoVolumeOutputCallBack)completion{
    self.setVideoVolumeOutputCallBack = completion;
    
    if (!self.arrayCfg || !self.cfgName) {
        [self sendSetResult:-1];
        return;
    }
    
    NSDictionary* jsonDic = @{@"Name":self.cfgName,self.cfgName:self.arrayCfg};
     
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *pCfgBufString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    FUN_DevSetConfig_Json(self.msgHandle, self.devID.UTF8String, self.cfgName.UTF8String,[pCfgBufString UTF8String], (int)(strlen([pCfgBufString UTF8String]) + 1), self.channelNumber);
}

//MARK: 获取左声道音量
- (int)getLeftVolume{
    NSDictionary *dic = [self.arrayCfg objectAtIndex:0];
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        return [[dic objectForKey:@"LeftVolume"] intValue];
    }
    
    return 0;
}

//MARK: 设置左声道音量
- (void)setLeftVolume:(int)volume{
    NSMutableDictionary *dic = [[self.arrayCfg objectAtIndex:0] mutableCopy];
    if (dic && [dic isKindOfClass:[NSMutableDictionary class]]) {
        [dic setObject:[NSNumber numberWithInt:volume] forKey:@"LeftVolume"];
        [self.arrayCfg replaceObjectAtIndex:0 withObject:dic];
    }
}

//MARK: 获取右声道音量
- (int)getRightVolume{
    NSDictionary *dic = [self.arrayCfg objectAtIndex:0];
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        return [[dic objectForKey:@"RightVolume"] intValue];
    }
    
    return 0;
}

//MARK: 设置右声道音量
- (void)setRightVolume:(int)volume{
    NSMutableDictionary *dic = [[self.arrayCfg objectAtIndex:0] mutableCopy];
    if (dic && [dic isKindOfClass:[NSMutableDictionary class]]) {
        [dic setObject:[NSNumber numberWithInt:volume] forKey:@"RightVolume"];
        [self.arrayCfg replaceObjectAtIndex:0 withObject:dic];
    }
}

- (void)sendGetResult:(int)result{
    if (self.getVideoVolumeOutputCallBack) {
        self.getVideoVolumeOutputCallBack(result,self.channelNumber);
    }
}

- (void)sendSetResult:(int)result{
    if (self.setVideoVolumeOutputCallBack) {
        self.setVideoVolumeOutputCallBack(result,self.channelNumber);
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
                    self.arrayCfg = [dicCfg mutableCopy];
                    [self sendGetResult:msg->param1];
                }else{
                    [self sendGetResult:-1];
                }
            }else{
                [self sendGetResult:msg->param1];
            }
        }
            break;
        case EMSG_DEV_SET_CONFIG_JSON:
        {
            [self sendSetResult:msg->param1];
        }
            break;
        default:
            break;
    }
}

@end
