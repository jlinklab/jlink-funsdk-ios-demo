//
//  IntelViewController.h
//  XMEye
//
//  Created by XM on 2017/4/21.
//  Copyright © 2017年 Megatron. All rights reserved.
//

#import "BaseJConfigController.h"
#import "InterInterfaceControl.h"
#import "AlarmAreaTypeView.h"
#import "SuperView.h"

@interface IntelViewController : BaseJConfigController

///保存成功后将当前报警区域类型字段通知到上一级 不需要再重新请求
@property (nonatomic, copy) void (^AreaPointNumSaveSuccessAction)(int areaPointNum);
@property (nonatomic) AlarmAreaTypeView *alarmView;
@property (nonatomic) enum DrawType drawType;
@property (nonatomic,strong) NSString *devID;      // 设备id
@property (nonatomic) int channelNum;              // 选中通道号
@property (nonatomic) int stream;                  // 播放的码流类型

@property (nonatomic,copy) NSString *navTitle;         // 标题

//可支持的方向选择(往里：0，往外：1以及双向：2)
@property (nonatomic, strong) NSMutableArray *directArray;

//如果是区域报警的话支持的报警区域类型(几边型)
@property (nonatomic, strong) NSMutableArray *areaShapeArray;

//智能分析还是人形检测
@property (nonatomic, assign) BOOL humanDetection;

@property (nonatomic, strong) NSMutableDictionary *humanDetectionDic;

@property (nonatomic,assign) int pedRuleIndex;       // 镜头报警区域对应pedRule数组的序号
@property (nonatomic,assign) BOOL ifMultiSensor;     // 是否是多镜头
@property (nonatomic,assign) int sensorIndex;        // 镜头序号 从0开始

-(void)setInterfaceControl:(InterInterfaceControl*)interControl;

@property (nonatomic,assign) int alarmDirection;    // 报警线类型
@property (nonatomic,assign) int areaPointNum;      // 报警区域类型

@end
