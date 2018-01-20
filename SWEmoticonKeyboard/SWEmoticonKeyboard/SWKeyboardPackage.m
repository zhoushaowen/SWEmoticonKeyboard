//
//  SWKeyboardPackage.m
//  SWKeyboardPackage
//
//  Created by zhoushaowen on 2018/1/13.
//  Copyright © 2018年 zhoushaowen. All rights reserved.
//

#import "SWKeyboardPackage.h"
#import "SWEmoticon.h"

@interface SWKeyboardPackage ()

@property (nonatomic,copy) NSString *ID;
@property (nonatomic,copy) NSString *group_name_cn;

@end

@implementation SWKeyboardPackage

- (instancetype)initWithID:(NSString *)ID {
    self = [super init];
    if(self){
        self.ID = ID;
    }
    return self;
}

//加载表情包
+ (NSArray<SWKeyboardPackage *> *)loadPackages {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"emoticons.plist" ofType:nil inDirectory:@"Emoticons.bundle"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray *arr = dic[@"packages"];
    NSMutableArray *mutableArr = [NSMutableArray arrayWithCapacity:0];
    SWKeyboardPackage *recentPackage = [[SWKeyboardPackage alloc] init];
    NSMutableArray *emotions = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //添加最近
    NSString *recentEmoticonPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"recentemoticon.plist"];
    if(![fileManager fileExistsAtPath:recentEmoticonPath]){
        emotions = [NSMutableArray arrayWithCapacity:0];
        for(int i=0;i<20;i++){
            SWEmoticon *emoticon = [SWEmoticon emptyEmoticon];
            [emotions addObject:emoticon];
        }
        SWEmoticon *deleteEmoticon = [SWEmoticon deleteEmpticon];
        [emotions addObject:deleteEmoticon];
        [NSKeyedArchiver archiveRootObject:emotions toFile:recentEmoticonPath];
    }else{
        emotions = [NSKeyedUnarchiver unarchiveObjectWithFile:recentEmoticonPath];
        [emotions enumerateObjectsUsingBlock:^(SWEmoticon*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if(obj.ID.length > 0 && obj.png.length > 0){
                //注意:沙盒路径在app重启之后每次都会变,存到本地的pngPath需要每次重写加载
                obj.png = obj.png;
            }
        }];
    }
    recentPackage.emoticons = emotions;
    [mutableArr addObject:recentPackage];
    [arr enumerateObjectsUsingBlock:^(NSDictionary*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SWKeyboardPackage *package = [[SWKeyboardPackage alloc] initWithID:obj[@"id"]];
        [mutableArr addObject:package];
        package.emoticons = [package loadEmotions];
    }];
    return mutableArr;
}

//加载表情
- (NSArray<SWEmoticon *> *)loadEmotions {
    NSString *path = [[NSBundle mainBundle] pathForResource:self.ID ofType:nil inDirectory:@"Emoticons.bundle"];
    path = [path stringByAppendingPathComponent:@"Info.plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
    self.group_name_cn = dic[@"group_name_cn"];
    NSArray *arr = dic[@"emoticons"];
    NSMutableArray *mutableArr = [NSMutableArray arrayWithCapacity:0];
    int count = 0;
    for (NSDictionary *dic in arr) {
        if(count % 20 == 0 && count != 0){
            SWEmoticon *deleteEmoticon = [SWEmoticon deleteEmpticon];
            [mutableArr addObject:deleteEmoticon];
        }
        SWEmoticon *emoticon = [[SWEmoticon alloc] initWithDic:dic ID:self.ID];
        [mutableArr addObject:emoticon];
        count ++;
    }
    NSInteger count2 = 20 - mutableArr.count % 21;
    for(int i=0;i<count2;i++){
        SWEmoticon *emptyEmoticon = [SWEmoticon emptyEmoticon];
        [mutableArr addObject:emptyEmoticon];
    }
    SWEmoticon *last = [mutableArr lastObject];
    if(!last.isDeleteIcon){
        SWEmoticon *deleteEmoticon = [SWEmoticon deleteEmpticon];
        [mutableArr addObject:deleteEmoticon];
    }
    return [mutableArr copy];
}

- (void)addFavoriteEmoticon:(SWEmoticon *)emoticon {
    if(emoticon.isDeleteIcon) return;
    if(emoticon.isEmpty) return;
    emoticon.count ++;
    NSMutableArray *mutableArr = [self.emoticons mutableCopy];
    [mutableArr removeLastObject];
    if(![mutableArr containsObject:emoticon]){
        [mutableArr removeLastObject];
        [mutableArr addObject:emoticon];
    }
    [mutableArr addObject:[SWEmoticon deleteEmpticon]];
    [mutableArr sortUsingComparator:^NSComparisonResult(SWEmoticon*  _Nonnull obj1, SWEmoticon*  _Nonnull obj2) {
        if(obj1.count < obj2.count){
            return NSOrderedDescending;
        }
        return NSOrderedAscending;
    }];
    self.emoticons = mutableArr;
    NSString *recentEmoticonPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"recentemoticon.plist"];
    [NSKeyedArchiver archiveRootObject:self.emoticons toFile:recentEmoticonPath];
}














@end
