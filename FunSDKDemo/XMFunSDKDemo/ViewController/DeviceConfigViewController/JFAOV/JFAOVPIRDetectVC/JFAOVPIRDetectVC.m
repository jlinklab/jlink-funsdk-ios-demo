//
//  JFAOVPIRDetectVC.m
//   iCSee
//
//  Created by Megatron on 2024/4/29.
//  Copyright © 2024 xiongmaitech. All rights reserved.
//

#import "JFAOVPIRDetectVC.h"
#import "JFAOVPIRDetectView.h"
#import "JFAOVPIRDetectAffairManager.h"


@interface JFAOVPIRDetectVC ()

/**导航栏按钮*/
@property (nonatomic, strong) UIButton *btnNavBack;
@property (nonatomic, strong) JFAOVPIRDetectView *contentView;
///工作模式事务管理器
@property (nonatomic, strong) JFAOVPIRDetectAffairManager *affairManager;

@end

@implementation JFAOVPIRDetectVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.affairManager requestCfgWithDeviceID:self.devID];
}

//MARK: - EventAction
- (void)btnNavBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

///更新内容视图
- (void)updateContentView{
    self.contentView.pirAlarmManager = self.affairManager.pirAlarmManager;
    
    [self.contentView configUpdate];
}

//MARK: - JFAOVPIRDetectDelegate


//MARK: - LazyLoad
- (UIButton *)btnNavBack{
    if (!_btnNavBack) {
        _btnNavBack = [UIButton buttonWithType:UIButtonTypeSystem];
        _btnNavBack.frame = CGRectMake(0, 0, 32, 32);
        [_btnNavBack setBackgroundImage:[UIImage imageNamed:@"UserLoginView-back-nor"] forState:UIControlStateNormal];
        [_btnNavBack addTarget:self action:@selector(btnNavBackClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _btnNavBack;
}

- (JFAOVPIRDetectView *)contentView{
    if (!_contentView){
        _contentView = [[JFAOVPIRDetectView alloc] init];
        _contentView.devID = self.devID;
        _contentView.ifSupportPIRSensitive = self.ifSupportPIRSensitive;
    }
    
    return _contentView;
}

- (JFAOVPIRDetectAffairManager *)affairManager{
    if (!_affairManager) {
        _affairManager = [[JFAOVPIRDetectAffairManager alloc] init];
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
