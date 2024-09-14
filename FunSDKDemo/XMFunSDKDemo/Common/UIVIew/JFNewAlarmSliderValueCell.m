//
//  JFNewAlarmSliderValueCell.m
//   iCSee
//
//  Created by kevin on 2023/9/25.
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import "JFNewAlarmSliderValueCell.h"
@interface JFNewAlarmSliderValueCell ()

@end
@implementation JFNewAlarmSliderValueCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.minValue = 1;
        self.maxValue = 100;
        [self buildUI];
    }
    
    return self;
}

- (void)buildUI {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(12);
         
    }];
    
    // 创建滑杆对象
    WeakSelf(weakSelf);
    self.valueSlider = [[JFNewCustomSliderValueView alloc] initWithFrame:CGRectMake(15, 45, SCREEN_WIDTH - 60, 65)];
    
    [self.valueSlider setValueChangedBlock:^(CGFloat value) {
       [weakSelf ChooseSliderValue:value];
    }];
    [self.contentView addSubview:self.valueSlider];
    
}
- (void)setStrLeftValue:(NSString *)strLeftValue {
    _strLeftValue = strLeftValue;
    self.valueSlider.lblLeft.text = strLeftValue;
}

- (void)setStrRightValue:(NSString *)strRightValue {
    _strRightValue = strRightValue;
    self.valueSlider.lblRight.text = strRightValue;
}
- (void)updateSliderValue {
    if ([self.titleLabel.text isEqualToString:TS("Intelligent_duration")]) {
        self.valueSlider.isNeedChangeShowType = YES;
    } else {
        self.valueSlider.isNeedChangeShowType = NO;
    }
    self.valueSlider.minValue = self.minValue;
    self.valueSlider.maxValue = self.maxValue;
    self.valueSlider.currentValue = self.currentValue;
    [self.valueSlider updateSliderValue];
}
 
//- (void)setSliderPointLevel:(SliderAction)action {
//    [self.levelSlider setSliderPoint:action];
//}
- (void)ChooseSliderValue:(CGFloat)value {
    if(self.valueChangedBlock) {
        self.valueChangedBlock(value);
    }
}

//MARK: 进入圆角模式
- (void)enterFilletMode{
    self.titleLabel.textColor = cTableViewFilletTitleColor;
     
    self.titleLabel.font = [UIFont systemFontOfSize:cTableViewFilletTitleFont];
     
    self.bottomLine.backgroundColor = cTableViewFilletUnderLineColor;

    [self.contentView addSubview:self.bottomLine];
    [self.bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView);
        make.right.right.equalTo(self.contentView);
        make.left.equalTo(self.contentView);
        make.height.equalTo(@0.5);
    }];
}

#pragma mark - **************** lazyload ****************


-(UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = cTableViewFilletTitleColor;
        _titleLabel.font = [UIFont systemFontOfSize:cTableViewFilletTitleFont];
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

- (UIView *)bottomLine{
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = cTableViewFilletUnderLineColor;
    }
    
    return _bottomLine;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
