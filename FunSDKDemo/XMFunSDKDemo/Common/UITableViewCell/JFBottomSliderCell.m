//
//  JFBottomSliderCell.m
//   iCSee
//
//  Created by Megatron on 2024/3/16.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import "JFBottomSliderCell.h"

@interface JFBottomSliderCell ()

/// 左侧顶部标题
@property (nonatomic, strong) UILabel *lbTopLeft;
/// 当前容器可用宽度
@property (nonatomic, assign) CGFloat contentWidth;
/// 标题左侧边距
@property (nonatomic, assign) CGFloat titleLeftBorder;
/// 标题右侧边距
@property (nonatomic, assign) CGFloat titleRightBorder;

@end
@implementation JFBottomSliderCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _underLineLeftBorder = 0;
        _underLineRightBorder = 0;
    }
    
    return self;
}

- (void)resetSubViewsWithContentWidth:(CGFloat)width titleLeftBorder:(CGFloat)titleLeftBorder titleRightBorder:(CGFloat)titleRightBorder{
    self.contentWidth = width;
    self.titleLeftBorder = titleLeftBorder;
    self.titleRightBorder = titleRightBorder;
    self.slider.frame = CGRectMake(0, 0, self.contentWidth - self.titleLeftBorder - self.titleRightBorder, 65);
    [self.contentView addSubview:self.lbTopLeft];
    [self.contentView addSubview:self.slider];
    [self.contentView addSubview:self.underLine];
    
    [self.lbTopLeft mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).mas_offset(self.titleLeftBorder);
        make.right.equalTo(self.contentView).mas_offset(-self.titleRightBorder);
        make.top.equalTo(self.contentView).mas_offset(12);
        make.height.equalTo(@21);
    }];
    [self.slider mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lbTopLeft.mas_bottom).mas_offset(12);
        make.left.equalTo(self.lbTopLeft);
        make.right.equalTo(self.lbTopLeft);
        make.height.equalTo(@65);
    }];
    [self.underLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).mas_offset(self.underLineLeftBorder);
        make.height.equalTo(@0.5);
        make.bottom.equalTo(self.contentView);
        make.right.equalTo(self.contentView).mas_offset(-self.underLineRightBorder);
    }];
}

/// 更新左侧标题
- (void)updateLeftTitle:(NSString *)title{
    self.lbTopLeft.text = title;
}

/// 更新底部分割线的边距
- (void)updateUnderLineBorderLeft:(CGFloat)leftBorder right:(CGFloat)rightBorder{
    BOOL needRelayout = NO;
    if (leftBorder != _underLineLeftBorder) {
        _underLineLeftBorder = leftBorder;
        needRelayout = YES;
    }
    if (rightBorder != _underLineRightBorder) {
        _underLineRightBorder = rightBorder;
        needRelayout = YES;
    }
    
    if (needRelayout) {
        [self.underLine mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).mas_offset(self.underLineLeftBorder);
            make.height.equalTo(@0.5);
            make.bottom.equalTo(self.contentView);
            make.right.equalTo(self.contentView).mas_offset(-self.underLineRightBorder);
        }];
    }
}

//MARK: - LazyLoad
- (UILabel *)lbTopLeft{
    if (!_lbTopLeft) {
        _lbTopLeft = [[UILabel alloc] init];
        _lbTopLeft.font = JFFont(15);
        _lbTopLeft.textColor = JFColor(@"#5A5A5A");
        _lbTopLeft.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    
    return _lbTopLeft;
}

- (JFNewCustomSliderValueView *)slider{
    if (!_slider) {
        _slider = [[JFNewCustomSliderValueView alloc] initWithFrame:CGRectMake(0, 0, self.contentWidth - self.titleLeftBorder - self.titleRightBorder, 65)];
        _slider.maxValue = 10;
        _slider.minValue = 0;
        _slider.lblLeft.text = @"0";
        _slider.lblRight.text = @"10";
    }
    
    return _slider;
}

- (UIView *)underLine{
    if (!_underLine) {
        _underLine = [[UIView alloc] init];
        _underLine.backgroundColor  = cTableViewFilletUnderLineColor;
    }
    
    return _underLine;
}

@end
