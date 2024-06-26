//
//  IntelData.h
//  XMEye
//
//  Created by XM on 2017/5/8.
//  Copyright © 2017年 Megatron. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IntelData : NSObject

@property (nonatomic) BOOL AnalyzeEnable;  //智能分析开关
@property (nonatomic) int ModuleType;  //智能分析算法
//周界警戒
@property (nonatomic) int PeaLevel;       //警戒级别
@property (nonatomic) BOOL PeaShowRule;   //显示规则
@property (nonatomic) BOOL PeaShowTrace;  //显示轨迹

@property (nonatomic) BOOL PerimeterEnable;   //周线警戒开关
@property (nonatomic) int DirectionLimit;    //周线警戒方向 YES是双向
@property (nonatomic) int PeaPointNu;       //周界警戒点数量
@property (nonatomic, strong) NSMutableArray *PerimeterArray; //周线警戒点数组

@property (nonatomic) BOOL TripWireEnable;   //单线警戒开关
@property (nonatomic) BOOL IsDoubleDir;     //单线警戒向，YES是双向
@property (nonatomic, strong) NSMutableArray *TripWireArray; //单线警戒点数组

//物品看护
@property (nonatomic) int OscLevel;       //警戒级别
@property (nonatomic) BOOL OscShowRule;   //显示规则
@property (nonatomic) BOOL OscShowTrace;  //显示轨迹

@property (nonatomic) BOOL AbandumEnable;    //物品滞留开关
@property (nonatomic, strong) NSMutableArray *AbandumArray; //物品滞留点数组

@property (nonatomic) BOOL StolenEnable;    //物品盗移开关
@property (nonatomic, strong) NSMutableArray *StolenArray; //物品盗移点数组

//视频诊断
@property (nonatomic) BOOL ChangeEnable;   //场景变换检测
@property (nonatomic) BOOL InterfereEnable;  //人为干扰检测
@property (nonatomic) BOOL FreezeEnable;   //画面冻结检测
@property (nonatomic) BOOL NosignalEnable;  //信号缺失检测

@end
