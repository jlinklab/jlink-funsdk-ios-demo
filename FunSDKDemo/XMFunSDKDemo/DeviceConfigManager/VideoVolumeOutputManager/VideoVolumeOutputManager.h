//
//  VideoVolumeOutputManager.h
//   
//
//  Created by Tony Stark on 2021/7/22.
//  Copyright © 2021 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FunSDKBaseObject.h"

//获取音量输出回调
typedef void(^GetVideoVolumeOutputCallBack)(int result,int channel);
//保存音量输出回调
typedef void(^SetVideoVolumeOutputCallBack)(int result,int channel);

NS_ASSUME_NONNULL_BEGIN

/*
 音量输出设置
 */
@interface VideoVolumeOutputManager : FunSDKBaseObject

@property (nonatomic,copy) GetVideoVolumeOutputCallBack getVideoVolumeOutputCallBack;

@property (nonatomic,copy) SetVideoVolumeOutputCallBack setVideoVolumeOutputCallBack;

//MARK: 获取音量输出
- (void)getVideoVolumeOutput:(NSString *)devID channel:(int)channel completed:(GetVideoVolumeOutputCallBack)completion;
//MARK: 设置音量输出
- (void)setVideoVolumeOutputCompleted:(SetVideoVolumeOutputCallBack)completion;

//MARK: 获取左声道音量
- (int)getLeftVolume;
//MARK: 设置左声道音量
- (void)setLeftVolume:(int)volume;
//MARK: 获取右声道音量
- (int)getRightVolume;
//MARK: 设置右声道音量
- (void)setRightVolume:(int)volume;

@end

NS_ASSUME_NONNULL_END
