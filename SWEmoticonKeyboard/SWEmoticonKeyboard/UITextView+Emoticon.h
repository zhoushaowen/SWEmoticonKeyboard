//
//  UITextView+Emoticon.h
//  SWEmojiKeyboard
//
//  Created by zhoushaowen on 2018/1/15.
//  Copyright © 2018年 zhoushaowen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SWEmoticon;
@class SWEmoticonStringGenerator;

@protocol SWEmotionTextViewDelegate <NSObject>

@optional

/**
 限制TextView的表情文字输出长度

 @param textView UITextView
 @param willChangedAttributedText 将要替换self.attributedText的NSAttributedString
 @return YES允许修改self.attributedText,否则不允许
 */
- (BOOL)sw_emotionTextView:(UITextView *)textView shouldChangeToAttributedText:(NSAttributedString *)willChangedAttributedText;

@end

@interface UITextView (Emoticon)

/**
 点击定位光标的手势
 */
@property (nonatomic,readonly,strong) UITapGestureRecognizer *sw_emoticonTapGesture;

@property (nonatomic,readonly,strong) SWEmoticonStringGenerator *sw_emoticonStringGenerator;

@property (nonatomic,weak) id<SWEmotionTextViewDelegate> sw_emoticonDelegate;


/**
 向UITextView中插入一个表情

 @param emoticon 表情
 */
- (void)sw_insertEmoticon:(SWEmoticon *)emoticon;

/**
 将所有表情字符串转换成普通字符串

 @return NSString
 */
- (NSString *)transalteAllEmoticonsToNormalString;

@end
