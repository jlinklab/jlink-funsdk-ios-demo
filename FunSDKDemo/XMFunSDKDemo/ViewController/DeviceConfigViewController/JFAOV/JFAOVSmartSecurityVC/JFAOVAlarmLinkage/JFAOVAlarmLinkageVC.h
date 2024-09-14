//
//  JFAOVAlarmLinkageVC.h
//   iCSee
//
//  Created by kevin on 2024/4/29.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FunSDKBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface JFAOVAlarmLinkageVC : FunSDKBaseViewController
@property (nonatomic, assign) BOOL iSupportSetVolume;// 报警联动--报警音量
@property (nonatomic, assign) BOOL supportAlarmVoiceTipInterval;//支持报警间隔
@end

NS_ASSUME_NONNULL_END
