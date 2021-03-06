//
//  KeyboardToolBar.m
//  AnjukeBroker_New
//
//  Created by Wu sicong on 13-10-26.
//  Copyright (c) 2013年 Wu sicong. All rights reserved.
//

#import "KeyboardToolBar.h"

@implementation KeyboardToolBar
@synthesize clickDelagate;
@synthesize leftButton, rightButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        int itemW = 60;
        int itemH = 30;
        UIButton *preBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        preBtn.frame = CGRectMake(5, (frame.size.height - itemH)/2, itemW, itemH);
        [preBtn setTitle:@"上一项" forState:UIControlStateNormal];
        [preBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        preBtn.backgroundColor = [UIColor clearColor];
        self.leftButton = preBtn;
        [preBtn addTarget:self action:@selector(doPre) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:preBtn];
        
        UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        nextBtn.frame = CGRectMake(5*2 + itemW, (frame.size.height - itemH)/2, itemW, itemH);
        [nextBtn setTitle:@"下一项" forState:UIControlStateNormal];
        [nextBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        nextBtn.backgroundColor = [UIColor clearColor];
        self.rightButton = nextBtn;
        [nextBtn addTarget:self action:@selector(doNext) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:nextBtn];
        
        CGFloat finishBtn_W = 56;
        CGFloat finishBtn_H = 30;
        UIButton *finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        finishBtn.frame = CGRectMake(frame.size.width- finishBtn_W*1.2, (frame.size.height-finishBtn_H)/2, finishBtn_W, finishBtn_H);
        finishBtn.backgroundColor = [UIColor clearColor];
        [finishBtn setTitle:@"完成" forState:UIControlStateNormal];
        [finishBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [finishBtn addTarget:self action:@selector(doDone) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:finishBtn];
        
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void)doPre {
    if ([self.clickDelagate respondsToSelector:@selector(preBtnClicked)]) {
        [self.clickDelagate preBtnClicked];
    }
}

- (void)doNext {
    if ([self.clickDelagate respondsToSelector:@selector(nextBtnClicked)]) {
        [self.clickDelagate nextBtnClicked];
    }
}

- (void)doDone {
    if ([self.clickDelagate respondsToSelector:@selector(finishBtnClicked)]) {
        [self.clickDelagate finishBtnClicked];
    }
}

- (void)setNormalWithButton:(UIButton *)btn {
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.enabled = YES;
}

- (void)setDisableWithButton:(UIButton *)btn {
    [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    btn.enabled = NO;
}

@end
