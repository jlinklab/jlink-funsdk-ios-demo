//
//  JFSegment.h
//   iCSee
//
//  Created by Megatron on 2023/6/2.
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JFSegmentDelegate <NSObject>

- (void)segmentSelectedIndexChanged:(int)index;

@end
NS_ASSUME_NONNULL_BEGIN

@interface JFSegment : UIView

@property (nonatomic,weak) id<JFSegmentDelegate>delegate;
//MARK: 是否可以切换
@property (nonatomic,assign) BOOL enableSwitch;
//MARK: 当前选中的序号
@property (nonatomic,assign) int selectedIndex;
//MARK: 默认字体颜色
@property (nonatomic,strong) UIColor *defaultColor;
//MARK: 选中字体颜色
@property (nonatomic,strong) UIColor *selectedColor;

- (instancetype)initWithItemNames:(NSArray *)names frame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
