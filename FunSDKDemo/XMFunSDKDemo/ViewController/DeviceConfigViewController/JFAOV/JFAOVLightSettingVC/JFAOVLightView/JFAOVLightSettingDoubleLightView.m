//
//  JFAOVLightSettingDoubleLightView.m
//   iCSee
//
//  Created by kevin on 2024/4/24.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import "JFAOVLightSettingDoubleLightView.h"
#import "OrderListItem.h"
#import "MyDatePickerView.h"
#import "JFLeftTitleRightButtonCell.h"
#import "TitleSwitchCell.h"
#import "JFLeftTitleCell.h"
#import "JFBottomSliderCell.h"
#import "EmptyTableViewCell.h"
#import "JFNewAlarmSliderValueCell.h"
#import "AppDelegate.h"

static NSString *const kTitleSwitchCell = @"TitleSwitchCell";
static NSString *const kJFLeftTitleRightButtonCell = @"kJFLeftTitleRightButtonCell";
static NSString *const kJFLeftTitleCell = @"kJFLeftTitleCell";
static NSString *const kJFBottomSliderCell = @"kJFBottomSliderCell";
static NSString *const kEmptyTableViewCell = @"kEmptyTableViewCell";
static NSString *const kJFNewAlarmSliderValueCell = @"kJFNewAlarmSliderValueCell";
static NSString *const kVideoPreviewFunctionListSwitchCell = @"VideoPreviewFunctionListSwitchCell";

@interface JFAOVLightSettingDoubleLightView ()<UITableViewDelegate,UITableViewDataSource,MyDatePickerViewDelegate>
@property (nonatomic, strong) UITableView *tbList;
// 配置顺序列表 修改顺序或者分组 增加项目 都要先在这里确定配置位置
@property (nonatomic,strong) NSMutableArray *cfgOrderList;
// 配置列表数据源
@property (nonatomic,strong) NSMutableArray *dataSource;
@end

@implementation JFAOVLightSettingDoubleLightView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.tbList];
        [self.tbList mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).mas_offset(cTableViewFilletLFBorder);
            make.right.equalTo(self).mas_offset(-cTableViewFilletLFBorder);
            make.top.equalTo(self);
            make.bottom.equalTo(self);
        }];
    }
    
    return self;
}

- (void)configData {
    [self.dataSource removeAllObjects];
    
    NSMutableArray *section0 = [NSMutableArray arrayWithCapacity:0];
    NSArray *arr = [[[self.cameraDayLightModesManager getLightModes] reverseObjectEnumerator] allObjects];
    for (NSString *value in arr) {
        if ([value intValue] == 3) {
            [section0 addObject:TS("Double_Light_Vision")];
        } else if ([value intValue] == 4) {
            [section0 addObject:TS("Full_Color_Vision")];
        } else if ([value intValue] == 5) {
            [section0 addObject:TS("General_Night_Vision")];
        }
    }
    
    NSMutableArray *section1 = [NSMutableArray arrayWithCapacity:0];
    if (self.needShowStatusLed) {
        [section1 addObject:TS("TR_Setting_Device_Indicator_Light")];
    }
    
    NSMutableArray *section2 = [NSMutableArray arrayWithCapacity:0];
    if (self.supportMicroFillLight) {
        [section2 addObject:TS("TR_Low_Light_Control")];
    }
    
    [self.dataSource addObject:section0];
    [self.dataSource addObject:section1];
    [self.tbList reloadData];
}
 
/// 更新列表
- (void)updateList{
    [self.tbList reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *arraySection = [self.dataSource objectAtIndex:section];
    
    return arraySection.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *arraySection = [self.dataSource objectAtIndex:indexPath.section];
    NSString *title = [arraySection objectAtIndex:indexPath.row];
    
    if ([title isEqualToString:TS("TR_Setting_Device_Indicator_Light")]){//AOV设备指示灯 使用特定cell
        TitleSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleSwitchCell];
        cell.titleLabel.text = title;
        cell.toggleSwitch.on = self.fbExtraStateCtrlManager.iStatueLed > 0 ? YES : NO;
        cell.bottomLineLeftBorder = 0;
        cell.titleLeftBorder = 0;
        cell.adjustSwitchBorder = -5;
        [cell enterFilletMode];
        WeakSelf(weakSelf);
        cell.toggleSwitchStateChangedAction = ^(BOOL on) {
            weakSelf.fbExtraStateCtrlManager.iStatueLed = on ? 1 : 0;
            if (weakSelf.AOVLightViewSaveLed) {
                weakSelf.AOVLightViewSaveLed();
            }
        };
         
         return cell;
    }else if ([title isEqualToString:TS("TR_Low_Light_Control")]){//微光控制
        TitleSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleSwitchCell];
        cell.titleLabel.text = title;
        cell.toggleSwitch.on = self.microFillLightOpen;
        cell.bottomLineLeftBorder = 0;
        cell.titleLeftBorder = 0;
        cell.adjustSwitchBorder = -5;
        [cell enterFilletMode];
        WeakSelf(weakSelf);
        cell.toggleSwitchStateChangedAction = ^(BOOL on) {
            weakSelf.microFillLightOpen = on;
            if (weakSelf.AOVMicroLightSaveAction) {
                weakSelf.AOVMicroLightSaveAction(on);
            }
        };
         
         return cell;
    }
    
    JFLeftTitleRightButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:kJFLeftTitleRightButtonCell];
    cell.style = JFLeftTitleRightButtonCellStyle_Title;
    cell.lbTitle.text = title;
    cell.lbSubTitle.text = @"";

    NSString *workMode = [self.whiteLightManager getWordMode];
    if ([workMode isEqualToString:@"Close"]){
    if ([title isEqualToString:TS("General_Night_Vision")]) {
        cell.btnRight.selected = YES;
    } else {
        cell.btnRight.selected = NO;
    }

    } else if ([workMode isEqualToString:@"Auto"]) {
    if ([title isEqualToString:TS("Full_Color_Vision")]) {
        cell.btnRight.selected = YES;
    } else {
        cell.btnRight.selected = NO;
    }
    } else if ([workMode isEqualToString:@"Intelligent"]) {
    if ([title isEqualToString:TS("Double_Light_Vision")]) {
        cell.btnRight.selected = YES;
    } else {
        cell.btnRight.selected = NO;
    }
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return cTableViewCellHeight;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *arraySection = [self.dataSource objectAtIndex:indexPath.section];
    NSString *title = [arraySection objectAtIndex:indexPath.row];
    if ([title isEqualToString:TS("General_Night_Vision")]) {
        [self.whiteLightManager setWorkMode:@"Close"];
        if (self.saveBlock) {
            self.saveBlock();
        }
    } else if ([title isEqualToString:TS("Full_Color_Vision")]) {
        [self.whiteLightManager setWorkMode:@"Auto"];
        if (self.saveBlock) {
            self.saveBlock();
        }
    } else if ([title isEqualToString:TS("Double_Light_Vision")]) {
        [self.whiteLightManager setWorkMode:@"Intelligent"];
        if (self.saveBlock) {
            self.saveBlock();
        }
    }
    
     
}

 
//MARK: - LazyLoad
- (UITableView *)tbList{
    if (!_tbList) {
        _tbList = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        [_tbList registerClass:[JFLeftTitleRightButtonCell class] forCellReuseIdentifier:kJFLeftTitleRightButtonCell];
        [_tbList registerClass:[TitleSwitchCell class] forCellReuseIdentifier:kTitleSwitchCell];
        _tbList.dataSource = self;
        _tbList.delegate = self;
        //test
//        [_tbList setCellSectionDefaultHeight];
        _tbList.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tbList.tableFooterView = [[UIView alloc] init];
    }
    
    return _tbList;
}

- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:0];
         
    }
    
    return _dataSource;
}


#pragma mark - **************** lazyload ****************



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
