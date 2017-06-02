//
//  BwVerificationCodeView.m
//  UI
//
//  Created by Zheng on 2017/3/19.
//  Copyright © 2017年 Zheng. All rights reserved.
//

#import "BwVerificationCodeView.h"

#import "BwVerificationCodeViewController.h"

@implementation BwVerificationCodeView

- (instancetype)init {
    self = [super init];
    if (self) {
        
        [self addSuviewsInit];
        
        [self layoutSubviewsInit];
    }
    return self;
}

#pragma mark - 限制输入位数
- (void)textDidChange:(UITextField *)textField {
    if (textField.text.length > (textField == _codeTfd ? 4 : 20)) {
        textField.text = [textField.text substringToIndex:(textField == _codeTfd ? 4 : 20)];
    }
}

#pragma mark - add subview
- (void)addSuviewsInit {
    [self addSubview:self.codeTfd];
    [self addSubview:self.passwordTxf];
    [self addSubview:self.enterBtn];
    [self addSubview:self.lineView1];
    [self addSubview:self.lineView2];
    [self addSubview:self.codeBtn];
}

#pragma mark - layout subview init
- (void)layoutSubviewsInit {
    
    CGFloat adaptWidth = [[BaiwenSDK SDKInit] isHorizontal] ? 0.4: 0.8;
    
    [_codeTfd mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(38);
        make.width.equalTo(self.mas_width).multipliedBy(adaptWidth);
        make.centerX.equalTo(self);
        make.height.mas_equalTo(30);
    }];
    
    [_lineView1 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_codeTfd);
        make.top.equalTo(_codeTfd.mas_bottom).offset(4);
        make.height.mas_equalTo(1);
    }];
    
    [_passwordTxf mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lineView1.mas_bottom).offset(10);
        make.left.right.height.equalTo(_codeTfd);
    }];
    
    [_lineView2 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(_lineView1);
        make.top.equalTo(_passwordTxf.mas_bottom).offset(4);
    }];
    
    [_enterBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lineView2.mas_bottom).offset(35);
        make.left.right.equalTo(_codeTfd);
        make.height.mas_equalTo(38);
    }];
    
    [_codeBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.right.equalTo(_codeTfd);
        make.width.mas_offset(100);
        make.height.mas_offset(30);
    }];
}

#pragma mark - lazy subviews
- (UITextField *)codeTfd {
    if (!_codeTfd) {
        _codeTfd = [[UITextField alloc] init];
        _codeTfd.placeholder = @"请输入验证码";
        _codeTfd.font = [UIFont systemFontOfSize:15];
        _codeTfd.keyboardType = UIKeyboardTypeNumberPad;
        [_codeTfd addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];

    }
    return _codeTfd;
}

- (UIView *)lineView1 {
    if (!_lineView1) {
        _lineView1 = [[UIView alloc] init];
        _lineView1.backgroundColor = kLineColor;
    }
    return _lineView1;
}

- (UITextField *)passwordTxf {
    if (!_passwordTxf) {
        _passwordTxf = [[UITextField alloc] init];
        _passwordTxf.secureTextEntry = YES;
        _passwordTxf.placeholder = @"请输入密码";
        _passwordTxf.secureTextEntry = YES;
        _passwordTxf.font = [UIFont systemFontOfSize:15];
        [_passwordTxf addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _passwordTxf;
}

- (UIView *)lineView2 {
    if (!_lineView2) {
        _lineView2 = [[UIView alloc] init];
        _lineView2.backgroundColor = kLineColor;
    }
    return _lineView2;
}

- (UIButton *)enterBtn {
    if (!_enterBtn) {
        _enterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _enterBtn.backgroundColor = kBwRedColor;
        _enterBtn.layer.cornerRadius = 6;
        _enterBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    }
    return _enterBtn;
}

- (UIButton *)codeBtn {
    if (!_codeBtn) {
        _codeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _codeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_codeBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_codeBtn addTarget:self action:@selector(sendCodeBtnAction) forControlEvents:UIControlEventTouchUpInside];
        _codeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    }
    return _codeBtn;
}

#pragma mark - 点击发送验证码
- (void)sendCodeBtnAction {
    
    [_delegate sendCodeWithNetquest];
    
    [self codeBtnAction];
}

#pragma mark - 倒计时
- (void)codeBtnAction {
    __block int timeout = 60;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(timer,dispatch_walltime(NULL, 0), 1.0*NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        if(timeout <= 0){
            dispatch_source_cancel(timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                [_codeBtn setTitle:@"重新发送" forState:UIControlStateNormal];
                _codeBtn.userInteractionEnabled = YES;
            });
        } else {
            NSString *timeStr = [NSString stringWithFormat:@"%d s", timeout];
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:1];
                [_codeBtn setTitle:timeStr forState:UIControlStateNormal];
                [UIView commitAnimations];
                _codeBtn.userInteractionEnabled = NO;
            });
            timeout--;
        }
    });
    dispatch_resume(timer);
}

@end
