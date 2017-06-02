//
//  ZYSuspensionView.m
//  ZYSuspensionView
//
//  GitHub https://github.com/ripperhe
//  Created by ripper on 16-02-25.
//  Copyright (c) 2016年 ripper. All rights reserved.
//

#import "ZYSuspensionView.h"
#import "NSObject+ZYSuspensionView.h"
#import "ZYSuspensionManager.h"

#define kLeanProportion (8/55.0)
#define kVerticalMargin 15.0

@implementation ZYSuspensionContainer
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.windowLevel = 1000000;
    }
    return self;
}

@end

@implementation ZYSuspensionViewController
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotate {
    return NO;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}

@end

@implementation ZYSuspensionView

+ (instancetype)defaultSuspensionViewWithDelegate:(id<ZYSuspensionViewDelegate>)delegate
{
    ZYSuspensionView *sus = [[ZYSuspensionView alloc] initWithFrame:CGRectMake(kLeanProportion * 55, 100, 55, 55)
                                                              color:[UIColor colorWithRed:0.21f green:0.45f blue:0.88f alpha:1.00f]
                                                           delegate:delegate];

    return sus;
}

+ (CGFloat)suggestXWithWidth:(CGFloat)width
{
    return - width * kLeanProportion;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame
                         color:[UIColor colorWithRed:0.21f green:0.45f blue:0.88f alpha:1.00f]
                      delegate:nil];
}

- (instancetype)initWithFrame:(CGRect)frame color:(UIColor*)color delegate:(id<ZYSuspensionViewDelegate>)delegate
{
    if(self = [super initWithFrame:frame])
    {
        _centerPoint = CGPointMake(frame.origin.x+45, frame.origin.y-20);
        _fCenterPoint = CGPointMake(frame.origin.x+90, frame.origin.y-20);
        
        self.delegate = delegate;
        self.userInteractionEnabled = YES;
        self.backgroundColor = color;
        self.alpha = .3;
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 1.0;
        self.clipsToBounds = YES;

        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanGesture:)];
        pan.delaysTouchesBegan = YES;
        [self addGestureRecognizer:pan];
        [self addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

#pragma mark - event response
- (void)handlePanGesture:(UIPanGestureRecognizer*)p {
    
    [self.delegate suspensionViewDidMoved];
    
    UIWindow *appWindow = [UIApplication sharedApplication].delegate.window;
    CGPoint panPoint = [p locationInView:appWindow];
    
    if(p.state == UIGestureRecognizerStateBegan) {
        self.alpha = 1;
    }else if(p.state == UIGestureRecognizerStateChanged) {
        [ZYSuspensionManager windowForKey:self.zy_md5Key].center = CGPointMake(panPoint.x, panPoint.y);
    }else if(p.state == UIGestureRecognizerStateEnded
             || p.state == UIGestureRecognizerStateCancelled) {
        self.alpha = .7;
        
        CGFloat ballHeight = self.frame.size.height;
        CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
        CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;

        CGFloat left = fabs(panPoint.x);
        CGFloat right = fabs(screenWidth - left);
        CGFloat top = fabs(panPoint.y);
        CGFloat bottom = fabs(screenHeight - top);
        
        CGFloat minSpace = 0;
        if (self.leanType == ZYSuspensionViewLeanTypeHorizontal) {
            minSpace = MIN(left, right);
        }else{
            minSpace = MIN(MIN(MIN(top, left), bottom), right);
        }
        CGPoint newCenter = CGPointZero;
        CGFloat targetY = 0;
        
        //Correcting Y
        if (panPoint.y < kVerticalMargin + ballHeight / 2.0) {
            targetY = kVerticalMargin + ballHeight / 2.0;
        }else if (panPoint.y > (screenHeight - ballHeight / 2.0 - kVerticalMargin)) {
            targetY = screenHeight - ballHeight / 2.0 - kVerticalMargin;
        }else{
            targetY = panPoint.y;
        }
        
        if (minSpace == left) {
            //XSpace
            newCenter = CGPointMake(20, targetY);
            _centerPoint = CGPointMake(45, targetY-40);
//            _fCenterPoint = CGPointMake(45, targetY+5);
            _fCenterPoint = CGPointMake(90, targetY-40);
            
        }else if (minSpace == right) {
            //XSpace
            newCenter = CGPointMake(screenWidth - 20, targetY);
            _centerPoint = CGPointMake(screenWidth - 85, targetY-40);
//            _fCenterPoint = CGPointMake(screenWidth - 85, targetY+5);
            _fCenterPoint = CGPointMake(screenWidth - 130, targetY-40);

        }else if (minSpace == top) {
            //YSpace
            newCenter = CGPointMake(panPoint.x, 20);
            _centerPoint = CGPointMake(panPoint.x-20, 25);
//            _fCenterPoint = CGPointMake(panPoint.x+25, 25);
            _fCenterPoint = CGPointMake(panPoint.x-20, 70);

        }else {
            //YSpace
            newCenter = CGPointMake(panPoint.x, screenHeight - 20);
            _centerPoint = CGPointMake(panPoint.x-20, screenHeight-105);
//            _fCenterPoint = CGPointMake(panPoint.x+25, screenHeight-105);
            _fCenterPoint = CGPointMake(panPoint.x-20, screenHeight-150);
        }
        
        [UIView animateWithDuration:.25 animations:^{
            [ZYSuspensionManager windowForKey:self.zy_md5Key].center = newCenter;
        }];
    }else{
        NSLog(@"pan state : %zd", p.state);
    }
}

- (void)click
{
    if([self.delegate respondsToSelector:@selector(suspensionViewClick:)])
    {
        [self.delegate suspensionViewClick:self];
    }
}

#pragma mark - public methods
- (void)show
{
    if ([ZYSuspensionManager windowForKey:self.zy_md5Key]) return;
    
    UIWindow *currentKeyWindow = [UIApplication sharedApplication].keyWindow;
    
    ZYSuspensionContainer *backWindow = [[ZYSuspensionContainer alloc] initWithFrame:self.frame];
    backWindow.rootViewController = [[ZYSuspensionViewController alloc] init];
//    backWindow.backgroundColor = [UIColor whiteColor];
    [backWindow makeKeyAndVisible];
    [ZYSuspensionManager saveWindow:backWindow forKey:self.zy_md5Key];

    self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.layer.cornerRadius = self.frame.size.width <= self.frame.size.height ? self.frame.size.width / 2.0 : self.frame.size.height / 2.0;
    [backWindow addSubview:self];
    
    // Keep the original keyWindow and avoid some unpredictable problems
    [currentKeyWindow makeKeyWindow];
}

- (void)removeFromScreen
{
    [ZYSuspensionManager destroyWindowForKey:self.zy_md5Key];
}

@end
