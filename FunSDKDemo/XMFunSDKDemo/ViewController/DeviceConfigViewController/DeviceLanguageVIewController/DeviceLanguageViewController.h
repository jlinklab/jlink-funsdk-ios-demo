//
//  DeviceLanguageViewController.h
//  FunSDKDemo
//
//  Created by feimy on 2024/9/10.
//  Copyright © 2024 feimy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceLanguageViewController : UIViewController

@property(nonatomic, copy) void (^languageSelectBlock)(NSString *selectLanguage);

@property(nonatomic,copy)NSString *devID;
//可选择的语言数据列表
@property (nonatomic, strong) NSMutableArray *languageList;
//当前设备语言
@property (nonatomic, copy) NSString *curDeviceLanguage;

@end

NS_ASSUME_NONNULL_END
