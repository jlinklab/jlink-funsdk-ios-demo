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
    
    NSMutableDictionary *g_mediaPlayerDict; //多目播放工具数组
    NSMutableDictionary *g_PlayViewDict; // 多目播放画布数组
    NSMutableDictionary *g_ZoomDict; // 多目播放变倍条数组
    
    ChannelObject *channel;
    DeviceObject *device;
    
    BOOL rsetRect;
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
    if (rsetRect == YES) {
        //如果多次刷新多目裁剪效果，并且其间操作过变倍，则有可能出现变倍计算异常。因此这里简单限制为只允许刷新一次，并且刷新前不允许操作变倍。（目前的变倍算法不允许在操作变倍之后，再改动位置和大小。如果要改动，则需要优化变倍算法。优化算法暂无，候补，APP上层逻辑）
        return;
    }
    rsetRect = YES;
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
    
    if (rsetRect == NO) {
        //如果刷新裁剪画面前操作过变倍，则demo后续变倍计算会有问题。demo这里简单做了限制，未刷新前不允许变倍。可以在刷新后重置变倍参数来解决 （目前的变倍算法不允许在操作变倍之后，再改动位置和大小。如果要改动，则需要优化变倍算法。优化算法暂无，候补，APP上层逻辑）
        return;
    }
    
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

#pragma mark- 打开视频预览回调  预览收到视频宽高比信息，可以用来刷新播放画面的宽高
-(void)mediaPlayer:(MediaplayerControl*)mediaPlayer width:(int)width htight:(int)height {
    NSLog(@"width = %d; height = %d",width, height);
    DeviceObject *dev = [[DeviceControl getInstance] GetDeviceObjectBySN: mediaPlayer.devID];
    dev.imageWidth = width;
    dev.imageHeight = height;
}


#pragma mark - 打开视频预览回调 -视频缓冲中
-(void)mediaPlayer:(MediaplayerControl*)mediaPlayer buffering:(BOOL)isBuffering ratioDetail:(double)ratioDetail {
    //ratioDetail 画面比例
    [self playScreenChaned];
}
#pragma mark 打开视频预览 自定义信息帧回调，通过这个判断是什么模式在预览
-(void)mediaPlayer:(MediaplayerControl*)mediaPlayer Hardandsoft:(int)Hardandsoft Hardmodel:(int)Hardmodel {
    //一路码流双目
    if(Hardmodel == XMVR_TYPE_TWO_LENSES){
       //说明当前是双目拼接设备，即便设备没有多目属性，demo这里依然设置为可以双目裁剪，并展示裁剪后的效果 （部分设备目前配置的有双目拼接支持3目效果）
        DeviceObject *dev = [[DeviceControl getInstance] GetDeviceObjectBySN: mediaPlayer.devID];
        if (dev.threeScreen.length == 0) {
            //多目拼接设备，但是未获取到支持多目裁剪效果，则这里直接赋值为支持
            dev.threeScreen = @"2";
        }
        [self playScreenChaned];
        [[DeviceControl getInstance] saveDeviceList];
    }
}

- (void)initSubView {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
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
