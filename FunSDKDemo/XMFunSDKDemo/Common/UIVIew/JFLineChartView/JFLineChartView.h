//
//  JFLineChartView.h
//   iCSee
//
//  Created by Megatron on 2024/4/30.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JFPointsLineView.h"

NS_ASSUME_NONNULL_BEGIN

///线性统计图
@interface JFLineChartView : UIView

///统计图名称
@property (nonatomic,strong) UILabel *lbTitle;
///统计图x轴右侧单位
@property (nonatomic,strong) UILabel *lbRightTitleX;
///统计图内容
@property (nonatomic,strong) JFPointsLineView *lineView;
///y轴显示的标题数组
@property (nonatomic,strong) NSMutableArray *yNames;
///x抽显示的标题数组
@property (nonatomic,strong) NSMutableArray *xNames;

- (void)updateXYNames:(NSMutableArray *)xNames yNames:(NSMutableArray *)yNames;

@end

NS_ASSUME_NONNULL_END
