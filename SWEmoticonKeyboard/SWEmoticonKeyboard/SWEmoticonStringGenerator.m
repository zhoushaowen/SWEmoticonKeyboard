//
//  SWEmoticonStringGenerator.m
//  SWEmojiKeyboard
//
//  Created by zhoushaowen on 2018/1/17.
//  Copyright © 2018年 zhoushaowen. All rights reserved.
//

#import "SWEmoticonStringGenerator.h"
#import <UIKit/NSTextAttachment.h>
#import <UIKit/UIFont.h>
#import <UIKit/UIImage.h>
#import <UIKit/NSAttributedString.h>
#import "SWKeyboardPackage.h"
#import "SWEmoticon.h"
#import "SWTextAttachment.h"

@interface SWEmoticonStringGenerator ()

@property (nonatomic,copy) NSArray *packages;

@end

@implementation SWEmoticonStringGenerator

#pragma mark - Public
- (NSAttributedString *)generateEmoticonAttributedStringWithOriginalString:(NSString *)originalStr font:(UIFont *)font {
    if(originalStr.length < 1) return nil;
    //表情的规则
    NSString *pattern = @"\\[.*?\\]";
    NSError *error = nil;
    //利用规则创建一个正则表达式对象
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    if(error){
        NSLog(@"正则表达式有误:%@",error.localizedDescription);
    }
    //匹配结果
    NSArray<NSTextCheckingResult *> *results = [regex matchesInString:originalStr options:0 range:NSMakeRange(0, originalStr.length)];
    //创建一个属性字符串
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:originalStr];
    //倒序遍历数组
    [results enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //取出匹配结果的chs
        NSString *chs = [originalStr substringWithRange:obj.range];
        //查找chs对应的pngPath
        NSString *pngPath = [self findEmoticonPngPathWithString:chs];
        if(pngPath.length > 0){
            //创建表情附件
            SWTextAttachment *attachment = [SWTextAttachment new];
            attachment.chs = chs;
            UIImage *image = [UIImage imageWithContentsOfFile:pngPath];
            attachment.image = image;
            attachment.bounds = CGRectMake(0, font.descender, font.lineHeight, font.lineHeight);
            NSAttributedString *emoticonAttriStr = [NSAttributedString attributedStringWithAttachment:attachment];
            //将之前字符串中chs替换成表情
            //不采用正序遍历的原因是因为:正序排列替换掉前面的字符串之后,后面的字符串的location就变了
            [attributedStr replaceCharactersInRange:obj.range withAttributedString:emoticonAttriStr];
        }
    }];
    [attributedStr addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, attributedStr.string.length)];
    return [attributedStr copy];
}

#pragma mark - Private
- (NSString *)findEmoticonPngPathWithString:(NSString *)str {
    NSArray *packages = self.packages;
    NSString *resultStr = nil;
    for (SWKeyboardPackage *package in packages) {
        for (SWEmoticon *emoticon in package.emoticons) {
            if([emoticon.chs isEqualToString:str]){
                resultStr = emoticon.pngPath;
                break;
            }
        }
        if(resultStr){
            break;
        }
    }
    return resultStr;
}

- (NSArray *)packages {
    if(!_packages){
        NSArray *packages = [SWKeyboardPackage loadPackages];
        NSMutableArray *mutableArr = [packages mutableCopy];
        [mutableArr removeObjectAtIndex:0];
        _packages = [mutableArr copy];
    }
    return _packages;
}


@end
