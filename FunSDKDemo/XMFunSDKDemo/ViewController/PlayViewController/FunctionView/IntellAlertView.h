//
//  IntellAlertView.h
//
//
//  Created by Tony Stark on 2021/7/29.
//  Copyright © 2021 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "ChannelSystemFunctionManager.h"

typedef void(^RefreshIntellAlertView)(CGFloat scale);

NS_ASSUME_NONNULL_BEGIN

@interface IntellAlertView : UIView

//MARK: 设备序列号
@property (nonatomic,copy) NSString *devID;
//MARK: 当前展示的通道
@property (nonatomic,assign) int channel;
//MARK: 当前操作序号
@property (nonatomic,assign) int index;
//MARK: 总的通道数 多通道设备是通道数 单品就是窗口序号
@property (nonatomic,assign) int channels;
//MARK: 设备序列号
@property (nonatomic,strong) NSMutableArray *arrayID;
//MARK: 距离底部距离
@property (nonatomic,assign) CGFloat bottomOffset;
//MARK: 通道能力集管理者
//@property (nonatomic,weak) ChannelSystemFunctionManager *channelSystemFunctionManager;

//UITableView内容刷新需要重新约束
@property (nonatomic,copy) RefreshIntellAlertView refreshIntellAlertView;

//MARK: 点击跳转界面回调
@property (nonatomic,copy) void (^ClickJumpVCSign)(NSString *sign);
 
//偏移基准视图
@property (nonatomic,weak) UIView *standardView;

- (instancetype)initWithFrame:(CGRect)frame arrayDeviceID:(NSArray *)arrayID;
//MARK: 根据设备和通道展示警戒界面
- (void)dispalyAlertView:(NSString *)devID channel:(int)channel index:(int)index;

//MARK: 根据数据源计算宽高比
- (float)hwRatioFromDataSource;
//MARK:
@property (nonatomic,assign) BOOL SupportListCameraDayLightModes;//黑光设备支持夜视模式

@end

NS_ASSUME_NONNULL_END
