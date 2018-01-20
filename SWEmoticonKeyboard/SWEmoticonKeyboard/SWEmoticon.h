//
//  SWEmoticon.h
//  SWEmojiKeyboard
//
//  Created by zhoushaowen on 2018/1/13.
//  Copyright © 2018年 zhoushaowen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SWEmoticon : NSObject

/**
 当前表情对应的组名 eg: com.apple.emoji
 */
@property (nonatomic,copy) NSString *ID;

/**
 Emoji表情对应的字符串
 */
@property (nonatomic,copy) NSString *code;

/**
 转换之后的emoji表情字符串
 */
@property (nonatomic,readonly,copy) NSString *emojiStr;

/**
 当前表情对应的字符串
 */
@property (nonatomic,copy) NSString *chs;

/**
 当前表情对应的图片
 */
@property (nonatomic,copy) NSString *png;
/**
 当前表情图片的绝对路径
 */
@property (nonatomic,copy) NSString *pngPath;

/**
 是否是空表情
 */
@property (nonatomic) BOOL isEmpty;

/**
 记录是否是删除按钮
 */
@property (nonatomic) BOOL isDeleteIcon;

/**
 记录当前表情点击的次数
 */
@property (nonatomic) NSInteger count;

- (instancetype)initWithDic:(NSDictionary *)dic ID:(NSString *)ID;
+ (instancetype)deleteEmpticon;
+ (instancetype)emptyEmoticon;

@end
