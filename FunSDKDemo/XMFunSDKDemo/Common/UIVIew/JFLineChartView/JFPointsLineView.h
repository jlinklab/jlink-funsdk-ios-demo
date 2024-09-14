//
//  JFPointsLineView.h
//   iCSee
//
//  Created by Megatron on 2024/4/30.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JFPointsLineView : UIView

///数据点 每个点对应的是当前视图宽高的百分比
@property (nonatomic,strong) NSMutableArray *points;
///坐标轴颜色
@property (nonatomic,strong) UIColor *axisColor;
///折线线条颜色
@property (nonatomic,strong) UIColor *lineColor;
///折线线条宽度
@property (nonatomic,assign) CGFloat lineWidth;
///渐变开始颜色
@property (nonatomic,strong) UIColor *gradientStartColor;
///渐变结束颜色
@property (nonatomic,strong) UIColor *gradientEndColor;
///x轴的最大值
@property (nonatomic,assign) CGFloat maxValueX;
///y轴的最大值
@property (nonatomic,assign) CGFloat maxValueY;
///y轴需要的虚线条数
@property (nonatomic,assign) int yAxisLineNumbers;

- (void)updateLine;

@end

NS_ASSUME_NONNULL_END
