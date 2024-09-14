//
//  UIServiceManager.m
//   iCSee
//
//  Created by Megatron on 2023/6/30.
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import "UIServiceManager.h"

@implementation UIServiceManager

//MARK: 给定固定宽度和字体计算文字需要的高度
+ (CGFloat)getTextHeightFromContent:(NSString *)content maxWidth:(CGFloat)maxWidth font:(UIFont *)font{
    CGSize size = CGSizeMake(maxWidth, MAXFLOAT);
    CGRect rect = [content boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil];
    
    //防止误差 导致显示不下 都加一
    return rect.size.height + 1;
}

//MARK: 给定固定高度和字体计算文字需要的宽度
+ (CGFloat)getTextWidthFromContent:(NSString *)content maxHeight:(CGFloat)maxHeight font:(UIFont *)font{
    CGSize size = CGSizeMake(MAXFLOAT, maxHeight);
    CGRect rect = [content boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil];
    
    //防止误差 导致显示不下 都加一
    return rect.size.width + 1;
}

@end
