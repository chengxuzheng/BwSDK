//
//  KeyChainManage.m
//  KeyChain
//
//  Created by Zheng on 2017/3/17.
//  Copyright © 2017年 Zheng. All rights reserved.
//

#import "KeyChainManage.h"


@implementation KeyChainManage

// UUID获得
+ (NSString *)obtainedUUID {
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}


+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (id)kSecClassGenericPassword,(id)kSecClass,
            service, (id)kSecAttrService,
            service, (id)kSecAttrAccount,
            (id)kSecAttrAccessibleAfterFirstUnlock,(id)kSecAttrAccessible,
            nil];
}

+ (void)save:(NSString *)service data:(id)data {
    //得到搜索字典
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //删除旧项目之前添加新的项目
    SecItemDelete((CFDictionaryRef)keychainQuery);
    //添加新对象搜索字典(注意:数据格式)
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(id)kSecValueData];
    //添加物品与搜索字典钥匙链
    SecItemAdd((CFDictionaryRef)keychainQuery, NULL);
}

+ (id)load:(NSString *)service {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];

    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        } @catch (NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@", service, e);
        } @finally {
        }
    }
    if (keyData)
        CFRelease(keyData);
    return ret;
}

+ (void)zcxKeyChainSave:(NSString *)service {
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
    [tempDic setObject:service forKey:kZCXDictionaryKey];
    [self save:kZCXChainKey data:tempDic];
}

+ (NSString *)zcxKeyChainLoad {
    NSMutableDictionary *tempDic = (NSMutableDictionary *)[self load:kZCXChainKey];
    
    NSString *uniqueStr = [tempDic objectForKey:kZCXDictionaryKey];
//    NSLog(@"%@",tempDic);
    if (uniqueStr == nil) {
        [self zcxKeyChainSave:[self obtainedUUID]];
        return [self obtainedUUID];
    }
    
    return uniqueStr;
}

+ (void)zcxKeyChainDelete{
    [self delete:kZCXChainKey];
}

+ (void)delete:(NSString *)service {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((CFDictionaryRef)keychainQuery);
}


@end
