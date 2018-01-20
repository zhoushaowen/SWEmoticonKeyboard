//
//  SendContentViewController.m
//  SWEmojiKeyboard
//
//  Created by zhoushaowen on 2018/1/13.
//  Copyright © 2018年 zhoushaowen. All rights reserved.
//

#import "SendContentViewController.h"
#import "SWEmoticonKeyboard.h"

@interface SendContentViewController ()<UITextViewDelegate,SWEmotionTextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic,strong) SWEmotionKeyboardView *emotionKeyboardView;

@end

@implementation SendContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textView.inputView = self.emotionKeyboardView;
    self.textView.delegate = self;
    self.textField.inputView = self.emotionKeyboardView;
    [self.textField addTarget:self action:@selector(textFieldTextDidChanged:) forControlEvents:UIControlEventEditingChanged];
    self.textView.sw_emoticonDelegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.textView becomeFirstResponder];
}

- (SWEmotionKeyboardView *)emotionKeyboardView {
    if(!_emotionKeyboardView){
        __weak typeof(self) weakSelf = self;
        _emotionKeyboardView = [[SWEmotionKeyboardView alloc] initWithEmoticonDidClickBlock:^(SWEmoticon *emoticon) {
            if([weakSelf.textView isFirstResponder]){
                [weakSelf.textView sw_insertEmoticon:emoticon];
            }else if ([weakSelf.textField isFirstResponder]){
                [weakSelf.textField sw_insertEmoticon:emoticon];
            }
        }];
        _emotionKeyboardView.sendEmotionActionBlock = ^{
            NSString *str = @"";
            if([weakSelf.textView isFirstResponder]){
                if(weakSelf.textView.text.length < 1) return;
                str = [weakSelf.textView transalteAllEmoticonsToNormalString];;
            }else if ([weakSelf.textField isFirstResponder]){
                if(weakSelf.textField.text.length < 1) return;
                str = weakSelf.textField.text;
            }
            //将表情文字存入到本地
            NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"message.plist"];
            if(![[NSFileManager defaultManager] fileExistsAtPath:path]){
                [NSKeyedArchiver archiveRootObject:@[str] toFile:path];
            }else{
                NSMutableArray *mutableArr = [[NSKeyedUnarchiver unarchiveObjectWithFile:path] mutableCopy];
                [mutableArr addObject:str];
                [NSKeyedArchiver archiveRootObject:[mutableArr copy] toFile:path];
            }
            [weakSelf.navigationController popViewControllerAnimated:YES];
        };
    }
    return _emotionKeyboardView;
}

- (void)textViewDidChange:(UITextView *)textView {
    [self.emotionKeyboardView setSendEmotionButtonEnable:textView.text.length > 0];
}

- (void)textFieldTextDidChanged:(UITextField *)sender {
    [self.emotionKeyboardView setSendEmotionButtonEnable:sender.text.length > 0];
}

#pragma mark - SWEmotionTextViewDelegate
- (BOOL)sw_emotionTextView:(UITextView *)textView shouldChangeToAttributedText:(NSAttributedString *)willChangedAttributedText {
    //限制表情文字输出的长度不超过20
    if(willChangedAttributedText.length > 80){
        return NO;
    }
    return YES;
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}

@end
