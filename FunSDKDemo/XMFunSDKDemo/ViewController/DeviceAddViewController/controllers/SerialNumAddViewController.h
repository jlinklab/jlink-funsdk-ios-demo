//
//  SerialNumAddViewController.h
//  FunSDKDemo
//
//  Created by wujiangbo on 2018/11/12.
//  Copyright © 2018年 wujiangbo. All rights reserved.
//
/**
 
 序列号添加设备视图控制器
 *1、输入设备名称，序列号(可通过扫描二维码添加)、设备密码。（用户名也可通过接口修改，默认admin）
 *2、点击确定按钮通过序列号添加设备
 *3、设置设备名称和设备密码
 */
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SerialNumAddViewController : UIViewController

//MARK: - 是否直接返回上一层界面 导航栏推出方式返回
@property (nonatomic,assign) BOOL directNavBackLastVC;


//MARK: 处理扫描返回的二维码
- (void)dealWithScanerCode:(NSString *)code delay:(BOOL)delay;

@end

NS_ASSUME_NONNULL_END
