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
    
    BOOL rsetRect; //开启预览后是否已刷新过预览模式 （不允许重复刷新预览模式）
    BOOL landscape; //横屏
    BOOL fullScreen; //横屏下双目摄像机是否全屏播放某个镜头
}
@property (strong, nonatomic) ScaleAnimationManager *scaleAnimationManager;
@property (strong, nonatomic) ZoomControlView *zoomControlView;
@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) PlayView *playView;
@property (strong, nonatomic) PlayView *playView2;

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
    
    //初始化播放器，播放成功后继续刷新UI （也可以缓存播放参数，后续进入时直接刷新）
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

- (void)rsetPlayViewRectLandscape:(MultileMediaplayerControl *)mediaControl {
    
    //原始画面的高度，三目品字型模式高度为 下方高度的3/4.双目上下屏高度为height
    float height = ScreenHeight * device.imageHeight / device.imageWidth /2.0;
    float width = ScreenWidth/2.0 - 15;
    
    //设置播放界面的起始y坐标。Y轴层级为： 起始Y坐标+上半部分画面高度+下半部分画面高度
    float mainY = (ScreenHeight - height) / 2.0;
    float mainX = ScreenWidth/2.0 + 5;

    //双目效果
    if (mediaControl.playWindowMode == JFMultipleEyesPlayViewWindowMode_Fake_Portrait_Original) {
        
        if (mediaControl.windowNumber == 0) {
            //主视图，位置为固定播放画面下半部分
            self.playView.frame = CGRectMake(0, 0, width, height);
            self.backgroundView.frame = CGRectMake(mainX, mainY, width, height);
            [self resetZoomView];
        }
        else if (mediaControl.windowNumber == 1) {
            //分割视图1,位置为固定播放画面上半部分
            mediaControl.renderWnd.frame = CGRectMake(5, mainY, width, height);
        }
    }
}

- (void)rsetPlayViewRectLandscape {
    self.playView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight-20);
    self.backgroundView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight-20);
    [self resetZoomView];
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
#pragma mark // 自定义信息帧回调重要说明
            //双目拼接设备中的一部分硬件类型配置过这个PID属性，但并不是所有设备都配置过这个属性。但是因双目拼接设备后续希望都按裁剪来走，因此默认参数设置为2，支持分屏为2个画面，所以未获取到支持多目裁剪效果的参数时，则这里直接赋值为支持，且为2画面裁剪。原先按一画面走时，一些功能如变倍缩放等手势不太好处理，因此考虑都按裁剪流程走，分开处理就可以规避这些问题。
            dev.threeScreen = @"2";
            //设置为支持多目裁剪效果，可以重新按照裁剪方式刷新UI
            rsetRect = NO;
            
        }
        [self playScreenChaned];
        [[DeviceControl getInstance] saveDeviceList];
    }
}


#pragma mark - 全屏处理
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
     [self layoutWithDeviceOrientation:toInterfaceOrientation];
}

-(void)layoutWithDeviceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    if (device == nil) {
        [self initData];
    }
    [self transformIdentity];
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || \
        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        if (@available(iOS 16.0, *)){
            landscape = YES;
            [UIView animateWithDuration:0.3 animations:^{
                if (device.threeScreen.length > 0 && [device.threeScreen intValue] > 1) {
                    //支持APP多目效果，增加裁剪效果，展示裁剪后变倍功能
                    mediaControl = [self getMediaplayerControl:channel.deviceMac channel:channel.channelNumber windowNumber:0];
                    //刷新播放主画面frame
                    [self rsetPlayViewRectLandscape:mediaControl];
                    
                    //分割视图1,这里设置显示原始画面上半部分
                    MultileMediaplayerControl *control1 = [self getMediaplayerControl:channel.deviceMac channel:channel.channelNumber windowNumber:1];
                    //刷新播放分割画面frame
                    [self rsetPlayViewRectLandscape:control1];
                }
                else{
                    //刷新播放分割画面frame
                    [self rsetPlayViewRectLandscape];
                }
            } completion:nil];
        }
        self.navigationController.navigationBar.hidden = YES;
    }else{
        if (@available(iOS 16.0, *)){
            landscape = NO;
            [UIView animateWithDuration:0.3 animations:^{
                if (device.threeScreen.length > 0 && [device.threeScreen intValue] > 1) {
                    //支持APP多目效果，增加裁剪效果，展示裁剪后变倍功能
                    mediaControl = [self getMediaplayerControl:channel.deviceMac channel:channel.channelNumber windowNumber:0];
                    //刷新播放主画面frame
                    [self rsetPlayViewRect:mediaControl];
                    
                    //分割视图1,这里设置显示原始画面上半部分
                    MultileMediaplayerControl *control1 = [self getMediaplayerControl:channel.deviceMac channel:channel.channelNumber windowNumber:1];
                    //刷新播放分割画面frame
                    [self rsetPlayViewRect:control1];
                }
                else{
                    //刷新播放分割画面frame
                    [self rsetPlayViewRect];
                }
            } completion:nil];
        }
        self.navigationController.navigationBar.hidden = NO;
    }
}

#pragma mark - 双击手势
- (void)tapActionHappened:(UITapGestureRecognizer *)gesture{
    if (!landscape) {
        //非横屏，不支持双击放大手势
        return;
    }
    if (device.threeScreen.length == 0) {
        //非双目设备，不支持双击放大手势
        return;
    }
    fullScreen = !fullScreen;
    if (gesture.state == UIGestureRecognizerStateEnded){
        UIView *tapView = gesture.view;
        if (fullScreen) {
            if (tapView.tag == 1) {
                //枪机画面
               self.playView2.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight-20);
            }
            if (tapView.tag == 0) {
                //球机画面
                [self transformIdentity];
                
                self.playView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight-20);
                self.backgroundView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight-20);
            }
        }else{
            [self transformIdentity];
            //支持APP多目效果，增加裁剪效果，展示裁剪后变倍功能
            mediaControl = [self getMediaplayerControl:channel.deviceMac channel:channel.channelNumber windowNumber:0];
            //刷新播放主画面frame
            [self rsetPlayViewRectLandscape:mediaControl];
            
            //分割视图1,这里设置显示原始画面上半部分
            MultileMediaplayerControl *control1 = [self getMediaplayerControl:channel.deviceMac channel:channel.channelNumber windowNumber:1];
            //刷新播放分割画面frame
            [self rsetPlayViewRectLandscape:control1];
        }
        
    }
}

- (void)transformIdentity {
    self.zoomControlView.curMultiple = 1.0;
    self.playView.transform = CGAffineTransformIdentity;
}

- (void)initSubView {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //配置播放视图
    //
    self.playView = [self getMediaplayView:channel.deviceMac channel:channel.channelNumber windowNumber:0];
    
    //支持分割的设备，才会用到 view2
    self.playView2 = [self getMediaplayView:channel.deviceMac channel:channel.channelNumber windowNumber:1];
    
    
    
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
        view.tag = number;
        
        //双击手势
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapActionHappened:)];
        recognizer.numberOfTapsRequired = 2;
        [view addGestureRecognizer:recognizer];
        
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
