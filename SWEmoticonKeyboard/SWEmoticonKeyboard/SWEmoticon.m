//
//  SWEmoticon.m
//  SWEmojiKeyboard
//
//  Created by zhoushaowen on 2018/1/13.
//  Copyright © 2018年 zhoushaowen. All rights reserved.
//

#import "SWEmoticon.h"

@interface SWEmoticon ()<NSCoding>

@property (nonatomic,copy) NSString *emojiStr;

@end

@implementation SWEmoticon

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if(self){
        self.ID = [aDecoder decodeObjectForKey:@"ID"];
        self.code = [aDecoder decodeObjectForKey:@"code"];
        self.emojiStr = [aDecoder decodeObjectForKey:@"emojiStr"];
        self.chs = [aDecoder decodeObjectForKey:@"chs"];
        self.png = [aDecoder decodeObjectForKey:@"png"];
        self.pngPath = [aDecoder decodeObjectForKey:@"pngPath"];
        self.isEmpty = [aDecoder decodeBoolForKey:@"isEmpty"];
        self.isDeleteIcon = [aDecoder decodeBoolForKey:@"isDeleteIcon"];
        self.count = [aDecoder decodeIntegerForKey:@"count"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.ID forKey:@"ID"];
    [aCoder encodeObject:self.code forKey:@"code"];
    [aCoder encodeObject:self.emojiStr forKey:@"emojiStr"];
    [aCoder encodeObject:self.chs forKey:@"chs"];
    [aCoder encodeObject:self.png forKey:@"png"];
    [aCoder encodeObject:self.pngPath forKey:@"pngPath"];
    [aCoder encodeBool:self.isEmpty forKey:@"isEmpty"];
    [aCoder encodeBool:self.isDeleteIcon forKey:@"isDeleteIcon"];
    [aCoder encodeInteger:self.count forKey:@"count"];
}


- (instancetype)initWithDic:(NSDictionary *)dic ID:(NSString *)ID {
    self = [super init];
    if(self){
        self.ID = ID;
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

+ (instancetype)deleteEmpticon {
    SWEmoticon *emoticon = [[self alloc] init];
    if(self){
        emoticon.isDeleteIcon = YES;
    }
    return emoticon;
}

+ (instancetype)emptyEmoticon {
    SWEmoticon *emoticon = [[self alloc] init];
    if(self){
        emoticon.isEmpty = YES;
    }
    return emoticon;
}

- (void)setPng:(NSString *)png {
    _png = [png copy];
    NSString *path = [[NSBundle mainBundle] pathForResource:self.ID ofType:nil inDirectory:@"Emoticons.bundle"];
    //这里不需要对@2x和@3x图片进行判断,因为系统会自动进行区分加载,不需要在后面补上@XX
    self.pngPath = [path stringByAppendingPathComponent:_png];
}

- (void)setCode:(NSString *)code {
    _code = [code copy];
    if(_code.length < 1) return;
    //16进制字符串转成emoji字符串显示
    NSScanner *scanner = [NSScanner scannerWithString:_code];
    unsigned int result = 0;
    [scanner scanHexInt:&result];
    char chars[4];
    int len = 4;
    chars[0] = (result >> 24) & (1 << 24) - 1;
    chars[1] = (result >> 16) & (1 << 16) - 1;
    chars[2] = (result >> 8) & (1 << 8) - 1;
    chars[3] = result & (1 << 8) - 1;
    NSString *emojiStr = [[NSString alloc] initWithBytes:chars length:len encoding:NSUTF32StringEncoding];
    self.emojiStr = emojiStr;
}







@end
