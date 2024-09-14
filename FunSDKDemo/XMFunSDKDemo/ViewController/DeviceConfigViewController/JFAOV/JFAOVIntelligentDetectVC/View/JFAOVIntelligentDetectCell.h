//
//  JFAOVIntelligentDetectCell.h
//   iCSee
//
//  Created by kevin on 2024/7/15.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JFAOVIntelligentDetectCell : UITableViewCell
@property (nonatomic, strong) UIView *leftView;
@property (nonatomic, strong) UIView *rightView;

@property (nonatomic,strong) UISwitch *leftSwitch;
@property (nonatomic,strong) UISwitch *rightSwitch;

@property (nonatomic, copy) void (^LeftSwitchValueChanged)(BOOL open);
@property (nonatomic, copy) void (^RightSwitchValueChanged)(BOOL open);

@end

NS_ASSUME_NONNULL_END
