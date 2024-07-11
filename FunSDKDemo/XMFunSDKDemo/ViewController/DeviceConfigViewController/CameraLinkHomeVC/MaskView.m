//
//  fheuhView.m
//   iCSee
//
//  Created by ctrl+c on 2023/4/6.
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import "MaskView.h"

@implementation MaskView

- (id)initWithFrame:(CGRect)frame backgroundColor:(UIColor*)color andTransparentRects:(NSArray*)rects
{
    backgroundColor = color;
    rectsArray = rects;
    self = [super initWithFrame:frame];
    if (self) {
     // Initialization code
//     self.opaque = NO;
        [self addImage];
    }
    return self;
}

- (void)addImage{
    UIImageView *imageV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];

    imageV.image = [self getImage];

//    imageV.alpha = 0.44;

    [self addSubview:imageV];

}

- (UIImage *)getImage{
    float radius = 60;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.frame.size.width, self.frame.size.height), NO, 1.0);
    CGContextRef con = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(con, backgroundColor.CGColor);//背景色
    CGContextFillRect(con, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
    CGContextAddEllipseInRect(con, CGRectMake((self.frame.size.width - radius) * 0.5, (self.frame.size.height - radius) * 0.5, radius, radius));
    CGContextSetBlendMode(con, kCGBlendModeClear);
    CGContextFillPath(con);
    UIImage *ima = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return ima;
}

@end
