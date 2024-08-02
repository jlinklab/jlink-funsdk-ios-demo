//
//  WDRViewController.m
//  FunSDKDemo
//
//  Created by zhang on 2024/7/17.
//  Copyright © 2024 zhang. All rights reserved.
//

#import "WDRViewController.h"
#import "PlayView.h"
#import "FlipManager.h"
#import "MediaplayerControl.h"

@interface WDRViewController () <MediaplayerControlDelegate,FlipManagerDelegate>
{
    FlipManager *manager;
    MediaplayerControl *mediaControl;
}
@property (weak, nonatomic) IBOutlet UILabel *titlelabel;
@property (weak, nonatomic) IBOutlet UISwitch *WDR_Switch;
@property (weak, nonatomic) IBOutlet UILabel *detaillabel;
@property (weak, nonatomic) IBOutlet PlayView *playView;

@end

@implementation WDRViewController

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self stopPlay];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //配置子视图
    [self configSubView];
    [self initData];
    
    [self getConfig];
    
    [self startPlay];
    
    
}

#pragma mark - 获取配置
- (void)getConfig {
    [SVProgressHUD show];
    [manager getWDRConfig];
}



- (void)startPlay {
    [mediaControl start];
}
- (void)stopPlay {
    [mediaControl stop];
}
- (void)saveConfig {
    [SVProgressHUD show];
    [manager setWDRConfig:self.WDR_Switch.isOn];
}

//获取WDR配置代理回调
- (void)getWDRConfigResult:(NSInteger)result {
    if (result < 0) {
        [MessageUI ShowErrorInt:result];
        return;
    }
    [SVProgressHUD dismiss];
    BOOL wdr = [manager readWDR];
    [self.WDR_Switch setOn:wdr];
}
//保存WDR配置代理回调
- (void)setWDRConfigResult:(NSInteger)result {
    if (result < 0) {
        [MessageUI ShowErrorInt:result];
        return;
    }
    [SVProgressHUD dismiss];
}

#pragma mark - 开始预览结果回调
-(void)mediaPlayer:(MediaplayerControl*)mediaPlayer startResult:(int)result DSSResult:(int)dssResult{
    if (result >= 0) {
        [self.playView playViewBufferEnd];
    }else{
        [MessageUI ShowErrorInt:result];
    }
}

- (void)configSubView {
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave  target:self action:@selector(saveConfig)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    self.titlelabel.text = TS("TR_Broad_Thrends_Switch");
    self.detaillabel.text = TS("TR_Broad_Thrends_Config_Tips");
    
    [self initPlayView];

}
- (void)initData {
    [self initManager];
    [self initMediaPlayer];
}

- (void)initPlayView {
    float width = ScreenWidth-40;
    float height = width *3/4;
    CGRect rect = CGRectMake(20, 240, width, height);
    PlayView *view = [[PlayView alloc] initWithFrame:rect];
    self.playView = view;
    [self.view addSubview:self.playView];
    [self.playView refreshView:0];
    [self.playView playViewBufferIng];
}

- (void)initManager {
    manager = [[FlipManager alloc] init];
    manager.delegate = self;
    ChannelObject *object = [[DeviceControl getInstance] getSelectChannel];
    manager.devID = object.deviceMac;
}

- (void)initMediaPlayer {
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    mediaControl = [[MediaplayerControl alloc] init];
    mediaControl.devID = channel.deviceMac;//设备序列号
    mediaControl.channel = channel.channelNumber;//当前通道号
    mediaControl.stream = 1;//辅码流
    mediaControl.renderWnd = self.playView;
    mediaControl.delegate = self;
    mediaControl.index = 1000;
}

@end
