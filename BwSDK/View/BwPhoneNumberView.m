//
//  BwPhoneNumberView.m
//  UI
//
//  Created by Zheng on 2017/3/19.
//  Copyright © 2017年 Zheng. All rights reserved.
//

#import "BwPhoneNumberView.h"

@implementation BwPhoneNumberView

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
    if (textField.text.length > 11) {
        textField.text = [textField.text substringToIndex:11];
    }
}

#pragma mark - add subview
- (void)addSuviewsInit {
    [self addSubview:self.titleLbl];
    [self addSubview:self.phoneTxf];
    [self addSubview:self.lineView];
    [self addSubview:self.enterBtn];
}

#pragma mark - layout subview init
- (void)layoutSubviewsInit {
    
    [_titleLbl mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(38);
        make.height.mas_equalTo(30);
        make.centerX.equalTo(self.mas_centerX);
    }];

    CGFloat adaptWidth = [[BaiwenSDK SDKInit] isHorizontal] ? 0.4: 0.8;
    
    [_phoneTxf mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleLbl.mas_bottom).offset(10);
        make.width.equalTo(self.mas_width).multipliedBy(adaptWidth);
        make.centerX.equalTo(self);
        make.height.mas_equalTo(30);
    }];
    
    [_lineView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_phoneTxf);
        make.top.equalTo(_phoneTxf.mas_bottom).offset(4);
        make.height.mas_equalTo(1);
    }];
    
    [_enterBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lineView.mas_bottom).offset(35);
        make.left.right.equalTo(_phoneTxf);
        make.height.mas_equalTo(38);
    }];

    
}

#pragma mark - lazy subviews
- (UILabel *)titleLbl {
    if (!_titleLbl) {
        _titleLbl = [[UILabel alloc] init];
        _titleLbl.text = @"请输入手机号";
        _titleLbl.font = [UIFont boldSystemFontOfSize:19];
    }
    return _titleLbl;
}

- (UITextField *)phoneTxf {
    if (!_phoneTxf) {
        _phoneTxf = [[UITextField alloc] init];
        _phoneTxf.textAlignment = NSTextAlignmentCenter;
        _phoneTxf.keyboardType = UIKeyboardTypeNumberPad;
        [_phoneTxf addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _phoneTxf;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = kLineColor;
    }
    return _lineView;
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



@end
