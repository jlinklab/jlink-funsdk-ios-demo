//
//  JFSegment.m
//   iCSee
//
//  Created by Megatron on 2023/6/2.
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import "JFSegment.h"

@interface JFSegment ()

@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) UIView *selectView;

@end
@implementation JFSegment

- (instancetype)initWithItemNames:(NSArray *)names frame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        self.layer.cornerRadius = 7.5;
        self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor colorWithHexStr:@"#F0F2F6"];
        self.dataSource = [names mutableCopy];
        self.defaultColor = [UIColor colorWithHexStr:@"#999999"];
        self.selectedColor = kDefaultTitleColor;
        self.selectedIndex = 0;
        self.enableSwitch = YES;
        
        CGFloat itemWidth = frame.size.width / self.dataSource.count - 6;
        float count = self.dataSource.count * 1.0;
        
        [self addSubview:self.selectView];
        [self.selectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(itemWidth);
            make.top.equalTo(self).mas_offset(3);
            make.bottom.equalTo(self).mas_offset(-3);
            make.centerX.equalTo(self).multipliedBy((self.selectedIndex * 2 + 1) / count);
        }];

        for (int i = 0;i < self.dataSource.count;i++){
            UILabel *lb = [[UILabel alloc] init];
            lb.tag = 100 + i;
            lb.userInteractionEnabled = YES;
            lb.text = [self.dataSource objectAtIndex:i];
            lb.textAlignment = NSTextAlignmentCenter;
            lb.font = [UIFont fontWithName:@"PingFang SC" size:15];
            lb.numberOfLines = 2;
            if (i == self.selectedIndex){
                lb.textColor = self.selectedColor;
            }else{
                lb.textColor = self.defaultColor;
            }
            
            [self addSubview:lb];
            [lb mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(itemWidth);
                make.top.equalTo(self).mas_offset(3);
                make.bottom.equalTo(self).mas_offset(-3);
                make.centerX.equalTo(self).multipliedBy((i * 2 + 1) / count);
            }];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
            [lb addGestureRecognizer:tap];
        }
    }
    
    return self;
}

- (void)tapAction:(UITapGestureRecognizer *)gesture{
    if (!self.enableSwitch){
        return;
    }
    if (gesture.state == UIGestureRecognizerStateEnded){
        UIView *tapView = gesture.view;
        if ([tapView isKindOfClass:[UILabel class]]){
            CGFloat itemWidth = self.frame.size.width / self.dataSource.count - 6;
            float count = self.dataSource.count * 1.0;
            self.selectedIndex = (int)tapView.tag - 100;
            [self.selectView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(itemWidth);
                make.top.equalTo(self).mas_offset(3);
                make.bottom.equalTo(self).mas_offset(-3);
                make.centerX.equalTo(self).multipliedBy((self.selectedIndex * 2 + 1) / count);
            }];
            
            for (int i = 0;i < self.dataSource.count;i++){
                UILabel *lb = [self viewWithTag:100 + i];
                if (i == self.selectedIndex){
                    lb.textColor = self.selectedColor;
                }else{
                    lb.textColor = self.defaultColor;
                }
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(segmentSelectedIndexChanged:)]){
                [self.delegate segmentSelectedIndexChanged:self.selectedIndex];
            }
        }
    }
}

//MARK: - LazyLoad
- (UIView *)selectView{
    if (!_selectView){
        _selectView = [[UIView alloc] init];
        _selectView.backgroundColor = UIColor.whiteColor;
        _selectView.layer.cornerRadius = 7.5;
        _selectView.layer.masksToBounds = YES;
    }
    
    return _selectView;
}

@end
