//
//  CircleWeekChoseCell.m
//   iCSee
//
//  Created by Megatron on 2023/5/17.
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import "CircleWeekChoseCell.h"

static const float kButtonWeekWidth = 37;
static const float kButtonWeekSpace = 11.5;
static const float kTopHSpaceOffset = 15;
static const float kCenterHSpaceOffset = 15;
static const float kBottomHSpaceOffset = 24;

@interface CircleWeekChoseCell ()

@property (nonatomic,strong) NSMutableArray *weekButtons;

@end
@implementation CircleWeekChoseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        self.titleLeftBorder = cTableViewFilletLFBorder;
        [self.contentView addSubview:self.lbLeft];
        [self.lbLeft mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).mas_offset(self.titleLeftBorder);
            make.right.equalTo(self);
            make.top.equalTo(self.contentView.mas_top).mas_offset(kTopHSpaceOffset);
        }];
        
        [self createWeekButtons];
    }
    
    return self;
}

- (void)createWeekButtons{
    [self.weekButtons removeAllObjects];
    
    float btnWidth = kButtonWeekWidth;
    NSArray *title = @[TS(@"Monday"),TS(@"Tuesday"),TS(@"Wednesday"),TS(@"Thursday"),TS(@"Friday"),TS(@"Saturday"),TS(@"Sunday")];
    for (int i = 0;i < 7;i++){
        UIButton *btnWeek = [UIButton buttonWithType:UIButtonTypeSystem];
        [btnWeek setBackgroundColor: [UIColor orangeColor]];
        [btnWeek setTitle:[title objectAtIndex:i] forState:UIControlStateNormal];
        [btnWeek setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        btnWeek.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size: 11];
        btnWeek.tag = i;
        [btnWeek addTarget:self action:@selector(btnWeekClicked:) forControlEvents:UIControlEventTouchUpInside];
        btnWeek.layer.cornerRadius = btnWidth * 0.5;
        btnWeek.layer.masksToBounds = YES;
        [self.weekButtons addObject:btnWeek];
        [self.contentView addSubview:btnWeek];
    }
    
    //设置按钮之间的间隔
    CGFloat space = kButtonWeekSpace;
    CGFloat border = 15;
    //第一行显示个数
    int firstNum = 7;
    for (int i = firstNum;i > 0;i--){
        float blank = SCREEN_WIDTH - cTableViewFilletLFBorder * 2 - btnWidth * i;
        if (blank >= (i - 1) * space + border * 2){
            firstNum = i;
            break;
        }
    }
    
    if (firstNum == 7){
        //一行能显示下就让它均匀排布
        float remain = SCREEN_WIDTH - cTableViewFilletLFBorder * 2 - btnWidth * firstNum - border * 2;
        float trailSpace = border;
        float realSpace = remain / 6.0;
        
        //设置每个按钮的宽高为y
        [self.weekButtons mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:realSpace leadSpacing:trailSpace tailSpacing:trailSpace];
        [self.weekButtons mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.lbLeft.mas_bottom).offset(kCenterHSpaceOffset);
            make.height.mas_equalTo(btnWidth);
            make.width.mas_equalTo(btnWidth);
        }];
    }else{
        NSMutableArray *buttons1 = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray *buttons2 = [NSMutableArray arrayWithCapacity:0];
        for (int i = 0;i < 7;i++){
            if (i <= firstNum - 1){
                [buttons1 addObject:[self.weekButtons objectAtIndex:i]];
            }else{
                [buttons2 addObject:[self.weekButtons objectAtIndex:i]];
            }
        }
        
        float trailSpace1 = SCREEN_WIDTH - cTableViewFilletLFBorder * 2 - btnWidth * buttons1.count - space * buttons1.count;
        [buttons1 mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:space leadSpacing:space tailSpacing:trailSpace1];
        [buttons1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.lbLeft.mas_bottom).offset(kCenterHSpaceOffset);
            make.height.mas_equalTo(btnWidth);
            make.width.mas_equalTo(btnWidth);
        }];
        
        if (buttons2.count > 1) {
            float trailSpace2 = SCREEN_WIDTH - cTableViewFilletLFBorder * 2 - btnWidth * buttons2.count - space * buttons2.count;
            [buttons2 mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:space leadSpacing:space tailSpacing:trailSpace2];
            [buttons2 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.lbLeft.mas_bottom).offset(kCenterHSpaceOffset + btnWidth + kCenterHSpaceOffset);
                make.height.mas_equalTo(btnWidth);
                make.width.mas_equalTo(btnWidth);
            }];
        }else{
            UIButton *btn = [buttons2 objectAtIndex:0];
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.lbLeft.mas_bottom).offset(kCenterHSpaceOffset + btnWidth + kCenterHSpaceOffset);
                make.left.mas_equalTo(space);
                make.height.mas_equalTo(btnWidth);
                make.width.mas_equalTo(btnWidth);
            }];
        }
    }
}

- (void)btnWeekClicked:(UIButton *)sender{
    int index = (int)sender.tag;
    if (index < 7){
        if (self.ClickWeekIndex) {
            self.ClickWeekIndex(index);
        }
    }
}

- (void)updateSelectedState:(NSArray *)state{
    for (int i = 0;i < self.weekButtons.count;i++){
        UIButton *btn = [self.weekButtons objectAtIndex:i];
        int stateValue = [[state objectAtIndex:i] intValue];
        if (stateValue <= 0){
            [btn setBackgroundColor:[UIColor colorWithHexStr:@"#D9D9D9"]];
        }else{
            [btn setBackgroundColor:[UIColor orangeColor]];
        }
    }
}

+ (CGFloat)cellHeight{
    float btnWidth = kButtonWeekWidth;
    //设置按钮之间的间隔
    CGFloat space = kButtonWeekSpace;
    CGFloat border = 15;
    //第一行显示个数
    int firstNum = 7;
    for (int i = firstNum;i > 0;i--){
        float blank = SCREEN_WIDTH - cTableViewFilletLFBorder * 2 - btnWidth * i;
        if (blank >= (i - 1) * space + border * 2){
            firstNum = i;
            break;
        }
    }
    
    if (firstNum == 7){
        return kTopHSpaceOffset + kBottomHSpaceOffset + cTableViewFilletTitleFont + kCenterHSpaceOffset + btnWidth;
    }else{
        return kTopHSpaceOffset + kBottomHSpaceOffset + cTableViewFilletTitleFont + kCenterHSpaceOffset + btnWidth + btnWidth + kCenterHSpaceOffset;
    }
}

//MARK: - LazyLoad
- (UILabel *)lbLeft{
    if (!_lbLeft){
        _lbLeft = [[UILabel alloc] init];
        _lbLeft.textColor = cTableViewFilletTitleColor;
        _lbLeft.font = [UIFont systemFontOfSize:cTableViewFilletTitleFont];
    }
    
    return _lbLeft;
}

- (NSMutableArray *)weekButtons{
    if (!_weekButtons){
        _weekButtons = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _weekButtons;
}

@end
