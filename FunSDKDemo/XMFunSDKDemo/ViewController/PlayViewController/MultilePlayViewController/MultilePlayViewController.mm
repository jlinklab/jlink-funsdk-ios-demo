//
//  MultilePlayViewController.m
//  FunSDKDemo
//
//  Created by zhang on 2024/10/24.
//  Copyright © 2024 zhang. All rights reserved.
//

#import "MultilePlayViewController.h"

#import "PlayView.h"
#import "MultileMediaplayerControl.h"

@interface MultilePlayViewController () <MediaplayerControlDelegate>
{
    MultileMediaplayerControl *mediaControl;
    NSMutableDictionary *g_mediaPlayerDict;
    NSMutableDictionary *g_PlayViewDict;
    
    ChannelObject *channel;
    DeviceObject *device;
}
@property (nonatomic,assign) JF_Multiple_Eyes_Device_Type medType;
@property (weak, nonatomic) PlayView *playView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *playScreenControl;

@end

@implementation MultilePlayViewController

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self stopPlay];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化对象
    [self initData];
    
    //配置子视图
    [self configSubView];
    
    //初始化播放器
    [self initPlayer];
    
    //开始播放
    [self startPlay];
    
    //刷新播放画面
    [self playScreenChaned:self.playScreenControl];
}

#pragma mark - 功能接口

- (void)startPlay {
    //demo这里，播放视频和停止播放视频功能没有做复杂考虑，仅增加了进入播放和推出停止，用来协助展示画面裁剪算法
    mediaControl.player = [mediaControl start];
    NSLog(@"mediaControl.player  = %d",mediaControl.player);
}
- (void)stopPlay {
    [mediaControl stop];
}

- (IBAction)playScreenChaned:(UISegmentedControl *)sender {
    
    if (sender.selectedSegmentIndex == 0) {
        //双目模式，刷新模式和UI
        [self updateMediaViewWithWindowMode:JFMultipleEyesPlayViewWindowMode_Fake_Portrait_Original];
    }
    if (sender.selectedSegmentIndex == 1) {
        //三目模式
        if ([device.threeScreen intValue] == 3) {
            //判断支持三目模式才执行操作
            [self updateMediaViewWithWindowMode:JFMultipleEyesPlayViewWindowMode_Fake_Portrait_Two_Small_Up_List];
        }else{
            //不支持3目，demo这里改为执行2目分割裁剪，防止刷新出现问题，实际使用中以设计为准
            [self updateMediaViewWithWindowMode:JFMultipleEyesPlayViewWindowMode_Fake_Portrait_Original];
        }
        
    }
}

#pragma mark - 模式和窗口设置函数
/**
 @brief 根据窗口显示模式刷新实际显示效果 切换完当前模式后或者重新起流后需要调用SDK刷新界面显示内容
 */
- (void)updateMediaViewWithWindowMode:(JFMultipleEyesPlayViewWindowMode)mode{
    if (mode == JFMultipleEyesPlayViewWindowMode_Fake_Portrait_Original) {
        
        //主视图，这里设置显示原始画面下半部分
        mediaControl = [self getMediaplayerControl:channel.deviceMac channel:channel.channelNumber windowNumber:0];
        [mediaControl updateWindowDisplayMode:JF_MEFD_Bottom_Half_Mode playWindowMode:mode];
        //刷新播放主画面frame
        [self rsetPlayViewRect:mediaControl];
        
        //分割视图1,这里设置显示原始画面上半部分
        MultileMediaplayerControl *control1 = [self getMediaplayerControl:channel.deviceMac channel:channel.channelNumber windowNumber:1];
        [control1 updateWindowDisplayMode:JF_MEFD_Top_Half_Mode playWindowMode:mode];
        //刷新播放分割画面frame
        [self rsetPlayViewRect:control1];
        
        MultileMediaplayerControl *control2 = [self getMediaplayerControl:channel.deviceMac channel:channel.channelNumber windowNumber:2];
        //2目模式下，第三个画面设置为隐藏
        control2.renderWnd.hidden = YES;
        
    }else if (mode == JFMultipleEyesPlayViewWindowMode_Fake_Portrait_Two_Small_Up_List) {
        //主视图 这里设置显示原始画面下半部分
        mediaControl = [self getMediaplayerControl:channel.deviceMac channel:channel.channelNumber windowNumber:0];
        [mediaControl updateWindowDisplayMode:JF_MEFD_Bottom_Half_Mode playWindowMode:mode];
        //刷新播放主画面frame
        [self rsetPlayViewRect:mediaControl];
        
        //分割视图1 这里设置显示原始画面左上部分
        MultileMediaplayerControl *control1 = [self getMediaplayerControl:channel.deviceMac channel:channel.channelNumber windowNumber:1];
        [control1 updateWindowDisplayMode:JF_MEFD_Top_Left_Middel_Mode playWindowMode:mode];
        //刷新播放分割画面frame
        [self rsetPlayViewRect:control1];
        
        //分割视图2 这里设置显示原始画面右上部分
        MultileMediaplayerControl *control2 = [self getMediaplayerControl:channel.deviceMac channel:channel.channelNumber windowNumber:2];
        [control2 updateWindowDisplayMode:JF_MEFD_Top_Right_Middel_Mode playWindowMode:mode];
        //刷新播放分割画面frame
        [self rsetPlayViewRect:control2];
        //分割画面设置为显示
        control2.renderWnd.hidden = NO;
    }
    
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
            mediaControl.renderWnd.frame = CGRectMake(0, mainY, ScreenWidth, height/2.0);
        }
        else if (mediaControl.windowNumber == 1) {
            //分割视图1,位置为固定播放画面上半部分
            mediaControl.renderWnd.frame = CGRectMake(0, y, ScreenWidth, height/2.0);
        }
    }
    //三目效果
    if (mediaControl.playWindowMode == JFMultipleEyesPlayViewWindowMode_Fake_Portrait_Two_Small_Up_List) {
        
        mainY = y + height/4.0 +5; //（额外往下放平移5的高度，用来明确区分上下部分画面）
        
        if (mediaControl.windowNumber == 0) {
            //主视图，位置为固定的下半部分
            mediaControl.renderWnd.frame = CGRectMake(0, mainY, ScreenWidth, height/2.0);
        }
        else if (mediaControl.windowNumber == 1) {
            //分割视图1
            mediaControl.renderWnd.frame = CGRectMake(0, y, ScreenWidth/2.0 - 1, height/4.0); // 宽度 -1 是为了便于观察demo功能的分割画面功能
        }
        else if (mediaControl.windowNumber == 2) {
            //分割视图2
            mediaControl.renderWnd.frame = CGRectMake(ScreenWidth/2.00, y, ScreenWidth/2.0, height/4.0);
        }
    }
}
#pragma mark - 预览结果回调
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
}

#pragma mark  - 初始化函数
- (void)initData {
    channel = [[DeviceControl getInstance] getSelectChannel];
    device = [[DeviceControl getInstance] GetDeviceObjectBySN:channel.deviceMac];
}

- (void)configSubView {
    //初始化主播放画面    Init main playView
    self.playView = [self getMediaplayView:channel.deviceMac channel:channel.channelNumber windowNumber:0];
}

- (void)initPlayer {
    //初始化主播放控制器    Init main playControl
    mediaControl = [self getMediaplayerControl:channel.deviceMac channel:channel.channelNumber windowNumber:0];
}

//初始化播放视图
- (PlayView*) getMediaplayView:(NSString*)deviceMac channel:(int)channel windowNumber:(int)number {
    
    if (!g_PlayViewDict) {
        g_PlayViewDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    NSString* mediaId = [NSString stringWithFormat:@"devid:%@;channel:%d;windowNum:%d", deviceMac, channel,number];
    
    PlayView *view = [g_PlayViewDict objectForKey:mediaId];
    if (!view) {
        
        float width = ScreenWidth-40;
        float height = width *9/16;
        view = [[PlayView alloc] init];
        [view refreshView:number];
        [self.view addSubview:view];
        
        if (number == 0) {
            //主视图设置宽高比16:18；
            height = width *18/16;
            [view playViewBufferIng];
        }else{
            //分割视图暂时不补设置高度，刷新模式时再设置
            height = width *0/16;
        }
        CGRect rect = CGRectMake(20, NavHeight+60, width, height);
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
@end
