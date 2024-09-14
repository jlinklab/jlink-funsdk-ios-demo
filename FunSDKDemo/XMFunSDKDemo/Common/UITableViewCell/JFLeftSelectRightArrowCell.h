//
//  JFLeftSelectRightArrowCell.h
//   iCSee
//
//  Created by Megatron on 2024/7/17.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMResizeButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface JFLeftSelectRightArrowCell : UITableViewCell

///左侧边距 默认25
@property (nonatomic,assign) CGFloat leftBorder;
///选择状态按钮
@property (nonatomic,strong) XMResizeButton *btnSelected;
///标题
@property (nonatomic,strong) UILabel *lbTitle;
///箭头
@property (nonatomic,strong) UIImageView *imgViewArrow;
/// 底部分割线
@property (nonatomic,strong) UIView *underLine;
///选中状态变化回调
@property (nonatomic,copy) void(^SelectStateChanged)(BOOL selected);

///更新约束 比如边距等参数发生变化需要调用才能刷新
- (void)updateJFConstraints;

@end

NS_ASSUME_NONNULL_END
