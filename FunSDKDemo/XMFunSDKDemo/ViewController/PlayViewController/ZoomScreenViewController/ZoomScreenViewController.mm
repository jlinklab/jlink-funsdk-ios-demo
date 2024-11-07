//
//  ZoomScreenViewController.m
//  FunSDKDemo
//
//  Created by zhang on 2024/10/30.
//  Copyright © 2024 zhang. All rights reserved.
//

#import "ZoomScreenViewController.h"
#import "PlayView.h"
#import "ZoomControlView.h"
#import "MultileMediaplayerControl.h"
#import "ScaleAnimationManager.h"



@interface ZoomScreenViewController () <MediaplayerControlDelegate>
{
    MultileMediaplayerControl *mediaControl;
    
    NSMutableDictionary *g_mediaPlayerDict;
    NSMutableDictionary *g_PlayViewDict;
    
    ChannelObject *channel;
    DeviceObject *device;
}
@property (strong, nonatomic) ScaleAnimationManager *scaleAnimationManager;
@property (strong, nonatomic) ZoomControlView *zoomControlView;
@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) PlayView *playView;

@end

@implementation ZoomScreenViewController

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self stopPlay];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    
    [self initSubView];
    
    [self startPlay];
    
}


- (void)startPlay {
    
    //初始化播放器
    mediaControl = [self getMediaplayerControl:channel.deviceMac channel:channel.channelNumber windowNumber:0];
    
    [mediaControl start];
}
- (void)stopPlay {
    [mediaControl stop];
}

- (void)playScreenChaned{
    
    if (device.threeScreen.length > 0 && [device.threeScreen intValue] > 1) {
        //支持APP多目效果，增加裁剪效果，展示裁剪后变倍功能
        mediaControl = [self getMediaplayerControl:channel.deviceMac channel:channel.channelNumber windowNumber:0];
        [mediaControl updateWindowDisplayMode:JF_MEFD_Bottom_Half_Mode playWindowMode:JFMultipleEyesPlayViewWindowMode_Fake_Portrait_Original];
        //刷新播放主画面frame
        [self rsetPlayViewRect:mediaControl];
        
        //分割视图1,这里设置显示原始画面上半部分
        MultileMediaplayerControl *control1 = [self getMediaplayerControl:channel.deviceMac channel:channel.channelNumber windowNumber:1];
        [control1 updateWindowDisplayMode:JF_MEFD_Top_Half_Mode playWindowMode:JFMultipleEyesPlayViewWindowMode_Fake_Portrait_Original];
        //刷新播放分割画面frame
        [self rsetPlayViewRect:control1];
    }
    else{
        //刷新播放分割画面frame
        [self rsetPlayViewRect];
    }
}

- (void)zoomMultiple:(float)multiple maxMultiple:(float)fMultiple {
    
    //计算实际需要缩放的倍数
    //实际倍数范围的跨度除以显示倍数范围的跨度
    CGFloat scale = (device.iAPPZoomScreenMaxNum - 1) / ((device.iAPPZoomScreenMaxDisplayNum - 1) * 1.0);
    //根据显示倍数和比例因子计算实际倍数
    CGFloat actualMultiplier = 1 + (multiple - 1) * scale;
    //缩放动画
    [self.scaleAnimationManager zoomControlViewChangeMultiple:actualMultiplier maxMultiple:device.iAPPZoomScreenMaxNum animationView:self.playView ignoreAnimation:NO];
}

//刷新播放画面frame
- (void)rsetPlayViewRect:(MultileMediaplayerControl *)mediaControl {
    
    //设置播放界面的起始y坐标。Y轴层级为： 起始Y坐标+上半部分画面高度+下半部分画面高度
    float y = NavHeight + 60;
    //原始画面的高度，三目品字型模式高度为 下方高度的3/4.双目上下屏高度为height
    float height = ScreenWidth * device.imageHeight / device.imageWidth;
    
    float mainY;

    //双目效果
    if (mediaControl.playWindowMode == JFMultipleEyesPlayViewWindowMode_Fake_Portrait_Original) {
        
        mainY = y + height/2.0 + 5; //（额外往下放平移5的高度，用来明确区分上下部分画面）
        if (mediaControl.windowNumber == 0) {
            //主视图，位置为固定播放画面下半部分
            self.playView.frame = CGRectMake(0, 0, ScreenWidth, height/2.0);
            self.backgroundView.frame = CGRectMake(0, mainY, ScreenWidth, height/2.0);
            [self resetZoomView];
        }
        else if (mediaControl.windowNumber == 1) {
            //分割视图1,位置为固定播放画面上半部分
            mediaControl.renderWnd.frame = CGRectMake(0, y, ScreenWidth, height/2.0);
        }
    }
}

- (void)rsetPlayViewRect {
    //设置播放界面的起始y坐标。Y轴层级为： 起始Y坐标+上半部分画面高度+下半部分画面高度
    float y = NavHeight + 60;
    float height = ScreenWidth * device.imageHeight / device.imageWidth;
    self.playView.frame = CGRectMake(0, 0, ScreenWidth, height);
    self.backgroundView.frame = CGRectMake(0, y, ScreenWidth, height);
}

- (void)resetZoomView {
    [_zoomControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backgroundView).mas_offset(50);
        make.right.equalTo(self.backgroundView).mas_offset(-50);
        make.bottom.equalTo(self.backgroundView);
        make.height.equalTo(@40);
    }];
}

#pragma mark - 开始预览结果回调
-(void)mediaPlayer:(MediaplayerControl*)mediaPlayer startResult:(int)result DSSResult:(int)dssResult{
    if (result >= 0) {
        [self.playView playViewBufferEnd];
    }else{
        [MessageUI ShowErrorInt:result];
    }
}

#pragma mark 预览收到视频宽高比信息，可以用来刷新播放画面的宽高
-(void)mediaPlayer:(MediaplayerControl*)mediaPlayer width:(int)width htight:(int)height {
    NSLog(@"width = %d; height = %d",width, height);
    DeviceObject *dev = [[DeviceControl getInstance] GetDeviceObjectBySN: mediaPlayer.devID];
    dev.imageWidth = width;
    dev.imageHeight = height;
    
    [self playScreenChaned];
}

#pragma mark  缓冲
-(void)mediaPlayer:(MediaplayerControl*)mediaPlayer buffering:(BOOL)isBuffering ratioDetail:(double)ratioDetail {
    //ratioDetail 画面比例
}

- (void)initSubView {
    //配置播放视图
    //
    self.playView = [self getMediaplayView:channel.deviceMac channel:channel.channelNumber windowNumber:0];
    
    //支持分割的设备，才会用到 view2
    PlayView *view2 = [self getMediaplayView:channel.deviceMac channel:channel.channelNumber windowNumber:1];
    
    [self initPlayBackView];
    
    //初始化变倍操作栏
    [self initZoomControlView];
}

- (void)initData {
    channel = [[DeviceControl getInstance] getSelectChannel];
    device = [[DeviceControl getInstance] GetDeviceObjectBySN:channel.deviceMac];
}

- (void)initPlayBackView {
    float width = ScreenWidth;
    float height = width *9/16;
    
    CGRect backRect = CGRectMake(0, NavHeight+20 , width, height);
    UIView *backView = [[UIView alloc] initWithFrame:backRect];
    backView.clipsToBounds = YES;
    self.backgroundView = backView;
    [self.view addSubview:self.backgroundView];
    
    // backgroundView 是变倍的背景view，playview的初始大小必须和背景view一样大
    [self.backgroundView addSubview:self.playView];

}

- (void)initZoomControlView {
    if (!_zoomControlView) {
        _zoomControlView = [[ZoomControlView alloc] initWithFrame:CGRectZero totalMultiple:device.iAPPZoomScreenMaxDisplayNum];
        _zoomControlView.backgroundColor = [UIColor clearColor];
        __weak typeof(self) weakSelf = self;
        _zoomControlView.multipleChangeCallBack = ^(float multiple,float fMultiple) {
            weakSelf.zoomControlView.curMultiple = multiple;
            [weakSelf zoomMultiple:multiple maxMultiple:fMultiple];
        };
    }
    [self.backgroundView addSubview:_zoomControlView];
    [self resetZoomView];
    
}


//初始化播放视图
- (PlayView*) getMediaplayView:(NSString*)deviceMac channel:(int)channel windowNumber:(int)number {
    
    if (!g_PlayViewDict) {
        g_PlayViewDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    NSString* mediaId = [NSString stringWithFormat:@"devid:%@;channel:%d;windowNum:%d", deviceMac, channel,number];
    
    PlayView *view = [g_PlayViewDict objectForKey:mediaId];
    if (!view) {
        
        float width = ScreenWidth;
        float height = width *9/16;
        view = [[PlayView alloc] init];
        [view refreshView:number];
        [self.view addSubview:view];
        
        if (number == 0) {
            //主视图设置宽高比16:18；
            height = width *9/16;
            [view playViewBufferIng];
        }else{
            //分割视图暂时不补设置高度，刷新模式时再设置
            height = width *0/16;
        }
        CGRect rect = CGRectMake(0, 0, width, height);
        view.frame = rect;
    }
    [g_PlayViewDict setObject:view forKey:mediaId];
    return view;
}

//初始化播放工具控制器
- (MultileMediaplayerControl*) getMediaplayerControl:(NSString*)deviceMac channel:(int)channel windowNumber:(int)number {
    if (!g_mediaPlayerDict) {
        g_mediaPlayerDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    NSString* mediaId = [NSString stringWithFormat:@"devid:%@;channel:%d;windowNum:%d", deviceMac, channel,number];
    MultileMediaplayerControl *control = [g_mediaPlayerDict objectForKey:mediaId];
    if (!control) {
        control = [[MultileMediaplayerControl alloc] init];
        control.devID = deviceMac;//设备序列号
        control.channel = channel;//当前通道号
        control.stream = 1;//这里默认打开了辅码流
        PlayView *view = [self getMediaplayView:deviceMac channel:channel windowNumber:number];
        control.renderWnd = view;
        control.delegate = self;
        control.windowNumber = number;
        control.nonuseYuv = YES; // 双目拼接设备也不使用YUV渲染模式，而是使用SDK渲染 （YUV模式会回调视频YUV数据给APP，APP自行渲染或调用特殊接口渲染，具体参考VRGLViewController的使用）
        if (number != 0) {
            //一路码流，共用一个播放具柄player （主播放器句柄）
            control.mainPlayer = mediaControl.player;
        }
        [g_mediaPlayerDict setObject:control forKey:mediaId];
    }

    
    return control;
}


- (ScaleAnimationManager *)scaleAnimationManager{
    if (!_scaleAnimationManager) {
        _scaleAnimationManager = [[ScaleAnimationManager alloc] init];
    }
    return  _scaleAnimationManager;
}

@end
