//
//  SWEmoticonStringGenerator.h
//  SWEmojiKeyboard
//
//  Created by zhoushaowen on 2018/1/17.
//  Copyright © 2018年 zhoushaowen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIFont;

@interface SWEmoticonStringGenerator : NSObject

/**
 生成表情属性字符串

 @param originalStr 原始的NSString
 @param font 生成的字符串字体大小
 @return NSAttributedString
 */
- (NSAttributedString *)generateEmoticonAttributedStringWithOriginalString:(NSString *)originalStr font:(UIFont *)font;

@end
