//
//  JFLeftTitleRightButtonCell.m
//   iCSee
//
//  Created by Megatron on 2024/3/16.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import "JFLeftTitleRightButtonCell.h"

@implementation JFLeftTitleRightButtonCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.lbTitle];
        [self.contentView addSubview:self.lbSubTitle];
        [self.contentView addSubview:self.btnRight];
        [self.contentView addSubview:self.underLine];
        
        _style = JFLeftTitleRightButtonCellStyle_None;
        self.style = JFLeftTitleRightButtonCellStyle_Title;
    }
    
    return self;
}

- (void)setStyle:(JFLeftTitleRightButtonCellStyle)style{
    if (_style != style) {
        _style = style;
        
        [self updateUI];
    }
}

- (void)updateUI{
    [self.btnRight mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).mas_offset(-20);
        make.width.equalTo(@20);
        make.height.equalTo(@20);
        make.centerY.equalTo(self.contentView);
    }];
    [self.underLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView);
        make.height.equalTo(@0.5);
        make.bottom.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
    }];
    if (self.style == JFLeftTitleRightButtonCellStyle_Title) {//只有标题
        [self.lbTitle mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).mas_offset(cTableViewFilletContentLRBorder);
            make.centerY.equalTo(self.contentView);
            make.right.equalTo(self.btnRight.mas_left).mas_offset(-5);
        }];
        [self.lbSubTitle mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).mas_offset(cTableViewFilletContentLRBorder);
            make.height.equalTo(@0);
            make.right.equalTo(self.lbTitle);
            make.top.equalTo(self.lbTitle.mas_bottom);
        }];
    }else if (self.style == JFLeftTitleRightButtonCellStyle_SubTitle) {//包含子标题
        [self.lbTitle mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).mas_offset(cTableViewFilletContentLRBorder);
            make.top.equalTo(self.contentView).mas_offset(cTableViewFilletContentLRBorder);
            make.right.equalTo(self.btnRight.mas_left).mas_offset(-5);
        }];
        [self.lbSubTitle mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).mas_offset(cTableViewFilletContentLRBorder);
            make.right.equalTo(self.lbTitle);
            make.top.equalTo(self.lbTitle.mas_bottom);
        }];
    }
}

//MARK: - LazyLoad
- (UILabel *)lbTitle{
    if (!_lbTitle) {
        _lbTitle = [[UILabel alloc] init];
        _lbTitle.font = JFFont(cTableViewFilletTitleFont);
        _lbTitle.textColor = cTableViewFilletTitleColor;
        _lbTitle.numberOfLines = 0;
    }
    
    return _lbTitle;
}

- (UILabel *)lbSubTitle{
    if (!_lbSubTitle) {
        _lbSubTitle = [[UILabel alloc] init];
        _lbSubTitle.font = JFFont(cTableViewFilletSubTitleFont);
        _lbSubTitle.textColor = cTableViewFilletSubTitleColor;
        _lbSubTitle.numberOfLines = 0;
    }
    
    return _lbSubTitle;
}

- (UIButton *)btnRight{
    if (!_btnRight) {
        _btnRight = [UIButton buttonWithType:UIButtonTypeSystem];
        _btnRight.userInteractionEnabled = NO;
        [_btnRight setBackgroundImage:[UIImage imageNamed:@"SM_check_off"] forState:UIControlStateNormal];
        [_btnRight setBackgroundImage:[UIImage imageNamed:@"SM_check_on"] forState:UIControlStateSelected];
    }
    
    return _btnRight;
}

- (UIView *)underLine{
    if (!_underLine) {
        _underLine = [[UIView alloc] init];
        _underLine.backgroundColor  = cTableViewFilletUnderLineColor;
    }
    
    return _underLine;
}
    
@end
