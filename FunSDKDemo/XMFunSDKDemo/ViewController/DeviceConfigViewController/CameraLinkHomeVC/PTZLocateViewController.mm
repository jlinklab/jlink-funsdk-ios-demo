//
//  PTZLocateViewController.m
//   iCSee
//
//  Created by ctrl+c on 2023/4/6.
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import "PTZLocateViewController.h"
#import "PTZLocateView.h"
#import <FunSDK/FunSDK.h>
#import "UIViewController+JFForbiddenSwipeRight.h"
#import "VRGLViewController.h"

typedef NS_ENUM(NSInteger,PTZDirectionLocate) {
    PTZDirectionLocate_None = -1,                 //没有云台
    PTZDirectionLocate_UP,                        //上
    PTZDirectionLocate_DOWN,                      //下
    PTZDirectionLocate_LEFT,                      //左
    PTZDirectionLocate_RIGHT,                     //右
};

@interface PTZLocateViewController ()<PTZLocateViewDelegate,VRGLViewControllerDelegate>

@property (nonatomic, assign) int msgHandle;

@property (nonatomic, strong) PTZLocateView *ptzLocateView;

@property (nonatomic, strong) VRGLViewController *mediaViewControllerOfGun;

@property (nonatomic, strong) VRGLViewController *mediaViewControllerOfBall;

@property (nonatomic, strong) UIImage *lastImage;

//手指拖动的放大图片
@property (nonatomic, strong) UIImageView *imgMove;
@property (nonatomic, strong) UIImageView *imgDownArrow;

//手指点击的基准图片
@property (nonatomic, strong) UIImageView *referenceImage;

//点击坐标和视图的比例
@property (nonatomic, assign) CGPoint scalePoint;

//加载过程中不允许返回
@property (nonatomic,assign) BOOL allowBack;

//最近一次云台微调的方向
@property (nonatomic,assign) PTZDirectionLocate lastDirection;

@property (nonatomic,assign) BOOL firstIn;  //是否是首次进入 首次进入需要禁止侧滑
@property (nonatomic,assign) BOOL needUnfreeze;  //是否需要解除限制

@end

@implementation PTZLocateViewController

static float kRadius = 30;
static float kScale = 1;

- (instancetype)init{
    self = [super init];
    if (self) {
        self.msgHandle = FUN_RegWnd((__bridge LP_WND_OBJ)self);
        self.channel = -1;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.firstIn = YES;
    
    [self myConfigNav];
    
    //配置子视图
    [self configSubViews];
    
    self.scalePoint = CGPointMake(0.5, 0.5);
    
    [self.ptzLocateView.ptzProcessManager requestNecessaryConfig:self.devID channel:self.channel useCache:YES];
    //相机初始化,让云台转到产测的坐标,超时时间20s
    NSString *cmdName = @"OPGunBallPtzLocateInit";
    NSDictionary *dic = @{@"Name":cmdName,cmdName:@[@{}]};
    NSString *str = [NSString convertToJSONData:dic];
    int size = [NSString getCharArraySize:str];
    char cfg[size];
    memcpy(cfg, [str cStringUsingEncoding:NSUTF8StringEncoding], 2*[str length]);
    
    FUN_DevCmdGeneral(self.msgHandle, self.devID.UTF8String, 3032, cmdName.UTF8String, -1, 60000, cfg, (int)strlen(cfg) + 1, -1, 1020);
    [SVProgressHUD showWithStatus: TS("TR_Camera_initialization")];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self performSelector:@selector(cacheImage) withObject:nil afterDelay:0.1];
    });
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.firstIn) {
        [self forbiddenSwipeRightGesture:self];
        self.firstIn = NO;
        self.needUnfreeze = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    if (self.needUnfreeze) {
        [self openSwipeRightGesture:self];
        self.needUnfreeze = NO;
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)cacheImage{
    self.lastImage = [UIImage snapshotView:self.mediaViewControllerOfBall.view];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(cacheImage) withObject:nil afterDelay:0.1];
}

//MARK: - OnFunSDKResult
- (void)OnFunSDKResult:(NSNumber *)pParam{
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    switch (msg->id) {
        case EMSG_DEV_CMD_EN:
        {
            if ( strcmp(msg->szStr, "OPGunBallPtzLocateInit") == 0 ) {
                self.allowBack = YES;
                if (msg->param1 >= 0) {
                    __weak typeof(self) weakSelf = self;
                        if (weakSelf.needUnfreeze) {
                            [weakSelf openSwipeRightGesture:weakSelf];
                            weakSelf.needUnfreeze = NO;
                        }
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [weakSelf addRightButton];
                            [weakSelf.view addSubview:weakSelf.ptzLocateView];
                            [weakSelf.ptzLocateView mas_makeConstraints:^(MASConstraintMaker *make) {
                                make.edges.equalTo(weakSelf.view);
                            }];
                            
                            [weakSelf addChildViewController:weakSelf.mediaViewControllerOfGun];
                            [weakSelf addChildViewController:weakSelf.mediaViewControllerOfBall];
                            
                            [weakSelf.ptzLocateView startPlayWithPlayViewOfGun:weakSelf.mediaViewControllerOfGun.view PlayViewOfBall:weakSelf.mediaViewControllerOfBall.view];
                            
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                [weakSelf startplayAfterBufferEnd];
                            });
                            
                        });
                }else{
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat: @"%d", msg->param1]];
                    [self btnBackClicked];
                }
            }else if (strcmp(msg->szStr, "OPGunBallPtzLocateAdjust") == 0 ){
                if (msg->param1 >= 0) {
                    [SVProgressHUD showSuccessWithStatus:TS("Save_Success")];
                    [self btnBackClicked];
                }else{
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat: @"%d", msg->param1]];
                }
            }
        }
            break;
        default:
            break;
    }
}

-(void)configSubViews{
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

//MARK: - ConfigNav
- (void)myConfigNav{
    self.navigationItem.title = TS("TR_Device_camera_link_aiming");
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, 0, 32, 32);
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"new_back.png"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(btnBackClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarBtn = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftBarBtn;
}

- (void)addRightButton{
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, 40, 30);
    [rightBtn setTitle:TS("OK") forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(btnSaveClicked) forControlEvents:UIControlEventTouchUpInside];
    rightBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
}

-(void)btnSaveClicked{
    [SVProgressHUD show];
    
    CGFloat xoffset = self.scalePoint.x *(4096*2) - 4096;
    CGFloat yoffset = 4096 - self.scalePoint.y *(4096*2);
    //相机初始化,让云台转到产测的坐标,超时时间20s
    NSString *cmdName = @"OPGunBallPtzLocateAdjust";
    NSDictionary *dic = @{@"Name":cmdName,cmdName:@[@{@"xoffset":[NSNumber numberWithFloat:xoffset],@"yoffset":[NSNumber numberWithFloat:yoffset]}]};
    NSString *str = [NSString convertToJSONData:dic];
    int size = [NSString getCharArraySize:str];
    char cfg[size];
    memcpy(cfg, [str cStringUsingEncoding:NSUTF8StringEncoding], 2*[str length]);
    
    FUN_DevCmdGeneral(self.msgHandle, self.devID.UTF8String, 3032, cmdName.UTF8String, -1, 60000, cfg, (int)strlen(cfg) + 1, -1, 1020);
}

-(void)btnBackClicked{
    if (!self.allowBack) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)startPlayBufferEndWidth:(float)width height:(float)height{
    DeviceObject *devSave = [[DeviceControl getInstance] GetDeviceObjectBySN: self.devID];
    devSave.imageWidth = width;
    devSave.imageHeight = height;
    
    if (devSave.iSceneType == XMVR_TYPE_TWO_LENSES) {
        [self.mediaViewControllerOfGun setVRFecParams:devSave.imageWidth * 0.5 yCenter:devSave.imageHeight * 0.5 radius:devSave.imageWidth * 0.5 Width:devSave.imageWidth Height:devSave.imageHeight * 0.5];
        [self.mediaViewControllerOfBall setVRFecParams:devSave.imageWidth * 0.5 yCenter:devSave.imageHeight * 0.5 radius:devSave.imageWidth * 0.5 Width:devSave.imageWidth Height:devSave.imageHeight * 0.5];
    }
}

-(void)PushYUVDataWidth:(int)width height:(int)height YUVData:(unsigned char *)pData{
    [self.mediaViewControllerOfGun PushData:width height:height YUVData:pData];
    [self.mediaViewControllerOfBall PushData:width height:height YUVData:pData];
}

-(void)startplayAfterBufferEnd{
    [self.mediaViewControllerOfGun configSoftEAGLContext];
    [self.mediaViewControllerOfGun setVRType:XMVR_TYPE_TWO_LENSES_IN_ONE];
    
    [self.mediaViewControllerOfBall configSoftEAGLContext];
    [self.mediaViewControllerOfBall setVRType:XMVR_TYPE_TWO_LENSES_IN_ONE];
    self.mediaViewControllerOfBall.view.layer.cornerRadius = 10;
    self.mediaViewControllerOfBall.view.layer.masksToBounds = YES;
    
    [self.ptzLocateView.playBackViewOfBall addSubview:self.referenceImage];
    [self.ptzLocateView.playBackViewOfBall bringSubviewToFront:self.referenceImage];
    self.referenceImage.center = CGPointMake(self.ptzLocateView.playBackViewOfBall.frame.size.width*0.5, self.ptzLocateView.playBackViewOfBall.frame.size.height*0.5);
    
    DeviceObject *devInfo = [[DeviceControl getInstance] GetDeviceObjectBySN: self.devID];
    if (devInfo.imageWidth != 0 && devInfo.imageHeight != 0) {
        [self.mediaViewControllerOfGun setVRFecParams:devInfo.imageWidth * 0.5 yCenter:devInfo.imageHeight * 0.5 radius:devInfo.imageWidth * 0.5 Width:devInfo.imageWidth Height:devInfo.imageHeight * 0.5];
        [self.mediaViewControllerOfBall setVRFecParams:devInfo.imageWidth * 0.5 yCenter:devInfo.imageHeight * 0.5 radius:devInfo.imageWidth * 0.5 Width:devInfo.imageWidth Height:devInfo.imageHeight * 0.5];
    }
    
    [self.mediaViewControllerOfGun setTwoLensesDrawMode:TopOnly];
    [self.mediaViewControllerOfBall setTwoLensesDrawMode:BottomOnly];
    
    [self.ptzLocateView.playBackViewOfGun addSubview:self.mediaViewControllerOfGun.view];
    [self.mediaViewControllerOfGun.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.ptzLocateView.playBackViewOfGun);
    }];
}

-(void)pointWithTouchesBegin:(CGPoint)point{
    self.imgMove.hidden = NO;
    self.imgDownArrow.hidden = NO;
    self.ptzLocateView.resetBtn.hidden = NO;
    
    [self.ptzLocateView.playBackViewOfBall bringSubviewToFront:self.referenceImage];
    
    [self.ptzLocateView.playBackViewOfBall addSubview:self.imgMove];
    [self.ptzLocateView.playBackViewOfBall addSubview:self.imgDownArrow];
    
    [self.imgDownArrow mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imgMove.mas_bottom).mas_offset(-1);
        make.centerX.equalTo(self.imgMove);
        make.width.equalTo(@15);
        make.height.equalTo(@10);
    }];
    
    [self.ptzLocateView.playBackViewOfBall bringSubviewToFront:self.imgDownArrow];
    [self.ptzLocateView.playBackViewOfBall bringSubviewToFront:self.imgMove];
    
    // 获取手指的位置
    CGPoint location = point;
    if (location.x < kRadius) {
        location.x = kRadius;
    }
    
    if (location.x > self.mediaViewControllerOfBall.view.tz_width - kRadius) {
        location.x = self.mediaViewControllerOfBall.view.tz_width - kRadius;
    }
    
    if (location.y < kRadius) {
        location.y = kRadius;
    }
    
    if (location.y > self.mediaViewControllerOfBall.view.tz_height - kRadius) {
        location.y = self.mediaViewControllerOfBall.view.tz_height - kRadius;
    }
    [self partViewNeedsRelayout:location];
}

-(void)pointWithTouchesMoved:(CGPoint)point{
    PTZDirectionLocate direction = PTZDirectionLocate_None;
    // 获取手指的位置
    CGPoint location = point;
    if (location.x < kRadius) {
        location.x = kRadius;
        if (direction == PTZDirectionLocate_None) {
            direction = PTZDirectionLocate_LEFT;
        }
    }
    
    if (location.x > self.mediaViewControllerOfBall.view.tz_width - kRadius) {
        location.x = self.mediaViewControllerOfBall.view.tz_width - kRadius;
        if (direction == PTZDirectionLocate_None) {
            direction = PTZDirectionLocate_RIGHT;
        }
    }
    
    if (location.y < kRadius) {
        location.y = kRadius;
        if (direction == PTZDirectionLocate_None) {
            direction = PTZDirectionLocate_UP;
        }
    }
    
    if (location.y > self.mediaViewControllerOfBall.view.tz_height - kRadius) {
        location.y = self.mediaViewControllerOfBall.view.tz_height - kRadius;
        if (direction == PTZDirectionLocate_None) {
            direction = PTZDirectionLocate_DOWN;
        }
    }
    
    //如果移动的过程中 一直在安全线上 需要发送对应方向的云台命令
    if (direction != PTZDirectionLocate_None) {
        if (self.lastDirection != PTZDirectionLocate_None) {
            if (direction == self.lastDirection) {
                
            }else{
                [self.ptzLocateView sendPTZ:(int)self.lastDirection stop:YES];
                self.lastDirection = direction;
                [self.ptzLocateView sendPTZ:(int)self.lastDirection stop:NO];
            }
        }else{
            self.lastDirection = direction;
            [self.ptzLocateView sendPTZ:(int)self.lastDirection stop:NO];
        }
    }else{
        if (self.lastDirection != PTZDirectionLocate_None) {
            [self.ptzLocateView sendPTZ:(int)self.lastDirection stop:YES];
            self.lastDirection = PTZDirectionLocate_None;
        }
    }
    
    [self partViewNeedsRelayout:location];
}

- (void)pointWithTouchesEnded:(CGPoint)point{
    self.imgMove.hidden = YES;
    self.imgDownArrow.hidden = YES;
    
    if (self.lastDirection != PTZDirectionLocate_None) {
        [self.ptzLocateView sendPTZ:(int)self.lastDirection stop:YES];
        self.lastDirection = PTZDirectionLocate_None;
    }
}

- (void)pointWithTouchsCanceled:(CGPoint)point{
    self.imgMove.hidden = YES;
    self.imgDownArrow.hidden = YES;
    
    if (self.lastDirection != PTZDirectionLocate_None) {
        [self.ptzLocateView sendPTZ:(int)self.lastDirection stop:YES];
        self.lastDirection = PTZDirectionLocate_None;
    }
}

- (void)partViewNeedsRelayout:(CGPoint)point{
    CGRect referenceImageRect = self.referenceImage.frame;
    referenceImageRect.origin = CGPointMake(point.x - 10, point.y - 10);
    self.referenceImage.frame = referenceImageRect;
    
    self.scalePoint = CGPointMake(point.x / self.mediaViewControllerOfBall.view.tz_height, point.y / self.mediaViewControllerOfBall.view.tz_height);
    
    UIImage *img = [UIImage zoomInCircleImageWithImage:self.lastImage centerPoint:self.scalePoint radius:kRadius scale:kScale];
    self.imgMove.image = img;

    CGRect rect = self.imgMove.frame;
    point.y = point.y - kRadius * 2 * kScale - 30;
    point.x = point.x - kRadius * kScale;
    rect.origin = point;
    self.imgMove.frame = rect;
}

- (void)touchesPointReset{
    [self partViewNeedsRelayout:CGPointMake(self.mediaViewControllerOfBall.view.tz_width * 0.5, self.mediaViewControllerOfBall.view.tz_height *0.5)];
    self.ptzLocateView.resetBtn.hidden = YES;
}


-(void)dealloc{
    FUN_UnRegWnd(self.msgHandle);
    self.msgHandle = -1;
    
    if (_mediaViewControllerOfBall){
        [_mediaViewControllerOfBall.view removeFromSuperview];
        _mediaViewControllerOfBall = nil;
    }
    
    if (_mediaViewControllerOfGun){
        [_mediaViewControllerOfGun.view removeFromSuperview];
        _mediaViewControllerOfGun = nil;
    }
}

#pragma mark -- lazyload
-(PTZLocateView *)ptzLocateView{
    if(!_ptzLocateView){
        _ptzLocateView = [[PTZLocateView alloc] initWithFrame:CGRectZero];
        _ptzLocateView.devID = self.devID;
        _ptzLocateView.channel = self.channel;
        _ptzLocateView.delegate = self;
    }
    return _ptzLocateView;
}

-(VRGLViewController *)mediaViewControllerOfGun {
    if (!_mediaViewControllerOfGun) {
        _mediaViewControllerOfGun = [[VRGLViewController alloc] init];
    }
    return _mediaViewControllerOfGun;
}

-(VRGLViewController *)mediaViewControllerOfBall{
    if (!_mediaViewControllerOfBall) {
        _mediaViewControllerOfBall = [[VRGLViewController alloc] init];
        _mediaViewControllerOfBall.vrglDelegate = self;
        _mediaViewControllerOfBall.view.layer.cornerRadius = 10;
    }
    return _mediaViewControllerOfBall;
}

-(UIImageView *)imgMove{
    if (!_imgMove) {
        _imgMove = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kRadius * kScale * 2, kRadius * kScale * 2)];
        _imgMove.backgroundColor = [UIColor clearColor];
        _imgMove.layer.cornerRadius = kRadius;
        _imgMove.layer.masksToBounds = YES;
        _imgMove.layer.borderColor = UIColor.whiteColor.CGColor;
        _imgMove.layer.borderWidth = 1;
    }
    return _imgMove;
}

- (UIImageView *)imgDownArrow{
    if (!_imgDownArrow) {
        _imgDownArrow = [[UIImageView alloc] init];
        _imgDownArrow.image = [UIImage imageNamed:@"trangle_white_down_missing"];
    }
    
    return _imgDownArrow;
}

-(UIImageView *)referenceImage{
    if (!_referenceImage) {
        _referenceImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _referenceImage.image = [UIImage imageNamed:@"ic_touchesPoint.png"];
    }
    return _referenceImage;
}

@end
