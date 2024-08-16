//
//  TitleComboxCell.m
//  XWorld
//
//  Created by DingLin on 17/1/9.
//  Copyright © 2017年 xiongmaitech. All rights reserved.
//

#import "TitleComboBoxCell.h"
#import <Masonry/Masonry.h>

@implementation TitleComboBoxCell

-(UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = cTableViewFilletTitleColor;
        _titleLabel.font = [UIFont systemFontOfSize:cTableViewFilletTitleFont];
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

-(UILabel *)toggleLabel {
    if (!_toggleLabel) {
        _toggleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _toggleLabel.textAlignment = NSTextAlignmentRight;
        _toggleLabel.font = [UIFont systemFontOfSize:cTableViewFilletRightTitleFont];
        _toggleLabel.textColor = cTableViewFilletRightTitleColor;
        _toggleLabel.numberOfLines = 0;
    }
    
    return _toggleLabel;
}

-(UILabel *)lbRight
{
    if (!_lbRight) {
        _lbRight = [[UILabel alloc] init];
        _lbRight.font = [UIFont systemFontOfSize:cTableViewFilletRightTitleFont];
        _lbRight.textColor = cTableViewFilletRightTitleColor;
        _lbRight.hidden = YES;
        _lbRight.numberOfLines = 0;
    }
    
    return _lbRight;
}

-(UIImageView *)accessoryImageView {
    if (!_accessoryImageView) {
        _accessoryImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"icon_wbs_arrow_right"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        _accessoryImageView.contentMode = UIViewContentModeScaleAspectFit;
    }

    return _accessoryImageView;
}

-(UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.contentMode = UIViewContentModeCenter;
    }
    return _iconImageView;
}

-(UIImageView *)imgUserHead {
    if (!_imgUserHead) {
        _imgUserHead = [[UIImageView alloc] init];
        _imgUserHead.backgroundColor = [UIColor lightGrayColor];
        _imgUserHead.contentMode = UIViewContentModeCenter;
    }
    return _imgUserHead;
}

-(void)toggleComboBoxStateChanged:(UISwitch *) sender{
    
    if (self.toggleComboBoxStateChangedAction) {
        self.toggleComboBoxStateChangedAction(sender.on);
    }
}

-(void)makeUI {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.toggleLabel];
    [self.contentView addSubview:self.lbDetail];
    [self.contentView addSubview:self.accessoryImageView];
    [self.contentView addSubview:self.lbRight];
    [self.contentView addSubview:self.imgUserHead];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImageView.mas_right);
        make.right.equalTo(self.lbRight.mas_left);
        make.centerY.equalTo(self.contentView);
        make.height.equalTo(@40);
    }];
    
    [self.lbDetail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.right.equalTo(self.lbRight.mas_left);
        make.top.equalTo(self.titleLabel.mas_bottom);
        make.height.equalTo(@0);
    }];
    
    [self.accessoryImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-20);
        make.width.equalTo(@9);
        make.height.equalTo(@12.5);
        make.centerY.equalTo(self.contentView);
    }];
    
    CGFloat width = SCREEN_WIDTH == 320 ? 100 : 150;
    [self.toggleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.accessoryImageView.mas_left).offset(-10);
        make.width.mas_equalTo(width);
        make.top.equalTo(self);
        make.bottom.equalTo(self);
    }];
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.centerY.equalTo(self);
        make.width.equalTo(@0);
        make.height.equalTo(@40);
    }];
    
    [self.lbRight mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.accessoryImageView.mas_left).mas_offset(-10);
        make.centerY.equalTo(self);
        make.height.equalTo(@35);
        make.width.equalTo(@40);
    }];
    
    [self.imgUserHead mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.accessoryImageView.mas_left).mas_offset(-10);
        make.centerY.equalTo(self);
        make.width.equalTo(@0);
        make.height.equalTo(@45);
    }];
    
}

-(void)noDisplayArrow
{
    [self.accessoryImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@0);
    }];
    
    self.accessoryImageView.hidden = YES;
}

-(void)displayArrow
{
    [self.accessoryImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@12.5);
    }];
    
    self.accessoryImageView.hidden = NO;
}

//MARK: 旋转箭头
- (void)makeArrowRotation:(CGFloat)radian reset:(BOOL)reset animation:(BOOL)animation{
    if(animation){
        if (reset) {
            [UIView animateWithDuration:0.01 animations:^{
                self.accessoryImageView.transform = CGAffineTransformIdentity;
                    } completion:^(BOOL finished) {
                        
                    }];
        }else{
            [UIView animateWithDuration:0.3 animations:^{
                self.accessoryImageView.transform = CGAffineTransformMakeRotation(radian);
                    } completion:^(BOOL finished) {
                        
                    }];
        }
    }else{
        if(reset){
            self.accessoryImageView.transform = CGAffineTransformIdentity;
        }else{
            self.accessoryImageView.transform = CGAffineTransformMakeRotation(radian);
        }
    }
}

-(void)displayIconImageView
{
    [self.iconImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.centerY.equalTo(self);
        make.width.mas_equalTo(cTableViewLeftIconWidth);
        make.height.mas_equalTo(cTableViewLeftIconWidth);
    }];
}

-(void)noDisplayIconImageView
{
    [self.iconImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.centerY.equalTo(self);
        make.width.equalTo(@0);
        make.height.equalTo(@40);
    }];
}
-(void)displayUserHeadImage {
    [self.imgUserHead mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.accessoryImageView.mas_left).mas_offset(-10);
        make.centerY.equalTo(self);
        make.width.equalTo(@45);
        make.height.equalTo(@45);
    }];
}

-(void)noDisplayUserHeadImage {
    [self.imgUserHead mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.accessoryImageView.mas_left).mas_offset(-10);
        make.centerY.equalTo(self);
        make.width.equalTo(@0);
        make.height.equalTo(@45);
    }];
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self makeUI];
    }
    
    return self;
}

#pragma mark - LazyLoad
-(UILabel *)lbDetail
{
    if (!_lbDetail) {
        _lbDetail = [[UILabel alloc] init];
        _lbDetail.backgroundColor = [UIColor clearColor];
        _lbDetail.font = [UIFont systemFontOfSize:cTableViewFilletSubTitleFont];
        _lbDetail.textColor = [UIColor lightGrayColor];
        _lbDetail.hidden = YES;
        _lbDetail.numberOfLines = 0;
    }
    
    return _lbDetail;
}

- (UIView *)bottomLine{
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = cTableViewFilletUnderLineColor;
    }
    
    return _bottomLine;
}

#pragma mark - 控制是否显示副标题 默认不显示
-(void)displayDetailLabel:(NSString *)content
{
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImageView.mas_right);
        make.right.equalTo(self.lbRight.mas_left);
        if (!self.autoAdjustAllTitheHeight){
            make.height.equalTo(@25);
            make.top.equalTo(self).mas_offset(5);
        }else{
            make.top.equalTo(self).mas_offset(15);
        }
    }];
    
    [self.lbDetail mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.right.equalTo(self.contentView).mas_offset(-60);
        if (!self.autoAdjustAllTitheHeight){
            make.top.equalTo(self.contentView).mas_offset(25);
            make.height.equalTo(@20);
        }else{
            make.top.equalTo(self.titleLabel.mas_bottom).mas_offset(5);
        }
    }];
    
    self.lbDetail.text = content;
    self.lbDetail.hidden = NO;
}

- (void)showAutoAdjustAllTitleHeight:(BOOL)autoAdjust{
    self.autoAdjustAllTitheHeight = autoAdjust;
    
    [self.lbDetail mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        if (!autoAdjust) {
            make.top.equalTo(self.contentView).mas_offset(25);
            make.height.equalTo(@20);
            make.right.equalTo(self.contentView).mas_offset(-60);
        }else{
            make.top.equalTo(self.titleLabel.mas_bottom);
            make.right.equalTo(self.toggleLabel.mas_left);
        }
    }];
    
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImageView.mas_right);
        make.right.equalTo(self.lbRight.mas_left);
        if (!self.autoAdjustAllTitheHeight){
            make.height.equalTo(@25);
            make.top.equalTo(self).mas_offset(5);
        }else{
            make.top.equalTo(self).mas_offset(15);
        }
    }];
}

-(void)noDisplayDetailLabel
{
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImageView.mas_right);
        make.right.equalTo(self.lbRight.mas_left);
        make.centerY.equalTo(self.contentView);
        make.height.equalTo(@40);
    }];
    
    self.lbDetail.hidden = YES;
}

//MARK: 进入圆角模式
- (void)enterFilletMode{
    self.titleLabel.textColor = cTableViewFilletTitleColor;
    self.lbDetail.textColor = cTableViewFilletSubTitleColor;
    self.lbRight.textColor = cTableViewFilletRightTitleColor;
    self.titleLabel.font = [UIFont systemFontOfSize:cTableViewFilletTitleFont];
    self.lbDetail.font = [UIFont systemFontOfSize:cTableViewFilletSubTitleFont];
    self.lbRight.font = [UIFont systemFontOfSize:cTableViewFilletRightTitleFont];
    self.bottomLine.backgroundColor = cTableViewFilletUnderLineColor;
    self.lbRight.textAlignment = NSTextAlignmentRight;
    
    if (self.lbDetail.hidden == NO) {
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconImageView.mas_right).mas_offset(self.titleLeftBorder);
            make.right.equalTo(self.lbRight.mas_left);
            if (!self.autoAdjustAllTitheHeight){
                make.height.equalTo(@25);
                make.top.equalTo(self).mas_offset(5);
            }else{
                make.top.equalTo(self).mas_offset(15);
            }
            
        }];
    }else{
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconImageView.mas_right).mas_offset(self.titleLeftBorder);
            make.right.equalTo(self.lbRight.mas_left);
            if (!self.autoAdjustAllTitheHeight){
                make.height.equalTo(@40);
                make.centerY.equalTo(self.contentView);
            }else{
                make.top.equalTo(self).mas_offset(15);
            }
        }];
    }
    
    [self.contentView addSubview:self.bottomLine];
    [self.bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView);
        make.right.right.equalTo(self.contentView);
        make.left.equalTo(self.contentView);
        make.height.equalTo(@1);
    }];
}

//MARK: 右侧显示大内容
- (void)makeRightLableLarge:(BOOL)large{
    if (large) {
        self.lbRight.numberOfLines = 2;
        
        [self.lbRight mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.accessoryImageView.mas_left).mas_offset(-10);
            make.centerY.equalTo(self);
            make.height.equalTo(@44);
            make.left.equalTo(@150);
        }];
    }else{
        CGFloat width = SCREEN_WIDTH == 320 ? 100 : 150;
        [self.toggleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.accessoryImageView.mas_left).offset(-10);
            make.width.mas_equalTo(width);
            make.height.equalTo(@32);
            make.centerY.equalTo(self.contentView);
        }];
        
        [self.lbRight mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.accessoryImageView.mas_left).mas_offset(-10);
            make.centerY.equalTo(self);
            make.height.equalTo(@35);
            make.width.equalTo(@50);
        }];
    }
}

- (void)makeTitleAndRightLabelAdjustHeight{
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImageView.mas_right).mas_offset(self.titleLeftBorder);
        make.right.equalTo(self.lbRight.mas_left);
        make.centerY.equalTo(self);
    }];
    
    [self.lbRight mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.accessoryImageView.mas_left).mas_offset(-10);
        make.centerY.equalTo(self);
        make.width.equalTo(@80);
    }];
}

//MARK: 是否半透明显示
- (void)makeSubtransparent:(BOOL)subtransparent{
    if (subtransparent){
        self.backgroundColor = UIColor.clearColor;
        self.titleLabel.textColor = UIColor.whiteColor;
        self.lbDetail.textColor = UIColor.whiteColor;
        self.toggleLabel.textColor = UIColor.whiteColor;
        self.lbRight.textColor = UIColor.whiteColor;
        self.bottomLine.backgroundColor = UIColor.whiteColor;
        self.accessoryImageView.image = [[UIImage imageNamed:@"icon_arrow_white"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }else{
        self.backgroundColor = UIColor.whiteColor;
        self.titleLabel.textColor = cTableViewFilletTitleColor;
        self.lbDetail.textColor = cTableViewFilletSubTitleColor;
        self.toggleLabel.textColor = cTableViewFilletRightTitleColor;
        self.lbRight.textColor = cTableViewFilletRightTitleColor;
        self.bottomLine.backgroundColor = cTableViewFilletUnderLineColor;
        self.accessoryImageView.image = [[UIImage imageNamed:@"icon_wbs_arrow_right"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
}

@end
