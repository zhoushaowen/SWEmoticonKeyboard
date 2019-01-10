//
//  UITextView+Emoticon.m
//  SWEmojiKeyboard
//
//  Created by zhoushaowen on 2018/1/15.
//  Copyright © 2018年 zhoushaowen. All rights reserved.
//

#import "UITextView+Emoticon.h"
#import "SWEmoticon.h"
#import "SWTextAttachment.h"
#import <objc/runtime.h>
#import "SWEmoticonStringGenerator.h"

static void *sw_emoticonTapGesture_key = &sw_emoticonTapGesture_key;
static void *emoticonStringGenerator_key = &emoticonStringGenerator_key;
static void *sw_emoticonDelegate_key = &sw_emoticonDelegate_key;

@interface UITextView ()

@property (nonatomic,strong) UITapGestureRecognizer *sw_emoticonTapGesture;
@property (nonatomic,strong) SWEmoticonStringGenerator *sw_emoticonStringGenerator;

@end

@implementation UITextView (Emoticon)

@dynamic sw_emoticonTapGesture;
@dynamic sw_emoticonDelegate;

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self exchangeMethodWithSystemSelector:@selector(initWithFrame:textContainer:) customSelector:@selector(swEmoticon_initWithFrame:textContainer:)];
        [self exchangeMethodWithSystemSelector:@selector(initWithCoder:) customSelector:@selector(swEmoticon_initWithCoder:)];
        [self exchangeMethodWithSystemSelector:@selector(copy:) customSelector:@selector(swEmoticon_copy:)];
        [self exchangeMethodWithSystemSelector:@selector(paste:) customSelector:@selector(swEmoticon_paste:)];
        [self exchangeMethodWithSystemSelector:@selector(becomeFirstResponder) customSelector:@selector(swEmoticon_becomeFirstResponder)];
        [self exchangeMethodWithSystemSelector:@selector(resignFirstResponder) customSelector:@selector(swEmoticon_resignFirstResponder)];
    });
}

+ (void)exchangeMethodWithSystemSelector:(SEL)systemSelector customSelector:(SEL)customSelector {
    Method systemMethod = class_getInstanceMethod([self class], systemSelector);
    Method customMethod = class_getInstanceMethod([self class], customSelector);
    if(class_addMethod([self class], systemSelector, method_getImplementation(customMethod), method_getTypeEncoding(customMethod))){
        class_replaceMethod([self class], customSelector, method_getImplementation(systemMethod), method_getTypeEncoding(systemMethod));
    }else{
        method_exchangeImplementations(systemMethod, customMethod);
    }
}

- (instancetype)swEmoticon_initWithFrame:(CGRect)frame textContainer:(nullable NSTextContainer *)textContainer {
    UITextView *obj = [self swEmoticon_initWithFrame:frame textContainer:textContainer];
    if(obj){
        [self sw_emotion_addTapGesture];
    }
    return obj;
}

- (instancetype)swEmoticon_initWithCoder:(NSCoder *)aDecoder {
    UITextView *obj = [self swEmoticon_initWithCoder:aDecoder];
    if(obj){
        [self sw_emotion_addTapGesture];
    }
    return obj;
}

//处理复制操作
- (void)swEmoticon_copy:(id)sender {
    NSAttributedString *selectedAttributedText = [self.attributedText attributedSubstringFromRange:self.selectedRange];
    NSString *str = [self transalteEmoticonAttributedString:selectedAttributedText];
    [UIPasteboard generalPasteboard].string = str;
}

//处理粘贴操作
- (void)swEmoticon_paste:(id)sender {
    UIPasteboard *generalPasteboard = [UIPasteboard generalPasteboard];
    NSMutableAttributedString *mutableAttriStr = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    NSDictionary *dic = [self.attributedText attributesAtIndex:0 effectiveRange:NULL];
    NSAttributedString *emoticonAttriStr = [self.sw_emoticonStringGenerator generateEmoticonAttributedStringWithOriginalString:generalPasteboard.string font:self.font];
    [mutableAttriStr replaceCharactersInRange:self.selectedRange withAttributedString:emoticonAttriStr];
    [mutableAttriStr addAttribute:NSForegroundColorAttributeName value:dic[NSForegroundColorAttributeName]?:[UIColor blackColor] range:NSMakeRange(self.selectedRange.location, emoticonAttriStr.string.length)];
    [self disableDragInteraction];
    if(self.sw_emoticonDelegate && [self.sw_emoticonDelegate respondsToSelector:@selector(sw_emotionTextView:shouldChangeToAttributedText:)]){
        //限制输入的文字长度
        BOOL should = [self.sw_emoticonDelegate sw_emotionTextView:self shouldChangeToAttributedText:[mutableAttriStr copy]];
        if(should){
            self.attributedText = mutableAttriStr;
            [self sendSystemMessage];
        }
    }else{
        self.attributedText = mutableAttriStr;
        [self sendSystemMessage];
    }
}

- (BOOL)swEmoticon_becomeFirstResponder {
    BOOL result = [self swEmoticon_becomeFirstResponder];
    if(result){//成功成为第一响应者
        self.sw_emoticonTapGesture.enabled = YES;
    }
    return result;
}

- (BOOL)swEmoticon_resignFirstResponder {
    BOOL result = [self swEmoticon_resignFirstResponder];
    if(result){
        self.sw_emoticonTapGesture.enabled = NO;
    }
    return result;
}

#pragma mark - Getter&Setter
- (void)setSw_emoticonTapGesture:(UITapGestureRecognizer *)sw_emoticonTapGesture {
    objc_setAssociatedObject(self, sw_emoticonTapGesture_key, sw_emoticonTapGesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UITapGestureRecognizer *)sw_emoticonTapGesture {
    return objc_getAssociatedObject(self, sw_emoticonTapGesture_key);
}

- (void)setSw_emoticonStringGenerator:(SWEmoticonStringGenerator *)sw_emoticonStringGenerator {
    objc_setAssociatedObject(self, emoticonStringGenerator_key, sw_emoticonStringGenerator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SWEmoticonStringGenerator *)sw_emoticonStringGenerator {
    SWEmoticonStringGenerator *generator = objc_getAssociatedObject(self, emoticonStringGenerator_key);
    if(generator == nil){
        generator = [SWEmoticonStringGenerator new];
    }
    return generator;
}

- (void)setSw_emoticonDelegate:(id<SWEmotionTextViewDelegate>)sw_emoticonDelegate {
    objc_setAssociatedObject(self, sw_emoticonDelegate_key, sw_emoticonDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (id<SWEmotionTextViewDelegate>)sw_emoticonDelegate {
    return objc_getAssociatedObject(self, sw_emoticonDelegate_key);
}

#pragma mark - Public
- (void)sw_insertEmoticon:(SWEmoticon *)emoticon {
    if(emoticon.emojiStr.length > 0){//emoji表情
        NSMutableAttributedString *mutableAttributedStr = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
        [mutableAttributedStr replaceCharactersInRange:self.selectedRange withString:emoticon.emojiStr];
        //限制输入的文字长度
        if(self.sw_emoticonDelegate && [self.sw_emoticonDelegate respondsToSelector:@selector(sw_emotionTextView:shouldChangeToAttributedText:)]){
            BOOL should = [self.sw_emoticonDelegate sw_emotionTextView:self shouldChangeToAttributedText:[mutableAttributedStr copy]];
            if(should){
                [self replaceRange:self.selectedTextRange withText:emoticon.emojiStr];
            }
        }else{
            [self replaceRange:self.selectedTextRange withText:emoticon.emojiStr];
        }
        return;
    }
    if(emoticon.pngPath.length > 0){//图片表情
        [self disableDragInteraction];
        NSMutableAttributedString *mutableAttributedStr = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
        //创建附件对象
        SWTextAttachment *attachment = [SWTextAttachment new];
        //设置附件图片为表情图片
        attachment.image = [UIImage imageWithContentsOfFile:emoticon.pngPath];
        attachment.chs = emoticon.chs;
        CGFloat height = self.font.lineHeight;
        attachment.bounds = CGRectMake(0, self.font.descender, height, height);
        NSAttributedString *imageAttributedStr = [NSAttributedString attributedStringWithAttachment:attachment];
        NSRange range = self.selectedRange;
        [mutableAttributedStr replaceCharactersInRange:range withAttributedString:imageAttributedStr];
        //需要重新设置富文本的字体大小,否则表情会出现大小不一样的bug
        [mutableAttributedStr addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, mutableAttributedStr.string.length)];
        //限制输入的文字长度
        if(self.sw_emoticonDelegate && [self.sw_emoticonDelegate respondsToSelector:@selector(sw_emotionTextView:shouldChangeToAttributedText:)]){
            BOOL should = [self.sw_emoticonDelegate sw_emotionTextView:self shouldChangeToAttributedText:[mutableAttributedStr copy]];
            if(should){
                self.attributedText = mutableAttributedStr;
                //直接给attributedText赋值,是不会触发textView的代理方法和通知的
                [self sendSystemMessage];
                //让光标移动到移动到最后位置
                self.selectedRange = NSMakeRange(range.location + 1, 0);
            }
        }else{
            self.attributedText = mutableAttributedStr;
            //直接给attributedText赋值,是不会触发textView的代理方法和通知的
            [self sendSystemMessage];
            //让光标移动到移动到最后位置
            self.selectedRange = NSMakeRange(range.location + 1, 0);
        }
        return;
    }
    if(emoticon.isDeleteIcon){//删除按钮
        [self deleteBackward];
    }
    
}

- (NSString *)transalteAllEmoticonsToNormalString {
    return [self transalteEmoticonAttributedString:self.attributedText];
}

#pragma mark - Private
- (void)sendSystemMessage {
    //手动触发代理和通知
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidChangeNotification object:nil];
    if(self.delegate && [self.delegate respondsToSelector:@selector(textViewDidChange:)]){
        [self.delegate textViewDidChange:self];
    }
}
- (NSString *)transalteEmoticonAttributedString:(NSAttributedString *)emoticonAttributedString {
    NSRange range = NSMakeRange(0, emoticonAttributedString.length);
    NSMutableString *result = [[NSMutableString alloc] initWithString:@""];
    //遍历NSAttributedString,SWTextAttachment对应的字符串
    [emoticonAttributedString enumerateAttributesInRange:range options:0 usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        SWTextAttachment *attachment = attrs[NSAttachmentAttributeName];
        if(attachment){
            [result appendString:attachment.chs];
        }else{
            NSString *str = [self.attributedText.string substringWithRange:range];
            [result appendString:str];
        }
    }];
    return result;
}

- (void)sw_emotion_addTapGesture {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hanlde_sw_emtion_tapGesture:)];
    [self addGestureRecognizer:tap];
    self.sw_emoticonTapGesture = tap;
    self.sw_emoticonTapGesture.enabled = NO;
}

- (void)hanlde_sw_emtion_tapGesture:(UITapGestureRecognizer *)gesture {
    if(gesture.state == UIGestureRecognizerStateEnded){
        CGPoint point = [gesture locationInView:gesture.view];
        //closestPositionToPoint:根据一个点计算出这个点在UITextView的文本当中最合适的一个位置
        UITextPosition *position = [self closestPositionToPoint:point];
        //beginningOfDocument:UITextView的文本开始位置
        //将点击的点转换成NSRange中的location
        NSInteger location = [self offsetFromPosition:self.beginningOfDocument toPosition:position];
        [self setSelectedRange:NSMakeRange(location, 0)];
    }
}

//禁止重按拖动textView上文本的交互
- (void)disableDragInteraction {
#ifdef __IPHONE_11_0
    if([self respondsToSelector:@selector(textDragInteraction)]){
        self.textDragInteraction.enabled = NO;
    }
#endif
}



@end
