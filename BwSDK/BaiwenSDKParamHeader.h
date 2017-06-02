//
//  BaiwenSDKParamHeader.h
//  BaiwenSDK
//
//  Created by Zheng on 2017/3/22.
//  Copyright © 2017年 Zheng. All rights reserved.
//

#ifndef BaiwenSDKParamHeader_h
#define BaiwenSDKParamHeader_h

#define RGB(R,G,B,A) [UIColor colorWithRed:R/255.f green:G/255.f blue:B/255.f alpha:A]

#define kBwRedColor RGB(249, 66, 73, 1)
#define kLineColor RGB(240, 240, 240 ,1)

//线下
//#define kURL @"http://101.37.18.43:8811/user.php"
//测试
//#define kURL @"http://101.37.18.43:8811/tourist.php"

//线上
#define kURL @"http://baiwenuser.slthgame.com/tourist.php"

#define kUserDefaults [NSUserDefaults standardUserDefaults]

#define kPhoneNumberKey @"phone"
#define kPasswordKey @"password"
#define kLogin @"login"
#define kUuid @"uuid"
#define kUserType @"kUserTpye"

#import "BwLoginViewController.h"
#import "BwPhoneNumberViewController.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import "KeyChainManage.h"
#import "BwMBProgress.h"

#endif /* BaiwenSDKParamHeader_h */
