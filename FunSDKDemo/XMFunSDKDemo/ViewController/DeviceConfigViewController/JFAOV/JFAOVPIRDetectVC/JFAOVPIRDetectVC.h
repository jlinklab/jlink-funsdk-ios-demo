//
//  JFAOVPIRDetectVC.h
//   iCSee
//
//  Created by Megatron on 2024/4/29.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///AOVPIR侦测VC
@interface JFAOVPIRDetectVC : UIViewController

@property (nonatomic,copy) NSString *devID;
///是否支持PIR灵敏度设置
@property (nonatomic,assign) BOOL ifSupportPIRSensitive;

@end

NS_ASSUME_NONNULL_END
