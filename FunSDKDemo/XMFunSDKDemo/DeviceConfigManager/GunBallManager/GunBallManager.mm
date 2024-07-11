//
//  GunBallManager.m
//   iCSee
//
//  Created by Megatron on 2023/4/12.
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import "GunBallManager.h"
#import <FunSDK/FunSDK.h>
#import "NSString+Utils.h"
#import "NSDictionary+Extension.h"

static NSString *const kPTZGunBallLocate = @"Ptz.GunBallLocate";

@interface GunBallManager ()

@property (nonatomic,assign) int msgHandle;
@property (nonatomic,copy) NSString *devID;
@property (nonatomic,strong) NSMutableArray *arrayCfg;

@end
@implementation GunBallManager

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

//MARK: 获取枪球联动配置
- (void)requestGunBallLocate:(NSString *)devID completed:(GetGunBallLocateCallBack)completion{
    self.devID = devID;
    self.getGunBallLocateCallBack = completion;
    
    NSString *cfgName = kPTZGunBallLocate;
    NSDictionary *dic = @{@"Name":cfgName,@"SessionID":@"0x0000000001"};
    NSString *str = [NSString convertToJSONData:dic];
    int size = [NSString getCharArraySize:str];
    char cfg[size];
    memcpy(cfg, [str cStringUsingEncoding:NSUTF8StringEncoding], 2*[str length]);
    
    FUN_DevCmdGeneral(self.msgHandle, self.devID.UTF8String, 1042, cfgName.UTF8String, -1, 15000, cfg, (int)strlen(cfg) + 1, -1, 1042);
}

- (BOOL)gunBallLocateEnable{
    NSDictionary *dic = [self.arrayCfg objectAtIndex:0];
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        NSNumber *number = [dic objectForKey:@"Enable"];
        if (number) {
            return [number boolValue];
        }
    }
    
    return NO;
}

- (void)setGunBallLocateEnable:(BOOL)enable{
    NSMutableDictionary *dic = [[self.arrayCfg objectAtIndex:0] mutableCopy];
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        [dic setObject:[NSNumber numberWithBool:enable] forKey:@"Enable"];
        [self.arrayCfg replaceObjectAtIndex:0 withObject:dic];
    }
}

/**
 * @brief 保存枪球联动配置
 * @param completion SetGunBallLocateCallBack
 * @return void
 */
- (void)requestSaveGunBallLocateCompleted:(SetGunBallLocateCallBack)completion{
    self.setGunBallLocateCallBack = completion;
    if (!self.arrayCfg) {
        [self sendSetGunBallLocateResult:-1];
        return;
    }
    NSString *cfgName = kPTZGunBallLocate;
    NSDictionary *dic = @{@"Name":cfgName,@"SessionID":@"0x0000000001",cfgName:self.arrayCfg};
    NSString *str = [NSString convertToJSONData:dic];
    int size = [NSString getCharArraySize:str];
    char cfg[size];
    memcpy(cfg, [str cStringUsingEncoding:NSUTF8StringEncoding], 2*[str length]);
    
    FUN_DevCmdGeneral(self.msgHandle, self.devID.UTF8String, 1040, cfgName.UTF8String, -1, 15000, cfg, (int)strlen(cfg) + 1, -1, 1040);
}

- (void)sendGetGunBallLocateResult:(int)result{
    if (self.getGunBallLocateCallBack) {
        self.getGunBallLocateCallBack(result);
    }
}

- (void)sendSetGunBallLocateResult:(int)result{
    if (self.setGunBallLocateCallBack) {
        self.setGunBallLocateCallBack(result);
    }
}

-(void)OnFunSDKResult:(NSNumber *) pParam{
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    switch (msg->id) {
        case EMSG_DEV_CMD_EN:
        {
            if (msg->seq == 1042) {
                if (msg->param1 >= 0) {
                    NSDictionary *jsonDic = [NSDictionary dictionaryFromData:msg->pObject];
                    if (jsonDic && [jsonDic isKindOfClass:[NSDictionary class]]) {
                        NSArray *arrayInfo = [jsonDic objectForKey:kPTZGunBallLocate];
                        if (arrayInfo && [arrayInfo isKindOfClass:[NSArray class]]) {
                            self.arrayCfg = [arrayInfo mutableCopy];
                            [self sendGetGunBallLocateResult:1];
                            return;
                        }
                    }
                }
                
                [self sendGetGunBallLocateResult:-1];
            }else if (msg->seq == 1040){
                [self sendSetGunBallLocateResult:msg->param1];
            }
        }
            break;
        default:
            break;
    }
}

@end
