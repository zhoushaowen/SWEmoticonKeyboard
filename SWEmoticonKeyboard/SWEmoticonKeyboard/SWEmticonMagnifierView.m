//
//  SWEmticonMagnifierView.m
//  SWEmoticonKeyboard
//
//  Created by zhoushaowen on 2018/1/22.
//  Copyright © 2018年 zhoushaowen. All rights reserved.
//

#import "SWEmticonMagnifierView.h"
#import "SWEmoticon.h"

@interface SWEmticonMagnifierView ()
{
    UIButton *_emoticonBtn;
    SWEmoticon *_currentEmoticon;
}

@property (nonatomic,strong) UIImageView *bgImgV;

@end

@implementation SWEmticonMagnifierView

+ (instancetype)magnifierView {
    NSString *path = [[[NSBundle mainBundle] pathForResource:@"Emoticons.bundle" ofType:nil] stringByAppendingPathComponent:@"emoticon_keyboard_magnifier"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    SWEmticonMagnifierView *view = [[SWEmticonMagnifierView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    view.bgImgV.image = image;
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        self.userInteractionEnabled = NO;
        _bgImgV = [[UIImageView alloc] initWithFrame:frame];
        _bgImgV.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:_bgImgV];
        _emoticonBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _emoticonBtn.titleLabel.font = [UIFont systemFontOfSize:35];
        [self addSubview:_emoticonBtn];
        _emoticonBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_emoticonBtn attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]]];
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_emoticonBtn(40)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_emoticonBtn)]];
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-16-[_emoticonBtn(40)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_emoticonBtn)]];
    }
    return self;
}

- (void)setEmoticon:(SWEmoticon *)emoticon {
    _emoticon = emoticon;
    [_emoticonBtn setTitle:nil forState:UIControlStateNormal];
    [_emoticonBtn setBackgroundImage:nil forState:UIControlStateNormal];
    if(_emoticon.emojiStr.length > 0){
        [_emoticonBtn setTitle:_emoticon.emojiStr forState:UIControlStateNormal];
    }
    if(_emoticon.png.length > 0){
        [_emoticonBtn setBackgroundImage:[UIImage imageWithContentsOfFile:_emoticon.pngPath] forState:UIControlStateNormal];
    }
    if(_currentEmoticon != _emoticon && _emoticon != nil){
        [_emoticonBtn.layer removeAllAnimations];
        _emoticonBtn.transform = CGAffineTransformIdentity;
        [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _emoticonBtn.transform = CGAffineTransformMakeTranslation(0, -12);
        } completion:^(BOOL finished) {
            
        }];
    }
    _currentEmoticon = _emoticon;
}



@end
