//
//  XMAlarmPeriodModel.h
//  XWorld
//
//  Created by dinglin on 2017/3/21.
//  Copyright © 2017年 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMAlarmPeriodModel : NSObject
@property (nonatomic, copy) NSString *startTime;
@property (nonatomic, copy) NSString *endTime;
@property (nonatomic, assign) BOOL isValid;
@property (nonatomic, assign) NSInteger weekBit;
@end
