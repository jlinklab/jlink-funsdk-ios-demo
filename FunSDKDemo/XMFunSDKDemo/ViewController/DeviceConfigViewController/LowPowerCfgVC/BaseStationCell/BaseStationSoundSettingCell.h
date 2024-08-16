//
//  BaseStationSoundSettingCell.h
//   
//
//  Created by Tony Stark on 2021/7/26.
//  Copyright © 2021 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SoundSettingCellSliderValueChanged)(CGFloat value);
typedef void(^SoundSettingCellSliderTouchEndAction)(CGFloat value);
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(int,BaseStationSoundSettingCellStyle){
    BaseStationSoundSettingCellStyle_Normal,
    BaseStationSoundSettingCellStyle_LeftImage,
};

@interface BaseStationSoundSettingCell : UITableViewCell

@property (nonatomic) UILabel *titleLabel;

@property (nonatomic,copy) SoundSettingCellSliderValueChanged soundSettingCellSliderValueChanged;
@property (nonatomic,copy) SoundSettingCellSliderTouchEndAction soundSettingCellSliderTouchEndAction;

@property (nonatomic,strong) UIImageView *leftImageView;
@property (nonatomic,strong) UILabel *lbLeftSlider;
@property (nonatomic,strong) UILabel *lbRightSlider;
@property (nonatomic,strong) UILabel *lbValue;
@property (nonatomic,strong) UISlider *slider;
@property (nonatomic,strong) UIView *bottomLine;
//标题偏移左边距
@property (nonatomic,assign) CGFloat titleLeftBorder;

@property (nonatomic,assign) BaseStationSoundSettingCellStyle style;

- (void)setSliderValue:(CGFloat)value;
//MARK: 进入圆角模式
- (void)enterFilletMode;
//MARK: 是否半透明显示
- (void)makeSubtransparent:(BOOL)subtransparent;

@end

NS_ASSUME_NONNULL_END
