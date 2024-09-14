//
//  JFNewAlarmPeriodVc.h
//   iCSee
//
//  Created by kevin on 2023/9/26.
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetectVolumeDetectionManager.h"
#import "DetectCryDetectionManager.h"
#import "DetectCarShapeDetectionManager.h"
#import "DetectPetDetectionManager.h"
#import "IntellAlertAlarmMannager.h"
#import "FunSDKBaseViewController.h"

typedef NS_ENUM(NSInteger, NewAlarmPeriodKind) {
    NewAlarmPeriodKind_Car,
    NewAlarmPeriodKind_Pet,
    NewAlarmPeriodKind_Cry,
    NewAlarmPeriodKind_AbnormalSound,
    NewAlarmPeriodKink_Intelligent,
};

NS_ASSUME_NONNULL_BEGIN

@interface JFNewAlarmPeriodVc : FunSDKBaseViewController
@property (nonatomic, assign) NewAlarmPeriodKind periodKind;

///时间段设置返回回调
@property (nonatomic, copy) void (^AlarmPeriodBack)();

@property (nonatomic, weak) DetectVolumeDetectionManager *detectVolumeDetectionManager;
@property (nonatomic, weak) DetectCryDetectionManager *detectCryDetectionManager;
@property (nonatomic, weak) DetectCarShapeDetectionManager *detectCarShapeDetectionManager;
@property (nonatomic, weak) DetectPetDetectionManager *detectPetDetectionManager;
///智能警戒管理器
@property (nonatomic, weak) IntellAlertAlarmMannager *intellAlertAlarmMannager;


@end

NS_ASSUME_NONNULL_END
