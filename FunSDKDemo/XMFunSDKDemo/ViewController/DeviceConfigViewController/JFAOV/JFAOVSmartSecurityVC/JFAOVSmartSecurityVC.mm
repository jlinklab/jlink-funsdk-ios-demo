//
//  JFAOVSmartSecurityVC.m
//   iCSee
//
//  Created by kevin on 2024/4/29.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import "JFAOVSmartSecurityVC.h"
#import "FunSDK/FunSDK.h"
#import "JFAOVSmartSecurityAffairManager.h"
#import "PhoneInfoManager.h"

@interface JFAOVSmartSecurityVC ()

@property (nonatomic, strong) UITableView *ruleTableView;
@property (nonatomic,strong) JFAOVSmartSecurityAffairManager *affairManager;

@end

@implementation JFAOVSmartSecurityVC

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.view.backgroundColor = cTableViewFilletGroupedBackgroudColor;
     
    [self configNav];
    [self configSubView];
    
//    [self.affairManager requestAllConfigWithDeviceID:self.devID];
     
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.affairManager viewWillAppearAction];
}
//MARK: - 配置子视图
- (void)configSubView{
    [self.view addSubview:self.ruleTableView];
    CGFloat safeBottom = [PhoneInfoManager safeAreaLength:SafeArea_Bottom];
    [self.ruleTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.top.equalTo(self);
        make.bottom.equalTo(self).mas_offset(-cTableViewFilletLFBorder);
        make.bottom.equalTo(self).mas_offset(-safeBottom);
    }];
}

- (void)configNav{
    self.navigationItem.title = TS("TR_Smart_Alarm");
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(btnBackClicked)];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
}
#pragma mark - **************** request ****************

//MARK: - EventAction
- (void)btnBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

//MARK: - LazyLoad
-(UITableView *)ruleTableView{
    if (!_ruleTableView) {
        _ruleTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _ruleTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _ruleTableView.dataSource = (id<UITableViewDataSource>)self.affairManager;
        _ruleTableView.delegate = (id<UITableViewDelegate>)self.affairManager;
        [_ruleTableView registerClass:[TitleSwitchCell class] forCellReuseIdentifier:kTitleSwitchCell];
        [_ruleTableView registerClass:[TitleComboBoxCell class] forCellReuseIdentifier:kTitleComboBoxCell];
        [_ruleTableView registerClass:[AlarmSwitchCell class] forCellReuseIdentifier:kAlarmSwitchCellIdentifier];
        [_ruleTableView registerClass:[EmptyTableViewCell class] forCellReuseIdentifier:kEmptyTableViewCell];
//        [_ruleTableView setCellSectionDefaultHeight];
        _ruleTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    
    return _ruleTableView;
}

- (JFAOVSmartSecurityAffairManager *)affairManager{
    if (!_affairManager){
        _affairManager = [[JFAOVSmartSecurityAffairManager alloc] init];
        _affairManager.devID = self.devID;
        _affairManager.associatedVC = self;
        _affairManager.iSupportPirAlarm = self.iSupportPirAlarm;
        _affairManager.iSupportIntellAlertAlarm = self.iSupportIntellAlertAlarm;
        _affairManager.iSupportHumanPedDetection = self.iSupportHumanPedDetection;
        _affairManager.ifSupportPIRSensitive = self.ifSupportPIRSensitive;
        _affairManager.iSupportSetVolume = self.iSupportSetVolume;
        _affairManager.supportAlarmVoiceTipInterval = self.supportAlarmVoiceTipInterval;
        _affairManager.iMultiAlgoCombinePed = self.iMultiAlgoCombinePed;
        _affairManager.associatedList = self.ruleTableView;
    }
    
    return _affairManager;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
