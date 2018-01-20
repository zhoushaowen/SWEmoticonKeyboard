//
//  UITextField+Emoticon.h
//  SWEmojiKeyboard
//
//  Created by zhoushaowen on 2018/1/17.
//  Copyright © 2018年 zhoushaowen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SWEmoticon;

@interface UITextField (Emoticon)

/**
 向UITextField中插入一个表情

 @param emoticon 表情
 */
- (void)sw_insertEmoticon:(SWEmoticon *)emoticon;

@end
