//
//  BwLoginView.h
//  UI
//
//  Created by Zheng on 2017/3/19.
//  Copyright © 2017年 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Masonry.h"
#import "BaiwenSDK.h"
#import "CusMD5.h"
#import "AFNetworking.h"
#import "KeyChainManage.h"
#import "MBProgressHUD.h"
#import "BaiwenSDKParamHeader.h"

@interface BwLoginView : UIView

@property (nonatomic, strong) UITextField *phoneTxf; //手机号
@property (nonatomic, strong) UITextField *passwordTxf; //密码
@property (nonatomic, strong) UIButton *loginBtn; //登录
@property (nonatomic, strong) UIButton *registerBtn; //注册
@property (nonatomic, strong) UIButton *forgetBtn; //忘记密码
@property (nonatomic, strong) UIView *lineView1;
@property (nonatomic, strong) UIView *lineView2;

@end
