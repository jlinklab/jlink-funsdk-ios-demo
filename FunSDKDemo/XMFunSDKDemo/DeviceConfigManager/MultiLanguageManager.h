//
//  MultiLanguageManager.h
//   
//
//  Created by Tony Stark on 2021/8/6.
//  Copyright © 2021 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FunSDKBaseObject.h"

//获取多语言配置回调
typedef void(^GetMultiLanguageCallBack)(int result,int channel);
//保存多语言配置回调
typedef void(^SetMultiLanguageCallBack)(int result,int channel);

NS_ASSUME_NONNULL_BEGIN

/*
 设备多语言配置管理者
 */
@interface MultiLanguageManager : FunSDKBaseObject

@property (nonatomic,copy) GetMultiLanguageCallBack getMultiLanguageCallBack;

@property (nonatomic,copy) SetMultiLanguageCallBack setMultiLanguageCallBack;

//MARK: 是否支持多语言设置
@property (nonatomic,assign) BOOL supportMultiLanguage;
//MARK: 可选择的语言数据列表
@property (nonatomic,strong) NSMutableArray *languageList;

//MARK: 获取多语言配置
- (void)getMultiLanguage:(NSString *)devID channel:(int)channel completed:(GetMultiLanguageCallBack)completion;
//MARK: 保存多语言配置
- (void)setMultiLanguageCompleted:(SetMultiLanguageCallBack)completion;

//MARK: 获取设备语言
- (NSString *)getDeviceLanguage;
//MARK: 设置设备语言
- (void)setDeviceLanguage:(NSString *)language;

@end

NS_ASSUME_NONNULL_END
