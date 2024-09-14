//
//  ResizeButton.m
//  OC-TBox
//
//  Created by Tony Stark on 2020/4/29.
//  Copyright © 2020 Tony Stark. All rights reserved.
//

#import "XMResizeButton.h"

@interface XMResizeButton ()

//需要自定义图片的长宽
@property (nonatomic,assign) CGFloat imgHeight;
@property (nonatomic,assign) CGFloat imgWidth;
//自定义图片距离左边和顶部的偏移
@property (nonatomic,assign) CGFloat imgOffsetTop;
@property (nonatomic,assign) CGFloat imgOffsetLeft;
//需要自定义标题的长宽
@property (nonatomic,assign) CGFloat titleHeight;
@property (nonatomic,assign) CGFloat titleWidth;
//自定义标题距离左边和顶部的偏移
@property (nonatomic,assign) CGFloat titleOffsetTop;
@property (nonatomic,assign) CGFloat titleOffsetLeft;

@end

@implementation XMResizeButton

+ (XMResizeButton *)resizeButtonWithSystemType:(UIButtonType)systemType{
    XMResizeButton *btn = [XMResizeButton buttonWithType:systemType];
    btn.imgWidth = 0;
    btn.imgHeight = 0;
    btn.imgOffsetTop = 0;
    btn.imgOffsetLeft = 0;
    btn.titleWidth = 0;
    btn.titleHeight = 0;
    btn.titleOffsetTop = 0;
    btn.titleOffsetLeft = 0;
    
    return btn;
}

//MARK: 自定义图片宽高偏移
- (void)setImageWidth:(CGFloat)width height:(CGFloat)height offsetTop:(CGFloat)top offsetLeft:(CGFloat)left{
    self.imgWidth = width;
    self.imgHeight = height;
    self.imgOffsetTop = top;
    self.imgOffsetLeft = left;
}

//MARK: 自定义文字宽高偏移
- (void)setTitleWidth:(CGFloat)width height:(CGFloat)height offsetTop:(CGFloat)top offsetLeft:(CGFloat)left{
    self.titleWidth = width;
    self.titleHeight = height;
    self.titleOffsetTop = top;
    self.titleOffsetLeft = left;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    return CGRectMake(self.imgOffsetLeft, self.imgOffsetTop, self.imgWidth, self.imgHeight);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    return CGRectMake(self.titleOffsetLeft, self.titleOffsetTop, self.titleWidth, self.titleHeight);
}

@end
