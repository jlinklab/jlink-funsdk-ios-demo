//
//  LowPowerRecordConfigManager.h
//  FunSDKDemo
//
//  Created by plf on 2024/6/25.
//  Copyright © 2024 plf. All rights reserved.
//

#import "FunSDKBaseObject.h"

typedef void(^GetLowPowerRecordConfigResult)(NSDictionary *dic);
typedef void(^SetLowPowerRecordConfigResult)(int result);

@interface LowPowerRecordConfigManager : FunSDKBaseObject

@property (nonatomic,copy) GetLowPowerRecordConfigResult getLowPowerRecordConfigResult;
@property (nonatomic,copy) SetLowPowerRecordConfigResult setLowPowerRecordConfigResult;

//MARK: 获取低功耗录像配置
- (void)getLowPowerRecordConfig:(GetLowPowerRecordConfigResult)completion;
//MARK: 设置低功耗录像配置
- (void)setLowPowerRecordConfig:(BOOL)openState completed:(SetLowPowerRecordConfigResult)completion;
@end
