//
//  BwPhoneNumberViewController.h
//  UI
//
//  Created by Zheng on 2017/3/19.
//  Copyright © 2017年 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BwPhoneNumberView;

@interface BwPhoneNumberViewController : UIViewController

@property (nonatomic, assign) BOOL isBinding; //YES:绑定账号 
@property (nonatomic, assign) BOOL isRegister; //YES:注册 NO:修改密码
@property (nonatomic, strong) BwPhoneNumberView *mainView;


@end
