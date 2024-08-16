//
//  SliderOnlyCell.m
//   
//
//  Created by Tony Stark on 2021/7/30.
//  Copyright © 2021 xiongmaitech. All rights reserved.
//

#import "SliderOnlyCell.h"
#import <Masonry/Masonry.h>

@implementation SliderOnlyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.slider];
        
        [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).mas_offset(20);
            make.right.equalTo(self).mas_offset(-20);
            make.centerY.equalTo(self);
            make.height.equalTo(@30);
        }];
    }
    
    return self;
}

- (void)sliderValueChanged:(UISlider *)sender{
    if (self.SliderOnlyCellValueChanged) {
        self.SliderOnlyCellValueChanged(sender.value);
    }
}

- (void)sliderTouchUpInside:(UISlider *)sender{
    if (self.SliderOnlyCellTouchUpInslide) {
        self.SliderOnlyCellTouchUpInslide(sender.value);
    }
}

//MARK: - LazyLoad
- (UISlider *)slider{
    if (!_slider) {
        _slider = [[UISlider alloc] init];
        _slider.tintColor = [UIColor orangeColor];
        [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [_slider addTarget:self action:@selector(sliderTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _slider;
}

//MARK: 是否半透明显示
- (void)makeSubtransparent:(BOOL)subtransparent{
    if (subtransparent){
        self.backgroundColor = UIColor.clearColor;
    }else{
        self.backgroundColor = UIColor.whiteColor;
    }
}

@end
