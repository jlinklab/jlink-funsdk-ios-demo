//
//  JFLeftTitleRightImageTitleCell.m
//   iCSee
//
//  Created by Megatron on 2024/4/25.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import "JFLeftTitleRightImageTitleCell.h"

@implementation JFLeftTitleRightImageTitleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        self.bottomLineHeight = 0.5;
        [self.contentView addSubview:self.lbRight];
        [self.lbRight mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-cTableViewFilletContentLRBorder);
            make.centerY.equalTo(self.contentView);
            make.height.mas_equalTo(50);
        }];
        
        [self.contentView addSubview:self.imgView];
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0);
            make.height.mas_equalTo(0);
            make.centerY.equalTo(self);
            make.right.equalTo(self.lbRight.mas_left);
        }];
        
        [self.contentView addSubview:self.batteryStateView];
        [self.batteryStateView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.imgView);
        }];
        
        [self.contentView addSubview:self.lbTitle];
        [self.lbTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).mas_offset(cTableViewFilletContentLRBorder);
            make.top.equalTo(self.contentView).mas_offset(cTableViewFilletContentLRBorder);
            make.right.equalTo(self.imgView.mas_left);
            make.bottom.equalTo(self.contentView).mas_offset(-cTableViewFilletContentLRBorder);
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

- (void)setCurStyle:(JFLeftTitleRightImageTitleCellStyle)curStyle{
    if (_curStyle != curStyle) {
        _curStyle = curStyle;
        if (curStyle == JFLeftTitleRightImageTitleCell_Default) {
            self.imgView.hidden = NO;
            self.batteryStateView.hidden = YES;
        }else{
            self.imgView.hidden = YES;
            self.batteryStateView.hidden = NO;
        }
    }
}

- (void)showImageView:(BOOL)show size:(CGSize)size maxRightTitleWidth:(CGFloat)rightWidth{
    if (show) {
        [self.imgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(size.width);
            make.height.mas_equalTo(size.height);
            make.centerY.equalTo(self);
            make.right.equalTo(self.lbRight.mas_left).mas_offset(-5);
        }];
        [self.lbRight mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-cTableViewFilletContentLRBorder);
            make.centerY.equalTo(self.contentView);
            make.height.mas_equalTo(50);
            make.width.mas_equalTo(rightWidth);
        }];
    }else{
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0);
            make.height.mas_equalTo(0);
            make.centerY.equalTo(self);
            make.right.equalTo(self.lbRight.mas_left);
        }];
        [self.lbRight mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-cTableViewFilletContentLRBorder);
            make.centerY.equalTo(self.contentView);
            make.height.mas_equalTo(50);
        }];
    }
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

- (UILabel *)lbRight{
    if (!_lbRight){
        _lbRight = [[UILabel alloc] init];
        _lbRight.font = [UIFont systemFontOfSize:cTableViewFilletSubTitleFont];
        _lbRight.textColor = cTableViewFilletSubTitleColor;
        _lbRight.numberOfLines = 1;
        _lbRight.textAlignment = NSTextAlignmentRight;
    }
    
    return _lbRight;
}

- (UIImageView *)imgView{
    if (!_imgView) {
        _imgView = [[UIImageView alloc] init];
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return _imgView;
}

- (UIView *)bottomLine{
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = cTableViewFilletUnderLineColor;
        _bottomLine.hidden = YES;
    }
    
    return _bottomLine;
}

- (DoorBellBatteryStateView *)batteryStateView{
    if (!_batteryStateView) {
        _batteryStateView = [[DoorBellBatteryStateView alloc] init];
        _batteryStateView.hidden = YES;
    }
    
    return _batteryStateView;
}

@end
