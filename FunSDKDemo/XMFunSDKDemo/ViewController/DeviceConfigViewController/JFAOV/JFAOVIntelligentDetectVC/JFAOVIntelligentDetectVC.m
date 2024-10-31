//
//  JFAOVIntelligentDetectVC.m
//   iCSee
//
//  Created by Megatron on 2024/4/29.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import "JFAOVIntelligentDetectVC.h"
#import "JFAOVIntelligentDetectView.h"
#import "JFAOVIntelligentDetectAffairManager.h"
#import "VCManager.h"

@interface JFAOVIntelligentDetectVC () <JFAOVIntelligentDetectDelegate>

/**导航栏按钮*/
@property (nonatomic, strong) UIButton *btnNavBack;
@property (nonatomic, strong) JFAOVIntelligentDetectView *contentView;
///工作模式事务管理器
@property (nonatomic, strong) JFAOVIntelligentDetectAffairManager *affairManager;

@end

@implementation JFAOVIntelligentDetectVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.affairManager requestCfgWithDeviceID:self.devID];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.contentView updateTableList];
}

//MARK: - EventAction
- (void)btnNavBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

///更新内容视图
- (void)updateContentView{
    self.contentView.humanDetectionManager = self.affairManager.humanDetectionManager;
    self.contentView.humanRuleLimitManager = self.affairManager.humanRuleLimitManager;
    self.contentView.intellAlertAlarmMannager = self.affairManager.intellAlertAlarmMannager;
    self.contentView.multiSensor = self.affairManager.multiSensor;
    if (self.contentView.multiSensor == 1) {
        self.contentView.arraySensors = [self.affairManager.humanRuleLimitManager supportAreaSensorList];
    }
    
    [self.contentView configUpdate];
}

//MARK: - JFAOVIntelligentDetectDelegate


//MARK: - LazyLoad
- (UIButton *)btnNavBack{
    if (!_btnNavBack) {
        _btnNavBack = [UIButton buttonWithType:UIButtonTypeSystem];
        _btnNavBack.frame = CGRectMake(0, 0, 32, 32);
        [_btnNavBack setBackgroundImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
        [_btnNavBack addTarget:self action:@selector(btnNavBackClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _btnNavBack;
}

- (JFAOVIntelligentDetectView *)contentView{
    if (!_contentView){
        _contentView = [[JFAOVIntelligentDetectView alloc] init];
        _contentView.devID = self.devID;
        _contentView.iMultiAlgoCombinePed = self.iMultiAlgoCombinePed;
        _contentView.delegate = self;
    }
    
    return _contentView;
}

- (JFAOVIntelligentDetectAffairManager *)affairManager{
    if (!_affairManager) {
        _affairManager = [[JFAOVIntelligentDetectAffairManager alloc] init];
        WeakSelf(weakSelf);
        _affairManager.AllConfigRequestedCallBack = ^{
            [weakSelf updateContentView];
        };
        _affairManager.ConfigRequestFailedCallBack = ^{
            [weakSelf btnNavBackClicked];
        };
    }
    
    return _affairManager;
}

@end
