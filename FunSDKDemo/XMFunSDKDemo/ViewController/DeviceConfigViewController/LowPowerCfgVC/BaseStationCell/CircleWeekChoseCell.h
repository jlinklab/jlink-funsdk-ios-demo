//
//  CircleWeekChoseCell.h
//   iCSee
//
//  Created by Megatron on 2023/5/17.
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CircleWeekChoseCell : UITableViewCell

@property (nonatomic,copy) void(^ClickWeekIndex)(int index);
@property (nonatomic,strong) UILabel *lbLeft;
//标题偏移左边距
@property (nonatomic,assign) CGFloat titleLeftBorder;

+ (CGFloat)cellHeight;

- (void)updateSelectedState:(NSArray *)state;

@end

NS_ASSUME_NONNULL_END
