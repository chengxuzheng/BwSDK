//
//  CXStoreManager.h
//  StoreKit
//
//  Created by Zheng on 2017/5/4.
//  Copyright © 2017年 Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CXStoreManager : NSObject

/** 初始化 **/
+ (instancetype)defaultManager;


/**
 通过productid发起内购申请

 @param productID 购买产品的id
 @param success 成功回调 response为成功的订单信息
 @param failure 失败回调 error为失败的错误信息
 */
- (void)throughProductLPurchaseRequestsWithProductID:(NSString *)productID
                                         withSuccess:(void(^)(id response))success
                                         withFailure:(void(^)(NSError *error))failure;



@end
