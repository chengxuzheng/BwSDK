//
//  BwVerificationCodeViewController.h
//  UI
//
//  Created by Zheng on 2017/3/19.
//  Copyright © 2017年 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BwVerificationCodeViewDelegate <NSObject>

- (void)sendCodeWithNetquest;

@end

@interface BwVerificationCodeViewController : UIViewController <BwVerificationCodeViewDelegate>

@property (nonatomic, copy) NSString *phoneStr; //电话号
@property (nonatomic, assign) BOOL isBinding; //YES:绑定账号


@end
