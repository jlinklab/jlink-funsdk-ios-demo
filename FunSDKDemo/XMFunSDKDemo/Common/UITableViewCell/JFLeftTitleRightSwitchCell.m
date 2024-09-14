//
//  JFLeftTitleRightSwitchCell.m
//   iCSee
//
//  Created by Megatron on 2024/4/29.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import "JFLeftTitleRightSwitchCell.h"

@implementation JFLeftTitleRightSwitchCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.lbTitle];
        [self.contentView addSubview:self.lbSubTitle];
        [self.contentView addSubview:self.rightSwitch];
        [self.contentView addSubview:self.underLine];
        
        _style = JFLeftTitleRightSwitchCellStyle_None;
        self.style = JFLeftTitleRightSwitchCellStyle_Title;
    }
    
    return self;
}

- (void)setStyle:(JFLeftTitleRightSwitchCellStyle)style{
    if (_style != style) {
        _style = style;
        
        [self updateUI];
    }
}

- (void)updateUI{
    [self.rightSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).mas_offset(-cTableViewFilletContentLRBorder);
        make.width.equalTo(@60);
        make.height.equalTo(@30);
        make.centerY.equalTo(self.contentView);
    }];
    [self.underLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView);
        make.height.equalTo(@0.5);
        make.bottom.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
    }];
    if (self.style == JFLeftTitleRightSwitchCellStyle_Title) {//只有标题
        [self.lbTitle mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).mas_offset(cTableViewFilletContentLRBorder);
            make.centerY.equalTo(self.contentView);
            make.right.equalTo(self.rightSwitch.mas_left).mas_offset(-5);
        }];
        [self.lbSubTitle mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).mas_offset(cTableViewFilletContentLRBorder);
            make.height.equalTo(@0);
            make.right.equalTo(self.lbTitle);
            make.top.equalTo(self.lbTitle.mas_bottom);
        }];
    }else if (self.style == JFLeftTitleRightSwitchCellStyle_SubTitle_Title) {//包含子标题
        [self.lbTitle mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).mas_offset(cTableViewFilletContentLRBorder);
            make.top.equalTo(self.contentView).mas_offset(cTableViewFilletContentLRBorder);
            make.right.equalTo(self.rightSwitch.mas_left).mas_offset(-5);
        }];
        [self.lbSubTitle mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).mas_offset(cTableViewFilletContentLRBorder);
            make.right.equalTo(self.lbTitle);
            make.top.equalTo(self.lbTitle.mas_bottom);
        }];
    }
}

- (void)rightSwitchValueChanged:(UISwitch *)sender{
    if (self.RightSwitchValueChanged) {
        self.RightSwitchValueChanged(sender.on);
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

-(UISwitch *)rightSwitch {
    if (!_rightSwitch) {
        _rightSwitch = [[UISwitch alloc] init];
        _rightSwitch.onTintColor = [UIColor redColor];
        _rightSwitch.onTintColor = NormalFontColor;
        [_rightSwitch addTarget:self action:@selector(rightSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    return _rightSwitch;
}

- (UIView *)underLine{
    if (!_underLine) {
        _underLine = [[UIView alloc] init];
        _underLine.backgroundColor  = cTableViewFilletUnderLineColor;
    }
    
    return _underLine;
}

@end
