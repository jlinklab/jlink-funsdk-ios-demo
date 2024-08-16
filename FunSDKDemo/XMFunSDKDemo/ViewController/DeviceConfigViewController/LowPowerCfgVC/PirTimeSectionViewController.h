//
//  PirTimeSectionViewController.h
//   
//
//  Created by 杨翔 on 2022/5/20.
//  Copyright © 2022 xiongmaitech. All rights reserved.
//

#import "FunSDKBaseViewController.h"

@class PirAlarmManager;

@interface PirTimeSectionViewController : FunSDKBaseViewController

//PIR报警数据源
@property (nonatomic,strong) PirAlarmManager *pirAlarmManager;

@property (nonatomic, copy) void(^PIRAlarmTimeSection)(PirAlarmManager *manager);

@end

