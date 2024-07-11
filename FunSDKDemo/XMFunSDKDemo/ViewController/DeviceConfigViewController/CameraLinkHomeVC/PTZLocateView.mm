//
//  PTZLocateView.m
//   iCSee
//
//  Created by ctrl+c on 2023/4/6.
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import "PTZLocateView.h"
#import <FunSDK/FunSDK.h>

@interface PTZLocateView ()

//播放句柄
@property (nonatomic,assign) int playHandle;

@property (nonatomic, strong) UILabel *tipLab;

@property (nonatomic, strong) UILabel *labelA;

@property (nonatomic, strong) UILabel *labelB;

@end

@implementation PTZLocateView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        self.backgroundColor = [UIColor whiteColor];
        self.msgHandle = FUN_RegWnd((__bridge void*)self);
        self.channelNum = -1;
        
        [self configSubViews];
    }
    
    return self;
}

-(void)configSubViews{
    [self addSubview:self.tipLab];
    [self.tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@100);
        make.centerX.equalTo(self);
        make.width.equalTo(self).multipliedBy(0.84);
    }];
    [self addSubview:self.playBackViewOfGun];
    [self.playBackViewOfGun mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self).multipliedBy(0.8);
        make.height.equalTo(self.playBackViewOfGun.mas_width).multipliedBy(9/16.0);
        make.top.equalTo(self.tipLab.mas_bottom).mas_offset(5);
        make.centerX.equalTo(self);
    }];
    
    [self addSubview:self.labelA];
    [self.labelA mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@40);
        make.height.equalTo(@22);
        make.top.equalTo(self.playBackViewOfGun.mas_bottom).offset(10);
        make.centerX.equalTo(self);
    }];
    
    [self addSubview:self.playBackViewOfBall];
    [self.playBackViewOfBall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.playBackViewOfGun);
        make.height.equalTo(self.playBackViewOfGun);
        make.top.equalTo(self.labelA.mas_bottom).offset(46);
        make.centerX.equalTo(self);
    }];
    
    [self addSubview:self.labelB];
    [self.labelB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.labelA);
        make.height.equalTo(self.labelA);
        make.top.equalTo(self.playBackViewOfBall.mas_bottom).offset(10);
        make.centerX.equalTo(self);
    }];
}

#pragma mark -- 开始启流
-(void)startPlayWithPlayViewOfGun:(UIView *)gunView PlayViewOfBall:(UIView *)ballView{
    [SVProgressHUD dismiss];
    [self.playBackViewOfGun addSubview:gunView];
    [gunView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.playBackViewOfGun);
    }];
    
    self.playHandle = FUN_MediaRealPlay(self.msgHandle, [self.devID UTF8String], self.channelNum == -1 ? 0 :  self.channelNum, 0, (__bridge void*)gunView,0);
    
    [self.playBackViewOfBall addSubview:ballView];
    [ballView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.playBackViewOfBall);
    }];
    
    DeviceObject *devInfo = [[DeviceControl getInstance] GetDeviceObjectBySN: self.devID];
    if (devInfo.iSceneType == XMVR_TYPE_TWO_LENSES){
        FUN_SetIntAttr(self.playHandle, EOA_MEDIA_YUV_USER, self.msgHandle);//返回Yuv数据
        FUN_SetIntAttr(self.playHandle, EOA_SET_MEDIA_VIEW_VISUAL, 0);//自己画画面
    }
}

#pragma mark -- 停止播放
-(void)stopPlay{
    FUN_MediaStop(self.playHandle);
}

//MARK: 发送云台命令
- (void)sendPTZ:(int)direction stop:(BOOL)stop{
    //在发送云台命令前 根据能力重新确定云台方向
    direction = (int)[self.ptzProcessManager convertPTZDrection:(PTZ_Direction)direction devID:self.devID channel:self.channel];
    
    FUN_DevPTZControl(self.msgHandle, CSTR(self.devID), self.channelNum == -1 ? 0 :  self.channelNum, direction, stop?1:0, 1);
}

#pragma mark - OnFunSDKResult
- (void)OnFunSDKResult:(NSNumber *)pParam{
    NSInteger nAddr = [pParam integerValue];
    MsgContent *msg = (MsgContent *)nAddr;
    switch ( msg->id ) {
#pragma mark 收到开始直播结果消息
        case EMSG_START_PLAY:
        {
            //可以在回调里加缓冲状态
        }
            break;
#pragma mark 收到开始缓存数据结果消息
        case EMSG_ON_PLAY_BUFFER_BEGIN:
        {
            
        }
            break;
#pragma mark 收到缓冲结束开始有画面结果消息
        case EMSG_ON_PLAY_BUFFER_END:
        {
            int wh[2] = {0};
            int vWidth = 0;int vHeight = 0;
            double ratioDetail = 3/4.0;
            FUN_GetAttr(msg->sender, EOA_VIDEO_WIDTH_HEIGHT, (char *)wh);
            if (wh[0] > 0 && wh[1] > 0) {
                ratioDetail = wh[1]*1.0/wh[0];
                vWidth = wh[0];
                vHeight = wh[1];
            }
            
            if ( self.delegate && [self.delegate respondsToSelector:@selector(startPlayBufferEndWidth:height:)] ) {
                [self.delegate startPlayBufferEndWidth:vWidth height:vHeight];
            }
            
            CGSize size = [self.resetBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
            [self.playBackViewOfBall addSubview:self.resetBtn];
            [self.resetBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.playBackViewOfBall);
                make.right.equalTo(self.playBackViewOfBall);
                make.width.mas_equalTo(size.width+20);
                make.height.mas_equalTo(30);
            }];
            
            [self setNeedsLayout];
            [self layoutIfNeeded];
            
            [self.playBackViewOfGun addSubview:self.maskView];
        }
            break;
        case EMSG_ON_PLAY_INFO:
        {
            
        }
            break;
        case EMSG_DEV_SET_CONFIG_JSON:{
            [SVProgressHUD dismiss];
        }
            break;
        //MARK: YUV数据回调
        case EMSG_ON_YUV_DATA:{
            if (self.delegate && [self.delegate respondsToSelector:@selector(PushYUVDataWidth:height:YUVData:)]) {
                [self.delegate PushYUVDataWidth:msg->param2 height:msg->param3 YUVData:(unsigned char *)msg->pObject];
            }
        }
            break;
        //MARK: -鱼眼相关处理
        //MARK: 用户自定义信息帧回调
        case EMSG_ON_FRAME_USR_DATA:{
            if (msg->param2 == 0x0e){//一路码流支持上下分屏
                FUN_SetIntAttr(self.playHandle, EOA_MEDIA_YUV_USER, self.msgHandle);//返回Yuv数据
                FUN_SetIntAttr(self.playHandle, EOA_SET_MEDIA_VIEW_VISUAL, 0);//自己画画面
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(startplayAfterBufferEnd)]) {
                    [self.delegate startplayAfterBufferEnd];
                }
                
                CGSize size = [self.resetBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
                [self.playBackViewOfBall addSubview:self.resetBtn];
                [self.resetBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.bottom.equalTo(self.playBackViewOfBall);
                    make.right.equalTo(self.playBackViewOfBall);
                    make.width.mas_equalTo(size.width+20);
                    make.height.mas_equalTo(30);
                }];
                
                [self setNeedsLayout];
                [self layoutIfNeeded];
                
                [self.playBackViewOfGun addSubview:self.maskView];
                
                //保存码流信息
                DeviceObject *dev = [[DeviceControl getInstance] GetDeviceObjectBySN: self.devID];
                dev.iSceneType = XMVR_TYPE_TWO_LENSES;
            }
        }
            break;
        default:
            break;
    }
}

-(UIView *)playBackViewOfGun{
    if (!_playBackViewOfGun) {
        _playBackViewOfGun = [[UIView alloc] init];
        _playBackViewOfGun.backgroundColor = [UIColor blackColor];
        _playBackViewOfGun.layer.cornerRadius = 10;
        _playBackViewOfGun.clipsToBounds = YES;
    }
    return _playBackViewOfGun;
}

-(UIView *)playBackViewOfBall{
    if (!_playBackViewOfBall) {
        _playBackViewOfBall = [[UIView alloc] init];
        _playBackViewOfBall.backgroundColor = [UIColor blackColor];
        _playBackViewOfBall.layer.cornerRadius = 10;
        //_playBackViewOfBall.clipsToBounds = YES;
    }
    return _playBackViewOfBall;
}

-(UIView *)maskView{
    if (!_maskView) {
        CGRect rect = CGRectMake((self.playBackViewOfGun.frame.size.width - 60) * 0.5, (self.playBackViewOfGun.frame.size.height - 60)*0.5, 60, 60);
        NSValue *value = [NSValue valueWithCGRect:rect];
        _maskView = [[MaskView alloc] initWithFrame:CGRectMake(0, 0, self.playBackViewOfGun.frame.size.width, self.playBackViewOfGun.frame.size.height) backgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.44] andTransparentRects:@[value]];
        
        UIView *circle = [[UIView alloc] init];
        circle.backgroundColor = UIColor.clearColor;
        circle.layer.borderColor = UIColor.whiteColor.CGColor;
        [_maskView addSubview:circle];
        [circle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_maskView);
            make.width.height.equalTo(@60);
        }];
    }
    return _maskView;
}

-(UILabel *)tipLab{
    if (!_tipLab) {
        _tipLab = [[UILabel alloc] init];
        _tipLab.text = TS("TR_Camera_Linkage_Tip");
        _tipLab.textColor = [UIColor blackColor];
        _tipLab.numberOfLines = 0;
    }
    return _tipLab;
}

-(UILabel *)labelA{
    if (!_labelA) {
        _labelA = [[UILabel alloc] init];
        _labelA.textColor = [UIColor lightGrayColor];
        _labelA.text = @"A";
        _labelA.textAlignment = NSTextAlignmentCenter;
    }
    return _labelA;
}

-(UILabel *)labelB{
    if (!_labelB) {
        _labelB = [[UILabel alloc] init];
        _labelB.textColor = [UIColor lightGrayColor];
        _labelB.text = @"B";
        _labelB.textAlignment = NSTextAlignmentCenter;
    }
    return _labelB;
}

-(UIButton *)resetBtn{
    if (!_resetBtn) {
        _resetBtn = [[UIButton alloc] init];
        _resetBtn.backgroundColor = [UIColor orangeColor];
        _resetBtn.layer.masksToBounds = YES;
        [_resetBtn setTitle:TS("TR_Reset") forState:UIControlStateNormal];
        _resetBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [_resetBtn addTarget:self action:@selector(resetBtnClick) forControlEvents:UIControlEventTouchUpInside];
        _resetBtn.hidden = YES;
    }
    return _resetBtn;
}

-(void)resetBtnClick{
    if (self.delegate && [self.delegate respondsToSelector:@selector(touchesPointReset)]) {
        [self.delegate touchesPointReset];
    }
}

#pragma mark -- 释放句柄
-(void)dealloc{
    FUN_UnRegWnd(self.msgHandle);
    self.msgHandle = -1;
}

- (PTZProcessManager *)ptzProcessManager{
    if (!_ptzProcessManager) {
        _ptzProcessManager = [[PTZProcessManager alloc] init];
    }
    
    return _ptzProcessManager;
}

@end
