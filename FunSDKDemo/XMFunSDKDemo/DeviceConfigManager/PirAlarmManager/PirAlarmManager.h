//
//  PirAlarmManager.h
//   
//
//  Created by Tony Stark on 2021/7/30.
//  Copyright © 2021 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FunSDKBaseObject.h"

typedef void(^GetPirAlarmResult)(int result,int channel);
typedef void(^SetPirAlarmResult)(int result,int channel);

NS_ASSUME_NONNULL_BEGIN

/*
 人体感应报警配置管理者
 */
@interface PirAlarmManager : FunSDKBaseObject

@property (nonatomic,copy) GetPirAlarmResult getPirAlarmResult;
@property (nonatomic,copy) SetPirAlarmResult setPirAlarmResult;

//MARK: 获取体感应报警配置
- (void)getPirAlarm:(NSString *)devID channel:(int)channel completed:(GetPirAlarmResult)completion;
//MARK: 保存体感应报警配置
- (void)setPirAlarmCompleted:(SetPirAlarmResult)completion;

//MARK: 获取人体感应报警开关
- (BOOL)getEnable;
//MARK: 设置人体感应报警开关
- (void)setEnable:(BOOL)enable;

////MARK: 设置灵敏度
- (void)setPirSensitive:(int)sensitive;
//MARK: 获取灵敏度报警
- (int)getPirSensitive;

//MARK: 获取徘徊检测时间
- (CGFloat)getPIRCheckTime;
//MARK: 设置徘徊检测时间
- (void)setPIRCheckTime:(CGFloat)PIRCheckTime;

//MARK:获取报警类型：1.PIR报警 2.微波报警 3.灵敏度触发 4.精准触发
- (int)getPIRAlarmType;
//MARK:设置报警类型
- (void)setPIRAlarmType:(int)type;

//获取录像段时长
-(int)getRecordLatch;
//设置录像段时长
-(void)setRecordLatch:(int)latch;

#pragma mark -- 侦测时间段信息 增加2组设置，sectionNum来判断
//是否打开报警时间段

-(BOOL)getPirTimeSection:(NSInteger)sectionNum;
-(void)setPirTimeSection:(BOOL)open sectionNum:(NSInteger)sectionNum;

//报警结束时间和开始时间
-(NSString *)getPirTimeSectionStartTime:(NSInteger)sectionNum;
-(void)setPirTimeSectionStartTime:(NSString *)startTime sectionNum:(NSInteger)sectionNum;

-(NSString *)getPirTimeSectionEndTime:(NSInteger)sectionNum;
-(void)setPirTimeSectionEndTime:(NSString *)endTime sectionNum:(NSInteger)sectionNum;

//报警周期(按星期算)
-(int)getPirTimeSectionWeekMask:(NSInteger)sectionNum;
-(void)setPirTimeSectionWeekMask:(int)weekMask sectionNum:(NSInteger)sectionNum;

@end

NS_ASSUME_NONNULL_END
