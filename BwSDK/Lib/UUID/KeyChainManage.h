//
//  KeyChainManage.h
//  KeyChain
//
//  Created by Zheng on 2017/3/17.
//  Copyright © 2017年 Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSString * const kZCXDictionaryKey = @"com.zheng.dictionaryKey";
static NSString * const kZCXChainKey = @"com.zheng.keychainUnique";

@interface KeyChainManage : NSObject

+ (NSString *)zcxKeyChainLoad;

+ (void)zcxKeyChainDelete;


@end
