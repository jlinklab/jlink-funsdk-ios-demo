//
//  TitleComboxCell.h
//  XWorld
//
//  Created by DingLin on 17/1/9.
//  Copyright © 2017年 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TitleComboBoxCell : UITableViewCell

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *lbDetail;
@property (nonatomic, copy) void (^toggleComboBoxStateChangedAction)(int);
@property (nonatomic) UILabel *toggleLabel;

@property (nonatomic) UIImageView *accessoryImageView;
@property (nonatomic, strong) UIImageView *iconImageView; // 左侧小图标 默认不显示

@property (nonatomic,strong) UILabel *lbRight;
//标题偏移左边距
@property (nonatomic,assign) CGFloat titleLeftBorder;
@property (nonatomic,strong) UIView *bottomLine;          // 底部分割线
@property (nonatomic,assign) BOOL ifFilletMode;           // 是否圆角模式
@property (nonatomic, strong) UIImageView *imgUserHead; // 右侧头像  默认隐藏
@property (nonatomic, assign) BOOL autoAdjustAllTitheHeight;

#pragma mark - 控制左侧icon图片是否显示
-(void)displayIconImageView;
-(void)noDisplayIconImageView;

-(void)noDisplayArrow;
-(void)displayArrow;

//控制头像是否显示
-(void)displayUserHeadImage;
-(void)noDisplayUserHeadImage;

//MARK: 旋转箭头
- (void)makeArrowRotation:(CGFloat)radian reset:(BOOL)reset animation:(BOOL)animation;

#pragma mark - 控制是否显示副标题 默认不显示
-(void)displayDetailLabel:(NSString *)content;
- (void)showAutoAdjustAllTitleHeight:(BOOL)autoAdjust;
-(void)noDisplayDetailLabel;

//MARK: 进入圆角模式
- (void)enterFilletMode;
//MARK: 右侧显示大内容
- (void)makeRightLableLarge:(BOOL)large;

//MARK: 是否半透明显示
- (void)makeSubtransparent:(BOOL)subtransparent;

- (void)makeTitleAndRightLabelAdjustHeight;


@end
