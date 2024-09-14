//
//  JFAOVSmartSecurityAffairManager.m
//   iCSee
//
//  Created by kevin on 2024/4/29.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import "JFAOVSmartSecurityAffairManager.h"
#import "DeviceLoginTipsManager.h"
//#import "Device.h"
//#import "AccountModel.h"
#import "UIView+Layout.h"
//
#import "CfgStatusManager.h"
//#import "XMWechatTipView.h"
#import "JFAOVIntelligentDetectVC.h"
#import "JFAOVPIRDetectVC.h"
#import "JFAOVAlarmLinkageVC.h"
#import "AppDelegate.h"
#import <FunSDK/FunSDK.h>

@interface JFAOVSmartSecurityAffairManager () <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,assign) int msgHandle;

@end

@implementation JFAOVSmartSecurityAffairManager
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    FUN_UnRegWnd(self.msgHandle);
    self.msgHandle = -1;
}
- (instancetype)init{
    self = [super init];
    if (self) {
        self.msgHandle = FUN_RegWnd((__bridge void*)self);
    }
    
    return self;
}


- (void)viewWillAppearAction{
     
    [SVProgressHUD show];
    [self wakeUpGetConfig];
    
}
//MARK: wake up to get config
- (void)wakeUpGetConfig{
    //低功耗先唤醒再操作
    [SVProgressHUD showWithStatus:TS("Waking_up")];
    FUN_DevWakeUp(self.msgHandle, CSTR(self.devID), 0);
        
}
- (void)wakeUpSetConfig{
    [SVProgressHUD show];
    FUN_DevWakeUp(self.msgHandle, CSTR(self.devID), 1);
        
}
//MARK: - OnFunSDKResult
- (void)baseOnFunSDKResult:(MsgContent *)msg{
    switch (msg->id) {
//MARK: 唤醒返回
        case EMSG_DEV_WAKE_UP:
        {
            if (msg->param1 >= 0) {
                if (msg->seq == 0) {
                   
                    
                }else{
                     
                }
            }else{
                if (msg->seq == 0) {
                    [self getConfigFailed:msg->param1];
                } else {
                    [MessageUI ShowErrorInt:msg->param1];
                }
            }
        }
            break;
        
        default:
            break;
    }
}

//MARK: 请求所有配置


- (void)updateDataSource{

    if (self.iSupportHumanPedDetection) {
        [self addTableViewItem:TS("TR_Setting_Intelligent_Detection") hidden:NO];

    }
    
    if (self.iSupportPirAlarm) {
        [self addTableViewItem:TS("TR_Setting_PIR_Detection") hidden:NO];

    }
    if (self.iSupportIntellAlertAlarm) {
        [self addTableViewItem:TS("TR_AlarmLinkage") hidden:NO];

    }
    [self.associatedList reloadData];
}

- (void)getConfigFailed:(int)result{
    [MessageUI ShowErrorInt:result];
    [self.associatedVC.navigationController popViewControllerAnimated:YES];
}

- (void)setConfigResult:(int)result{
    if (result >= 0) {
        [SVProgressHUD showSuccessWithStatus:TS("Save_Success")];;
    }else{
        [MessageUI ShowErrorInt:result];
    }
}

//MARK: - UITableViewDelegate/DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSourceVisiable.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSMutableArray * sectionData = [self.dataSourceVisiable objectAtIndex:section];
    return sectionData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray * sectionData = [self.dataSourceVisiable objectAtIndex:indexPath.section];
    OrderListItem *item = [sectionData objectAtIndex:indexPath.row];
    if ([item.titleName isEqualToString:TS("Alarm_push")]) {
        return item.preCellHeight;
    } else if ([item.titleName isEqualToString:TS("open_wechat_alarm")]) {
        return 70;
    }
    
    return cTableViewCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray * sectionData = [self.dataSourceVisiable objectAtIndex:indexPath.section];
    OrderListItem *item = [sectionData objectAtIndex:indexPath.row];
    __weak typeof(self) weakSelf = self;
    if ([item.titleName isEqualToString:TS("TR_Setting_Intelligent_Detection")]){
        //智能侦测
        TitleComboBoxCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleComboBoxCell];
        cell.titleLeftBorder = -5;
        [cell enterFilletMode];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.titleLabel.text = TS("TR_Setting_Intelligent_Detection");
         
        
        return cell;
    } else if ([item.titleName isEqualToString:TS("TR_Setting_PIR_Detection")]){
        //PIR侦测
        TitleComboBoxCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleComboBoxCell];
        cell.titleLeftBorder = -5;
        [cell enterFilletMode];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.titleLabel.text = TS("TR_Setting_PIR_Detection");
         
        
        return cell;
    }else if ([item.titleName isEqualToString:TS("TR_AlarmLinkage")]){
        //联动报警
        TitleComboBoxCell *cell = [tableView dequeueReusableCellWithIdentifier:kTitleComboBoxCell];
        cell.titleLeftBorder = -5;
        [cell enterFilletMode];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.titleLabel.text = TS("TR_AlarmLinkage");
         
        
        return cell;
    }

    return [tableView dequeueReusableCellWithIdentifier:kEmptyTableViewCell];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSMutableArray * sectionData = [self.dataSourceVisiable objectAtIndex:indexPath.section];
    OrderListItem *item = [sectionData objectAtIndex:indexPath.row];
    if ([item.titleName isEqualToString:TS("TR_Setting_Intelligent_Detection")]){
        //智能侦测
        JFAOVIntelligentDetectVC *vc = [[JFAOVIntelligentDetectVC alloc] init];
        vc.devID = self.devID;
        vc.iMultiAlgoCombinePed = self.iMultiAlgoCombinePed;
        [[VCManager getCurrentVC].navigationController pushViewController:vc animated:YES];
    } else if ([item.titleName isEqualToString:TS("TR_Setting_PIR_Detection")]){
        //PIR侦测
        JFAOVPIRDetectVC *vc = [[JFAOVPIRDetectVC alloc] init];
        vc.devID = self.devID;
        vc.ifSupportPIRSensitive = self.ifSupportPIRSensitive;
        
        [[VCManager getCurrentVC].navigationController pushViewController:vc animated:YES];
    }  else if ([item.titleName isEqualToString:TS("TR_AlarmLinkage")]){
        //联动报警
        JFAOVAlarmLinkageVC *vc = [[JFAOVAlarmLinkageVC alloc] init];
        vc.iSupportSetVolume = self.iSupportSetVolume;
        vc.supportAlarmVoiceTipInterval = self.supportAlarmVoiceTipInterval;
        vc.devID = self.devID;
        [self.associatedVC.navigationController pushViewController:vc animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
}



//MARK: 增加配置项
- (void)addTableViewItem:(NSString *)title hidden:(BOOL)hidden{
    [self.dataSourceVisiable removeAllObjects];
    for (int s = 0; s < self.dataSource.count; s++) {
        NSMutableArray *section = [NSMutableArray arrayWithCapacity:0];
        NSArray <OrderListItem *>*arrayItems = [self.dataSource objectAtIndex:s];
        for (int r = 0; r < arrayItems.count; r++) {
            OrderListItem *item = [arrayItems objectAtIndex:r];
            if ([item.titleName isEqualToString:title]) {
                item.hidden = hidden;
            }
            if (!item.hidden) {
                [section addObject:item];
            }
        }
        [self.dataSourceVisiable addObject:section];
    }
}
/// 计算cell需要的高度
- (CGFloat)cellHeightWithTitle:(NSString *)title titleFont:(UIFont *)titleFont subTitle:(NSString *)subTitle subTitleFont:(UIFont *)subTitleFont maxWidht:(CGFloat)maxWdith tbOffset:(CGFloat)tbOffset{
    CGFloat titleHeight = 0,subTitleHeight = 0;
    if (title.length > 0) {
        titleHeight = [UIServiceManager getTextHeightFromContent:title maxWidth:maxWdith font:titleFont];
    }
    if (subTitle.length > 0) {
        subTitleHeight = [UIServiceManager getTextHeightFromContent:subTitle maxWidth:maxWdith font:subTitleFont];
    }
    
    return titleHeight + subTitleHeight + 2 * tbOffset;
}
//MARK: - LazyLoad
 

- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
        
        NSMutableArray *firstSection = [[NSMutableArray alloc] initWithCapacity:0];
        NSMutableArray *secondSection = [[NSMutableArray alloc] initWithCapacity:0];
        NSMutableArray *thirdSection = [[NSMutableArray alloc] initWithCapacity:0];
        
        //智能侦测
        OrderListItem *Section2HumanDetectionItem = [[OrderListItem alloc] init];
        Section2HumanDetectionItem.titleName = TS("TR_Setting_Intelligent_Detection");
        Section2HumanDetectionItem.cellStyle = 0;
        Section2HumanDetectionItem.hidden = YES;
        
        //PIR侦测
        OrderListItem *Section2PIRItem = [[OrderListItem alloc] init];
        Section2PIRItem.titleName = TS("TR_Setting_PIR_Detection");
        Section2PIRItem.cellStyle = 0;
        Section2PIRItem.hidden = YES;
        
        //报警联动
        OrderListItem *Section2IntellAlertAlarmItem = [[OrderListItem alloc] init];
        Section2IntellAlertAlarmItem.titleName = TS("TR_AlarmLinkage");
        Section2IntellAlertAlarmItem.cellStyle = 0;
        Section2IntellAlertAlarmItem.hidden = YES;
        

        [thirdSection addObject:Section2HumanDetectionItem];
        [thirdSection addObject:Section2PIRItem];
        [thirdSection addObject:Section2IntellAlertAlarmItem];
         
        [_dataSource addObject:thirdSection];
        
    }
    
    return _dataSource;
}

- (NSMutableArray *)dataSourceVisiable{
    if (!_dataSourceVisiable) {
        _dataSourceVisiable = [NSMutableArray arrayWithCapacity:0];
        [self addTableViewItem:@"" hidden:NO];
    }
    
    return _dataSourceVisiable;
}

@end
