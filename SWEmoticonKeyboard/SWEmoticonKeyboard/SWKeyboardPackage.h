//
//  SWKeyboardPackage.h
//  SWKeyboardPackage
//
//  Created by zhoushaowen on 2018/1/13.
//  Copyright © 2018年 zhoushaowen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SWEmoticon;

@interface SWKeyboardPackage : NSObject

+ (NSArray<SWKeyboardPackage *> *)loadPackages;
- (void)addFavoriteEmoticon:(SWEmoticon *)emoticon;

@property (nonatomic,copy) NSArray<SWEmoticon *> *emoticons;

@end
