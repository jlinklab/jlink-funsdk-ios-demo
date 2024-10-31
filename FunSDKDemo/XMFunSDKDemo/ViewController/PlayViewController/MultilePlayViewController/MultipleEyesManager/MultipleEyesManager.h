//
//  MultipleEyesManager.h
//  FunSDKDemo
//
//  Created by zhang on 2024/10/25.
//  Copyright © 2024 zhang. All rights reserved.
//

#import <Foundation/Foundation.h>



///当前设备的类型
typedef NS_ENUM(NSInteger,JF_Multiple_Eyes_Device_Type) {
    ///普通的多目枪球 使用设备返回配置来决定显示模式
    JF_Multiple_Eyes_Device_Type_Normal,
    ///一路码流上下分屏假3目
    JF_Multiple_Eyes_Device_Type_Fake
};

///假3目的播放窗口显示模式
typedef NS_ENUM(NSInteger,JF_Multiple_Eyes_Fake_Display_Mode) {
    JF_MEFD_Original_Mode, // 显示原始的内容
    JF_MEFD_Top_Half_Mode, // 显示上半屏内容
    JF_MEFD_Bottom_Half_Mode, // 显示底部半屏内容
    JF_MEFD_Top_Left_Middel_Mode, // 显示上半屏左侧中间部分内容
    JF_MEFD_Top_Right_Middel_Mode, // 显示上半屏右侧中间部分内容
};


NS_ASSUME_NONNULL_BEGIN

@interface MultipleEyesManager : NSObject


/**
 @brief 获取窗口显示模式对应的json数据
 */
+ (NSString *)playViewJsonParamWithDisplayMode:(JF_Multiple_Eyes_Fake_Display_Mode)mode;
@end

NS_ASSUME_NONNULL_END
