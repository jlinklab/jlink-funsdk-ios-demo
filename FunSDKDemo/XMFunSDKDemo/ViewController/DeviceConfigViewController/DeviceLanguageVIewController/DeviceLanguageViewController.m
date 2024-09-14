//
//  DeviceLanguageViewController.m
//  FunSDKDemo
//
//  Created by feimy on 2024/9/10.
//  Copyright © 2024 feimy. All rights reserved.
//

#import "DeviceLanguageViewController.h"
#import "MultiLanguageManager.h"

@interface DeviceLanguageViewController () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) MultiLanguageManager *muilLanguageManager;

@property (nonatomic, strong) UITableView *tableView;


@end

@implementation DeviceLanguageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configSubView];
    [self initData];
    
}

- (void)configSubView {
    self.navigationItem.title = TS("TR_Device_language");
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"new_back.png"] style:UIBarButtonItemStyleDone target:self action:@selector(backItemClicked)];

}

- (void)initData{
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}

#pragma mark - EventAction
-(void)backItemClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -- UITableViewDelegate/dataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.languageList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = TS([[self.languageList objectAtIndex: indexPath.row] UTF8String]);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.curDeviceLanguage = [self.languageList objectAtIndex: indexPath.row];
    [self.muilLanguageManager setDeviceLanguage: self.curDeviceLanguage];
    __weak typeof(self) weakSelf = self;
    [self.muilLanguageManager setMultiLanguageCompleted:^(int result, int channel) {
        if (result >= 0) {
            if(weakSelf.languageSelectBlock){
                weakSelf.languageSelectBlock(self.curDeviceLanguage);
            }
            [SVProgressHUD showSuccessWithStatus: TS("success")];
        }else{
            [SVProgressHUD dismissWithError:[NSString stringWithFormat: @"%d", result]];
        }
        [self backItemClicked];
    }];
}


- (NSMutableArray *)languageList{
    if (!_languageList) {
        _languageList = [[NSMutableArray alloc] initWithCapacity: 0];
    }
    return _languageList;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 0, ScreenWidth - 20, ScreenHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    }
    return _tableView;
}

- (MultiLanguageManager *)muilLanguageManager{
    if (!_muilLanguageManager) {
        _muilLanguageManager = [[MultiLanguageManager alloc] init];
        _muilLanguageManager.devID = self.devID;
    }
    return _muilLanguageManager;
}


@end
