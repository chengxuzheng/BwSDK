//
//  BaiwenSDK.m
//  BaiwenSDK
//
//  Created by Zheng on 2017/3/18.
//  Copyright © 2017年 Zheng. All rights reserved.
//

#import "BaiwenSDK.h"
#import "BaiwenSDKParamHeader.h"
#import <UIKit/UIKit.h>
#import "ZYSuspensionView.h"
#import "BWSeriveViewController.h"
#import <sys/utsname.h>
#import "CusMD5.h"
#import "CXStoreManager.h"

#import "SuspensionToolKitView.h"


static NSString *url = @"http://server.slthgame.com/home/index/index"; //客服

@interface BaiwenSDK () <ZYSuspensionViewDelegate>
@property (nonatomic, copy, readonly) loginSuccessBlock loginBlock; //登录
@property (nonatomic, copy, readonly) loginSuccessBlock touristsBLock; //游客绑定
@property (nonatomic, copy, readonly) loginSuccessBlock registerBlock; //注册
@property (nonatomic, strong, readonly) UIViewController *rootVC;
@property (nonatomic, strong) ZYSuspensionView *suspensionView;
@property (nonatomic, copy, readonly) NSString *serverName;
@property (nonatomic, copy, readonly) NSString *roleID;
@property (nonatomic, copy, readonly) NSString *roleName;
@property (nonatomic, copy, readonly) NSString *uuidStr;
@property (nonatomic, copy, readonly) NSString *roleLevel;
@property (nonatomic, copy, readonly) NSString *serviceURL; //客服地址

@property (nonatomic, strong) SuspensionToolKitView *serviceView; //客服
@property (nonatomic, strong) SuspensionToolKitView *strategyView; //攻略

@end

@implementation BaiwenSDK 

+ (instancetype)SDKInit {
    static BaiwenSDK *instance = nil;
    static dispatch_once_t t;
    dispatch_once(&t, ^{
        instance = [[BaiwenSDK alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _isHorizontal = YES;
        _rootVC = [UIApplication sharedApplication].delegate.window.rootViewController;
        _uuidStr = [KeyChainManage zcxKeyChainLoad];
        NSLog(@"%@",[self iphoneType]);
    }
    return self;
}

- (void)roleActivationWithInfo:(NSDictionary *)info
                   withSuccess:(void (^)(NSDictionary *response))success
                   withFailure:(void (^)(NSError *error))failure {
    
    NSString *f_time = info[@"f_time"];
    NSString *f_user_id = info[@"f_user_id"];
    NSString *f_game_id = info[@"f_game_id"];
    NSString *f_sid = info[@"f_sid"];
    NSString *f_character_id = info[@"f_character_id"];
    NSString *f_activate = info[@"f_activate"];
    
    NSDictionary *data = @{ @"data":@{@"f_game_id":f_game_id,
                                     @"f_user_id":f_user_id,
                                     @"f_sid":f_sid,
                                     @"f_character_id":f_character_id,
                                     @"f_activate":f_activate,
                                     @"f_time":f_time
                                    }
                           };
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *action = @"active_device";
    NSString *game_id = f_game_id;
    NSString *os = @"ios";
    NSString *channel = @"appstore";
    NSString *device_code = [KeyChainManage zcxKeyChainLoad];
    NSString *key = @"ASD23%*!KK4@8MwdWddOc";
    
    NSString *sign = [CusMD5 md5String:[NSString stringWithFormat:@"action%@data%@game_id%@os%@channel%@device_code%@%@",action,jsonStr,game_id,os,channel,device_code,key]];
    
    NSDictionary *param = @{@"action":action,
                            @"data":jsonStr,
                            @"game_id":game_id,
                            @"os":os,
                            @"channel":channel,
                            @"device_code":device_code,
                            @"sign":sign};
    
   AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:kURL parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
    
}


- (void)receivePayOrderWithInfo:(NSDictionary *)info
                    withSuccess:(void (^)())success
                    withFailure:(void (^)())failure {
    
    NSString *f_game_id = info[@"f_game_id"];
    NSString *f_game_name = info[@"f_game_name"];
    NSString *f_orderid = info[@"f_orderid"];
    NSString *f_product_id = info[@"f_product_id"];
    NSString *f_channel = info[@"f_channel"];
    NSString *f_character_id = info[@"f_character_id"];
    NSString *f_character_name = info[@"f_character_name"];
    NSString *f_sid = info[@"f_sid"];
    NSString *f_time = info[@"f_time"];
    NSString *f_yunying_id = info[@"f_yunying_id"];
    NSString *f_dept = info[@"f_dept"];
    NSString *f_rechage_money = info[@"f_rechage_money"];
    NSString *f_user_id = info[@"f_user_id"];
    NSString *f_user_name = _userAccount;
    
    NSMutableDictionary *newInfo = [info mutableCopy];
    
    [newInfo setObject:_userAccount forKey:@"f_user_name"];
    
    NSString *key = @"ASD23%*!KK4@8MwdWddOc";
    
    NSString *signStr = [NSString stringWithFormat:@"f_game_id%@f_game_name%@f_orderid%@f_product_id%@f_channel%@f_character_id%@f_character_name%@f_sid%@f_time%@f_yunying_id%@f_dept%@f_rechage_money%@f_user_id%@f_user_name%@%@",f_game_id,f_game_name,f_orderid,f_product_id,f_channel,f_character_id,f_character_name,f_sid,f_time,f_yunying_id,f_dept,f_rechage_money,f_user_id,f_user_name,key];
    NSString *sign = [CusMD5 md5String:signStr];
    
    [newInfo setObject:sign forKey:@"sign"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:@"http://114.55.93.35:8000/home/indent" parameters:[newInfo copy] progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success();
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure();
    }];
    
}

#pragma mark - 发起内购
- (void)throughProductLPurchaseRequestsWithProductID:(NSString *)productID
                                         withSuccess:(void(^)(id response))success
                                         withFailure:(void(^)(NSError *error))failure {
    
    [[CXStoreManager defaultManager] throughProductLPurchaseRequestsWithProductID:productID withSuccess:success withFailure:failure];
    
}

#pragma mark - 用户登录成功
- (void)loginSuccess:(NSDictionary *)data {
    _loginBlock(data);
}

- (void)cancelLoginStatus {
    [kUserDefaults removeObjectForKey:kLogin];
}

#pragma mark - 游客绑定成功
- (void)bindingToursitSuccess:(NSDictionary *)data {
    _touristsBLock(data);
}

#pragma mark - 登录
- (void)userGotoLoginUI {
    
    BwLoginViewController *loginVC = [[BwLoginViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
    nav.view.backgroundColor = [UIColor clearColor];
    nav.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    _rootVC.definesPresentationContext = YES;
    [_rootVC presentViewController:nav animated:YES completion:nil];
}

- (void)touristGotoUI {
    BwMBProgress *progress = [[BwMBProgress alloc] init];
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:_rootVC.view];
    hud.delegate = progress;
    [_rootVC.view bringSubviewToFront:hud];
    [_rootVC.view addSubview:hud];
    [hud show:YES];
    
    NSString *game_id = [BaiwenSDK SDKInit].gameID;
    NSString *uuidStr = [KeyChainManage zcxKeyChainLoad];

    NSString *signStr = [CusMD5 md5String:[NSString stringWithFormat:@"actiontouristdevice_code%@osioschannelappstoredevice%@game_id%@",[KeyChainManage zcxKeyChainLoad],uuidStr,game_id]];
    
    NSDictionary *param = @{@"action":@"tourist",
                            @"device_code":[KeyChainManage zcxKeyChainLoad],
                            @"os":@"ios",
                            @"channel":@"appstore",
                            @"device":uuidStr,
                            @"game_id":game_id,
                            @"sign":signStr
                            };
    
    [[AFHTTPSessionManager manager] POST:kURL parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [hud hide:YES];
        });
        if ([responseObject[@"code"] isEqualToNumber:@200]) {
            [BaiwenSDK SDKInit].userID = responseObject[@"data"][@"user_id"];
            NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:responseObject];
            [data setObject:[KeyChainManage zcxKeyChainLoad] forKey:kUuid];
            [data setObject:@"tourist" forKey:kUserType];
            _loginBlock(data);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [hud hide:YES];
        });
    }];
}

- (void)startSDKLoginType:(SDKLoginType)type WithGameID:(NSString *)gameID WithReturnDataBlock:(void(^)(id data))block {
    
    _loginBlock = block;
    _gameID = gameID;
    
    //判断网络是否可用
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi) { //网络可用
            switch (type) {
                case SDKLoginTypeUser: {
                    //用户登录
                    [self userGotoLoginUI];
                }
                    break;
                case SDKLoginTypeTourist: {
                    //游客登录
                    //判断用户是否是游客
                    [[kUserDefaults objectForKey:kLogin] isEqualToString:kLogin]? [self userGotoLoginUI]: [self touristGotoUI];
                }
                    break;
            }
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请检查您的网络" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *act = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alert addAction:act];
            [_rootVC presentViewController:alert animated:YES completion:nil];
        }
    }];
    [manager.reachabilityManager startMonitoring];
}

- (void)bindingToursitWithDataBlock:(void (^)(id))block {
    if (!_rootVC) {
        _rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi) {
            //4G或者WiFi
            //弹出选择是否绑定手机号
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"是否同时绑定手机号" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *act1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //去绑定
                _touristsBLock = block;
                BwPhoneNumberViewController *phoneVC = [[BwPhoneNumberViewController alloc] init];
                phoneVC.isBinding = YES;
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:phoneVC];
                [_rootVC presentViewController:nav animated:YES completion:nil];
            }];
            UIAlertAction *act2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:act2];
            [alert addAction:act1];
            [_rootVC presentViewController:alert animated:YES completion:nil];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请检查您的网络" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *act = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:act];
            [_rootVC presentViewController:alert animated:YES completion:nil];
        }
    }];
    
    [manager.reachabilityManager startMonitoring];
}

- (void)showServiceWtihServerName:(NSString *)serverName withRoleID:(NSString *)roleID withRoleName:(NSString *)roleName {
    if (_suspensionView) {
        [_suspensionView removeFromScreen];
    }
    _serverName = serverName;
    _roleID = roleID;
    _roleName = roleName;
    
    if (_serverName && _roleID && _roleName && _userID) {
        _serviceURL = [NSString stringWithFormat:@"%@?game_id=%@&server_name=%@&user_id=%@&role_id=%@&device=%@&os=iOS&channel=appstore&role_name=%@&user_name=%@",url,_gameID,_serverName,_userID,_roleID,_uuidStr,_roleName,[BaiwenSDK SDKInit].userAccount];
        _serviceURL = [_serviceURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [self showSuspensionView];
    }
}

- (void)showSuspensionView {
    ZYSuspensionView *suspensionView = [[ZYSuspensionView alloc] initWithFrame:CGRectMake([ZYSuspensionView suggestXWithWidth:0], 200, 40, 40) color:[UIColor orangeColor] delegate:self];
    suspensionView.leanType = ZYSuspensionViewLeanTypeEachSide;
    NSString *pathName = [NSString stringWithFormat:@"Resources.bundle/Contents/Resources/123.png"];
    NSString *fullImagePath = [[[NSBundle mainBundle] resourcePath]stringByAppendingPathComponent:pathName];
    UIImage *img = [UIImage imageWithContentsOfFile:fullImagePath];
    [suspensionView setImage:img forState:UIControlStateNormal];
    [suspensionView show];
    self.suspensionView = suspensionView;
}

- (void)suspensionViewDidMoved {
    if (_strategyView&&_serviceView) {
        _suspensionView.isFirstClick = NO;
        [_serviceView removeFromScreen];
        [_strategyView removeFromScreen];
        _serviceView = nil;
        _strategyView = nil;
    }
}

- (void)suspensionViewClick:(ZYSuspensionView *)suspensionView {
    
//    if (_suspensionView.isFirstClick&&suspensionView!=_serviceView&&suspensionView!=_strategyView) {
//        [_serviceView removeFromScreen];
//        _serviceView = nil;
//        [_strategyView removeFromScreen];
//        _strategyView = nil;
//    } else {
//        if (!_serviceView) {
//            _serviceView = [[SuspensionToolKitView alloc] initWithFrame:CGRectMake(suspensionView.centerPoint.x, suspensionView.centerPoint.y+20, 40, 40) color:[UIColor blackColor] delegate:self];
//            _serviceView.leanType = ZYSuspensionViewLeanTypeEachSide;
//            NSString *pathName = [NSString stringWithFormat:@"Resources.bundle/Contents/Resources/123.png"];
//            NSString *fullImagePath = [[[NSBundle mainBundle] resourcePath]stringByAppendingPathComponent:pathName];
//            UIImage *img = [UIImage imageWithContentsOfFile:fullImagePath];
//            [_serviceView setImage:img forState:UIControlStateNormal];
//            [_serviceView show];
//        }
//        
//        if (!_strategyView) {
//            _strategyView = [[SuspensionToolKitView alloc] initWithFrame:CGRectMake(suspensionView.fCenterPoint.x, suspensionView.fCenterPoint.y+20, 40, 40) color:[UIColor blackColor] delegate:self];
//            _strategyView.leanType = ZYSuspensionViewLeanTypeEachSide;
//            NSString *pathName = [NSString stringWithFormat:@"Resources.bundle/Contents/Resources/123.png"];
//            NSString *fullImagePath = [[[NSBundle mainBundle] resourcePath]stringByAppendingPathComponent:pathName];
//            UIImage *img = [UIImage imageWithContentsOfFile:fullImagePath];
//            [_strategyView setImage:img forState:UIControlStateNormal];
//            [_strategyView show];
//        }
//        
//        if (suspensionView == _serviceView) {
//            BWSeriveViewController *sVC = [[BWSeriveViewController alloc] init];
//            sVC.serviceURL = _serviceURL;
//            [_rootVC presentViewController:sVC animated:YES completion:^{
//                [_suspensionView removeFromScreen];
//                [_serviceView removeFromScreen];
//                _serviceView = nil;
//                [_strategyView removeFromScreen];
//                _strategyView = nil;
//            }];
//        }
//        
//        if (suspensionView == _strategyView) {
//            //TODO: 跳转到攻略页面
//            BWSeriveViewController *sVC = [[BWSeriveViewController alloc] init];
//            sVC.serviceURL = _serviceURL;
//            [_rootVC presentViewController:sVC animated:YES completion:^{
//                [_suspensionView removeFromScreen];
//                [_serviceView removeFromScreen];
//                _serviceView = nil;
//                [_strategyView removeFromScreen];
//                _strategyView = nil;
//            }];
//        }
//    }
    
//    _suspensionView.isFirstClick = !_suspensionView.isFirstClick;
    
//    NSLog(@"%@",NSStringFromCGPoint(_suspensionView.centerPoint));
    
    BWSeriveViewController *sVC = [[BWSeriveViewController alloc] init];
    sVC.serviceURL = _serviceURL;
    [_rootVC presentViewController:sVC animated:YES completion:^{
        [_suspensionView removeFromScreen];
        [_serviceView removeFromScreen];
        _serviceView = nil;
        [_strategyView removeFromScreen];
        _strategyView = nil;
    }];
}

- (void)getRegisterSuccess:(void(^)(id data))block {
    _registerBlock = block;    
}

- (void)registerSuccess:(NSDictionary *)data {
    _registerBlock(data);
}

- (NSString *)iphoneType {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPhone8,4"]) return @"iPhone SE";
    if ([platform isEqualToString:@"iPhone9,1"]) return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus";
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1G";
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini 1G";
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini 1G";
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini 1G";
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,5"])   return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,6"])   return @"iPad 4";
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2G";
    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    
    return platform;
    
}


@end
