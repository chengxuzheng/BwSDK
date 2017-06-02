//
//  ZYSuspensionView.h
//  ZYSuspensionView
//
//  Created by Zheng on 16-02-25.
//  Copyright (c) 2016年 ripper. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZYSuspensionContainer : UIWindow
@end

@interface ZYSuspensionViewController : UIViewController
@end

@class ZYSuspensionView;
@protocol ZYSuspensionViewDelegate <NSObject>
- (void)suspensionViewClick:(ZYSuspensionView *)suspensionView;

- (void)suspensionViewDidMoved;

@end

typedef NS_ENUM(NSUInteger, ZYSuspensionViewLeanType) {
    ZYSuspensionViewLeanTypeHorizontal,
    ZYSuspensionViewLeanTypeEachSide
};

@interface ZYSuspensionView : UIButton

@property (nonatomic, weak) id<ZYSuspensionViewDelegate> delegate;
@property (nonatomic, assign) ZYSuspensionViewLeanType leanType;
@property (nonatomic, assign) CGPoint centerPoint; //first view
@property (nonatomic, assign) CGPoint fCenterPoint; //second view

@property (nonatomic, assign) BOOL isFirstClick;


+ (instancetype)defaultSuspensionViewWithDelegate:(id<ZYSuspensionViewDelegate>)delegate;

+ (CGFloat)suggestXWithWidth:(CGFloat)width;

- (instancetype)initWithFrame:(CGRect)frame color:(UIColor*)color delegate:(id<ZYSuspensionViewDelegate>)delegate;

- (void)show;

- (void)removeFromScreen;

- (void)handlePanGesture:(UIPanGestureRecognizer*)p;

@end


