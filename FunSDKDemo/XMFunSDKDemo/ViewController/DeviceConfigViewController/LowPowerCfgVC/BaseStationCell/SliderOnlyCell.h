//
//  SliderOnlyCell.h
//   
//
//  Created by Tony Stark on 2021/7/30.
//  Copyright © 2021 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SliderOnlyCell : UITableViewCell

@property (nonatomic,strong) UISlider *slider;

@property (nonatomic,copy) void(^SliderOnlyCellValueChanged)(CGFloat value);

@property (nonatomic,copy) void(^SliderOnlyCellTouchUpInslide)(CGFloat value);

//MARK: 是否半透明显示
- (void)makeSubtransparent:(BOOL)subtransparent;

@end

NS_ASSUME_NONNULL_END
