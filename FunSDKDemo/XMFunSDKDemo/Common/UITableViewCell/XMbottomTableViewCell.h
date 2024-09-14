//
//  XMbottomTableViewCell.h
//  XWorld
//
//  Created by dinglin on 2017/3/20.
//  Copyright © 2017年 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XMbottomTableViewCell : UITableViewCell

@property (nonatomic, strong)UILabel *descriptionLabel;//最右侧描述label
@property (nonatomic, strong)UILabel *timeLabel;//时间label
@property (nonatomic, strong)UILabel *dateLabel;//日期label
@property (nonatomic, strong)UILabel *isOpenLabel;//是否开启
@property (nonatomic, strong)UIImageView *indicatorImageView;//左侧指示符
@property (nonatomic,strong) UIView *bottomLine;


@end
