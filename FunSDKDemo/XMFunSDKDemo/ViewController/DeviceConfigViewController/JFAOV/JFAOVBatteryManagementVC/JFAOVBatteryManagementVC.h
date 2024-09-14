//
//  JFAOVBatteryManagementVC.h
//   iCSee
//
//  Created by Megatron on 2024/4/25.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///AOV电池管理VC
@interface JFAOVBatteryManagementVC : UIViewController

@property (nonatomic,copy) NSString *devID;
///是否支持低功耗设备唤醒和预览时长
@property (nonatomic,assign) BOOL supportLowPowerWorkTime;
///是否是非AOV设备 非AOV设备只有供电方式和电量
@property (nonatomic,assign) BOOL notAOVDevice;

@end

NS_ASSUME_NONNULL_END
