//
//  BwVerificationCodeView.h
//  UI
//
//  Created by Zheng on 2017/3/19.
//  Copyright © 2017年 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Masonry.h"
#import "AFNetworking.h"
#import "KeyChainManage.h"
#import "CusMD5.h"
#import "MBProgressHUD.h"
#import "BaiwenSDK.h"
#import "BaiwenSDKParamHeader.h"

@class BwVerificationCodeViewController;

@interface BwVerificationCodeView : UIView

@property (nonatomic, strong) UITextField *codeTfd;
@property (nonatomic, strong) UITextField *passwordTxf;
@property (nonatomic, strong) UIButton *enterBtn;
@property (nonatomic, strong) UIView *lineView1;
@property (nonatomic, strong) UIView *lineView2;

@property (nonatomic, strong) UIButton *codeBtn;

- (void)codeBtnAction;

@property (nonatomic, weak) BwVerificationCodeViewController *delegate;


@end
