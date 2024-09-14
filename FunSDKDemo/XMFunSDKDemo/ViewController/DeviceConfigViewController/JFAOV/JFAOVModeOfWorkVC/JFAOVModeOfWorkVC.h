//
//  JFAOVModeOfWorkVC.h
//   iCSee
//
//  Created by Megatron on 2024/4/24.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DevAovWorkModeManager.h"

NS_ASSUME_NONNULL_BEGIN

///AOV工作模式VC
@interface JFAOVModeOfWorkVC : UIViewController

@property (nonatomic,copy) NSString *devID;
///工作模式管理器
@property (nonatomic,weak) DevAovWorkModeManager *workModeManager;
@property (nonatomic, assign) BOOL supportDoubleLightBoxCamera;//支持双光
@property (nonatomic, assign) BOOL supportAovAlarmHold;//支持aov 报警间隔
@property (nonatomic, assign) BOOL supportAovWorkModeIndieControl;//支持aov新工作模式

@end

NS_ASSUME_NONNULL_END
