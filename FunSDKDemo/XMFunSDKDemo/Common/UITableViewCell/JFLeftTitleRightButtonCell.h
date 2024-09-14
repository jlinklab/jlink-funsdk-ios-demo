//
//  JFLeftTitleRightButtonCell.h
//   iCSee
//
//  Created by Megatron on 2024/3/16.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,JFLeftTitleRightButtonCellStyle) {
    /// 无内容
    JFLeftTitleRightButtonCellStyle_None,
    /// 只有标题
    JFLeftTitleRightButtonCellStyle_Title,
    /// 标题和子标题都显示
    JFLeftTitleRightButtonCellStyle_SubTitle,
};

NS_ASSUME_NONNULL_BEGIN

@interface JFLeftTitleRightButtonCell : UITableViewCell

@property (nonatomic, strong) UILabel *lbTitle;
@property (nonatomic, strong) UILabel *lbSubTitle;
@property (nonatomic, strong) UIButton *btnRight;
/// 底部分割线
@property (nonatomic,strong) UIView *underLine;

/// 当前cell的显示模式
@property (nonatomic, assign) JFLeftTitleRightButtonCellStyle style;

@end

NS_ASSUME_NONNULL_END
