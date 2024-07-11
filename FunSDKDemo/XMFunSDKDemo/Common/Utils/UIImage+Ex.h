//
//  UIImage+Ex.h
//  XWorld
//
//  Created by liuguifang on 16/6/18.
//  Copyright © 2016年 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Ex)

//灰阶图
-(UIImage*)grayImage;

//MARK:颜色转图片
+(UIImage*)createImageWithColor:(UIColor*) color;

+ (UIImage *)resizeQRCodeImage:(CIImage *)image withSize:(CGFloat)size;

//MARK:修改图片大小
+(UIImage*)originImage:(UIImage *)image scaleToSize:(CGSize)size;

//MARK:修改图片颜色
+ (UIImage *)imageWithImageName:(NSString *)name imageColor:(UIColor *)imageColor;
+ (UIImage *)imageOriginal:(UIImage *)imgOriginal imageColor:(UIColor *)imgColor;

//MARK:旋转图片方向
+(UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation;

/**
 @brief 获取图片某个位置的RGB值
 @param point 需要取值的位置
 @return NSArray 返回@[@R,@G,@B]数组
 */
- (nullable NSArray<NSNumber *> *)pixelColorFromPoint:(CGPoint)point;

//MARK: 抓取截图
+ (UIImage *_Nonnull)snapshotView:(UIView *_Nonnull)view;
//MARK: 接受一个UIImage对象、一个CGPoint类型的中心点、一个CGFloat类型的半径和一个放大倍数，返回一个基于中心点和半径的圆形图片，并且已经按照指定的放大倍数进行了缩放。点的坐标是相对于整个图片的宽高百分比的，范围是0-1
+ (UIImage *_Nonnull)zoomInCircleImageWithImage:(UIImage *_Nonnull)image centerPoint:(CGPoint)centerPoint radius:(CGFloat)radius scale:(CGFloat)scale;
@end
