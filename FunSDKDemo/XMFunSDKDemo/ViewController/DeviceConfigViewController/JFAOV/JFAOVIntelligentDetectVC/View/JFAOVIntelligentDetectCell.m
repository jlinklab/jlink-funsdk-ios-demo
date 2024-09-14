//
//  JFAOVIntelligentDetectCell.m
//   iCSee
//
//  Created by kevin on 2024/7/15.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import "JFAOVIntelligentDetectCell.h"

@implementation JFAOVIntelligentDetectCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
        self.contentView.backgroundColor = cTableViewFilletGroupedBackgroudColor;

    }
    
    return self;
}
- (void)setupUI {
    self.leftView = [[UIView alloc] init];
    self.leftView.backgroundColor = [UIColor whiteColor];
    [self.leftView.layer setMasksToBounds:YES];
    [self.leftView.layer setCornerRadius:7.5];
//    [self.leftView.layer setBorderColor:UIColorFromHex(0xCFDAE3).CGColor];
//    [self.leftView.layer setBorderWidth:0.5];
    [self.contentView addSubview:self.leftView];
    [self.leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(10);
        make.width.mas_equalTo((SCREEN_WIDTH - 40)/2);
        make.height.mas_equalTo(100);
    }];
    
    UIImageView *imgLeft = [[UIImageView alloc] init];
    imgLeft.image = [UIImage imageNamed:@"set_detection_people"];
    [self.leftView addSubview:imgLeft];
    [imgLeft mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(17);
        make.left.mas_equalTo(20);
        make.size.mas_equalTo(CGSizeMake(35, 35));
    }];
    
    UILabel *lblLeft = [[UILabel alloc] init];
    lblLeft.textColor = UIColorFromHex(0x333333);
    lblLeft.font = [UIFont systemFontOfSize:15];
    lblLeft.textAlignment = NSTextAlignmentCenter;
    lblLeft.text = TS("TR_Human_Shape");
    [self.leftView addSubview:lblLeft];
    [lblLeft mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(imgLeft.mas_bottom).mas_offset(10);
        make.left.mas_equalTo(20);
         
    }];
    
    self.leftSwitch = [[UISwitch alloc] init];
    self.leftSwitch.onTintColor = NormalFontColor;
    [self.leftSwitch addTarget:self action:@selector(leftSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.leftView addSubview:self.leftSwitch];
    [self.leftSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(17);
    }];

    
  
    self.rightView = [[UIView alloc] init];
    self.rightView.backgroundColor = [UIColor whiteColor];
    [self.rightView.layer setMasksToBounds:YES];
    [self.rightView.layer setCornerRadius:7.5];
//    [self.rightView.layer setBorderColor:UIColorFromHex(0xCFDAE3).CGColor];
//    [self.rightView.layer setBorderWidth:0.5];
    [self.contentView addSubview:self.rightView];
    [self.rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(10);
        make.width.mas_equalTo((SCREEN_WIDTH - 40)/2);
        make.height.mas_equalTo(100);
    }];
    
    UIImageView *imgRight = [[UIImageView alloc] init];
    imgRight.image = [UIImage imageNamed:@"set_detection_car"];
    [self.rightView addSubview:imgRight];
    [imgRight mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(17);
        make.left.mas_equalTo(20);
        make.size.mas_equalTo(CGSizeMake(35, 35));
    }];
    
    UILabel *lblRight  = [[UILabel alloc] init];
    lblRight.textColor = UIColorFromHex(0x333333);
    lblRight.font = [UIFont systemFontOfSize:15];
    lblRight.textAlignment = NSTextAlignmentCenter;
    lblRight.text = TS("TR_Car_Shape");
    [self.rightView addSubview:lblRight];
    [lblRight mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(imgRight.mas_bottom).mas_offset(10);
        make.left.mas_equalTo(20);
    }];
    
    self.rightSwitch = [[UISwitch alloc] init];
    self.rightSwitch.onTintColor = NormalFontColor;
    [self.rightSwitch addTarget:self action:@selector(rightSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.rightView addSubview:self.rightSwitch];
    [self.rightSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(17);
    }];
    
     
    
     
}
- (void)leftSwitchValueChanged:(UISwitch *)sender{
    if (self.LeftSwitchValueChanged) {
        self.LeftSwitchValueChanged(sender.on);
    }
}
 
- (void)rightSwitchValueChanged:(UISwitch *)sender{
    if (self.RightSwitchValueChanged) {
        self.RightSwitchValueChanged(sender.on);
    }
}
 
 

@end
