//
//  BWSeriveViewController.m
//  BWServiceSDK
//
//  Created by Zheng on 2017/4/6.
//  Copyright © 2017年 Zheng. All rights reserved.
//

#import "BWSeriveViewController.h"
#import "Masonry.h"
#import <WebKit/WebKit.h>
#import "BaiwenSDK.h"
#import "MBProgressHUD.h"

@interface BWSeriveViewController () <WKNavigationDelegate,MBProgressHUDDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation BWSeriveViewController

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self layoutSubviewsInView];
    [self clearCache];
}

- (void)setServiceURL:(NSString *)serviceURL {
    _serviceURL = serviceURL;
}

#pragma mark - 清理缓存
- (void)clearCache {
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
        NSSet *websiteDataTypes = [NSSet setWithArray:@[WKWebsiteDataTypeDiskCache,
                                                        WKWebsiteDataTypeMemoryCache,
                                                        WKWebsiteDataTypeCookies]];
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
            [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_serviceURL]]];
        }];
    } else {
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
        NSError *errors;
        [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&errors];
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_serviceURL]]];
    }
}

#pragma mark - wkwebview navigationdelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    decisionHandler(WKNavigationActionPolicyAllow);
    if ([[navigationAction.request.URL absoluteString] rangeOfString:@"#close"].location != NSNotFound) {
        [self dismissViewControllerAnimated:YES completion:^{
            [[BaiwenSDK SDKInit] showSuspensionView];
        }];
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    [_hud show:YES];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [_hud hide:YES];
}



#pragma mark - subviews
- (void)layoutSubviewsInView {
    [self.view addSubview:self.webView];
    [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self.view);
    }];
    
    [self.view addSubview:self.hud];
}

- (MBProgressHUD *)hud {
    if (!_hud) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        _hud.delegate = self;
    }
    return _hud;
}

- (WKWebView *)webView {
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:self.view.frame];
        _webView.navigationDelegate = self;
    }
    return _webView;
}


#pragma mark - 内存警告
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
