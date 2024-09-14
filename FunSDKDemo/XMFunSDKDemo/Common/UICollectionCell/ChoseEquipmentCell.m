//
//  ChoseEquipmentCell.m
//  XWorld_General
//
//  Created by SaturdayNight on 2018/10/18.
//  Copyright © 2018年 xiongmaitech. All rights reserved.
//

#import "ChoseEquipmentCell.h"
#import <Masonry/Masonry.h>

@implementation ChoseEquipmentCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.content];
        [self.contentView addSubview:self.lbTitle];
        [self.contentView addSubview:self.topBorder];
        [self.contentView addSubview:self.leftBorder];
        [self.contentView addSubview:self.bottomBorder];
        [self.contentView addSubview:self.rightBorder];
        
        [self.content mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.equalTo(self.mas_width).multipliedBy(0.5);
            make.height.equalTo(self.mas_height).multipliedBy(0.5);
        }];
        
        [self.lbTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).mas_offset(-10);
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.height.equalTo(@20);
        }];
        
        [self.bottomBorder mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.bottom.equalTo(self).mas_offset(1);
            make.height.equalTo(@1);
        }];
        
        [self.topBorder mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.top.equalTo(self);
            make.height.equalTo(@1);
        }];
        
        [self.rightBorder mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.bottom.equalTo(self);
            make.width.equalTo(@1);
            make.right.equalTo(self.mas_right);
        }];
        
        [self.leftBorder mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.bottom.equalTo(self);
            make.width.equalTo(@1);
            make.left.equalTo(self.mas_left);
        }];
    }
    
    return self;
}

-(UIImageView *)content{
    if (!_content) {
        _content = [[UIImageView alloc] init];
        _content.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return _content;
}

-(UILabel *)lbTitle{
    if (!_lbTitle) {
        _lbTitle = [[UILabel alloc] init];
        _lbTitle.textAlignment = NSTextAlignmentCenter;
        _lbTitle.font = [UIFont systemFontOfSize:12];
    }
    
    return _lbTitle;
}

-(UIView *)topBorder{
    if (!_topBorder) {
        _topBorder = [[UIView alloc] init];
        _topBorder.backgroundColor = [UIColor lightGrayColor];
    }
    
    return _topBorder;
}

-(UIView *)leftBorder{
    if (!_leftBorder) {
        _leftBorder = [[UIView alloc] init];
        _leftBorder.backgroundColor = [UIColor lightGrayColor];
    }
    
    return _leftBorder;
}

-(UIView *)bottomBorder{
    if (!_bottomBorder) {
        _bottomBorder = [[UIView alloc] init];
        _bottomBorder.backgroundColor = [UIColor lightGrayColor];
    }
    
    return _bottomBorder;
}

-(UIView *)rightBorder{
    if (!_rightBorder) {
        _rightBorder = [[UIView alloc] init];
        _rightBorder.backgroundColor = [UIColor lightGrayColor];
    }
    
    return _rightBorder;
}

@end
