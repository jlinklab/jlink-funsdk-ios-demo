//
//  LocalSaveVideoEnableManager.h
//   
//
//  Created by Megatron on 2022/8/8.
//  Copyright © 2022 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FunSDKBaseObject.h"

typedef void(^GetLocalSaveVideoEnableCallBack)(int result);
typedef void(^SetLocalSaveVideoEnableCallBack)(int result);

NS_ASSUME_NONNULL_BEGIN

/*
 本地录像是否保存配置管理者
 关闭：SD卡不再保存录像 （不影响云存储录像）
 */
@interface LocalSaveVideoEnableManager : FunSDKBaseObject

@property (nonatomic,copy,nullable) GetLocalSaveVideoEnableCallBack getLocalSaveVideoEnableCallBack;
@property (nonatomic,copy,nullable) SetLocalSaveVideoEnableCallBack setLocalSaveVideoEnableCallBack;

//MARK: 请求本地录像是否保存配置
- (void)requestLocalSaveVideoEnableDevice:(NSString *)devID completed:(GetLocalSaveVideoEnableCallBack)completion;
//MARK: 保存本地录像是否保存配置
- (void)saveCompleted:(SetLocalSaveVideoEnableCallBack)completion;

//MARK: 获取是否开启本地录像
- (BOOL)getLocalVdeioEnable;
//MARK: 设置是否开启本地录像
- (void)setLocalVideoEnable:(BOOL)enable;

@end

NS_ASSUME_NONNULL_END
