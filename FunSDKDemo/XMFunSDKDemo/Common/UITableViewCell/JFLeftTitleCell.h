//
//  JFLeftTitleCell.h
//   iCSee
//
//  Created by Megatron on 2024/3/16.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JFLeftTitleCell : UITableViewCell

@property (nonatomic, strong) UILabel *lbTitle;
/// 左侧额外偏移
@property (nonatomic, assign) CGFloat leftOffset;
/// 底部分割线
@property (nonatomic,strong) UIView *underLine;

@end

NS_ASSUME_NONNULL_END
