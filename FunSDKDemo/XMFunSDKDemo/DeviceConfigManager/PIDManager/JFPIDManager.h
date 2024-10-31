//
//  JFPIDManager.h
//  FunSDKDemo
//
//  Created by zhang on 2024/10/18.
//  Copyright © 2024 zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JFPIDManagerDelegate <NSObject>
@optional
- (void)requestPropvalueResult:(int)result;
@end


#define kData                  @"data"
#define kMsg                   @"msg"
#define kCode                 @"code"
#define kPOST @"POST"
#define kGET @"GET"

#define kGetDeviceTypePropUrl @"https:/cn-jvss.xmcsrv.net/deviceTypeProp/getDeviceTypePropListByPageForApp" //分页查询设备类型属性列表

NS_ASSUME_NONNULL_BEGIN

@interface JFPIDManager : NSObject


@property (nonatomic, weak) id <JFPIDManagerDelegate> delegate;

- (void)requestPropvalue:(id)object;
@end

NS_ASSUME_NONNULL_END
