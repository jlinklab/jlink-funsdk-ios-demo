//
//  PTZLocateView.h
//   iCSee
//
//  Created by ctrl+c on 2023/4/6.
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MaskView.h"
#import "PTZProcessManager.h"
#import "FunSDKBaseView.h"

@protocol PTZLocateViewDelegate <NSObject>

- (void)startPlayBufferEndWidth:(float)width height:(float)height;

//YUV数据流
-(void)PushYUVDataWidth:(int)width height:(int)height YUVData:(unsigned char *)pData;

//用YUV数据开始播放
-(void)startplayAfterBufferEnd;

//触碰点复位(中心位置)
-(void)touchesPointReset;

@end

@interface PTZLocateView : FunSDKBaseView


@property (nonatomic, assign) int channelNum;

@property (nonatomic, assign) NSString *devID;
@property (nonatomic, assign) int channel;

@property (nonatomic, weak) id <PTZLocateViewDelegate> delegate;

//背景视图
@property (nonatomic, strong) UIView *playBackViewOfGun;

@property (nonatomic, strong) UIView *playBackViewOfBall;

@property (nonatomic, strong) MaskView *maskView;

@property (nonatomic, strong) UIButton *resetBtn;

/**云台处理逻辑管理者*/
@property (nonatomic,strong) PTZProcessManager *ptzProcessManager;

#pragma mark -- 开始启流
-(void)startPlayWithPlayViewOfGun:(UIView *)gunView PlayViewOfBall:(UIView *)ballView;

#pragma mark -- 停止播放
-(void)stopPlay;

//MARK: 发送云台命令
- (void)sendPTZ:(int)direction stop:(BOOL)stop;

@end

