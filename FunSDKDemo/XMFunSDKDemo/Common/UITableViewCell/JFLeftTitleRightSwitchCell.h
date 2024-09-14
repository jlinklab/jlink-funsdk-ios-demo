//
//  JFLeftTitleRightSwitchCell.h
//   iCSee
//
//  Created by Megatron on 2024/4/29.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,JFLeftTitleRightSwitchCellStyle) {
    JFLeftTitleRightSwitchCellStyle_None,
    /// 只有标题
    JFLeftTitleRightSwitchCellStyle_Title,
    /// 标题和子标题都显示
    JFLeftTitleRightSwitchCellStyle_SubTitle_Title,
};

NS_ASSUME_NONNULL_BEGIN

@interface JFLeftTitleRightSwitchCell : UITableViewCell

@property (nonatomic, strong) UILabel *lbTitle;
@property (nonatomic, strong) UILabel *lbSubTitle;
@property (nonatomic, strong) UISwitch *rightSwitch;
///开关状态变化
@property (nonatomic, copy) void (^RightSwitchValueChanged)(BOOL open);
/// 底部分割线
@property (nonatomic,strong) UIView *underLine;
/// 当前cell的显示模式
@property (nonatomic, assign) JFLeftTitleRightSwitchCellStyle style;

@end

NS_ASSUME_NONNULL_END
