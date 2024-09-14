//
//  JFAOVModeOfWorkView.h
//   iCSee
//
//  Created by Megatron on 2024/4/24.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>

///AOV工作模式
typedef NS_ENUM(NSInteger,JFAOVWorkMode) {
    JFAOVWorkMode_Unknow,//未知模式
    JFAOVWorkMode_Saving,//省电模式
    JFAOVWorkMode_Performance,//性能模式
    JFAOVWorkMode_Custom,//自定义模式
};

@protocol JFAOVModeOfWorkViewDelegate <NSObject>

@optional
///用户切换工作模式
- (void)userChangeWorkMode:(JFAOVWorkMode)mode;
///用户切换事件录像延迟时间
- (void)userChangeCustomEventRecordLatch:(int)recordLatch;
///用户切换设置帧率 （自定义模式）
- (void)userChangeCustomFPS:(NSString *_Nonnull)fps;
///用户切换报警间隔 （自定义模式）
- (void)userChangeCustomAlarmHoldTime:(int)alarmHoldTime;
///用户切换最大录像时长（自定义模式）
- (void)userChangeCustomRecordLength:(int)RecordLength;

///aov 报警间隔时间 （老的通用报警间隔）
- (void)userChangeAlarmHoldTime:(int)alarmHoldTime;
@end



NS_ASSUME_NONNULL_BEGIN

@interface JFAOVModeOfWorkView : UIView

@property (nonatomic,weak) id<JFAOVModeOfWorkViewDelegate>delegate;
///当前AOV工作模式
@property (nonatomic,assign) JFAOVWorkMode workMode;

///省电模式FPS
@property (nonatomic,copy) NSString *savingModeFPS;
///省电模式报警间隔
@property (nonatomic,assign) int savingModeAlarmHoldTime;
///省电模式最大录像时长
@property (nonatomic,assign) int savingModeRecordLength;

///性能模式FPS
@property (nonatomic,copy) NSString *performanceModeFPS;
///性能模式报警间隔
@property (nonatomic,assign) int performanceModeAlarmHoldTime;
///性能模式最大录像时长
@property (nonatomic,assign) int performanceModeRecordLength;

///自定义模式FPS
@property (nonatomic,copy) NSString *customFPS;
///自定义模式延迟录像时间
@property (nonatomic,assign) int customRecordLatch;
///自定义模式报警间隔
@property (nonatomic,assign) int customAlarmHoldTime;
///自定义模式最大录像时长
@property (nonatomic,assign) int customRecordLength;

///自定义模式支持FPS的列表
@property (nonatomic,strong) NSArray *customFPSList;
///自定义模式支持延迟录像时间的列表
@property (nonatomic,strong) NSArray *customRecordLatchList;
///自定义模式支持最大录像时长列表
@property (nonatomic,strong) NSArray *customRecordLengthList;
///自定义模式支持报警间隔时间列表
@property (nonatomic,strong) NSArray *customAlarmHoldTimeList;


///当前电池电量
@property (nonatomic,assign) int batteryLevel;
///是否正在充电中
@property (nonatomic,assign) BOOL ifCharging;
///低电量模式的电量
@property (nonatomic,assign) int lowBatteryLevel;
@property (nonatomic, assign) BOOL supportDoubleLightBoxCamera;//支持双光
@property (nonatomic, assign) BOOL supportAovAlarmHold;//aov 报警间隔
/////aov 报警间隔时间
@property (nonatomic,assign) int aovAlarmHoldTime;
@property (nonatomic,strong) NSArray *aovAlarmHoldTimeList;

@property (nonatomic, assign) BOOL supportAovWorkModeIndieControl;//支持aov新工作模式

///更新列表
- (void)updateTableList;

- (void)configBatterValueTips;
@end

NS_ASSUME_NONNULL_END
