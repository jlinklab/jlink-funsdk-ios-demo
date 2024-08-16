//
//  HumanDetectManager.m
//  XWorld_General
//
//  Created by Megatron on 2019/6/18.
//  Copyright © 2019 xiongmaitech. All rights reserved.
//

#import "HumanDetectManager.h"
#import <FunSDK/FunSDK.h>

@interface HumanDetectManager ()

@property (nonatomic,strong) NSMutableDictionary *humanDetectionDic;

@end

@implementation HumanDetectManager

- (instancetype)init{
    self = [super init];
    if (self) {
        self.msgHandle = FUN_RegWnd((__bridge void*)self);
    }
    
    return self;
}

- (void)listenOperationCallBack:(HumanDetectManagerCallBack)callBack{
    self.callBack = callBack;
}

//MARK: 获取配置
- (void)request{
    int channelNum = 0;
    FUN_DevGetConfig_Json(self.msgHandle, [self.devID UTF8String], "Detect.HumanDetection", 0,channelNum);
}

//MARK: 获取配置
- (void)request:(GetHumanDetectCallBack)callBack{
    self.getHumanDetectCallBack = callBack;
    
    int channelNum = 0;
    FUN_DevGetConfig_Json(self.msgHandle, [self.devID UTF8String], "Detect.HumanDetection", 0,channelNum);
}

//MARK: 保存配置
- (void)saveConfig:(SaveHumanDetectCallBack)callBack{
    self.saveHumanDetectCallBack = callBack;
    
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self.humanDetectionDic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *strValues = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    int channelNum = 0;
    FUN_DevSetConfig_Json(self.msgHandle, [self.devID UTF8String],"Detect.HumanDetection",[strValues UTF8String] ,(int)[strValues length]+1,channelNum);
}

//MARK: 获取人形检测是否开启
- (BOOL)getHumanDetectEnable{
    return [[self.humanDetectionDic objectForKey:@"Enable"] boolValue];
}

- (void)setHumanDetectEnable:(BOOL)enable{
    [self.humanDetectionDic setObject:[NSNumber numberWithBool:enable] forKey:@"Enable"];
}

//MARK: 显示踪迹
- (BOOL)getShowTraceEnabled{
    return [[self.humanDetectionDic objectForKey:@"ShowTrack"] boolValue];
}

- (void)setShowTraceEnable:(BOOL)enable{
    [self.humanDetectionDic setObject:[NSNumber numberWithBool:enable] forKey:@"ShowTrack"];
}

//MARK: - OnFunSDKResult
- (void)baseOnFunSDKResult:(MsgContent *)msg{
    if (msg->id == EMSG_DEV_GET_CONFIG_JSON ) {
        [self.humanDetectionDic removeAllObjects];
        if (msg->param1 < 0) {
            
        }else{
            if (msg->pObject == NULL) {
                if (self.callBack) {
                    self.callBack(nil, -110);
                }
                
                if (self.getHumanDetectCallBack) {
                    self.getHumanDetectCallBack(-110);
                }
                return;
            }
            NSData *data = [[[NSString alloc]initWithUTF8String:msg->pObject] dataUsingEncoding:NSUTF8StringEncoding];
            if ( data == nil ){
                if (self.callBack) {
                    self.callBack(nil, -110);
                }
                
                if (self.getHumanDetectCallBack) {
                    self.getHumanDetectCallBack(-110);
                }
                return;
            }
            NSDictionary *appData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if ( appData == nil) {
            }
            
            NSString* strConfigName = [appData valueForKey:@"Name"];
            NSDictionary *dic = [appData objectForKey:strConfigName];
            if (dic && [dic isKindOfClass:[NSDictionary class]]) {
                self.humanDetectionDic = [dic mutableCopy];
            }
        }
        
        if (self.callBack) {
            self.callBack(nil, msg->param1);
        }
        
        if (self.getHumanDetectCallBack) {
            self.getHumanDetectCallBack(msg->param1);
        }
    }else if (msg->id == EMSG_DEV_SET_CONFIG_JSON){
        if (self.saveHumanDetectCallBack) {
            self.saveHumanDetectCallBack(msg->param1);
        }
    }
}

- (NSMutableDictionary *)humanDetectionDic{
    if (!_humanDetectionDic) {
        _humanDetectionDic = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    
    return _humanDetectionDic;
}

- (void)dealloc{
    FUN_UnRegWnd(self.msgHandle);
    self.msgHandle = -1;
}

@end
