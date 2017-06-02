//
//  BwPhoneNumberViewController.m
//  UI
//
//  Created by Zheng on 2017/3/19.
//  Copyright © 2017年 Zheng. All rights reserved.
//

#import "BwPhoneNumberViewController.h"
#import "BwVerificationCodeViewController.h"
#import "BwPhoneNumberView.h"

@interface BwPhoneNumberViewController () <MBProgressHUDDelegate>

@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) NSMutableDictionary *paramDic; //参数
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) UIBarButtonItem *backItem;

@end

@implementation BwPhoneNumberViewController

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_isBinding) {
        self.title = @"账号绑定";
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.navigationController.navigationBar.barTintColor = kBwRedColor;
        self.navigationController.navigationBar.backItem.hidesBackButton = NO;
        
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
        backItem.title = @"返回";
        self.navigationItem.backBarButtonItem = backItem;
    }
    
    _manager = [AFHTTPSessionManager manager];

    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;

    [self inSubviews];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [_mainView.phoneTxf becomeFirstResponder];
}

#pragma mark - 用户点击事件
//返回上级
- (void)backToUnityUIAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}


//确定
- (void)enterButtonAction {
    
    if (_mainView.phoneTxf.text.length != 11) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请输入正确的手机号" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alert animated:YES completion:^{
            
            sleep(1);
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        
        return;
    }
    
    BwVerificationCodeViewController *vcVC = [[BwVerificationCodeViewController alloc] init];
    if (![_mainView.phoneTxf.text isEqualToString:@""]) {
        vcVC.phoneStr = _mainView.phoneTxf.text;
        if (_isBinding) { //绑定
            vcVC.title = @"账号绑定";
            vcVC.isBinding = YES;
            [self checkRigister:vcVC];
        } else { //注册或者找回密码
            if (_isRegister) {
                vcVC.title = @"注册";
                [self checkRigister:vcVC];
            } else {
                vcVC.title = @"找回密码";
                [self retrievePass:vcVC];
            }
        }
    }
}

#pragma mark 注册
- (void)checkRigister:(BwVerificationCodeViewController *)vcVC {
    NSString *game_id = [BaiwenSDK SDKInit].gameID;
    NSString *uuidStr = [KeyChainManage zcxKeyChainLoad];
    NSString *keyStr = @"ASD23%*!KK4@8MwdWddOc";
    NSString *signStr = [CusMD5 md5String:[NSString stringWithFormat:@"actioncheckgame_id%@osioschannelappstorephone_num%@device%@%@",game_id,_mainView.phoneTxf.text,uuidStr,keyStr]];
    
    NSDictionary *parmDc = @{@"action":@"check",
                             @"game_id":game_id,
                             @"os":@"ios",
                             @"channel":@"appstore",
                             @"device":uuidStr,
                             @"phone_num":_mainView.phoneTxf.text,
                             @"sign":signStr};
    
    [_hud show:YES];
    
    [_manager POST:kURL parameters:parmDc progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [_hud hide:YES];
        
        if ([responseObject[@"code"] isEqualToNumber:@200]) {
            [self.navigationController pushViewController:vcVC animated:YES];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"此手机号不可用" message:nil preferredStyle:UIAlertControllerStyleAlert];
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

#pragma mark 找回密码
- (void)retrievePass:(BwVerificationCodeViewController *)vcVC {
    NSString *game_id = [BaiwenSDK SDKInit].gameID;
    NSString *uuidStr = [KeyChainManage zcxKeyChainLoad];
    NSString *keyStr = @"ASD23%*!KK4@8MwdWddOc";
    NSString *signStr = [CusMD5 md5String:[NSString stringWithFormat:@"actioncheckgame_id%@osioschannelappstorephone_num%@device%@%@",game_id,_mainView.phoneTxf.text,uuidStr,keyStr]];
    
    NSDictionary *parmDc = @{@"action":@"get_change_pass",
                             @"game_id":game_id,
                             @"os":@"ios",
                             @"channel":@"appstore",
                             @"device":uuidStr,
                             @"phone_num":_mainView.phoneTxf.text,
                             @"sign":signStr};
    
    [_hud show:YES];
    
    [_manager POST:kURL parameters:parmDc progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [_hud hide:YES];
        
//        NSLog(@"%@",responseObject);
        
        if ([responseObject[@"code"] isEqualToNumber:@200]) {
            [self.navigationController pushViewController:vcVC animated:YES];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请输入正确的手机号" message:nil preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:alert animated:YES completion:^{
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [_hud hide:YES];
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
    
    NSString *titleStr = @"下一步";
    
    if (_isBinding) {
        _backItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(backToUnityUIAction)];
        self.navigationItem.leftBarButtonItem = _backItem;
    } else {
        titleStr = [self.title isEqualToString:@"注册"] ? @"一键注册":@"下一步";
    }
    
    [_mainView.enterBtn setTitle:titleStr forState:UIControlStateNormal];
    
    [_mainView.enterBtn addTarget:self action:@selector(enterButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
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
- (BwPhoneNumberView *)mainView {
    if (!_mainView) {
        _mainView = [[BwPhoneNumberView alloc] init];
        _mainView.backgroundColor = [UIColor whiteColor];
    }
    return _mainView;
}

#pragma mark - 传值
- (void)setIsRegister:(BOOL)isRegister {
    
    _isRegister = isRegister;
    
    self.title = _isRegister ? @"注册":@"找回密码";
}


#pragma mark - memory warning
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
