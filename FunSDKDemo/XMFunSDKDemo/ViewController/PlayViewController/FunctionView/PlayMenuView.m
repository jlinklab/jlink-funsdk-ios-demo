//
//  PlayMenuView.m
//  XMEye
//
//  Created by Levi on 2016/6/22.
//  Copyright © 2016年 Megatron. All rights reserved.
//

#import "PlayMenuView.h"

@implementation PlayMenuView

-(UIButton *)PTZBtn{
    if (!_PTZBtn) {
        _PTZBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        _PTZBtn.center = CGPointMake((self.frame.size.width - 200)/5 +25,70);
        [_PTZBtn setBackgroundImage:[UIImage imageNamed:@"ptz_unselect.png"] forState:UIControlStateNormal];
        [_PTZBtn addTarget:self action:@selector(PTZBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _PTZBtn;
}

-(UIButton *)streamBtn{
    if (!_streamBtn) {
        _streamBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        _streamBtn.center = CGPointMake((self.frame.size.width - 200)/5 *2 +25+ 50, 70);
        [_streamBtn addTarget:self action:@selector(streamBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self setDPIBtnImage:1];
    }
    return _streamBtn;
}

-(UIButton *)playBackBtn{
    if (!_playBackBtn) {
        _playBackBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        _playBackBtn.center = CGPointMake((self.frame.size.width - 200)/5 *3 +25 + 100, 70);
        [_playBackBtn addTarget:self action:@selector(playBackBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_playBackBtn setBackgroundImage:[UIImage imageNamed:@"record_temp_normal.png"] forState:UIControlStateNormal];
    }
    return _playBackBtn;
}

//预览按钮（自己处理视频YUV数据）
-(UIButton *)playYUVBtn{
    if (!_playYUVBtn) {
        _playYUVBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        _playYUVBtn.center = CGPointMake((self.frame.size.width - 200)/5 *4 +25 + 150, 70);
        [_playYUVBtn addTarget:self action:@selector(playYUVBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_playYUVBtn setBackgroundImage:[UIImage imageNamed:@"YUV_temp_normal.png"] forState:UIControlStateNormal];
//        [_playYUVBtn setTitle:@"YUV" forState:UIControlStateNormal];
//        [_playYUVBtn setTitleColor:[UIColor colorWithRed:48.0/255.0 green:159.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    }
    return _playYUVBtn;
}

//远程控制
-(UIButton *)controlBtn{
    if (!_controlBtn) {
        _controlBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 50)];
        _controlBtn.center = CGPointMake((self.frame.size.width - 200)/5 +25, 70*2);
        [_controlBtn addTarget:self action:@selector(gotoControlVC) forControlEvents:UIControlEventTouchUpInside];
        [_controlBtn setTitle:TS("TR_Remote_Ctrl") forState:UIControlStateNormal];
        [_controlBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _controlBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
        _controlBtn.titleLabel.numberOfLines = 0;
        _controlBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _controlBtn;
}

//设备抓图
-(UIButton *)StoreSnapBtn{
    if (!_StoreSnapBtn) {
        _StoreSnapBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 50)];
        _StoreSnapBtn.center = CGPointMake(self.streamBtn.center.x, 70*2);
        [_StoreSnapBtn addTarget:self action:@selector(storeSnapEvent) forControlEvents:UIControlEventTouchUpInside];
        [_StoreSnapBtn setTitle:TS("StoreSnap") forState:UIControlStateNormal];
        [_StoreSnapBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _StoreSnapBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
        _StoreSnapBtn.titleLabel.numberOfLines = 0;
        _StoreSnapBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _StoreSnapBtn;
}


//走廊模式
-(UIButton *)corridorModelBtn{
    if (!_corridorModelBtn) {
        _corridorModelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 50)];
        _corridorModelBtn.center = CGPointMake(self.playBackBtn.center.x, 70*2);
        [_corridorModelBtn addTarget:self action:@selector(corridorModelEvent) forControlEvents:UIControlEventTouchUpInside];
        [_corridorModelBtn setTitle:TS("TR_CorridorModel") forState:UIControlStateNormal];
        [_corridorModelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _corridorModelBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
        _corridorModelBtn.titleLabel.numberOfLines = 0;
        _corridorModelBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _corridorModelBtn;
}

//全屏
-(UIButton *)btnFull{
    if (!_btnFull) {
        _btnFull = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
        _btnFull.center = CGPointMake(self.controlBtn.center.x, 70*3);
        [_btnFull addTarget:self action:@selector(fullScreenEvent) forControlEvents:UIControlEventTouchUpInside];
        [_btnFull setTitle:TS("TR_FullScreen") forState:UIControlStateNormal];
        [_btnFull setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        _btnFull.titleLabel.font = [UIFont systemFontOfSize:12.0];
        _btnFull.titleLabel.numberOfLines = 0;
        _btnFull.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _btnFull.hidden = YES;
    }
    return _btnFull;
}

//视频对讲
-(UIButton *)btnVideoCall{
    if (!_btnVideoCall) {
        _btnVideoCall = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
        _btnVideoCall.center = CGPointMake(self.controlBtn.center.x, 70*3);
        [_btnVideoCall addTarget:self action:@selector(btnVideoCallClicked) forControlEvents:UIControlEventTouchUpInside];
        [_btnVideoCall setTitle:TS("TR_VideoCall") forState:UIControlStateNormal];
        [_btnVideoCall setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _btnVideoCall.titleLabel.font = [UIFont systemFontOfSize:12.0];
        _btnVideoCall.titleLabel.numberOfLines = 0;
        _btnVideoCall.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _btnVideoCall.hidden = YES;
    }
    return _btnVideoCall;
}

//声光报警
- (UIButton *)btnLightAlarm{
    if (!_btnLightAlarm) {
        _btnLightAlarm = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
        _btnLightAlarm.center = CGPointMake(self.playYUVBtn.center.x, 70*2);
        [_btnLightAlarm addTarget:self action:@selector(btnLightAlarmClicked) forControlEvents:UIControlEventTouchUpInside];
        [_btnLightAlarm setTitle:TS("TR_Alarm_By_Voice_Light") forState:UIControlStateNormal];
        [_btnLightAlarm setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _btnLightAlarm.titleLabel.font = [UIFont systemFontOfSize:12.0];
        _btnLightAlarm.titleLabel.numberOfLines = 0;
        _btnLightAlarm.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _btnLightAlarm.hidden = YES;
    }
    return _btnLightAlarm;
}

//APP 多目预览
-(UIButton *)MultilePlayBtn{
    if (!_MultilePlayBtn) {
        _MultilePlayBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
        _MultilePlayBtn.center = CGPointMake(self.streamBtn.center.x, 70*3);
        [_MultilePlayBtn addTarget:self action:@selector(multilePreviewEvent) forControlEvents:UIControlEventTouchUpInside];
        [_MultilePlayBtn setTitle:TS("Multi preview") forState:UIControlStateNormal];
        [_MultilePlayBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _MultilePlayBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
        _MultilePlayBtn.titleLabel.numberOfLines = 0;
        _MultilePlayBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _MultilePlayBtn;
}

//APP 多目预览
-(UIButton *)APPZoomScreenBtn{
    if (!_APPZoomScreenBtn) {
        _APPZoomScreenBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
        _APPZoomScreenBtn.center = CGPointMake(self.playYUVBtn.center.x, 70*3);
        [_APPZoomScreenBtn addTarget:self action:@selector(zoomScreenEvent) forControlEvents:UIControlEventTouchUpInside];
        [_APPZoomScreenBtn setTitle:TS("Zoom Screen") forState:UIControlStateNormal];
        [_APPZoomScreenBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _APPZoomScreenBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
        _APPZoomScreenBtn.titleLabel.numberOfLines = 0;
        _APPZoomScreenBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _APPZoomScreenBtn;
}


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.localLanguage =[LanguageManager currentLanguage];
        [self configSubView];
    }
    return self;
}

-(void)configSubView{
    [self addSubview:self.PTZBtn];
    [self addSubview:self.streamBtn];
    [self addSubview:self.playBackBtn];
    [self addSubview:self.playYUVBtn];
    [self addSubview:self.controlBtn];
    [self addSubview:self.StoreSnapBtn];
    [self addSubview:self.corridorModelBtn];
    [self addSubview: self.btnFull];
    [self addSubview: self.btnVideoCall];
    [self addSubview: self.btnLightAlarm];
    [self addSubview: self.MultilePlayBtn];
    [self addSubview: self.APPZoomScreenBtn];
    
}

-(void)PTZBtnClick:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(showPTZControl)]) {
        [self.delegate showPTZControl];
    }
}


-(void)streamBtnClick:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(changeStreamType)]) {
        [self.delegate changeStreamType];
    }
}

-(void)playBackBtnClick:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(presentPlayBackViewController)]) {
        [self.delegate presentPlayBackViewController];
    }
}

- (void)playYUVBtnClick:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(presentPlayBackViewController)]) {
        [self.delegate playYUVBtnClick];
    }
}


-(void)setDPIBtnImage:(int)stream{
    if ([self.localLanguage isEqualToString:@"zh_CN"]) {
        if (stream == 1) {//辅码流
            [self.streamBtn setBackgroundImage:[UIImage imageNamed:TS("btn_SD")] forState:UIControlStateNormal];
        }else{
            [self.streamBtn setBackgroundImage:[UIImage imageNamed:TS("btn_HD")] forState:UIControlStateNormal];
        }
        
    }else if ([self.localLanguage isEqualToString:@"zh_TW"]){
        if (stream == 1) {//辅码流
            [self.streamBtn setBackgroundImage:[UIImage imageNamed:TS("btn_SD_F")] forState:UIControlStateNormal];
            
        }else{
            [self.streamBtn setBackgroundImage:[UIImage imageNamed:TS("btn_HD_F")] forState:UIControlStateNormal];
        }
    }else if([self.localLanguage isEqualToString:@"en"] || [self.localLanguage isEqualToString:@"ko_KR"] ){
        if (stream == 1) {//辅码流
            [self.streamBtn setBackgroundImage:[UIImage imageNamed:TS("btn_SD_E")] forState:UIControlStateNormal];
            
        }else{
            [self.streamBtn setBackgroundImage:[UIImage imageNamed:TS("btn_HD_E")] forState:UIControlStateNormal];
        }
    }else{
        if ([LanguageManager checkSystemCurrentLanguageIsSimplifiedChinese]) {
            if (stream == 1) {//辅码流
                [self.streamBtn setBackgroundImage:[UIImage imageNamed:TS("btn_SD")] forState:UIControlStateNormal];
                
            }else{
                [self.streamBtn setBackgroundImage:[UIImage imageNamed:TS("btn_HD")] forState:UIControlStateNormal];
            }
        }else if([LanguageManager checkSystemCurrentLanguageIsSimplifiedChinese]){
            if (stream == 1) {//辅码流
                [self.streamBtn setBackgroundImage:[UIImage imageNamed:TS("btn_SD_F")] forState:UIControlStateNormal];
                
            }else{
                [self.streamBtn setBackgroundImage:[UIImage imageNamed:TS("btn_HD_F")] forState:UIControlStateNormal];
            }
        }else{
            if (stream == 1) {//辅码流
                [self.streamBtn setBackgroundImage:[UIImage imageNamed:TS("btn_SD_E")] forState:UIControlStateNormal];
                
            }else{
                [self.streamBtn setBackgroundImage:[UIImage imageNamed:TS("btn_HD_E")] forState:UIControlStateNormal];
            }
        }
    }
}

-(void)setStreamType:(int)streamType{
    _streamType = streamType;
    [self setDPIBtnImage:_streamType];
}

-(void)gotoControlVC
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(changeToControlVC)]) {
        [self.delegate changeToControlVC];
    }
}

- (void)storeSnapEvent {
    if (self.delegate && [self.delegate respondsToSelector:@selector(storeSnapEvent)]) {
        [self.delegate storeSnapEvent];
    }
}

- (void)corridorModelEvent {
    if (self.delegate && [self.delegate respondsToSelector:@selector(corridorModelEvent)]) {
        [self.delegate corridorModelEvent];
    }
}

- (void)fullScreenEvent{
    if(self.delegate && [self.delegate respondsToSelector:@selector(fullScreenEvent)]){
        [self.delegate fullScreenEvent];
    }
}

- (void)btnVideoCallClicked{
    if(self.delegate && [self.delegate respondsToSelector:@selector(btnVideoCallClicked)]){
        [self.delegate btnVideoCallClicked];
    }
}

- (void)btnLightAlarmClicked{
    if(self.delegate && [self.delegate respondsToSelector:@selector(btnLightAlarmClicked)]){
        [self.delegate btnLightAlarmClicked];
    }
}
- (void)multilePreviewEvent{
    if(self.delegate && [self.delegate respondsToSelector:@selector(btnmultilePreviewClicked)]){
        [self.delegate btnmultilePreviewClicked];
    }
}
- (void)zoomScreenEvent{
    if(self.delegate && [self.delegate respondsToSelector:@selector(btnZoomScreenClicked)]){
        [self.delegate btnZoomScreenClicked];
    }
}

@end
