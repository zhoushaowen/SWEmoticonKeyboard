//
//  SWEmticonMagnifierView.h
//  SWEmoticonKeyboard
//
//  Created by zhoushaowen on 2018/1/22.
//  Copyright © 2018年 zhoushaowen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SWEmoticon;

@interface SWEmticonMagnifierView : UIView

+ (instancetype)magnifierView;

@property (nonatomic,strong) SWEmoticon *emoticon;

@end
