//
//  XMFbExtraStateCtrlManager.h
//   
//
//  Created by Tony Stark on 2022/5/21.
//  Copyright © 2022 xiongmaitech. All rights reserved.
//

#import "FunSDKBaseObject.h"

typedef void(^GetXMFbExtraStateCtrlCallBack)(int result);
typedef void(^SetXMFbExtraStateCtrlCallBack)(int result);

NS_ASSUME_NONNULL_BEGIN

/*
 状态灯提示音配置管理器
 */
@interface XMFbExtraStateCtrlManager : FunSDKBaseObject

@property (nonatomic,copy) GetXMFbExtraStateCtrlCallBack getXMFbExtraStateCtrlCallBack;
@property (nonatomic,copy) SetXMFbExtraStateCtrlCallBack setXMFbExtraStateCtrlCallBack;

//MARK: 状态灯开关
@property (nonatomic,assign) int iStatueLed;
//MARK: 提示音开关
@property (nonatomic,assign) int iVoiceTip;

//MARK: SDK请求
- (void)requestGetXMFbExtraStateCtrlCfg:(NSString *)devID completed:(GetXMFbExtraStateCtrlCallBack)completion;

- (void)requestSetXMFbExtraStateCtrlCfgCompleted:(SetXMFbExtraStateCtrlCallBack)completion;

@end

NS_ASSUME_NONNULL_END
