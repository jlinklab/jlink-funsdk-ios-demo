//
//  MultilePlayViewController.h
//  FunSDKDemo
//
//  Created by zhang on 2024/10/24.
//  Copyright © 2024 zhang. All rights reserved.
//
/*
 *
 APP multi view effect, mainly aimed at multi view devices with one stream splicing
 The device contains multiple cameras, and multiple video frames are spliced into a stream and sent to the APP. If the APP wants to achieve some special effects, it needs to re segment and crop the stream
 The demo mainly showcases the cropping function. Please develop the specific business logic according to the specific product design
 
 Business logic:
 1. Start playing the video according to the normal process; [MediaControl start];
 2. Call the interface to crop the current playback range; FUNMediaSetPlayViewAttr
 3. Call the interface to crop the playback range of the second screen from the original playback data; FUNMediaAddPlayView
 4. Refresh the position and size of the first and second playback images to achieve the effect of cropping one stream into two or more images
 
 
 APP多目效果，主要针对一路码流拼接的多目设备
 设备包含多个摄像头，多个视频画面拼接成一路码流发送给APP，APP这边想要实现部分特殊效果，就需要对一路码流重新做分割和裁剪
 demo这里主要展示裁剪功能，具体业务逻辑请根据具体产品设计进行开发
 业务逻辑：
 1、按正常流程开始播放视频 [mediaControl start];
 2、调用接口裁剪当前播放画面范围 FUN_MediaSetPlayViewAttr
 3、调用接口从原播放数据中裁剪第二画面播放范围 FUN_MediaAddPlayView
 4、刷新第一播放画面和后续播放画面的位置和大小，实现一路码流裁剪为两副/多幅画面的效果 playScreenChaned:
 *
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MultilePlayViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
