//
//  JFLeftSelectRightArrowCell.m
//   iCSee
//
//  Created by Megatron on 2024/7/17.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import "JFLeftSelectRightArrowCell.h"

@implementation JFLeftSelectRightArrowCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.leftBorder = 25;
        
        [self.contentView addSubview:self.btnSelected];
        [self.btnSelected mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).mas_offset(self.leftBorder - 7.5);
            make.centerY.equalTo(self);
            make.width.equalTo(@40);
            make.height.equalTo(@40);
        }];
        [self.contentView addSubview:self.lbTitle];
        [self.lbTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.btnSelected.mas_right).mas_offset(2.5);
            make.top.equalTo(self);
            make.bottom.equalTo(self);
            make.right.equalTo(self.imgViewArrow.mas_left);
        }];
        [self.contentView addSubview:self.imgViewArrow];
        [self.imgViewArrow mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).mas_offset(-15);
            make.centerY.equalTo(self);
            make.width.equalTo(@20);
            make.height.equalTo(@20);
        }];
        [self.contentView addSubview:self.underLine];
        [self.underLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView);
            make.height.equalTo(@0.5);
            make.bottom.equalTo(self.contentView);
            make.right.equalTo(self.contentView);
        }];
    }
    
    return self;
}

///更新约束 比如边距等参数发生变化需要调用才能刷新
- (void)updateJFConstraints {
    [self.btnSelected mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).mas_offset(self.leftBorder - 7.5);
        make.centerY.equalTo(self);
        make.width.equalTo(@40);
        make.height.equalTo(@40);
    }];
}

//MARK: - EventAction
- (void)btnSelectedClicked:(XMResizeButton *)sender {
    sender.selected = !sender.selected;
    
    if (self.SelectStateChanged) {
        self.SelectStateChanged(sender.selected);
    }
}

//MARK: - LazyLoad
- (XMResizeButton *)btnSelected {
    if (!_btnSelected) {
        _btnSelected = [XMResizeButton resizeButtonWithSystemType:UIButtonTypeSystem];
        _btnSelected.tintColor = UIColor.clearColor;
        [_btnSelected setImage:[[UIImage imageNamed:@"select_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        [_btnSelected setImage:[[UIImage imageNamed:@"select_press"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateSelected];
        [_btnSelected setImageWidth:25 height:25 offsetTop:7.5 offsetLeft:7.5];
        [_btnSelected addTarget:self action:@selector(btnSelectedClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _btnSelected;
}

- (UILabel *)lbTitle {
    if (!_lbTitle) {
        _lbTitle = [[UILabel alloc] init];
        _lbTitle.textAlignment = NSTextAlignmentLeft;
        _lbTitle.font = JFFont(15);
        _lbTitle.textColor = JFColor(@"#555555");
    }
    
    return _lbTitle;
}

- (UIImageView *)imgViewArrow{
    if (!_imgViewArrow){
        _imgViewArrow = [[UIImageView alloc] init];
        _imgViewArrow.image = [UIImage imageNamed:@"arrow_right"];
        _imgViewArrow.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return _imgViewArrow;
}
- (UIView *)underLine{
    if (!_underLine) {
        _underLine = [[UIView alloc] init];
        _underLine.backgroundColor  = cTableViewFilletUnderLineColor;
    }
    
    return _underLine;
}
@end
