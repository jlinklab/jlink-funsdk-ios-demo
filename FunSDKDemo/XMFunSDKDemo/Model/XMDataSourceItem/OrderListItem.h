//
//  OrderListItem.h
//   
//
//  Created by Tony Stark on 2022/3/4.
//  Copyright © 2022 xiongmaitech. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*
 列表排序对象
 */
@interface OrderListItem : NSObject

//MARK: 主标题
@property (nonatomic, copy) NSString *titleName;
@property (nonatomic, copy) NSString *titleNameSelected;
//MARK: 副标题
@property (nonatomic, copy) NSString *subTitle;
//MARK: 左侧图标图片名称
@property (nonatomic, copy) NSString *leftIconName;
//MARK: 中间图片名称
@property (nonatomic,copy) NSString *middleIconName;
@property (nonatomic,copy) NSString *middleIconNameSelected;
//MARK: 中间图片数组和当前选中序号
@property (nonatomic,strong) NSMutableArray *middleIconNames;
@property (nonatomic,assign) int middleIconIndex;
//MARK: 是否是选中状态
@property (nonatomic, assign) BOOL selected;
//MARK: 是否需要自动切换选中状态
@property (nonatomic, assign) BOOL autoSwitchSelectState;
//MARK: 是否仅仅展示选中状态 不自动切换
@property (nonatomic, assign) BOOL showSelectStateOnly;

@property (nonatomic, assign) int cellStyle;
//MARK: 是否隐藏
@property (nonatomic, assign) BOOL hidden;

//MARK: 数据标记
@property (nonatomic, assign) int iMarker;

@property (nonatomic, copy) NSString *devID;
@property (nonatomic, assign) int channel;

@property (nonatomic, strong) id model;

@end

NS_ASSUME_NONNULL_END
