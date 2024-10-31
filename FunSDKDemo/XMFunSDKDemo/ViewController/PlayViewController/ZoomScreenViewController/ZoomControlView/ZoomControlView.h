//
//  ZoomControlView.h
//   
//
//  Created by Tony Stark on 2021/11/8.
//  Copyright © 2021 xiongmaitech. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * _Nonnull const kZoomControlViewTouchBegin = @"kZoomControlViewTouchBegin";
static NSString * _Nonnull const kZoomControlViewTouchEnd = @"kZoomControlViewTouchBegin";

NS_ASSUME_NONNULL_BEGIN

typedef void(^ZoomControlViewMultipleChangeCallBack)(float multiple,float fMultiple);

@interface ZoomControlView : UIView

@property (nonatomic,copy) ZoomControlViewMultipleChangeCallBack multipleChangeCallBack;

//展示当前倍数视图
@property (nonatomic,strong) UIView *curMultipleView;
@property (nonatomic,strong) UILabel *lbMultiple;
@property (nonatomic,strong) UILabel *lbMultipleCircle;
//当前倍数
@property (nonatomic,assign) float curMultiple;
//总倍数
@property (nonatomic,assign) int totalMultiple;

- (instancetype)initWithFrame:(CGRect)frame totalMultiple:(int)multiple;

@end

NS_ASSUME_NONNULL_END
