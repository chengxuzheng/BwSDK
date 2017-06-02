//
//  BwPhoneNumberView.h
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

@interface BwPhoneNumberView : UIView

@property (nonatomic, strong) UILabel *titleLbl;
@property (nonatomic, strong) UITextField *phoneTxf;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIButton *enterBtn;


@end
