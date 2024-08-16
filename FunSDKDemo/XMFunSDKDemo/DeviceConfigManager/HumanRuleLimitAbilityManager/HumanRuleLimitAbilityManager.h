//
//  HumanRuleLimitAbilityManager.h
//  XWorld_General
//
//  Created by Tony Stark on 2020/7/22.
//  Copyright © 2020 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FunSDKBaseObject.h"

typedef void(^GetConfigResult)(int result);
typedef void(^SetConfigResult)(int result);

/*
 人行检测能力集
 */

@interface HumanRuleLimitAbilityManager : FunSDKBaseObject

@property (nonatomic,copy) NSString *devID;

@property (nonatomic,copy) GetConfigResult getConfigResult;
@property (nonatomic,copy) SetConfigResult setConfigResult;

//区域方向
@property (nonatomic, strong) NSMutableArray* areaDirectArray;
//区域形状(一个数组  里面值多少就是支持集中类型   比如：@[3，4，5],就是支持四边形，五边形和六边形)
@property (nonatomic, strong) NSMutableArray* areaLineArray;

//线性方向
@property (nonatomic, strong) NSMutableArray* lineDirectArray;

- (void)getConfig:(GetConfigResult)callBack;

//- (void)setConfig:(SetConfigResult)callBack;

//MARK: 获取是否支持踪迹显示
- (BOOL)supportShowTrack;
//MARK: 获取是否支持警戒线
- (BOOL)supportLine;
//MARK: 获取是否支持警戒区域
- (BOOL)supportArea;

@end
