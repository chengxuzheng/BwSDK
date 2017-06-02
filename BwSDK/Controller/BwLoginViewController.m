//
//  BwLoginViewController.m
//  UI
//
//  Created by Zheng on 2017/3/18.
//  Copyright © 2017年 Zheng. All rights reserved.
//

#import "BwLoginViewController.h"
#import "BwPhoneNumberViewController.h"

#import "BwLoginView.h"

@interface BwLoginViewController () <MBProgressHUDDelegate>
@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) UIBarButtonItem *backItem;

@end

@implementation BwLoginViewController

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _manager = [AFHTTPSessionManager manager];
    
    [self setWithController];
    [self addSubviews];
    [self layoutSubviews];
    [self addSubviewsAction];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([kUserDefaults objectForKey:kPhoneNumberKey] || [kUserDefaults objectForKey:kPasswordKey]) {
        _loginView.phoneTxf.text = [kUserDefaults objectForKey:kPhoneNumberKey];
        _loginView.passwordTxf.text = [kUserDefaults objectForKey:kPasswordKey];
    }
    
    //自动登录
    if ([[kUserDefaults objectForKey:kLogin] isEqualToString:kLogin]) {
        [self performSelector:@selector(loginRequest) withObject:nil afterDelay:2.5];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loginRequest) object:nil];
}

#pragma mark - 点击事件  
#pragma mark 返回游戏界面
- (void)backToUnityUIAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark 登录 跳转注册 跳转密码找回
- (void)subviewAction:(UIButton *)sender {
    (sender == _loginView.loginBtn)? [self loginRequest]: [self gotoOhterController:sender];
}

- (void)loginRequest {
    
//    if (_loginView.phoneTxf.text.length != 11) {
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请输入正确的手机号" message:nil preferredStyle:UIAlertControllerStyleAlert];
//        [self presentViewController:alert animated:YES completion:^{
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [alert dismissViewControllerAnimated:YES completion:nil];
//            });
//        }];
//        return;
//    }
    
//    if (_loginView.passwordTxf.text.length < 6) {
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请输入正确的密码" message:nil preferredStyle:UIAlertControllerStyleAlert];
//        [self presentViewController:alert animated:YES completion:^{
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [alert dismissViewControllerAnimated:YES completion:nil];
//            });
//        }];
//        return;
//    }
    
    //取消延迟操作
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loginRequest) object:nil];
    
    [_hud show:YES];
    
    NSString *action = @"login_user";
    NSString *game_id = [BaiwenSDK SDKInit].gameID;
    NSString *uuidStr = [KeyChainManage zcxKeyChainLoad];
    NSString *password = _loginView.passwordTxf.text;
    NSString *keyStr = @"ASD23%*!KK4@8MwdWddOc";
    NSString *phone = _loginView.phoneTxf.text;
    NSString *signStr = [CusMD5 md5String:[NSString stringWithFormat:@"actioncheckgame_id%@osioschannelappstorephone_num%@device%@%@%@",game_id,_loginView.phoneTxf.text,uuidStr,password,keyStr]];
    NSDictionary *parmDc = @{@"action":action,
                             @"game_id":game_id,
                             @"os":@"ios",
                             @"channel":@"appstore",
                             @"device":uuidStr,
                             @"phone_num":phone,
                             @"password":password,
                             @"sign":signStr};
    
//    __block NSMutableString *fullStr = [[kURL stringByAppendingString:@"?"] mutableCopy];
//    
//    [parmDc enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
//        [fullStr appendString:[NSString stringWithFormat:@"%@=%@",key,obj]];
//        
//        NSLog(@"---%@",fullStr);
//    }];
//    
    
    [_manager POST:kURL parameters:parmDc progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] isEqualToNumber:@200]) {
            _hud.labelText = @"登录成功";
            [_hud hide:YES];
            [BaiwenSDK SDKInit].userAccount = responseObject[@"data"][@"phone_num"];
            [BaiwenSDK SDKInit].userID = responseObject[@"data"][@"user_id"];
            [kUserDefaults setObject:phone forKey:kPhoneNumberKey];
            [kUserDefaults setObject:password forKey:kPasswordKey];
            [kUserDefaults setObject:kLogin forKey:kLogin];
            NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:responseObject];
            [data setObject:[KeyChainManage zcxKeyChainLoad] forKey:kUuid];
            [data setObject:kLogin forKey:kUserType];
            [[BaiwenSDK SDKInit] loginSuccess:data];
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        } else {
            [_hud hide:YES];
            NSString *message = responseObject[@"messsage"];
            NSString *str = @"";
            if ([message isEqualToString:@"phone_num wrong"]) {
                str = @"用户不存在";
            }
            if ([message isEqualToString:@"pwssword wrong"]) {
                str = @"密码错误";
            }
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:str message:nil preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:alert animated:YES completion:^{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [alert dismissViewControllerAnimated:YES completion:nil];
                });
            }];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_hud hide:YES];
            
        });
    }];
    
}

- (void)gotoOhterController:(UIButton *)sender {
    BwPhoneNumberViewController *pnVC = [[BwPhoneNumberViewController alloc] init];
    
    pnVC.isRegister = (sender == _loginView.registerBtn) ? YES:NO;
    
    [self.navigationController pushViewController:pnVC animated:YES];

}

#pragma mark - 添加子视图事件
- (void)addSubviewsAction {
    
    [_loginView.loginBtn addTarget:self action:@selector(subviewAction:) forControlEvents:UIControlEventTouchUpInside];
    [_loginView.registerBtn addTarget:self action:@selector(subviewAction:) forControlEvents:UIControlEventTouchUpInside];
    [_loginView.forgetBtn addTarget:self action:@selector(subviewAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)keyboardHide {
    [self.view endEditing:YES];
}

#pragma mark - 设置控制器
- (void)setWithController {
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = kBwRedColor;
    self.navigationController.navigationBar.backItem.hidesBackButton = NO;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    
    self.title = @"登录";
    
    self.view.backgroundColor = [UIColor clearColor];

}

#pragma mark - 添加子视图
- (void)addSubviews {
    [self.view addSubview:self.loginView];
    
    _hud = [[MBProgressHUD alloc] initWithView:self.view];
    _hud.delegate = self;
    _hud.labelText = @"正在登陆";
    [self.view bringSubviewToFront:_hud];
    [self.view addSubview:_hud];
    
    _backItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(backToUnityUIAction)];
    self.navigationItem.leftBarButtonItem = _backItem;
    
}

#pragma mark - 约束子视图
- (void)layoutSubviews {
    [_loginView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self.view);
    }];
}

#pragma mark - lazy
- (BwLoginView *)loginView {
    if (!_loginView) {
        _loginView = [[BwLoginView alloc] init];
        _loginView.backgroundColor = [UIColor whiteColor];
//        _loginView.backgroundColor = [UIColor clearColor];
        _loginView.alpha = 0.3;
    }
    return _loginView;
}


#pragma mark memory warning
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
