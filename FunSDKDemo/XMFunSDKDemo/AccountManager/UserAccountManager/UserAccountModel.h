//
//  UserAccountModel.h
//  MobileVideo
//
//  Created by XM on 2018/4/23.
//  Copyright © 2018年 XM. All rights reserved.
//

/*
 1、账号登录流程直接调用loginWithName登录接口
 2、账号注册流程先获取验证码getCodeWithPhoneOrEmailNumber，然后点用注册接口RegisterWithName
 3、通过原密码修改密码直接调用修改用户密码接口changeUserPasswordWithUserName：
 4、找回密码流程：
   1.先获取手机邮箱验证码getCodeWithPhoneOrEmailNumber:
   2.检查验证码合法性checkCode:
   3.调用找回密码的接口resetPassword:
 5、账号登录时，如果需要同时获取当前账号的设备列表和其他人分享给当前账号的设备列表，则需要在账号登录回调中 EMSG_SYS_GET_DEV_INFO_BY_USER 执行 FUN_GetFunStrAttr(EFUN_ATTR_GET_USER_ACCOUNT_DATA_INFO, devJson, 750*500)接口，执行之后的devJson数据就是设备列表json数据，本方法是阻塞方法，网络等请求异常时可能会阻塞主线程
 */


@protocol UserAccountModelDelegate <NSObject>
@optional
// 登录结果回调,result 结果信息，一般<0是失败，>=0是成功
- (void)loginWithNameDelegate:(long)reslut;

// 获取验证码回调
- (void)getCodeDelegateResult:(long)reslut;

// 忘记密码收到验证码回调
- (void)forgetPwdGetCodeDelegateResult:(long)reslut userName:(NSString *)name;

// 验证码校验合法性回调
- (void)checkCodeDelegateResult:(long)reslut;

// 找回重置密码回调
- (void)resetPasswordDelegateResult:(long)reslut;

// 注册密码回调
- (void)registerUserNameDelegateResult:(long)reslut;

// 修改密码回调
- (void)changePasswordDelegateResult:(long)result;

//请求账户信息（是否绑定手机号或者邮箱）
-(void)getUserInfo:(NSMutableDictionary *)userInfoDic result:(int)result;

//获取验证码回调 (绑定手机号/邮箱需要)
-(void)getCodeForBindPhoneEmailResult:(long)result;

//绑定手机号/邮箱回调
-(void)bindPhoneEmailResult:(long)result;

//删除账号
-(void)deleteAccountResult:(long)result;

@end

#import <Foundation/Foundation.h>
#import "FunMsgListener.h"

@interface UserAccountModel : FunMsgListener

@property (nonatomic, assign) id <UserAccountModelDelegate> delegate;

#pragma mark 账号登陆 userName：用户名，password：用户密码
- (void)loginWithName:(NSString *)userName andPassword:(NSString *)psw;

#pragma mark 本地登陆   local login
- (void)loginWithTypeLocal;

#pragma mark ap直连  ap login
- (void)loginWithTypeAP;

#pragma mark 登出  login out
- (void)loginOut;

#pragma mark 通过邮箱或者手机号获取验证码
- (void)getCodeWithPhoneOrEmailNumber:(NSString *)phoneEmail;

#pragma mark 忘记密码 获取验证码
-(int)fogetPwdWithPhoneNum:(NSString *)phoneNum;

#pragma mark 检查验证码的合法性,找回密码之前需要验证
- (void)checkCode:(NSString *)phoneEmail code:(NSString *)code;

#pragma mark 通过邮箱或者手机号找回用户登录密码
- (void)resetPassword:(NSString *)phoneEmail newPassword:(NSString *)psw;

#pragma mark 通过邮箱或者手机号注册新用户
- (void)registerUserName:(NSString *)username password:(NSString *)psw code:(NSString *)code PhoneOrEmail:(NSString *)phoneEmail;

#pragma mark 通过原先的密码修改用户密码
- (void)changePassword:(NSString *)userName oldPassword:(NSString *)oldPsw newPsw:(NSString *)newPsw;

#pragma mark 请求账户信息（是否绑定手机号或者邮箱）
- (void)requestAccountInfo;

#pragma mark 获取验证码 (绑定手机号或者邮箱需要)
- (void)getBindingPhoneEmailCode:(NSString *)username password:(NSString *)psw PhoneOrEmail:(NSString *)phoneEmail;

#pragma mark 绑定手机或者邮箱
- (void)bindPhoneEmail:(NSString *)username password:(NSString *)psw PhoneOrEmail:(NSString *)phoneEmail code:(NSString *)code;

/*
 deleteAccount 删除账号接口有时需要调用两次，第一次直接调用，code = @""；如果手机未绑定邮箱和手机号，可以直接删除成功。
 如果账号绑定了手机/邮箱，则此时会回调手机号或邮箱，并且发送验证码到手机号/邮箱中。输入验证码再调用deleteAccount接口，才可以删除成功设备
 */
#pragma mark 删除账号 code：验证码
- (void)deleteAccount:(NSString*)code;


/*
 获取当前账号的登陆token，部分接口要求传登陆token进行验证
 */
//MARK: 获取登录Token
- (NSString *)loginToken;

/**
未登录状态SDK初始化
 */
- (void)initWithTypeNoneLogin;

@end
