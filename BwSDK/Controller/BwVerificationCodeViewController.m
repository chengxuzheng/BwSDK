//
//  BwVerificationCodeViewController.m
//  UI
//
//  Created by Zheng on 2017/3/19.
//  Copyright © 2017年 Zheng. All rights reserved.
//

#import "BwVerificationCodeViewController.h"

#import "BwVerificationCodeView.h"

@interface BwVerificationCodeViewController () <MBProgressHUDDelegate>

@property (nonatomic, strong) BwVerificationCodeView *mainView;
@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation BwVerificationCodeViewController

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _manager = [AFHTTPSessionManager manager];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self inSubviews];

    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //验证码倒计时
    [_mainView codeBtnAction];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [_mainView.codeTfd becomeFirstResponder];
}

#pragma mark - BwVerificationCodeViewDelegate
#pragma mark 发送验证码 Request
- (void)sendCodeWithNetquest {
    
    NSString *game_id = [BaiwenSDK SDKInit].gameID;
    NSString *uuidStr = [KeyChainManage zcxKeyChainLoad];
    NSString *keyStr = @"ASD23%*!KK4@8MwdWddOc";
    NSString *signStr = [CusMD5 md5String:[NSString stringWithFormat:@"actioncheckgame_id%@osioschannelappstorephone_num%@device%@%@",game_id,_phoneStr,uuidStr,keyStr]];
    
    NSDictionary *parmDc = @{@"action":@"get_regist_code",
                             @"game_id":game_id,
                             @"os":@"ios",
                             @"channel":@"appstore",
                             @"device":uuidStr,
                             @"phone_num":_phoneStr,
                             @"sign":signStr};
    
    [_manager POST:kURL parameters:parmDc progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (![responseObject[@"code"] isEqualToNumber:@200]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"验证码发送失败" message:nil preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:alert animated:YES completion:^{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [alert dismissViewControllerAnimated:YES completion:nil];
                });
            }];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

    }];
}

#pragma mark - 注册或修改密码 Request
- (void)commitRequestWithRegister {
    
    if (_mainView.codeTfd.text.length != 4) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请输入正确的验证码" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alert animated:YES completion:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [alert dismissViewControllerAnimated:YES completion:nil];
            });
        }];
        
        return;
    }
    
    if (_mainView.passwordTxf.text.length < 6) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"密码不能少于6位" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alert animated:YES completion:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [alert dismissViewControllerAnimated:YES completion:nil];
            });
        }];
        return;
    }
    
    //注册或修改密码
    NSString *action = [self.title isEqualToString:@"注册"] ? @"regist_user": @"change_password";
    NSString *deviceKey = @"device";

    if (_isBinding) {
        action = @"trans_toruist";
        deviceKey = @"device_code";
    }
    
    NSString *game_id = [BaiwenSDK SDKInit].gameID;
    NSString *uuidStr = [KeyChainManage zcxKeyChainLoad];
    NSString *keyStr = @"ASD23%*!KK4@8MwdWddOc";
    NSString *password = _mainView.passwordTxf.text;
    NSString *code = _mainView.codeTfd.text;
    NSString *signStr = [CusMD5 md5String:[NSString stringWithFormat:@"actioncheckgame_id%@osioschannelappstorephone_num%@device%@%@%@%@",game_id,_phoneStr,uuidStr,password,code,keyStr]];
    
    NSDictionary *parmDc = @{@"action":action,
                             @"game_id":game_id,
                             @"os":@"ios",
                             @"channel":@"appstore",
                             deviceKey:uuidStr,
                             @"phone_num":_phoneStr,
                             @"password":_mainView.passwordTxf.text,
                             @"register_code":_mainView.codeTfd.text,
                             @"sign":signStr};

    [_hud show:YES];
    
    [_manager POST:kURL parameters:parmDc progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [_hud hide:YES];
        
        if ([responseObject[@"code"] isEqualToNumber:@200]) {
            
            [[NSUserDefaults standardUserDefaults] setObject:_phoneStr forKey:@"phone"];
            
            if (![self.title isEqualToString:@"找回密码"]) {
                [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"password"];
                [[NSUserDefaults standardUserDefaults] setObject:kLogin forKey:kLogin];
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:@"notLogin" forKey:kLogin];
            }

            if (_isBinding) {
                [[BaiwenSDK SDKInit] bindingToursitSuccess:responseObject];
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            } else {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            
            //注册和绑定用户 通知游戏 新用户注册
            if (![action isEqualToString:@"change_password"]) {
                [[BaiwenSDK SDKInit] registerSuccess:responseObject];
            }
        } else {
            NSString *message = responseObject[@"messsage"];
            NSString *title = @"";
            if ([message isEqualToString:@"code fail"]) {
                title = @"验证码错误";
            } else {
                if ([action isEqualToString:@"change_password"]) {
                    title = @"密码修改失败";
                } else {
                    title = @"注册失败";
                }
            }
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:alert animated:YES completion:^{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [alert dismissViewControllerAnimated:YES completion:nil];
                });
            }];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [_hud hide:YES];
    }];

}

#pragma mark - add subviews
- (void)inSubviews {
    [self.view addSubview:self.mainView];
    
    [_mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self.view);
    }];
    
    NSString *titleStr = [self.title isEqualToString:@"注册"] ? @"注册":@"修改密码";
    
    [_mainView.enterBtn setTitle:titleStr forState:UIControlStateNormal];
    
    [_mainView.enterBtn addTarget:self action:@selector(commitRequestWithRegister) forControlEvents:UIControlEventTouchUpInside];
    
    _hud = [[MBProgressHUD alloc] initWithView:self.view];
    _hud.delegate = self;
    [self.view bringSubviewToFront:_hud];
    [self.view addSubview:_hud];

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)keyboardHide {
    [self.view endEditing:YES];
}

#pragma mark - lazy
- (BwVerificationCodeView *)mainView {
    if (!_mainView) {
        _mainView = [[BwVerificationCodeView alloc] init];
        _mainView.delegate = self;
    }
    return _mainView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
