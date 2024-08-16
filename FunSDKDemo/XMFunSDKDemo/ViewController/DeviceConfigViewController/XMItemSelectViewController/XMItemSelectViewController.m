//
//  XMItemSelectViewController.m
//  XWorld
//
//  Created by DingLin on 17/1/9.
//  Copyright © 2017年 xiongmaitech. All rights reserved.
//

#import "XMItemSelectViewController.h"
#import <Masonry/Masonry.h>
#import "UIColor+Util.h"
#import "SelectItemCell.h"

NSString *const kUITableViewCell = @"kUITableViewCell";
static NSString *const kSelectItemCell = @"kSelectItemCell";

@interface XMItemSelectViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic,strong) UIView *tbContainer;
@property (nonatomic) UITableView *tbSettings;

@end

@implementation XMItemSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self myConfigNav];

    [self.view addSubview:self.tbContainer];
    
    [self.tbContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.tbContainer addSubview:self.tbSettings];
    
    [self.tbSettings mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.tbContainer).mas_offset(self.filletMode ?  15 : 0);
        make.right.equalTo(self.tbContainer).mas_offset(self.filletMode ?  -15 : 0);
        make.top.equalTo(self.tbContainer);
        make.bottom.equalTo(self.tbContainer);
    }];
    if ([self.title isEqualToString:TS(@"TR_ScreenCloseTime")]) {
        self.tbSettings.tableFooterView = [self creatTableFootView];
    }
}

//MARK: - ConfigNav
- (void)myConfigNav{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, 0, 32, 32);
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"UserLoginView-back-nor"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarBtn = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    
    self.navigationItem.leftBarButtonItem = leftBarBtn;
    
    if (self.needSaveButton) {
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightBtn setTitle:TS(@"finish") forState:UIControlStateNormal];
        [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        rightBtn.frame = CGRectMake(0, 0, 48, 32);
        [rightBtn addTarget:self action:@selector(rightBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightBarBtn = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
        self.navigationItem.rightBarButtonItems = @[rightBarBtn];
    }

    if (self.title) {
        self.navigationItem.title = self.title;
    }
}
- (UIView *)creatTableFootView {
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100)];
    footView.backgroundColor = cTableViewFilletGroupedBackgroudColor;
    UIImageView *imgIcon = [[UIImageView alloc] init];
    imgIcon.image = [UIImage imageNamed:@"login_icon_hint"];
    [footView addSubview:imgIcon];
    [imgIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.top.mas_equalTo(10);
        make.size.mas_equalTo(CGSizeMake(17, 17));
    }];
    UILabel *lblTitle = [[UILabel alloc] init];
    lblTitle.text = TS(@"TR_ScreenCloseTime_Click_Tips");
    lblTitle.font = [UIFont systemFontOfSize:12];
    lblTitle.numberOfLines = 0;
    lblTitle.textColor = [UIColor blackColor];
    [footView addSubview:lblTitle];
    [lblTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(imgIcon.mas_right).mas_offset(3);
        make.top.mas_equalTo(10);
        make.right.mas_equalTo(-25);
    }];
    return footView;
}
//MARK: EventAction
- (void)rightBtnClicked{
    if (self.clickSaveAction) {
        [SVProgressHUD show];
        self.clickSaveAction(self.lastIndex);
    }
}

//MARK: - 配置保存成功处理
- (void)saveSuccess{
    [SVProgressHUD showSuccessWithStatus:TS(@"Save_Success")];
    
    if (self.itemChangedAction) {
        self.itemChangedAction(self.lastIndex);
    }
    
    [self backViewController];
}

//MARK: 退出界面
-(void)backViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)backViewControllerAnimated:(BOOL)animated{
    [self.navigationController popViewControllerAnimated:animated];
}

//MARK: Deleegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrItems.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SelectItemCell *cell = (SelectItemCell *)[tableView dequeueReusableCellWithIdentifier:kSelectItemCell];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self.lastIndex == indexPath.row) {
        cell.ifSelected = YES;
    } else {
        cell.ifSelected = NO;
    }
    cell.lbTitle.text = [self.arrItems objectAtIndex:indexPath.row];
    
    if (self.arrItems.count - 1 == indexPath.row) {
        cell.bottomLine.hidden = YES;
    }else{
        cell.bottomLine.hidden = NO;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 2 && self.ifNeedSleepTips) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:TS(@"Set_Never_Sleep_Tips") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:TS(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.lastIndex = 2;
            
            if (self.itemChangedAction) {
                self.itemChangedAction(self.lastIndex);
            }
            
            [self.tbSettings reloadData];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:TS(@"cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.tbSettings reloadData];
        }];
        
        [alertVC addAction:action];
        [alertVC addAction:cancelAction];
        [action setValue: [UIColor orangeColor] forKey:@"titleTextColor"];
        [cancelAction setValue:[UIColor orangeColor] forKey:@"titleTextColor"];
        
        [self presentViewController:alertVC animated:YES completion:nil];
        return;
    }
    
    if (indexPath.row != self.lastIndex) {
        
        SelectItemCell *newCell = (SelectItemCell *)[tableView cellForRowAtIndexPath:indexPath];
        newCell.ifSelected = YES;
        
        SelectItemCell *oldCell = (SelectItemCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.lastIndex inSection:0]];
        oldCell.ifSelected = NO;
        
        self.lastIndex = (int)indexPath.row;
        
    }
    
    if (self.needAutoBack) {
        [self backViewController];
    }
    
    if (self.itemChangedAction) {
        self.itemChangedAction(self.lastIndex);
    }
}

//MARK: - LazyLoad
- (UIView *)tbContainer{
    if (!_tbContainer) {
        _tbContainer = [[UIView alloc] init];
        _tbContainer.backgroundColor = cTableViewFilletGroupedBackgroudColor;
    }
    return _tbContainer;
}

- (UITableView *)tbSettings {
    if (!_tbSettings) {
        _tbSettings = [[UITableView alloc] initWithFrame:CGRectZero style:self.filletMode ? UITableViewStyleGrouped : UITableViewStylePlain];
        _tbSettings.tableFooterView = [[UIView alloc] init];
        _tbSettings.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tbSettings.showsVerticalScrollIndicator = NO;
        _tbSettings.delegate = self;
        _tbSettings.dataSource = self;
        [_tbSettings registerClass:[SelectItemCell class] forCellReuseIdentifier:kSelectItemCell];
    }
    
    return _tbSettings;
}

@end
