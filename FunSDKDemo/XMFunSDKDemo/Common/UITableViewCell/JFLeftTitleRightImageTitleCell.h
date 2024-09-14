//
//  JFLeftTitleRightImageTitleCell.h
//   iCSee
//
//  Created by Megatron on 2024/4/25.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DoorBellBatteryStateView.h"

typedef NS_ENUM(NSInteger,JFLeftTitleRightImageTitleCellStyle) {
    JFLeftTitleRightImageTitleCell_Default,
    JFLeftTitleRightImageTitleCell_BatteryState,
};
NS_ASSUME_NONNULL_BEGIN

@interface JFLeftTitleRightImageTitleCell : UITableViewCell

@property (nonatomic,strong) UILabel *lbTitle;
@property (nonatomic,strong) UIImageView *imgView;
@property (nonatomic,strong) UILabel *lbRight;
@property (nonatomic,strong) UIView *bottomLine;
///分割线高度 同上
@property (nonatomic,assign) CGFloat bottomLineHeight;
///电池状态视图
@property (nonatomic,strong) DoorBellBatteryStateView *batteryStateView;
///当前cell的显示模式
@property (nonatomic,assign) JFLeftTitleRightImageTitleCellStyle curStyle;

- (void)showImageView:(BOOL)show size:(CGSize)size maxRightTitleWidth:(CGFloat)rightWidth;

@end

NS_ASSUME_NONNULL_END
