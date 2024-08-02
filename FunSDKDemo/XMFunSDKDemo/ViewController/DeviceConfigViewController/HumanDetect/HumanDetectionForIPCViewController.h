//
//  HumanDetectionForIPCViewController.h
//  XMEye
//
//  Created by 杨翔 on 2019/5/6.
//  Copyright © 2019 Megatron. All rights reserved.
//
/*
* 人形检测配置 IPC  完整版本
* 需要先获取能力级，判断是否支持人形检测  SystemFunction.AlarmFunction.PEAInHumanPed

*DVR人形检测和IPC人形检测 不是同一个功能。
DVR人形检测主要功能包括报警开关、报警录像开关、报警抓图开关、消息推送开关等等
IPC人形检测则主要包括报警开关、设置报警拌线、设置报警区域等等。
 
*/

#import <UIKit/UIKit.h>

@interface HumanDetectionForIPCViewController : UIViewController

@property (nonatomic) int channelNum;               // 选中通道号

@property (nonatomic,strong) NSString *devID;       // 设备id

@end
