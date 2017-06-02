//
//  BwLoginViewController.h
//  UI
//
//  Created by Zheng on 2017/3/18.
//  Copyright © 2017年 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BwLoginView;

@interface BwLoginViewController : UIViewController

@property (nonatomic, strong) BwLoginView *loginView;

@property (nonatomic, copy) NSString *uuidStr; //设备id
@property (nonatomic, copy) NSString *phoneStr; //手机号
@property (nonatomic, copy) NSString *userID; //用户名



@end
