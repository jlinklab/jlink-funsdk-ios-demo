//
//  JFLineChartView.m
//   iCSee
//
//  Created by Megatron on 2024/4/30.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import "JFLineChartView.h"

@interface JFLineChartView ()

@property (nonatomic,strong) NSMutableArray *arrayYLabels;
@property (nonatomic,strong) NSMutableArray *arrayXLabels;
@property (nonatomic,strong) UIView *lbBG;
@property (nonatomic,strong) UIView *standardView;

@end
@implementation JFLineChartView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.lbTitle];
        [self.lbTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).mas_offset(15);
            make.right.equalTo(self).mas_offset(-15);
            make.top.equalTo(self);
        }];
        
        [self addSubview:self.lbRightTitleX];
        [self addSubview:self.lbBG];
        [self addSubview:self.lineView];
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).mas_offset(45);
            make.right.equalTo(self).mas_offset(-45);
            make.top.equalTo(self.lbTitle.mas_bottom).mas_offset(20);
            make.bottom.equalTo(self).mas_offset(-30);
        }];
        [self.lbBG mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.lineView);
        }];
        [self.lbRightTitleX mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.lbBG.mas_bottom).mas_offset(5);
            make.left.equalTo(self.lbBG.mas_right).mas_offset(15);
        }];
    }
    
    return self;
}

- (void)updateXYNames:(NSMutableArray *)xNames yNames:(NSMutableArray *)yNames{
    self.xNames = xNames;
    self.yNames = yNames;
    //先移除已经添加的Label
    for (UILabel *label in self.arrayYLabels) {
        [label removeFromSuperview];
    }
    for (UILabel *label in self.arrayXLabels) {
        [label removeFromSuperview];
    }
    if (self.xNames.count >=2 && self.yNames.count >= 2) {
        for (int i = 0; i < self.xNames.count; i++) {
            NSString *name = [self.xNames objectAtIndex:i];
            UILabel *lb = [[UILabel alloc] init];
            lb.textColor = JFColor(@"#C5C5C7");
            lb.font = JFFont(12);
            lb.numberOfLines = 1;
            lb.text = name;
            [self.lbBG addSubview:lb];
            [self.arrayXLabels addObject:lb];
            if (i == 0) {
                [lb mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self.standardView.mas_left);
                    make.top.equalTo(self.standardView.mas_bottom).mas_offset(5);
                }];
            }else{
                [lb mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self.standardView).multipliedBy(i * 2 / ((self.xNames.count - 1) * 1.0));
                    make.top.equalTo(self.standardView.mas_bottom).mas_offset(5);
                }];
            }
        }
        
        for (int i = 0; i < self.yNames.count; i++) {
            NSString *name = [self.yNames objectAtIndex:i];
            UILabel *lb = [[UILabel alloc] init];
            lb.textColor = JFColor(@"#C5C5C7");
            lb.font = JFFont(12);
            lb.numberOfLines = 1;
            lb.text = name;
            [self.lbBG addSubview:lb];
            [self.arrayYLabels addObject:lb];
            NSInteger index = self.yNames.count - 1 - i;
            if (index == 0) {
                [lb mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(self.standardView.mas_top);
                    make.right.equalTo(self.standardView.mas_left).mas_offset(-5);
                }];
            }else{
                [lb mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(self.standardView).multipliedBy(index * 2 / ((self.yNames.count - 1) * 1.0));
                    make.right.equalTo(self.standardView.mas_left).mas_offset(-5);
                }];
            }
        }
    }
    
}

//MARK: - LazyLoad
- (UILabel *)lbTitle{
    if (!_lbTitle) {
        _lbTitle = [[UILabel alloc] init];
        _lbTitle.font = JFFont(12);
        _lbTitle.textColor = JFColor(@"#C5C5C7");
        _lbTitle.textAlignment = NSTextAlignmentLeft;
        _lbTitle.numberOfLines = 2;
    }
    
    return _lbTitle;
}

- (UILabel *)lbRightTitleX{
    if (!_lbRightTitleX) {
        _lbRightTitleX = [[UILabel alloc] init];
        _lbRightTitleX.font = JFFont(12);
        _lbRightTitleX.textColor = JFColor(@"#C5C5C7");
        _lbRightTitleX.textAlignment = NSTextAlignmentLeft;
        _lbRightTitleX.numberOfLines = 2;
    }
    
    return _lbRightTitleX;
}

- (JFPointsLineView *)lineView{
    if (!_lineView) {
        _lineView = [[JFPointsLineView alloc] init];
    }
    
    return _lineView;
}

- (NSMutableArray *)arrayXLabels{
    if (!_arrayXLabels) {
        _arrayXLabels = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _arrayXLabels;
}

- (NSMutableArray *)arrayYLabels{
    if (!_arrayYLabels) {
        _arrayYLabels = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _arrayYLabels;
}

- (UIView *)lbBG{
    if (!_lbBG) {
        _lbBG = [[UIView alloc] init];
        _lbBG.backgroundColor = UIColor.clearColor;
        
        self.standardView = [[UIView alloc] init];
        self.standardView.backgroundColor = UIColor.clearColor;
        [_lbBG addSubview:self.standardView];
        [self.standardView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_lbBG);
        }];
    }
    
    return _lbBG;
}

@end
