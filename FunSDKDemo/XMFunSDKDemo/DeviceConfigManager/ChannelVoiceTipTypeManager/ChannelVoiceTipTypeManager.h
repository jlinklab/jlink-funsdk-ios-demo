//
//  ChannelVoiceTipTypeManager.h
//   
//
//  Created by Tony Stark on 2021/7/22.
//  Copyright © 2021 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FunSDKBaseObject.h"

//获取警戒声音类型列表回调
typedef void(^GetChannelVoiceTipTypeCallBack)(int result,int channel);
//保存警戒声音类型列表回调
typedef void(^SetChannelVoiceTipTypeCallBack)(int result,int channel);

/*
 警戒声音能力管理者 针对通道
 获取可以设置的警戒声音列表
 */
NS_ASSUME_NONNULL_BEGIN

@interface ChannelVoiceTipTypeManager : FunSDKBaseObject

@property (nonatomic,copy) GetChannelVoiceTipTypeCallBack getChannelVoiceTipTypeCallBack;

@property (nonatomic,copy) SetChannelVoiceTipTypeCallBack setChannelVoiceTipTypeCallBack;

//MARK: 获取声音列表
- (void)getChannelVoiceTipType:(NSString *)devID channel:(int)channel completed:(GetChannelVoiceTipTypeCallBack)completion;
//MARK: 设置警戒声音列表
- (void)setChannelVoiceTipType:(int)type completed:(SetChannelVoiceTipTypeCallBack)completion;

//MARK: 获取警戒声音列表
- (NSArray *)getVoiceTypeList;

@end

NS_ASSUME_NONNULL_END
