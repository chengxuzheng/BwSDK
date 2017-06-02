//
//  CXStoreManager.m
//  StoreKit
//
//  Created by Zheng on 2017/5/4.
//  Copyright © 2017年 Zheng. All rights reserved.
//

#import "CXStoreManager.h"
#import <StoreKit/StoreKit.h>

typedef void(^SuccessBlock)(id response);
typedef void(^FailureBlock)(NSError *error);

@interface CXStoreManager () <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (nonatomic, copy) SuccessBlock success;
@property (nonatomic, copy) FailureBlock failure;

@end

@implementation CXStoreManager

- (void)throughProductLPurchaseRequestsWithProductID:(NSString *)productID
                                         withSuccess:(void(^)(id response))success
                                         withFailure:(void(^)(NSError *error))failure {
    
    _success = success;
    _failure = failure;
    
    [self requestProductsWith:productID];
}

- (void)dealloc {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

+ (instancetype)defaultManager {
    static CXStoreManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CXStoreManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

- (BOOL)canMakePayments {
    return [SKPaymentQueue canMakePayments];
}


- (void)requestProductsWith:(NSString *)productID {
    NSSet *set = [NSSet setWithArray:@[productID]];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
    request.delegate = self;
    [request start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    for (SKProduct *product in response.products) {
        NSLog(@"价格:%@", product.price);
        NSLog(@"标题:%@", product.localizedTitle);
        NSLog(@"描述:%@", product.localizedDescription);
        NSLog(@"productid:%@", product.productIdentifier);
        [self buyProduct:product];
    }
}

- (void)buyProduct:(SKProduct *)product {
    SKPayment *payment = [SKPayment paymentWithProduct:product];
//    BOOL isSandBox = payment.simulatesAskToBuyInSandbox;
//    NSLog(@"1=沙盒 2=appstore === %d",isSandBox);
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing: {
                NSLog(@"用户正在购买");
            }
                break;
            case SKPaymentTransactionStatePurchased: {
                NSLog(@"购买成功");
                [queue finishTransaction:transaction];

                [self VerifyOrder];
            }
                break;
            case SKPaymentTransactionStateFailed: {
                NSLog(@"购买失败");
                [queue finishTransaction:transaction];
            }
                break;
            case SKPaymentTransactionStateRestored: {
                NSLog(@"恢复购买");
                [queue finishTransaction:transaction];
            }
                break;
            case SKPaymentTransactionStateDeferred: {
                NSLog(@"最终状态未确定");
            }
                break;
                
            default:
                break;
        }
    }
}

- (void)VerifyOrder {
    
    NSData *receipt = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];
    NSError *error;
    NSDictionary *requestContents = @{@"receipt-data": [receipt base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed]};
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestContents options:0 error:&error];
    
    if (!requestData) {
        if (_failure) {
            _failure(error);
        }
        return;
    }
    
    NSURL *url = [NSURL URLWithString:@"https://sandbox.itunes.apple.com/verifyReceipt"];
//    NSURL *url = [NSURL URLWithString:@"https://buy.itunes.apple.com/verifyReceipt"];
        
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = requestData;
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        
        if (jsonResponse) {
            if (_success) {
                if ([jsonResponse[@"status"] integerValue] == 0) {
                    _success(jsonResponse);
                }
            }
        } else {
            if (_failure) {
                _failure(error);
            }
        }
    }];
    
    [task resume];

}


@end
