//
//  ChoseEquipmentCell.h
//  XWorld_General
//
//  Created by SaturdayNight on 2018/10/18.
//  Copyright © 2018年 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChoseEquipmentCell : UICollectionViewCell

@property (nonatomic,strong) UIImageView *content;
@property (nonatomic,strong) UILabel *lbTitle;

@property (nonatomic,strong) UIView *topBorder;
@property (nonatomic,strong) UIView *leftBorder;
@property (nonatomic,strong) UIView *bottomBorder;
@property (nonatomic,strong) UIView *rightBorder;

@end

NS_ASSUME_NONNULL_END
