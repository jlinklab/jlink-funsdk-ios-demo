//
//  TitleSwitchCell.h
//  XWorld
//
//  Created by DingLin on 17/1/7.
//  Copyright © 2017年 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMUISwitch.h"

@interface TitleSwitchCell : UITableViewCell

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *lbDetail;
@property (nonatomic,strong) UIImageView *leftIcon;
@property (nonatomic, copy) void (^toggleSwitchStateChangedAction)(BOOL on);
@property (nonatomic) XMUISwitch *toggleSwitch;
@property (nonatomic, assign) CGFloat leftEdgeInset;

//分割线左边距
@property (nonatomic,assign) CGFloat bottomLineLeftBorder;
//标题偏移左边距
@property (nonatomic,assign) CGFloat titleLeftBorder;
///开关微调边距
@property (nonatomic,assign) CGFloat adjustSwitchBorder;

@property (nonatomic,assign) BOOL autoAdjustAllTitleHeight;
@property (nonatomic,assign) NSInteger row;
@property (nonatomic,assign) NSInteger section;

@property (nonatomic,copy) void (^SwitchStateChanged)(BOOL ifOpen,NSInteger row,NSInteger section);

@property (nonatomic,strong) UIView *bottomLine;          // 底部分割线

//MARK: 进入圆角模式
- (void)enterFilletMode;
//MARK: 显示子标题 子标题内容过多
- (void)subTitleVisible:(BOOL)visible ContentRich:(BOOL)rich;
//MARK: 是否半透明显示
- (void)makeSubtransparent:(BOOL)subtransparent;
//MARK: 是否显示最左边icon
- (void)showLeftIconAndTitle;
@end
