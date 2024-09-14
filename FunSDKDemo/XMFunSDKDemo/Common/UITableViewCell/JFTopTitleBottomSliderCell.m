//
//  JFTopTitleBottomSliderCell.m
//   iCSee
//
//  Created by Megatron on 2024/4/26.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import "JFTopTitleBottomSliderCell.h"

@interface JFTopTitleBottomSliderCell ()

/// 当前容器可用宽度
@property (nonatomic, assign) CGFloat contentWidth;
/// 标题左侧边距
@property (nonatomic, assign) CGFloat titleLeftBorder;
/// 标题右侧边距
@property (nonatomic, assign) CGFloat titleRightBorder;

@end
@implementation JFTopTitleBottomSliderCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        [self.contentView addSubview:self.lbTitle];
        [self.lbTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).mas_offset(cTableViewFilletContentLRBorder);
            make.top.equalTo(self.contentView).mas_offset(cTableViewFilletContentLRBorder);
            make.right.equalTo(self.contentView).mas_offset(-cTableViewFilletContentLRBorder);
        }];
        
        [self.contentView addSubview:self.lbSubTitle];
        [self.lbSubTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.lbTitle);
            make.top.equalTo(self.lbTitle.mas_bottom).mas_offset(2);
            make.right.equalTo(self.contentView).mas_offset(-cTableViewFilletContentLRBorder);
        }];
    }
    
    return self;
}

- (void)resetSubViewsWithContentWidth:(CGFloat)width{
    self.contentWidth = width;
    self.slider.frame = CGRectMake(0, 0, self.contentWidth, 65);
    [self.contentView addSubview:self.slider];
    
    [self.slider mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lbSubTitle.mas_bottom).mas_offset(11);
        make.left.equalTo(self.lbSubTitle);
        make.right.equalTo(self.lbSubTitle);
        make.height.equalTo(@65);
    }];
}

//MARK: - LazyLoad
- (UILabel *)lbTitle{
    if (!_lbTitle){
        _lbTitle = [[UILabel alloc] init];
        _lbTitle.font = [UIFont systemFontOfSize:cTableViewFilletTitleFont];
        _lbTitle.textColor = cTableViewFilletTitleColor;
        _lbTitle.numberOfLines = 0;
    }
    
    return _lbTitle;
}

- (UILabel *)lbSubTitle{
    if (!_lbSubTitle){
        _lbSubTitle = [[UILabel alloc] init];
        _lbSubTitle.font = [UIFont systemFontOfSize:cTableViewFilletSubTitleFont];
        _lbSubTitle.textColor = cTableViewFilletSubTitleColor;
        _lbSubTitle.numberOfLines = 0;
    }
    
    return _lbSubTitle;
}

- (JFNewCustomSliderValueView *)slider{
    if (!_slider) {
        _slider = [[JFNewCustomSliderValueView alloc] initWithFrame:CGRectMake(0, 0, self.contentWidth - self.titleLeftBorder - self.titleRightBorder, 65)];
        _slider.maxValue = 100;
        _slider.minValue = 0;
        _slider.lblLeft.text = @"0%";
        _slider.lblRight.text = @"100%";
    }
    
    return _slider;
}

@end
