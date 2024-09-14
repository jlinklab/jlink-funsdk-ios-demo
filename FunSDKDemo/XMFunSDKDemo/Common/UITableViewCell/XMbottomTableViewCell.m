//
//  XMbottomTableViewCell.m
//  XWorld
//
//  Created by dinglin on 2017/3/20.
//  Copyright © 2017年 xiongmaitech. All rights reserved.
//

#import "XMbottomTableViewCell.h"


@implementation XMbottomTableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //最右侧描述label
        self.descriptionLabel= [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH * 0.08, 0 , SCREEN_WIDTH * 0.15, self.frame.size.height)];
        self.descriptionLabel.font = [UIFont systemFontOfSize:cTableViewFilletTitleFont];
        self.descriptionLabel.textColor = cTableViewFilletRightTitleColor;
        self.descriptionLabel.textAlignment = NSTextAlignmentLeft;
        self.descriptionLabel.numberOfLines = 2;
        [self.contentView addSubview:self.descriptionLabel];
        
        //时间label
        self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH * 0.23, 0 , SCREEN_WIDTH * 0.4, self.frame.size.height)];
        self.timeLabel.font = [UIFont systemFontOfSize:cTableViewFilletTitleFont];
        self.timeLabel.textColor = cTableViewFilletTitleColor;
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.timeLabel];
        
        //日期label
        self.dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH * 0.6, 0 , SCREEN_WIDTH * 0.35, self.frame.size.height/2)];
        self.dateLabel.font = [UIFont systemFontOfSize:cTableViewFilletTitleFont];
        self.dateLabel.textColor = cTableViewFilletRightTitleColor;
        self.dateLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.dateLabel];
        
        //是否开启label
        self.isOpenLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH * 0.6,   self.frame.size.height/2, SCREEN_WIDTH * 0.35, self.frame.size.height/2)];
        self.isOpenLabel.font =[UIFont systemFontOfSize:cTableViewFilletTitleFont];
        self.isOpenLabel.textColor = cTableViewFilletRightTitleColor;
        self.isOpenLabel.textAlignment = NSTextAlignmentLeft;
        //        self.isOpenLabel.backgroundColor = [UIColor blueColor];///
        [self.contentView addSubview:self.isOpenLabel];
        
        
        //左侧指示符
        self.indicatorImageView = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH * 0.9, 0 , 25, 25)];
        self.indicatorImageView.center = CGPointMake(SCREEN_WIDTH * 0.95, self.frame.size.height/2);
        UIImage* image = [UIImage imageNamed:@"arrow_right"];
        if ( image ) {
            self.indicatorImageView.image = image;
        }
        
        [self.contentView addSubview:self.indicatorImageView];
        
        self.bottomLine.backgroundColor = cTableViewFilletUnderLineColor;
        
        [self.contentView addSubview:self.bottomLine];
        [self.bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self);
            make.right.equalTo(self);
            make.left.equalTo(self);
            make.height.equalTo(@1);
        }];
        
        
    }
    return self;
}

- (UIView *)bottomLine{
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = cTableViewFilletUnderLineColor;
    }
    
    return _bottomLine;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
