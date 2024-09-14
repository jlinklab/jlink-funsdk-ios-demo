//
//  TitleSwitchCell.m
//  XWorld
//
//  Created by DingLin on 17/1/7.
//  Copyright © 2017年 xiongmaitech. All rights reserved.
//

#import "TitleSwitchCell.h"
#import <Masonry/Masonry.h>
#import "UIColor+Util.h"

@interface TitleSwitchCell ()

@property (nonatomic,assign) BOOL ifFilletMode;

@end

@implementation TitleSwitchCell


-(UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont systemFontOfSize:cTableViewFilletTitleFont];
        _titleLabel.numberOfLines = 0;

//        _titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightLight];
        _titleLabel.text = @"Title";
    }
    return _titleLabel;
}

- (UILabel *)lbDetail {
    if (!_lbDetail) {
        _lbDetail = [[UILabel alloc] init];
        _lbDetail.textColor = [UIColor blackColor];
        _lbDetail.text = @"";
        _lbDetail.font = [UIFont systemFontOfSize:cTableViewFilletSubTitleFont];
        _lbDetail.textColor = [UIColor lightGrayColor];
        _lbDetail.numberOfLines = 0;
    }
    
    return _lbDetail;
}

-(XMUISwitch *)toggleSwitch {
    if (!_toggleSwitch) {
        _toggleSwitch = [[XMUISwitch alloc] init];
        _toggleSwitch.onTintColor = NormalFontColor;
        
        [_toggleSwitch addTarget:self action:@selector(toggleSwitchStateChanged:) forControlEvents:UIControlEventValueChanged];
    }

    return _toggleSwitch;
}

- (UIView *)bottomLine{
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = cTableViewFilletUnderLineColor;
    }
    
    return _bottomLine;
}
- (UIImageView *)leftIcon{
    if (!_leftIcon) {
        _leftIcon = [[UIImageView alloc] init];
    }
    
    return _leftIcon;
}
-(void)toggleSwitchStateChanged:(UISwitch *) sender{

    if (self.toggleSwitchStateChangedAction) {
        self.toggleSwitchStateChangedAction(sender.on);
    }

    if (self.SwitchStateChanged) {
        self.SwitchStateChanged(sender.on, self.row, self.section);
    }
}



-(void)makeUI {

    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentView addSubview:self.leftIcon];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.lbDetail];
    [self.contentView addSubview:self.toggleSwitch];
    [self.toggleSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-20);
        make.centerY.equalTo(self.contentView);
        make.width.equalTo(@60);
        make.height.equalTo(@30);
    }];
    
    [self.leftIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(20);
        make.width.mas_equalTo(0);
        make.height.mas_equalTo(30);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftIcon.mas_right).mas_offset(20);
        make.right.mas_equalTo(self.toggleSwitch.mas_left).mas_offset(-5);
        make.centerY.equalTo(self.contentView);
    }];

    [self.lbDetail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom);
        make.left.equalTo(self.titleLabel);
        make.right.equalTo(self.contentView).mas_offset(-80);
    }];
}

//MARK: 进入圆角模式
- (void)enterFilletMode{
    self.ifFilletMode = YES;
    self.titleLabel.textColor = cTableViewFilletTitleColor;
    self.lbDetail.textColor = cTableViewFilletSubTitleColor;
    self.titleLabel.font = [UIFont systemFontOfSize:cTableViewFilletTitleFont];
    self.bottomLine.backgroundColor = cTableViewFilletUnderLineColor;
    self.leftIcon.hidden = YES;
    [self.toggleSwitch mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-(cTableViewFilletLFBorder + self.titleLeftBorder + self.adjustSwitchBorder));
        make.centerY.equalTo(self.contentView);
        make.width.equalTo(@60);
        make.height.equalTo(@30);
    }];
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(cTableViewFilletLFBorder + self.titleLeftBorder);
        make.right.mas_equalTo(self.contentView).offset(-(cTableViewFilletLFBorder + self.titleLeftBorder + 51 + 5));
        if (!self.autoAdjustAllTitleHeight){
            make.centerY.equalTo(self.contentView);
        }else{
            make.top.equalTo(self).mas_offset(15);
        }
    }];
    
    if (self.autoAdjustAllTitleHeight){
        [self.lbDetail mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).mas_offset(5);
            make.left.equalTo(self.titleLabel);
            make.right.mas_equalTo(self.toggleSwitch.mas_left).mas_offset(-5);
        }];
    }else{
        [self.lbDetail mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom);
            make.left.equalTo(self.titleLabel);
            make.right.equalTo(self.contentView).mas_offset(-80);
        }];
    }
    
    [self.contentView addSubview:self.bottomLine];
    [self.bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.right.equalTo(self);
        make.left.equalTo(self);
        make.height.equalTo(@0.5);
    }];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

//MARK: 是否半透明显示
- (void)makeSubtransparent:(BOOL)subtransparent{
    if (subtransparent){
        self.backgroundColor = UIColor.clearColor;
        self.titleLabel.textColor = UIColor.whiteColor;
        self.lbDetail.textColor = UIColor.whiteColor;
        self.bottomLine.backgroundColor = UIColor.whiteColor;
    }else{
        self.backgroundColor = UIColor.whiteColor;
        self.titleLabel.textColor = cTableViewFilletTitleColor;
        self.lbDetail.textColor = cTableViewFilletSubTitleColor;
        self.bottomLine.backgroundColor = cTableViewFilletUnderLineColor;
    }
}

- (void)subTitleVisible:(BOOL)visible ContentRich:(BOOL)rich{
    self.lbDetail.numberOfLines = 0;
    
    float border = 20;
    if (self.ifFilletMode) {
        border = cTableViewFilletLFBorder;
    }
    if (visible) {
        CGFloat offset = 7.5;
        if(rich){
            offset = 15;
            self.lbDetail.numberOfLines = 0;
        }
        
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(border + self.titleLeftBorder);
            make.right.mas_equalTo(self.toggleSwitch.mas_left).mas_offset(-5);
            if (!self.autoAdjustAllTitleHeight){
                make.centerY.equalTo(self.contentView).mas_offset(-offset);
            }else{
                make.top.equalTo(self).mas_offset(15);
            }
            
        }];
    }else{
        self.lbDetail.text = @"";
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(border + self.titleLeftBorder);
            make.right.mas_equalTo(self.toggleSwitch.mas_left).mas_offset(-5);
            make.centerY.equalTo(self.contentView);
        }];
    }
}

- (void)showLeftIconAndTitle {
    self.leftIcon.hidden = NO;
    [self.leftIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(30);
        make.centerY.equalTo(self.contentView);
    }];
     
    
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftIcon.mas_right).mas_offset(10);
//        make.right.mas_equalTo(self.toggleSwitch.mas_left).mas_offset(-5);
        make.centerY.equalTo(self.contentView);
    }];
    [self.toggleSwitch mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.centerY.equalTo(self.contentView);
         
    }];
    
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.titleLeftBorder = 0;
        self.bottomLineLeftBorder = 0;
        self.adjustSwitchBorder = 0;
        
        [self makeUI];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)setLeftEdgeInset:(CGFloat)leftEdgeInset {
    
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(leftEdgeInset);
    }];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
