//
//  SWEmotionCell.m
//  SWEmojiKeyboard
//
//  Created by zhoushaowen on 2018/1/15.
//  Copyright © 2018年 zhoushaowen. All rights reserved.
//

#import "SWEmotionCell.h"
#import "SWEmoticon.h"


@interface SWEmotionCell ()
{
    UIButton *_btn;
}

@end

@implementation SWEmotionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _btn = [UIButton buttonWithType:UIButtonTypeCustom];
    _btn.userInteractionEnabled = NO;
    _btn.titleLabel.font = [UIFont systemFontOfSize:30];
    _btn.frame = CGRectInset(self.bounds, 4, 4);
    _btn.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:_btn];
}

- (void)setEmoticon:(SWEmoticon *)emoticon {
    _emoticon = emoticon;
    [_btn setTitle:nil forState:UIControlStateNormal];
    [_btn setImage:nil forState:UIControlStateNormal];
    [_btn setImage:nil forState:UIControlStateHighlighted];
    if(_emoticon.emojiStr.length > 0){
        [_btn setTitle:_emoticon.emojiStr forState:UIControlStateNormal];
    }
    if(_emoticon.png.length > 0){
        [_btn setImage:[UIImage imageWithContentsOfFile:_emoticon.pngPath] forState:UIControlStateNormal];
    }
    if(_emoticon.isDeleteIcon){
        NSString *norPath = [[[NSBundle mainBundle] pathForResource:@"Emoticons.bundle" ofType:nil] stringByAppendingPathComponent:@"compose_emotion_delete"];
        NSString *hilPath = [[[NSBundle mainBundle] pathForResource:@"Emoticons.bundle" ofType:nil] stringByAppendingPathComponent:@"compose_emotion_delete_highlighted"];
        [_btn setImage:[UIImage imageWithContentsOfFile:norPath] forState:UIControlStateNormal];
        [_btn setImage:[UIImage imageWithContentsOfFile:hilPath] forState:UIControlStateHighlighted];
    }
}

@end
