//
//  XMAlarmPeriodDetailController.h
//  XWorld
//
//  Created by dinglin on 2017/3/20.
//  Copyright © 2017年 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMAlarmPeriodModel.h"


@interface XMAlarmPeriodDetailController : UIViewController
@property (nonatomic, copy) void (^backRefreshBlock)(void);
@property (nonatomic) XMAlarmPeriodModel *alarmPeriod;
@end
