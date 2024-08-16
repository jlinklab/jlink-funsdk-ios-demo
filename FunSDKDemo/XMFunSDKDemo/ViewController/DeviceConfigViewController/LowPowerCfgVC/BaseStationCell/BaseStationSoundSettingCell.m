//
//  BaseStationSoundSettingCell.m
//   
//
//  Created by Tony Stark on 2021/7/26.
//  Copyright © 2021 xiongmaitech. All rights reserved.
//

#import "BaseStationSoundSettingCell.h"

@implementation BaseStationSoundSettingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.titleLeftBorder = 0;
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.lbLeftSlider];
        [self.contentView addSubview:self.lbRightSlider];
        [self.contentView addSubview:self.slider];
        [self.contentView addSubview:self.leftImageView];
        [self.contentView addSubview:self.lbValue];
        [self.contentView addSubview:self.bottomLine];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(20+self.titleLeftBorder);
            make.right.equalTo(self.contentView).offset(-20-self.titleLeftBorder);
            make.height.equalTo(@30);
            make.top.equalTo(self).mas_offset(10);
        }];
        
        [self.lbLeftSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).mas_offset(20);
            make.height.equalTo(@20);
            make.top.equalTo(self.titleLabel.mas_bottom).mas_offset(20);
            make.width.equalTo(@50);
        }];
        
        [self.lbRightSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).mas_offset(-20);
            make.height.equalTo(@20);
            make.top.equalTo(self.titleLabel.mas_bottom).mas_offset(20);
            make.width.equalTo(@50);
        }];
        
        [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.lbLeftSlider.mas_right).offset(5);
            make.right.equalTo(self.lbRightSlider.mas_left).offset(-5);
            make.centerY.equalTo(self.lbLeftSlider);
        }];
        
        [self.leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(cTableViewLeftIconWidth);
            make.height.mas_equalTo(cTableViewLeftIconWidth);
            make.right.equalTo(self.slider.mas_left).mas_offset(-5);
            make.centerY.equalTo(self.slider);
        }];
        
        CGFloat percentage = self.slider.value / self.slider.maximumValue;
        [self.lbValue mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.slider).mas_offset(-25 + percentage * self.slider.frame.size.width);
            make.bottom.equalTo(self.slider.mas_top);
            make.width.equalTo(@50);
            make.height.equalTo(@20);
        }];
        
        [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.height.equalTo(@1);
            make.bottom.equalTo(self);
        }];
        
        [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
    
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"frame"]) {
        [self setSliderValue:self.slider.value];
    }
}

//MARK: - EventAction
- (void)sliderValueChanged:(UISlider *)sender{
    [self setSliderValue:sender.value];
    
    if (self.soundSettingCellSliderValueChanged) {
        self.soundSettingCellSliderValueChanged(sender.value);
    }
}

- (void)sliderTouchUpInside:(UISlider *)sender{
    [self setSliderValue:sender.value];
    
    [self touchEndAction];
}

- (void)sliderTouchUpOutside:(UISlider *)sender{
    [self setSliderValue:sender.value];
    
    [self touchEndAction];
}

- (void)touchEndAction{
    if (self.soundSettingCellSliderTouchEndAction){
        self.soundSettingCellSliderTouchEndAction(self.slider.value);
    }
}

- (void)setSliderValue:(CGFloat)value{
    self.slider.value = value;
    CGFloat percentage = self.slider.value / self.slider.maximumValue;
    [self.lbValue mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.slider).mas_offset( - 30 * percentage  + percentage * self.slider.frame.size.width);
        make.bottom.equalTo(self.slider.mas_top);
        make.width.equalTo(@30);
        make.height.equalTo(@20);
    }];
    
    self.lbValue.text = [NSString stringWithFormat:@"%i",(int)value];
}

//MARK: 进入圆角模式
- (void)enterFilletMode{
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(20+self.titleLeftBorder);
        make.right.equalTo(self.contentView).offset(-20-self.titleLeftBorder);
         
        make.height.equalTo(@30);
        make.top.equalTo(self).mas_offset(10);
    }];
}

//MARK: 是否半透明显示
- (void)makeSubtransparent:(BOOL)subtransparent{
    if (subtransparent){
        self.backgroundColor = UIColor.clearColor;
        self.titleLabel.textColor = UIColor.whiteColor;
        self.lbLeftSlider.textColor = UIColor.whiteColor;
        self.lbRightSlider.textColor = UIColor.whiteColor;
        self.lbValue.textColor = UIColor.whiteColor;
        self.bottomLine.backgroundColor = UIColor.whiteColor;
    }else{
        self.backgroundColor = UIColor.whiteColor;
        self.titleLabel.textColor = cTableViewFilletTitleColor;
        self.lbLeftSlider.textColor = cTableViewFilletRightTitleColor;
        self.lbRightSlider.textColor = cTableViewFilletRightTitleColor;
        self.lbValue.textColor = cTableViewFilletRightTitleColor;
        self.bottomLine.backgroundColor = cTableViewFilletUnderLineColor;
    }
}

- (void)setStyle:(BaseStationSoundSettingCellStyle)style{
    _style = style;
    if (style == BaseStationSoundSettingCellStyle_Normal){
        self.leftImageView.hidden = YES;
        self.lbLeftSlider.hidden = NO;
        self.lbRightSlider.hidden = NO;
        
        [self.lbLeftSlider mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@50);
        }];
        
        [self.lbRightSlider mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@50);
        }];
    }else if (style == BaseStationSoundSettingCellStyle_LeftImage){
        self.leftImageView.hidden = NO;
        self.lbLeftSlider.hidden = YES;
        self.lbRightSlider.hidden = YES;
        
        [self.lbLeftSlider mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@20);
        }];
        
        [self.lbRightSlider mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@0);
        }];
    }
}

//MARK: - LazyLoad
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = cTableViewFilletTitleColor;
        _titleLabel.font = [UIFont systemFontOfSize:cTableViewFilletTitleFont];
    }
    return _titleLabel;
}

- (UIImageView *)leftImageView{
    if (!_leftImageView){
        _leftImageView = [[UIImageView alloc] init];
        _leftImageView.hidden = YES;
        _leftImageView.image = [UIImage imageNamed:@"sun_gray"];
    }
    
    return _leftImageView;
}

- (UILabel *)lbLeftSlider{
    if (!_lbLeftSlider) {
        _lbLeftSlider = [[UILabel alloc] init];
        _lbLeftSlider.textColor = cTableViewFilletRightTitleColor;
        _lbLeftSlider.font = [UIFont systemFontOfSize:cTableViewFilletRightTitleFont];
    }
    
    return _lbLeftSlider;
}

- (UILabel *)lbRightSlider{
    if (!_lbRightSlider) {
        _lbRightSlider = [[UILabel alloc] init];
        _lbRightSlider.textAlignment = NSTextAlignmentRight;
        _lbRightSlider.textColor = cTableViewFilletRightTitleColor;
        _lbRightSlider.font = [UIFont systemFontOfSize:cTableViewFilletRightTitleFont];
    }
    
    return _lbRightSlider;
}

- (UILabel *)lbValue{
    if (!_lbValue) {
        _lbValue = [[UILabel alloc] init];
        _lbValue.backgroundColor = [UIColor clearColor];
        _lbValue.textAlignment = NSTextAlignmentCenter;
        _lbValue.textColor = cTableViewFilletRightTitleColor;
        _lbValue.font = [UIFont systemFontOfSize:cTableViewFilletRightTitleFont];
    }
    
    return _lbValue;
}

- (UISlider *)slider{
    if (!_slider) {
        _slider = [[UISlider alloc] init];
        _slider.tintColor = [UIColor orangeColor];
        [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [_slider addTarget:self action:@selector(sliderTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [_slider addTarget:self action:@selector(sliderTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    }
    
    return _slider;
}

- (UIView *)bottomLine{
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = cTableViewFilletUnderLineColor;
    }
    
    return _bottomLine;
}

-(void)dealloc{
    [self removeObserver:self forKeyPath:@"frame"];
}
@end
