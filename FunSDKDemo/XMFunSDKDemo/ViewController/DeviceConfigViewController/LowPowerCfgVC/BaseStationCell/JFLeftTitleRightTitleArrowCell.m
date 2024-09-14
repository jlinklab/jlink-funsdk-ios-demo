//
//  JFLeftTitleRightTitleArrowCell.m
//   iCSee
//
//  Created by Megatron on 2023/5/17.
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import "JFLeftTitleRightTitleArrowCell.h"

@interface JFLeftTitleRightTitleArrowCell ()

@end
@implementation JFLeftTitleRightTitleArrowCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        self.extraBorderLeft = 0;
        self.bottomLineHeight = 1;
        [self.contentView addSubview:self.lbRight];
        [self.lbRight mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-cTableViewFilletContentLRBorder);
            make.centerY.equalTo(self.contentView);
        }];
        
        [self.contentView addSubview:self.lbTitle];
        [self.lbTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).mas_offset(cTableViewFilletContentLRBorder);
            make.top.equalTo(self.contentView).mas_offset(10);
            make.right.equalTo(self.lbRight.mas_left);
            make.bottom.equalTo(self.contentView).mas_offset(-10);
        }];
        
        [self.contentView addSubview:self.lbDescription];
        [self.lbDescription mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.lbTitle);
            make.top.equalTo(self.lbTitle.mas_bottom);
            make.right.equalTo(self.lbRight.mas_left);
            make.height.equalTo(@0);
        }];
        
        [self.contentView addSubview:self.imageViewArrow];
        [self.imageViewArrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).mas_offset(-cTableViewFilletContentLRBorder);
            make.centerY.equalTo(self);
            make.width.mas_equalTo(9);
            make.height.equalTo(@12.5);
        }];
        
        [self.contentView addSubview:self.lbRight];
        [self.lbRight mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(@100);
            make.top.equalTo(self);
            make.bottom.equalTo(self);
            make.right.equalTo(self.imageViewArrow.mas_left).mas_offset(-cTableViewFilletTitleAndSubTitleBorder);
        }];
        
        [self.contentView addSubview:self.bottomLine];
        [self.bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self);
            make.right.equalTo(self);
            make.left.equalTo(self);
            make.height.mas_equalTo(self.bottomLineHeight);
        }];
    }
    
    return self;
}

- (void)switchRightValueChanged:(UISwitch *)sender{
    BOOL open = sender.on;
    
    if (self.SwitchValueChanged){
        self.SwitchValueChanged(open);
    }
}

- (void)showTitle:(NSString *)title description:( NSString * _Nullable )description rightTitle:(NSString * _Nullable )rightTitle{
    self.lbTitle.textAlignment = NSTextAlignmentLeft;
    self.imageViewArrow.hidden = NO;
    if (title){
        self.lbTitle.text = title;
    }else{
        self.lbTitle.text = @"";
    }
    
    if (description){
        self.lbDescription.text = description;
    }else{
        self.lbDescription.text = @"";
    }
    
    if (rightTitle){
        self.lbRight.text = rightTitle;
    }else{
        self.lbRight.text = @"";
    }
    
    if (!description || description.length <= 0){
        [self.lbTitle mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).mas_offset(self.extraBorderLeft +  cTableViewFilletContentLRBorder);
            make.top.equalTo(self.contentView).mas_offset(10);
            make.right.equalTo(self.lbRight.mas_left);
            make.bottom.equalTo(self.contentView).mas_offset(-10);
        }];
        
        [self.lbDescription mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.lbTitle);
            make.top.equalTo(self.lbTitle.mas_bottom);
            make.right.equalTo(self.lbRight.mas_left);
            make.height.equalTo(@0);
        }];
    }else{
        [self.lbTitle mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).mas_offset(self.extraBorderLeft + cTableViewFilletContentLRBorder);
            make.top.equalTo(self.contentView).mas_offset(10);
            make.right.equalTo(self.lbRight.mas_left);
        }];
        
        [self.lbDescription mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.lbTitle);
            make.top.equalTo(self.lbTitle.mas_bottom).mas_offset(self.extraBorderLeft + cTableViewFilletTitleAndSubTitleBorder);
            make.right.equalTo(self.lbRight.mas_left);
            make.bottom.equalTo(self.contentView).mas_offset(-10);
        }];
    }
    
    [self.bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.right.equalTo(self);
        make.left.equalTo(self);
        make.height.mas_equalTo(self.bottomLineHeight);
    }];
}
- (void)showOnlyTitle:(NSString *)title {
    self.lbTitle.text = title;
    self.lbTitle.textAlignment = NSTextAlignmentCenter;
    self.lbDescription.text = @"";
    self.lbRight.text = @"";
    self.imageViewArrow.hidden = YES;
    [self.lbTitle mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).mas_offset(0);
        make.top.equalTo(self.contentView).mas_offset(10);
        make.right.equalTo(self.contentView).mas_offset(0);
        make.bottom.equalTo(self.contentView).mas_offset(-10);
    }];
    
    [self.bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.right.equalTo(self);
        make.left.equalTo(self);
        make.height.mas_equalTo(self.bottomLineHeight);
    }];
}
//MARK: - LazyLoad
- (UILabel *)lbTitle{
    if (!_lbTitle){
        _lbTitle = [[UILabel alloc] init];
        _lbTitle.font = [UIFont systemFontOfSize:cTableViewFilletTitleFont];
        _lbTitle.textColor = cTableViewFilletTitleColor;
    }
    
    return _lbTitle;
}

- (UILabel *)lbDescription{
    if (!_lbDescription){
        _lbDescription = [[UILabel alloc] init];
        _lbDescription.font = [UIFont systemFontOfSize:cTableViewFilletSubTitleFont];
        _lbDescription.textColor = cTableViewFilletSubTitleColor;
        _lbDescription.numberOfLines = 0;
    }
    
    return _lbDescription;
}

- (UILabel *)lbRight{
    if (!_lbRight){
        _lbRight = [[UILabel alloc] init];
        _lbRight.font = [UIFont systemFontOfSize:cTableViewFilletSubTitleFont];
        _lbRight.textColor = cTableViewFilletSubTitleColor;
        _lbRight.numberOfLines = 0;
        _lbRight.textAlignment = NSTextAlignmentRight;
    }
    
    return _lbRight;
}

- (UIImageView *)imageViewArrow{
    if (!_imageViewArrow) {
        _imageViewArrow = [[UIImageView alloc] init];
        _imageViewArrow.image = [UIImage imageNamed:@"icon_wbs_arrow_right"];
        _imageViewArrow.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return _imageViewArrow;
}

- (UIView *)bottomLine{
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = cTableViewFilletUnderLineColor;
        _bottomLine.hidden = YES;
    }
    
    return _bottomLine;
}


@end
