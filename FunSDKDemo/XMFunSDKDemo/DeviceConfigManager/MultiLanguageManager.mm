//
//  MultiLanguageManager.m
//   
//
//  Created by Tony Stark on 2021/8/6.
//  Copyright © 2021 xiongmaitech. All rights reserved.
//

#import "MultiLanguageManager.h"
#import <FunSDK/FunSDK.h>

@interface MultiLanguageManager ()

@property (nonatomic,copy) NSString *curDeviceLanguage;

@end
@implementation MultiLanguageManager

//MARK: 获取多语言配置
- (void)getMultiLanguage:(NSString *)devID channel:(int)channel completed:(GetMultiLanguageCallBack)completion{
    self.devID = devID;
    self.channelNumber = channel;
    self.getMultiLanguageCallBack = completion;
    
    FUN_DevCmdGeneral(self.msgHandle, CSTR(self.devID), 1360, "MultiLanguage", 1024, 100000, NULL, 0, 0);
}

//MARK: 保存多语言配置
- (void)setMultiLanguageCompleted:(SetMultiLanguageCallBack)completion{
    self.setMultiLanguageCallBack = completion;
    
    if (self.curDeviceLanguage.length > 0) {
        FUN_DevSetConfig_Json(self.msgHandle, CSTR(self.devID), "General.Location.Language", [self.curDeviceLanguage UTF8String], (int)(strlen([self.curDeviceLanguage UTF8String]) + 1), -1, 10000, 0);
    }else{
        [self sendSetResult:-1];
    }
}

- (void)sendGetResult:(int)result{
    if (self.getMultiLanguageCallBack) {
        self.getMultiLanguageCallBack(result,self.channelNumber);
    }
}

//MARK: 获取设备语言
- (NSString *)getDeviceLanguage{
    return self.curDeviceLanguage;
}

//MARK: 设置设备语言
- (void)setDeviceLanguage:(NSString *)language{
    self.curDeviceLanguage = language;
}

- (void)sendSetResult:(int)result{
    if (self.setMultiLanguageCallBack) {
        self.setMultiLanguageCallBack(result,self.channelNumber);
    }
}

//MARK: SDKCallBack
- (void)baseOnFunSDKResult:(MsgContent *)msg{
    switch (msg->id) {
        case EMSG_DEV_GET_CONFIG_JSON:
        {
            if (msg->pObject != NULL) {
                NSData *jsonData = [NSData dataWithBytes:msg->pObject length:strlen(msg->pObject)];
                NSError *error;
                NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
                self.curDeviceLanguage = jsonDic[@"General.Location.Language"];
                [self sendGetResult:msg->param1];
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
        case EMSG_DEV_CMD_EN:
        {
            if ([OCSTR(msg->szStr) isEqualToString:@"MultiLanguage"]){
                if (msg->param1 >= 0) {
                    if (msg->pObject != NULL) {
                        NSData *jsonData = [NSData dataWithBytes:msg->pObject length:strlen(msg->pObject)];
                        NSError *error;
                        NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
                        if (jsonDic && [jsonDic isKindOfClass:[NSDictionary class]]) {
                            self.languageList = [[jsonDic objectForKey:@"MultiLanguage"] mutableCopy];
                            
                            FUN_DevGetConfig_Json(self.msgHandle, CSTR(self.devID), "General.Location.Language", 0,-1,10000, 0);
                            return;
                        }
                    }
                    [self sendGetResult:-1];
                }else{
                    [self sendGetResult:msg->param1];
                }
            }
        }
            break;
        default:
            break;
    }
}

@end
