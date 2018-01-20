//
//  UITextField+Emoticon.m
//  SWEmojiKeyboard
//
//  Created by zhoushaowen on 2018/1/17.
//  Copyright © 2018年 zhoushaowen. All rights reserved.
//

#import "UITextField+Emoticon.h"
#import "SWEmoticon.h"
#import "SWTextAttachment.h"

@implementation UITextField (Emoticon)

- (void)sw_insertEmoticon:(SWEmoticon *)emoticon {
    if(emoticon.emojiStr.length > 0){//emoji表情
        [self replaceRange:self.selectedTextRange withText:emoticon.emojiStr];
        return;
    }
    if(emoticon.pngPath.length > 0){//图片表情
        [self replaceRange:self.selectedTextRange withText:emoticon.chs];
        return;
    }
    if(emoticon.isDeleteIcon){//删除按钮
        [self deleteBackward];
    }
}

@end
