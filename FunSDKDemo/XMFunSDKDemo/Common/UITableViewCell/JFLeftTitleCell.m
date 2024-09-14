//
//  JFLeftTitleCell.m
//   iCSee
//
//  Created by Megatron on 2024/3/16.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import "JFLeftTitleCell.h"

@implementation JFLeftTitleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _leftOffset = 0;
        [self.contentView addSubview:self.lbTitle];
        [self.contentView addSubview:self.underLine];
        [self.lbTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(cTableViewFilletContentLRBorder+self.leftOffset);
            make.centerY.equalTo(self.contentView);
            make.right.equalTo(self.contentView).mas_offset(-cTableViewFilletContentLRBorder);
        }];
        [self.underLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView);
            make.height.equalTo(@0.5);
            make.bottom.equalTo(self.contentView);
            make.right.equalTo(self.contentView);
        }];
    }
    
    return self;
}

- (void)setLeftOffset:(CGFloat)leftOffset{
    if (_leftOffset != leftOffset) {
        _leftOffset = leftOffset;
        
        [self.contentView addSubview:self.lbTitle];
        [self.lbTitle mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(cTableViewFilletContentLRBorder+self.leftOffset);
            make.centerY.equalTo(self.contentView);
            make.right.equalTo(self.contentView).mas_offset(-cTableViewFilletContentLRBorder);
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

- (UIView *)underLine{
    if (!_underLine) {
        _underLine = [[UIView alloc] init];
        _underLine.backgroundColor  = cTableViewFilletUnderLineColor;
    }
    
    return _underLine;
}

@end
