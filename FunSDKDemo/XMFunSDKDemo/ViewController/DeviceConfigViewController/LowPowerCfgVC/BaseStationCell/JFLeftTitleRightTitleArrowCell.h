//
//  JFLeftTitleRightTitleArrowCell.h
//   iCSee
//
//  Created by Megatron on 2023/5/17.
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JFLeftTitleRightTitleArrowCell : UITableViewCell

@property (nonatomic,copy) void(^SwitchValueChanged)(BOOL open);

@property (nonatomic,strong) UILabel *lbTitle;
@property (nonatomic,strong) UILabel *lbDescription;
@property (nonatomic,strong) UILabel *lbRight;
@property (nonatomic,strong) UIImageView *imageViewArrow;
@property (nonatomic,strong) UIView *bottomLine;
///额外的左侧边距 需要在showTitle之前调用
@property (nonatomic,assign) CGFloat extraBorderLeft;
///分割线高度 同上
@property (nonatomic,assign) CGFloat bottomLineHeight;

- (void)showTitle:(NSString *)title description:( NSString * _Nullable )description rightTitle:(NSString * _Nullable )rightTitle;
- (void)showOnlyTitle:(NSString *)title;
@end

NS_ASSUME_NONNULL_END
