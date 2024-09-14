//
//  UIServiceManager.h
//   iCSee
//
//  Created by Megatron on 2023/6/30.
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 UI服务配置管理器
 */
@interface UIServiceManager : NSObject

/**
 @brief 给定固定宽度和字体计算文字需要的高度
 @param content 需要计算高度的文字
 @param maxWidth 文字固定的宽度
 @param font 文字的字体
 */
+ (CGFloat)getTextHeightFromContent:(NSString *)content maxWidth:(CGFloat)maxWidth font:(UIFont *)font;

/**
 @brief 给定固定高度和字体计算文字需要的宽度
 @param content 需要计算宽度的文字
 @param maxHeight 文字固定的高度
 @param font 文字的字体
*/
+ (CGFloat)getTextWidthFromContent:(NSString *)content maxHeight:(CGFloat)maxHeight font:(UIFont *)font;

@end

NS_ASSUME_NONNULL_END
