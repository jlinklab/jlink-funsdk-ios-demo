//
//  ManuIntelAlarmManager.h
//   
//
//  Created by Tony Stark on 2021/7/28.
//  Copyright © 2021 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FunSDKBaseObject.h"

typedef void(^StartManuIntelAlarmResult)(int result);
typedef void(^StopManuIntelAlarmResult)(int result);
NS_ASSUME_NONNULL_BEGIN

@interface ManuIntelAlarmManager : FunSDKBaseObject

@property (nonatomic,copy) StartManuIntelAlarmResult startManuIntelAlarmResult;
@property (nonatomic,copy) StopManuIntelAlarmResult stopManuIntelAlarmResult;

//MARK: 开启手动警戒
- (void)startManuIntelAlarm:(NSString *)devID completed:(StartManuIntelAlarmResult)completion;
//MARK: 停止手动警戒
- (void)stopManuIntelAlarm:(NSString *)devID completed:(StopManuIntelAlarmResult)completion;

@end

NS_ASSUME_NONNULL_END
