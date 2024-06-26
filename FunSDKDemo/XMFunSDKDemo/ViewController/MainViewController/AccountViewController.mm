//
//  AccountViewController.m
//  FunSDKDemo
//
//  Created by XM on 2018/11/29.
//  Copyright © 2018年 XM. All rights reserved.
//

#import "AccountViewController.h"
#import "RegisterViewController.h"
#import "ChangePasswordViewController.h"
#import "UserAccountModel.h"
#import "ForgetPasswordViewController.h"
#import "UserInfoViewController.h"
#import "PasswordSaveViewController.h"
#import "LoginViewController.h"

@interface AccountViewController () <UITableViewDelegate,UITableViewDataSource,UserAccountModelDelegate>
{
    UserAccountModel *accountModel;
    NSMutableArray *titleArray;
    UITableView *mainTableView;
}

@end
@implementation AccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置导航栏样式
    [self setNaviStyle];
    [self initData];
    //配置子试图
    [self configSubView];
}

- (void)setNaviStyle {
    self.navigationItem.title = TS("About_User");
    self.navigationItem.titleView = [[UILabel alloc] initWithTitle:self.navigationItem.title name:NSStringFromClass([self class])];
}

- (void)initData {
    accountModel = [[UserAccountModel alloc] init];
    accountModel.delegate = self;
    titleArray =  (NSMutableArray*)@[TS("Register_User"),TS("Login_User"),TS("Modify_pwd"),
                                     TS("Forget_Pwd"),TS("Info_User"),TS("Save_Pwd"),TS("Delete_Account")];
}
- (void)configSubView {
    [self.view addSubview:self.mainTableView];
}

#pragma mark -- UITableViewDelegate/dataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mainCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [titleArray objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = [titleArray objectAtIndex:indexPath.row];
    if ([title isEqualToString:TS("Register_User")]) {
        //用户注册
        RegisterViewController *registerVC = [[RegisterViewController alloc] init];
        [self.navigationController pushViewController:registerVC animated:YES];
    }
    if ([title isEqualToString:TS("Login_User")]) {
        //用户登录
        if ([[LoginShowControl getInstance] getLoginType] != loginTypeNone) {
            [accountModel loginOut];
            [[LoginShowControl getInstance] setLoginType:loginTypeNone];
        }
        LoginViewController *loginV = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:loginV animated:YES];
        loginV.userNameTf.text = @"";
        loginV.passwordTf.text = @"";
    }
    if ([title isEqualToString:TS("Modify_pwd")]) {
        //修改密码
        ChangePasswordViewController *changePwdVC = [[ChangePasswordViewController alloc] init];
        [self.navigationController pushViewController:changePwdVC animated:YES];
    }
    if ([title isEqualToString:TS("Forget_Pwd")]) {
        //忘记密码
        ForgetPasswordViewController *forgetPwdVC = [[ForgetPasswordViewController alloc] init];
        [self.navigationController pushViewController:forgetPwdVC animated:YES];
    }
    if ([title isEqualToString:TS("Info_User")]) {
        //用户信息
        UserInfoViewController *userInfoVC = [[UserInfoViewController alloc] init];
        [self.navigationController pushViewController:userInfoVC animated:YES];
    }
    if ([title isEqualToString:TS("Save_Pwd")]) {
        //保存密码
        PasswordSaveViewController *passwordSaveVC = [[PasswordSaveViewController alloc] init];
        [self.navigationController pushViewController:passwordSaveVC animated:YES];
    }
    if ([title isEqualToString:TS("Delete_Account")]) {
        
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"Delete Account" message:TS("delete accpunt tip") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:TS("Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        
        UIAlertAction *actionOK = [UIAlertAction actionWithTitle:TS("OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //删除账户
            [accountModel deleteAccount:@""];
        }];
        [alertVC addAction:actionCancel];
        [alertVC addAction:actionOK];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}
- (UITableView *)mainTableView {
    if (!mainTableView) {
        mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 0, ScreenWidth - 20, ScreenHeight) style:UITableViewStylePlain];
        mainTableView.delegate = self;
        mainTableView.dataSource = self;
        [mainTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"mainCell"];
    }
    return mainTableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//删除账号
-(void)deleteAccountResult:(long)result {
    if (result == 0) {
        //需要验证码
        
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"Delete Account" message:TS("input_code") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:TS("Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        
        UIAlertAction *actionOK = [UIAlertAction actionWithTitle:TS("OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UITextField *codeTF = [alertVC.textFields objectAtIndex:0];
            NSString *code = (NSString *)codeTF.text;
            [accountModel deleteAccount:code];
        }];

        //验证码输入框
        [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = TS("input_code");
            textField.secureTextEntry = YES;

            [textField setRightViewMode:UITextFieldViewModeAlways];
        }];
        [alertVC addAction:actionCancel];
        [alertVC addAction:actionOK];
        [self presentViewController:alertVC animated:YES completion:nil];
        
    }else if (result < 0) {
        //失败
    }else {
        //成功
    }
}
@end
