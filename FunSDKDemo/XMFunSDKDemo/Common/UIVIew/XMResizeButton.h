//
//  ResizeButton.h
//  OC-TBox
//
//  Created by Tony Stark on 2020/4/29.
//  Copyright © 2020 Tony Stark. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XMResizeButton : UIButton

//最终按钮的宽度高度
@property (nonatomic,assign) float finalWidth;
@property (nonatomic,assign) float finalHeight;

+ (XMResizeButton *)resizeButtonWithSystemType:(UIButtonType)systemType;

//MARK: 自定义图片宽高偏移
- (void)setImageWidth:(CGFloat)width height:(CGFloat)height offsetTop:(CGFloat)top offsetLeft:(CGFloat)left;
//MARK: 自定义文字宽高偏移
- (void)setTitleWidth:(CGFloat)width height:(CGFloat)height offsetTop:(CGFloat)top offsetLeft:(CGFloat)left;

@end

NS_ASSUME_NONNULL_END
