//
//  SWEmotionKeyboardView.h
//  SWEmojiKeyboard
//
//  Created by zhoushaowen on 2018/1/15.
//  Copyright © 2018年 zhoushaowen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SWEmoticon;

@interface SWEmotionKeyboardView : UIView

- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

- (instancetype)initWithEmoticonDidClickBlock:(void(^)(SWEmoticon *emoticon))emotionDidClickBlock NS_DESIGNATED_INITIALIZER;

/**
 设置发送按钮是否可用
 */
- (void)setSendEmotionButtonEnable:(BOOL)enable;

/**
 点击发送按钮回调
 */
@property (nonatomic,strong) void(^sendEmotionActionBlock)(void);


@end
