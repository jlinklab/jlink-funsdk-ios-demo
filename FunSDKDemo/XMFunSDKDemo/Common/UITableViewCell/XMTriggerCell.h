//
//  XMTriggerCell.h
//  XWorld
//
//  Created by dinglin on 2017/3/18.
//  Copyright © 2017年 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XMTriggerCell : UITableViewCell
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UIButton *selectBtn;
@property (nonatomic, strong) UIButton *btnSelectTitle;
@property (nonatomic, strong) UILabel *lbRight;

@property (nonatomic, strong) UILabel *subTitle;

@property (nonatomic,assign) int indexRow;

@property (nonatomic,strong) UIView *bottomLine;

@property (nonatomic, assign) float extroLeftborder;

- (void)showSubTitle:(BOOL)show needSelectTitleButton:(BOOL)needSelectTitleButton;

@property (nonatomic, copy) void (^toggleBtnClickedAction)(XMTriggerCell *);
@property (nonatomic, copy) void (^TrigggerListButtonClickAction)(int indexRow);

//MARK: 更新左边距
- (void)updateExtroLeftBorder:(float)border;
- (void)enterFilletMode;

@end
