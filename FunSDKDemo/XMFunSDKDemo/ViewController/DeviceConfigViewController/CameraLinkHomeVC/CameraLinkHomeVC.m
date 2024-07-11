//
//  CameraLinkHomeVC.m
//   iCSee
//
//  Created by Megatron on 2023/4/15.
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import "CameraLinkHomeVC.h"
#import "CameraLinkHomeView.h"
#import "GunBallManager.h"
#import "PTZLocateViewController.h"

@interface CameraLinkHomeVC () <CameraLinkHomeViewDelegate>

/**导航栏按钮*/
@property (nonatomic, strong) UIButton *btnNavBack;
@property (nonatomic, strong) CameraLinkHomeView *contentView;

@property (nonatomic, assign) BOOL needRequestGunBallLocate;
@property (nonatomic, strong) GunBallManager *gunBallManager;

@end

@implementation CameraLinkHomeVC

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.needRequestGunBallLocate){
        self.needRequestGunBallLocate = NO;
        
        [SVProgressHUD show];
        WeakSelf(weakSelf);
        [self.gunBallManager requestGunBallLocate:self.devID completed:^(int result) {
            [SVProgressHUD dismiss];
            weakSelf.contentView.cameraLinkEnable = [weakSelf.gunBallManager gunBallLocateEnable];
        }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [SVProgressHUD show];
    WeakSelf(weakSelf);
    [self.gunBallManager requestGunBallLocate:self.devID completed:^(int result) {
        if (result < 0) {
            [SVProgressHUD showErrorWithStatus: [NSString stringWithFormat: @"%d", result]];
            [weakSelf btnNavBacktClicked];
        }else{
            weakSelf.contentView.cameraLinkEnable = [weakSelf.gunBallManager gunBallLocateEnable];
            [SVProgressHUD dismiss];
        }
    }];
}

//MARK: - EventAction
- (void)btnNavBacktClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

//MARK: - CameraLinkHomeViewDelegate
- (void)changeLinkSwitchState:(BOOL)open{
    [self.gunBallManager setGunBallLocateEnable:open];
    [SVProgressHUD show];
    WeakSelf(weakSelf);
    [self.gunBallManager requestSaveGunBallLocateCompleted:^(int result) {
        if (result < 0) {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat: @"%d", result]];
            weakSelf.contentView.cameraLinkEnable = !weakSelf.contentView.cameraLinkEnable;
        }else{
            [SVProgressHUD showSuccessWithStatus:TS(@"Save_Success")];
        }
    }];
}

- (void)goPTZLocateVC{
    PTZLocateViewController *vc = [[PTZLocateViewController alloc] init];
    vc.devID = self.devID;
    self.needRequestGunBallLocate = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

 //MARK: - LazyLoad
 - (UIButton *)btnNavBack{
     if (!_btnNavBack) {
         _btnNavBack = [UIButton buttonWithType:UIButtonTypeSystem];
         _btnNavBack.frame = CGRectMake(0, 0, 32, 32);
         [_btnNavBack setBackgroundImage:[UIImage imageNamed:@"new_back.png"] forState:UIControlStateNormal];
         [_btnNavBack addTarget:self action:@selector(btnNavBacktClicked) forControlEvents:UIControlEventTouchUpInside];
     }
     
     return _btnNavBack;
}

- (CameraLinkHomeView *)contentView{
    if (!_contentView){
        _contentView = [[CameraLinkHomeView alloc] init];
        _contentView.delegate = self;
    }
    
    return _contentView;
}

- (GunBallManager *)gunBallManager{
    if (!_gunBallManager){
        _gunBallManager = [[GunBallManager alloc] init];
    }
    
    return _gunBallManager;
}

@end
