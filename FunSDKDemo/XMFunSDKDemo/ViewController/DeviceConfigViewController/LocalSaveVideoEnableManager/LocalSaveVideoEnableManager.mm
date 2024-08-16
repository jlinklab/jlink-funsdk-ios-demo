//
//  LocalSaveVideoEnableManager.m
//   
//
//  Created by Megatron on 2022/8/8.
//  Copyright © 2022 xiongmaitech. All rights reserved.
//

#import "LocalSaveVideoEnableManager.h"
#import "FunSDK/FunSDK.h"

@interface LocalSaveVideoEnableManager ()

@property (nonatomic,strong) NSMutableDictionary *dicConfig;

@end
@implementation LocalSaveVideoEnableManager

//MARK: 请求本地录像是否保存配置
- (void)requestLocalSaveVideoEnableDevice:(NSString *)devID completed:(GetLocalSaveVideoEnableCallBack)completion{
    self.devID = devID;
    self.getLocalSaveVideoEnableCallBack = completion;
    
    FUN_DevGetConfig_Json(self.msgHandle, self.devID.UTF8String, "NetWork.SetEnableVideo", 1024);
}

//MARK: 保存本地录像是否保存配置
- (void)saveCompleted:(SetLocalSaveVideoEnableCallBack)completion{
    self.setLocalSaveVideoEnableCallBack = completion;
    
    NSDictionary* jsonDic1 = @{@"Name":@"NetWork.SetEnableVideo",@"NetWork.SetEnableVideo":self.dicConfig};
    NSError *error;
    NSData *jsonData1 = [NSJSONSerialization dataWithJSONObject:jsonDic1 options:NSJSONWritingPrettyPrinted error:&error];
    NSString *pCfgBufString1 = [[NSString alloc] initWithData:jsonData1 encoding:NSUTF8StringEncoding];

    FUN_DevSetConfig_Json(self.msgHandle, self.devID.UTF8String, "NetWork.SetEnableVideo", [pCfgBufString1 UTF8String], int(strlen([pCfgBufString1 UTF8String]) + 1));
}

//MARK: 获取配置回调
- (void)getConfigResult:(int)result{
    if (self.getLocalSaveVideoEnableCallBack) {
        self.getLocalSaveVideoEnableCallBack(result);
        self.getLocalSaveVideoEnableCallBack = nil;
    }
}

//MARK: 保存配置回调
- (void)setConfigResult:(int)result{
    if (self.setLocalSaveVideoEnableCallBack) {
        self.setLocalSaveVideoEnableCallBack(result);
        self.setLocalSaveVideoEnableCallBack = nil;
    }
}

//MARK: 获取是否开启本地录像
- (BOOL)getLocalVdeioEnable{
    BOOL enable = NO;
    if (self.dicConfig && [self.dicConfig isKindOfClass:[NSDictionary class]]) {
        enable = [[self.dicConfig objectForKey:@"Enable"] boolValue];
    }
    
    return enable;
}

//MARK: 设置是否开启本地录像
- (void)setLocalVideoEnable:(BOOL)enable{
    if (self.dicConfig && [self.dicConfig isKindOfClass:[NSDictionary class]]) {
        [self.dicConfig setObject:[NSNumber numberWithBool:enable] forKey:@"Enable"];
    }
}

//MARK: - FunSDKCallBack
- (void)baseOnFunSDKResult:(MsgContent *)msg{
    switch (msg->id) {
        case EMSG_DEV_GET_CONFIG_JSON:{
            if (msg->param1 >= 0) {
                if (msg->pObject == NULL) {
                    [self getConfigResult:-1];
                    return;
                }
                NSData *retJsonData = [NSData dataWithBytes:msg->pObject length:strlen(msg->pObject)];
                
                NSError *error;
                NSDictionary *retDic = [NSJSONSerialization JSONObjectWithData:retJsonData options:NSJSONReadingMutableLeaves error:&error];
                if (!retDic) {
                    [self getConfigResult:-1];
                    return;
                }
                
                self.dicConfig = [[retDic objectForKey:@"NetWork.SetEnableVideo"] mutableCopy];
                
                if (self.dicConfig && [self.dicConfig isKindOfClass:[NSDictionary class]]) {
                    [self getConfigResult:msg->param1];
                }else{
                    [self getConfigResult:-1];
                }
            }else{
                [self getConfigResult:msg->param1];
            }
        }
            break;
        case EMSG_DEV_SET_CONFIG_JSON:{
            [self setConfigResult:msg->param1];
        }
            break;
            default:
            break;
    }
}

@end
