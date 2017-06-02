//
//  BaiwenSDK.h
//  BaiwenSDK
//
//  Created by Zheng on 2017/3/18.
//  Copyright © 2017年 Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^loginSuccessBlock)(NSDictionary *data);

typedef NS_ENUM(NSUInteger, SDKLoginType) {
    SDKLoginTypeUser, //用户登录
    SDKLoginTypeTourist, //游客登录
};

@interface BaiwenSDK : NSObject

/**
 初始化SDK

 @return BaiwenSDK类
 */
+ (instancetype)SDKInit;

/**
 根据SDKLoginType类型启动 游客登录或用户界面

 @param type 登录类型
 @param gameID 游戏ID
 @param block 数据回调
 */
- (void)startSDKLoginType:(SDKLoginType)type
               WithGameID:(NSString *)gameID
      WithReturnDataBlock:(void(^)(id data))block;


/**
 注销自动登录
 */
- (void)cancelLoginStatus;


/**
 激活账号
 
 @param info 参数信息
 */
- (void)roleActivationWithInfo:(NSDictionary *)info
                   withSuccess:(void(^)(NSDictionary *response))success
                   withFailure:(void(^)(NSError *error))failure;


/**
 接收订单信息

 @param info 参数信息
 @param success 成功回调
 @param failure 失败回调
 */
- (void)receivePayOrderWithInfo:(NSDictionary *)info
                    withSuccess:(void(^)())success
                    withFailure:(void(^)())failure;


/**
 选择游戏大区并创建人物进入游戏后调用 启动客服浮窗按钮
 
 @param serverName 服务器名称
 @param roleID 角色id
 @param roleName 角色名称
 */
- (void)showServiceWtihServerName:(NSString *)serverName
                       withRoleID:(NSString *)roleID
                     withRoleName:(NSString *)roleName;

/**
 充值时调用 如果是游客跳转绑定界面 在绑定成功后回调
 
 @param block 数据回调
 */
- (void)bindingToursitWithDataBlock:(void(^)(id data))block;

/**
 获得注册成功状态
 
 @param block 数据回调
 */
- (void)getRegisterSuccess:(void(^)(id data))block;


- (void)throughProductLPurchaseRequestsWithProductID:(NSString *)productID
                                         withSuccess:(void(^)(id response))success
                                         withFailure:(void(^)(NSError *error))failure;






/**
 设置isHorizontal 是否水平显示 默认值为YES
 */
@property (nonatomic, assign) BOOL isHorizontal;

@property (nonatomic, copy) NSString *gameID;
@property (nonatomic, copy) NSString *userAccount;
@property (nonatomic, copy) NSString *userID;

- (void)loginSuccess:(NSDictionary *)data;
- (void)bindingToursitSuccess:(NSDictionary *)data;
- (void)registerSuccess:(NSDictionary *)data;
- (void)showSuspensionView;

@end
