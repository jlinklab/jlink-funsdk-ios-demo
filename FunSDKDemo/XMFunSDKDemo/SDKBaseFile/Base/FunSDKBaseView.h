//
//  FunSDKBaseView.h
//  FunSDKDemo
//
//  Created by feimy on 2024/6/26.
//  Copyright © 2024 feimy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FunSDK/FunSDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface FunSDKBaseView : UIView

@property (nonatomic,assign) UI_HANDLE msgHandle;

@end

@protocol FunSDKResultDelegate <NSObject>

@required
-(void)OnFunSDKResult:(NSNumber *)pParam;

@end

NS_ASSUME_NONNULL_END
