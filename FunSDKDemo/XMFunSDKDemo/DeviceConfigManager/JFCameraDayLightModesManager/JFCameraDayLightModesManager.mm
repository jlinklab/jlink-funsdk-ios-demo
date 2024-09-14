//
//  JFCameraDayLightModesManager.m
//   iCSee
//
//  Created by kevin on 2023/11/2.
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import "JFCameraDayLightModesManager.h"
#import <FunSDK/FunSDK.h>
#import "NSString+Utils.h"
#import "NSDictionary+Extension.h"
@interface JFCameraDayLightModesManager ()

@property (nonatomic,assign) int msgHandle;
@property (nonatomic,copy) NSString *devID;
@property (nonatomic,strong) NSMutableArray *arrayCfg;

@end
@implementation JFCameraDayLightModesManager
- (instancetype)init{
    self = [super init];
    if (self) {
        self.msgHandle = FUN_RegWnd((__bridge LP_WND_OBJ)self);
    }

    return self;
}

- (void)dealloc{
    FUN_UnRegWnd(self.msgHandle);
    self.msgHandle = -1;
}

- (void)requestCameraDayLightModesWithDevice:(NSString *)devID channel:(int)channel completed:(GetCameraDayLightModesCallBack)completion {
    self.devID = devID;
    self.channelNumber = channel;
    self.getCameraDayLightModesCallBack = completion;

    NSString *cfgName = @"CameraDayLightModes";
    if (channel >= 0){
       cfgName = [NSString stringWithFormat:@"bypass@CameraDayLightModes.[%i]",channel];
    }
    NSDictionary *dic = @{@"Name":cfgName,@"SessionID":@"0x0000000001"};
    NSString *str = [NSString convertToJSONData:dic];
    int size = [NSString getCharArraySize:str];
    char cfg[size];
    memcpy(cfg, [str cStringUsingEncoding:NSUTF8StringEncoding], 2*[str length]);
    if (channel >= 0){
        FUN_DevCmdGeneral(self.msgHandle, self.devID.UTF8String, 1362, cfgName.UTF8String, -1, 15000, cfg, (int)strlen(cfg) + 1, -1, 1362);
    } else {
        FUN_DevCmdGeneral(self.msgHandle, self.devID.UTF8String, 1360, cfgName.UTF8String, -1, 15000, cfg, (int)strlen(cfg) + 1, -1, 1360);
    }
    
}

- (NSArray *)getLightModes {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (NSDictionary *dic in self.arrayCfg) {
        [arr addObject:[dic objectForKey:@"value"]];
    }
    return arr;
}


//MARK: FunSDK CallBack
- (void)baseOnFunSDKResult:(MsgContent *)msg{
    switch (msg->id) {
        case EMSG_DEV_CMD_EN:
        {
            if (msg->seq == 1360) {
                if (msg->param1 >= 0) {
                    NSDictionary *jsonDic = [NSDictionary dictionaryFromData:msg->pObject];
                    if (jsonDic && [jsonDic isKindOfClass:[NSDictionary class]]) {
                        NSArray *arrayInfo = [jsonDic objectForKey:@"CameraDayLightModes"];
                        if (arrayInfo && [arrayInfo isKindOfClass:[NSArray class]]) {
                            self.arrayCfg = [arrayInfo mutableCopy];
                            [self sendGetDetectCarShapeDetectionResult:msg->param1];
                            return;
                        }
                    }
                }

                [self sendGetDetectCarShapeDetectionResult:msg->param1];
            } else if ( msg->seq == 1362) {
                if (msg->param1 >= 0) {
                    NSDictionary *jsonDic = [NSDictionary dictionaryFromData:msg->pObject];
                    if (jsonDic && [jsonDic isKindOfClass:[NSDictionary class]]) {
                        self.cfgName = OCSTR(msg->szStr);
                        NSString *key = self.cfgName;
                        if (self.channelNumber >= 0) {
                            key = [NSString stringWithFormat:@"%@",self.cfgName];
                        }
                        
                        NSArray *arrayInfo = [jsonDic objectForKey:key];
                        if (arrayInfo && [arrayInfo isKindOfClass:[NSArray class]]) {
                            self.arrayCfg = [arrayInfo mutableCopy];
                            [self sendGetDetectCarShapeDetectionResult:msg->param1];
                            return;
                        }
                    }
                }

                [self sendGetDetectCarShapeDetectionResult:msg->param1];
            }
        }
            break;
        default:
            break;
    }
}
- (void)sendGetDetectCarShapeDetectionResult:(int)result{
    if (self.getCameraDayLightModesCallBack) {
        self.getCameraDayLightModesCallBack(result);
    }
}

 
@end
