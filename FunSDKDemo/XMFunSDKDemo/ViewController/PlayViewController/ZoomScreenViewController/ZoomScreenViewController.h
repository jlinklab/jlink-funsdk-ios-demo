//
//  ZoomScreenViewController.h
//  FunSDKDemo
//
//  Created by zhang on 2024/10/30.
//  Copyright © 2024 zhang. All rights reserved.
//

/*
 *
The APP zoom effect is actually the process of enlarging or reducing the playback image by zooming in or out on the "play View" to achieve the desired image zoom in or out effect.
Some special equipment requires customers to add their own processing logic. For example, when zooming in on a multi view device app, in the demo, it is determined that the device supports multi view attributes before zooming in or out on individual screens. If the device does not support multi view attributes, the demo will perform APP zoom on the entire screen. To zoom in on a single shot, it is necessary to first crop the playback image and then apply APP zoom to the cropped image. Please refer to the processing logic in the playScreenChaned method for details
Business logic:
 
Normal logic:
1. Start playing the video according to the normal process [MediaControl start];
2. Add a zoom bar controller or zoom gesture to the screen to achieve zoom multiple effect
 
To crop the image, you can zoom in and out of a certain area of the screen
1. Start playing the video according to the normal process [MediaControl start];
2. Call the interface to crop the current playback range FUNMediaSetPlayViewAttr
3. Call the interface to crop the playback range of the second screen from the original playback data FUNMediaAddPlayView
4. Refresh the position and size of the first and subsequent playback images to achieve the effect of cropping one stream into two or more images playScreenChaned:
5. Add a zoom bar controller or zoom multiple gesture to the cropped image:
 
 APP变倍效果，其实就是对播放画面进行放大缩小，通过对播放view进行放大缩小，实现图像的放大缩小效果。
 部分特殊设备需要客户自己增加处理逻辑。比如多目设备APP变倍，demo这里判断设备支持多目属性时，才能对单独的画面进行APP变倍缩放。如果设备不支持多目属性，demo会对整个画面进行APP变倍缩放。想对单个某个镜头画面变倍，就需要先行对播放画面进行裁剪，并对裁剪后的画面进行APP变倍缩放，具体参考 playScreenChaned 方法中的处理逻辑
 业务逻辑：
 
 正常逻辑：
 1、按正常流程开始播放视频 [mediaControl start];
 2、对画面增加变倍条控制器，或者增加变倍手势，相应变倍效果 zoomMultiple:
 
 想要裁剪画面，可以变倍缩放画面其中一部分区域
 1、按正常流程开始播放视频 [mediaControl start];
 2、调用接口裁剪当前播放画面范围 FUN_MediaSetPlayViewAttr
 3、调用接口从原播放数据中裁剪第二画面播放范围 FUN_MediaAddPlayView
 4、刷新第一播放画面和后续播放画面的位置和大小，实现一路码流裁剪为两副/多幅画面的效果 playScreenChaned:
 5、对裁剪后的画面增加变倍条控制器，或者增加变倍手势 zoomMultiple:
 *
 */


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZoomScreenViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
