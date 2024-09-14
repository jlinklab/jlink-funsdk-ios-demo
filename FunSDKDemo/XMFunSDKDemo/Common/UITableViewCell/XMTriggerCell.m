//
//  XMTriggerCell.m
//  XWorld
//
//  Created by dinglin on 2017/3/18.
//  Copyright © 2017年 xiongmaitech. All rights reserved.
//

#import "XMTriggerCell.h"
#import <Masonry/Masonry.h>

@interface XMTriggerCell ()

@end

@implementation XMTriggerCell

-(void)makeUI {
    self.extroLeftborder = 0;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentView addSubview:self.selectBtn];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.btnSelectTitle];
    [self.contentView addSubview:self.lbRight];
    [self.contentView addSubview:self.subTitle];
    
    [self.selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@32);
        make.height.equalTo(@32);
        make.left.equalTo(self.contentView).offset(10 + self.extroLeftborder);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.selectBtn.mas_right).offset(5);
//        make.width.equalTo(@100);
//        make.height.equalTo(@24);
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.btnSelectTitle.mas_left);
    }];
    
    [self.btnSelectTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).mas_offset(-20);
        make.centerY.equalTo(self);
        make.width.equalTo(@120);
        make.height.equalTo(@40);
    }];
    
    [self.lbRight mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).mas_offset(-10);
        make.centerY.equalTo(self);
        make.width.equalTo(@120);
        make.height.equalTo(@40);
    }];

    [self.titleLabel sizeToFit];
}

- (void)enterFilletMode{

    self.bottomLine.backgroundColor = cTableViewFilletUnderLineColor;
    
    [self.contentView addSubview:self.bottomLine];
    [self.bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.right.equalTo(self);
        make.left.equalTo(self);
        make.height.equalTo(@1);
    }];
  
}

- (void)showSubTitle:(BOOL)show needSelectTitleButton:(BOOL)needSelectTitleButton{
    if(show){
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.selectBtn.mas_right).offset(5);
            make.top.equalTo(self.contentView).offset(8);
            make.height.equalTo(@20);
            if (needSelectTitleButton) {
                make.right.equalTo(self.btnSelectTitle.mas_left);
            }else{
                make.right.equalTo(self.contentView).mas_offset(-10);
            }
            
        }];
        
        [self.subTitle mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleLabel);
            make.right.equalTo(self.titleLabel);
            make.bottom.equalTo(self.contentView);
            make.top.equalTo(self.titleLabel.mas_bottom).offset(3);
        }];
    }else{
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.selectBtn.mas_right).offset(5);
            make.top.equalTo(self.contentView);
            make.bottom.equalTo(self.contentView);
            make.right.equalTo(self.btnSelectTitle.mas_left);
        }];
        
        [self.subTitle mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleLabel);
            make.right.equalTo(self.titleLabel);
            make.top.equalTo(self.titleLabel.mas_bottom).offset(3);
            make.height.equalTo(@0);
        }];
    }
}

- (void)updateExtroLeftBorder:(float)border{
    self.extroLeftborder = border;
    [self.selectBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@32);
        make.height.equalTo(@32);
        make.left.equalTo(self.contentView).offset(10 + self.extroLeftborder);
        make.centerY.equalTo(self.contentView);
    }];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self makeUI];
    }
    
    return self;
}

#pragma mark - EventAction
-(void)toggleBtnClicked:(UIButton *)sender{
    BOOL selected = sender.selected;
    sender.selected = !selected;
    
    if (self.toggleBtnClickedAction) {
        self.toggleBtnClickedAction(self);
    }
}

- (void)btnSelectTitleClicked:(UIButton *)sender{
    if (self.TrigggerListButtonClickAction) {
        self.TrigggerListButtonClickAction(self.indexRow);
    }
}

#pragma mark - LazyLoad
- (UIButton *)btnSelectTitle{
    if (!_btnSelectTitle) {
        _btnSelectTitle = [[UIButton alloc] init];
        [_btnSelectTitle setTitleColor:NormalFontColor forState:UIControlStateNormal];
        _btnSelectTitle.titleLabel.textAlignment = NSTextAlignmentRight;
        [_btnSelectTitle addTarget:self action:@selector(btnSelectTitleClicked:) forControlEvents:UIControlEventTouchUpInside];
        _btnSelectTitle.hidden = YES;
    }
    
    return _btnSelectTitle;
}

-(UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = cTableViewFilletTitleColor;
        _titleLabel.font = [UIFont systemFontOfSize:cTableViewFilletTitleFont];
        _titleLabel.numberOfLines = 0;
    }
    
    return _titleLabel;
}

-(UIButton *)selectBtn {
    if (!_selectBtn) {
        _selectBtn = [[UIButton alloc] init];
        [_selectBtn setImage:[UIImage imageNamed:@"AlarmModeView-correct-nor"] forState:UIControlStateNormal];
        [_selectBtn setImage:[UIImage imageNamed:@"AlarmModeView-correct-sel"] forState:UIControlStateSelected];
        [_selectBtn addTarget:self action:@selector(toggleBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _selectBtn;
}

- (UILabel *)lbRight{
    if (!_lbRight) {
        _lbRight = [[UILabel alloc] init];
        _lbRight.textColor = cTableViewFilletRightTitleColor;
        _lbRight.textAlignment = NSTextAlignmentRight;
        _lbRight.hidden = YES;
        _lbRight.numberOfLines = 2;
        _lbRight.font = [UIFont systemFontOfSize:cTableViewFilletRightTitleFont];
    }
    
    return _lbRight;
}

-(UILabel *)subTitle{
    if (!_subTitle) {
        _subTitle = [[UILabel alloc] init];
        _subTitle.textColor = cTableViewFilletRightTitleColor;
        _subTitle.numberOfLines = 0;
        _subTitle.font = [UIFont systemFontOfSize:cTableViewFilletRightTitleFont];
    }
    
    return _subTitle;
}

- (UIView *)bottomLine{
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = cTableViewFilletUnderLineColor;
    }
    
    return _bottomLine;
}
@end
