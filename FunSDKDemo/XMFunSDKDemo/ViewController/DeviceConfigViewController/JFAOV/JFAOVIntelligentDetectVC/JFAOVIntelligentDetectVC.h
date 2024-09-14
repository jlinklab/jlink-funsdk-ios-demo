//
//  JFAOVIntelligentDetectVC.h
//   iCSee
//
//  Created by Megatron on 2024/4/29.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///AOV智能侦测VC
@interface JFAOVIntelligentDetectVC : UIViewController

@property (nonatomic,copy) NSString *devID;
///AOV多算法组合, 支持人车
@property (nonatomic, assign) BOOL iMultiAlgoCombinePed;

@end

NS_ASSUME_NONNULL_END
