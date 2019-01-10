//
//  ContentListViewController.m
//  SWEmoticonKeyboard
//
//  Created by zhoushaowen on 2018/1/25.
//  Copyright © 2018年 zhoushaowen. All rights reserved.
//

#import "ContentListViewController.h"
#import "SWEmoticonKeyboard.h"
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "ContentCellNode.h"

@interface ContentListViewController ()<ASTableDelegate,ASTableDataSource>
{
    ASTableNode *_tableNode;
    NSArray *_array;
}

@property (nonatomic,strong) NSCache *rowHeightCache;
@property (nonatomic,strong) SWEmoticonStringGenerator *emoticonStringGenerator;

@end

@implementation ContentListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableNode = [[ASTableNode alloc] initWithStyle:UITableViewStylePlain];
    _tableNode.frame = self.view.bounds;
    _tableNode.delegate = self;
    _tableNode.dataSource = self;
    [self.view addSubnode:_tableNode];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadData];
}

- (void)loadData {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"message.plist"];
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        NSMutableArray *mutableArr = [NSMutableArray arrayWithCapacity:array.count];
        [array enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSAttributedString *attriStr = [self.emoticonStringGenerator generateEmoticonAttributedStringWithOriginalString:obj font:[UIFont systemFontOfSize:18]];
            if(attriStr){
                [mutableArr addObject:attriStr];
            }
        }];
        _array = [mutableArr copy];
        [self.rowHeightCache removeAllObjects];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableNode reloadData];
        });
    });
}

- (NSCache *)rowHeightCache {
    if(!_rowHeightCache){
        _rowHeightCache = [[NSCache alloc] init];
    }
    return _rowHeightCache;
}

- (SWEmoticonStringGenerator *)emoticonStringGenerator {
    if(!_emoticonStringGenerator){
        _emoticonStringGenerator = [SWEmoticonStringGenerator new];
    }
    return _emoticonStringGenerator;
}

- (NSInteger)numberOfSectionsInTableNode:(ASTableNode *)tableNode {
    return 1;
}

- (NSInteger)tableNode:(ASTableNode *)tableNode numberOfRowsInSection:(NSInteger)section {
    return _array.count;
}

- (ASCellNodeBlock)tableNode:(ASTableNode *)tableNode nodeBlockForRowAtIndexPath:(NSIndexPath *)indexPath {
    ASCellNodeBlock block = ^{
        ContentCellNode *node = [ContentCellNode new];
        return node;
    };
    
    return block;
}


@end
