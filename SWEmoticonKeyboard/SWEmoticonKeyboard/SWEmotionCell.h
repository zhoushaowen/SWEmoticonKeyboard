//
//  SWEmotionCell.h
//  SWEmojiKeyboard
//
//  Created by zhoushaowen on 2018/1/15.
//  Copyright © 2018年 zhoushaowen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SWEmoticon;
@class SWEmotionKeyboardView;

@interface SWEmotionCell : UICollectionViewCell

@property (nonatomic,readonly,strong) UIButton *btn;

@property (nonatomic,strong) SWEmoticon *emoticon;

@property (nonatomic,weak) SWEmotionKeyboardView *keyboardView;

@end
