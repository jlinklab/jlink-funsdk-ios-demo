//
//  CfgStatusManager.m
//  XWorld_General
//
//  Created by Tony Stark on 25/10/2019.
//  Copyright © 2019 xiongmaitech. All rights reserved.
//

#import "CfgStatusManager.h"

@interface CfgStatusManager ()

@property (nonatomic,strong) NSMutableDictionary *dicCfgStatus;

@end

@implementation CfgStatusManager

- (instancetype)init{
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

//MARK: - EventAction
//MARK: 添加配置
- (void)addCfgName:(NSString *)cfgName{
    [self.dicCfgStatus setObject:@{@"Status":[NSNumber numberWithInt:XMCfgStatus_UnRequest]} forKey:cfgName];
}

//MARK: 修改配置状态 未请求 请求中 请求成功 请求失败
- (void)changeCfgStatus:(XMCfgStatus)status name:(NSString *)cfgName{
    if (status == XMCfgStatus_Success) {
        //NSLog(@"ccyy XMCfgStatus= %@",cfgName);
    }
    
    [self.dicCfgStatus setObject:@{@"Status":[NSNumber numberWithInt:status]} forKey:cfgName];
}

//MARK: 检测所有配置是否请求完成
- (BOOL)checkAllCfgFinishedRequest{
    BOOL ifFinished = YES;
    
    NSArray *array = self.dicCfgStatus.allValues;
    for (NSDictionary *dic in array) {
        if (((XMCfgStatus)[[dic objectForKey:@"Status"] intValue]) == XMCfgStatus_UnRequest) {
            ifFinished = NO;
            break;
        }
    }
    
    return ifFinished;
}

//MARK: 获取某个配置的状态
- (XMCfgStatus)configStatusWithName:(NSString *)cfgName {
    XMCfgStatus status = XMCfgStatus_UnRequest;
    NSNumber *number = JFSafeDictionary([self.dicCfgStatus objectForKey:cfgName], @"Status");
    if (number) {
        status = (XMCfgStatus)[number intValue];
    }
    
    return status;
}

//MARK: 重制所有请求状态
- (void)resetAllCfgStatus{
    NSArray *array = self.dicCfgStatus.allKeys;
    for (int i = 0; i < array.count; i++) {
        
        NSMutableDictionary *dic = [self.dicCfgStatus objectForKey:[array objectAtIndex:i]];
        if ([[dic objectForKey:@"Status"] intValue] == XMCfgStatus_NotSupport) {
            continue;
        }
        
        [self.dicCfgStatus setObject:@{@"Status":[NSNumber numberWithInt:XMCfgStatus_UnRequest]} forKey:[array objectAtIndex:i]];
    }
}

//MARK: - LazyLoad
- (NSMutableDictionary *)dicCfgStatus{
    if (!_dicCfgStatus) {
        _dicCfgStatus = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    
    return _dicCfgStatus;
}

@end
