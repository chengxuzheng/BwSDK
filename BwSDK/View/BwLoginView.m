//
//  BwLoginView.m
//  UI
//
//  Created by Zheng on 2017/3/19.
//  Copyright © 2017年 Zheng. All rights reserved.
//

#import "BwLoginView.h"


@implementation BwLoginView

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
    if (textField.text.length > (textField == _phoneTxf ? 35 : 20)) {
        textField.text = [textField.text substringToIndex:(textField == _phoneTxf ? 35 : 20)];
    }
}


#pragma mark - add subview
- (void)addSuviewsInit {
    [self addSubview:self.phoneTxf];
    [self addSubview:self.passwordTxf];
    [self addSubview:self.loginBtn];
    [self addSubview:self.registerBtn];
    [self addSubview:self.forgetBtn];
    [self addSubview:self.lineView1];
    [self addSubview:self.lineView2];
}

#pragma mark - layout subview init
- (void)layoutSubviewsInit {
    
    CGFloat adaptWidth = [[BaiwenSDK SDKInit] isHorizontal] ? 0.4: 0.8;
    
    [_phoneTxf mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(38);
        make.width.equalTo(self.mas_width).multipliedBy(adaptWidth);
        make.centerX.equalTo(self);
        make.height.mas_equalTo(30);
    }];
    
    [_lineView1 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_phoneTxf);
        make.top.equalTo(_phoneTxf.mas_bottom).offset(4);
        make.height.mas_equalTo(1);
    }];

    [_passwordTxf mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lineView1.mas_bottom).offset(10);
        make.left.right.height.equalTo(_phoneTxf);
    }];
    
    [_lineView2 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(_lineView1);
        make.top.equalTo(_passwordTxf.mas_bottom).offset(4);
    }];
    
    [_loginBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lineView2.mas_bottom).offset(35);
        make.left.right.equalTo(_phoneTxf);
        make.height.mas_equalTo(38);
    }];
    
    [_registerBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_loginBtn.mas_bottom).offset(15);
        make.left.height.equalTo(_loginBtn);
    }];
    
    [_forgetBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.height.equalTo(_registerBtn);
        make.right.equalTo(_phoneTxf);
    }];
    
}

#pragma mark - lazy subviews
- (UITextField *)phoneTxf {
    if (!_phoneTxf) {
        _phoneTxf = [[UITextField alloc] init];
        _phoneTxf.textAlignment = NSTextAlignmentCenter;
        _phoneTxf.placeholder = @"请输入账号";
//        _phoneTxf.keyboardType = UIKeyboardTypeNumberPad;
        [_phoneTxf addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _phoneTxf;
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
        _passwordTxf.textAlignment = NSTextAlignmentCenter;
        _passwordTxf.placeholder = @"请输入密码";
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

- (UIButton *)loginBtn {
    if (!_loginBtn) {
        _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginBtn setTitle:@"登录" forState:UIControlStateNormal];
        _loginBtn.backgroundColor = kBwRedColor;
        _loginBtn.layer.cornerRadius = 6;
        _loginBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    }
    return _loginBtn;
}

- (UIButton *)registerBtn {
    if (!_registerBtn) {
        _registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_registerBtn setTitle:@"新用户注册" forState:UIControlStateNormal];
        [_registerBtn setTitleColor:kBwRedColor forState:UIControlStateNormal];
        _registerBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    }
    return _registerBtn;
}

- (UIButton *)forgetBtn {
    if (!_forgetBtn) {
        _forgetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_forgetBtn setTitle:@"忘记密码?" forState:UIControlStateNormal];
        [_forgetBtn setTitleColor:kBwRedColor forState:UIControlStateNormal];
        _forgetBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    }
    return _forgetBtn;
}


@end
