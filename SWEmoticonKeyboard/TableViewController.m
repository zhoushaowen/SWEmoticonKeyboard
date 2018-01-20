//
//  TableViewController.m
//  SWEmojiKeyboard
//
//  Created by zhoushaowen on 2018/1/17.
//  Copyright © 2018年 zhoushaowen. All rights reserved.
//

#import "TableViewController.h"
#import "TableTableViewCell.h"
#import "SWEmoticonKeyboard.h"

@interface TableViewController ()
{
    NSArray *_array;
}

@property (nonatomic,strong) NSCache *rowHeightCache;
@property (nonatomic,strong) SWEmoticonStringGenerator *emoticonStringGenerator;

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    [self.tableView registerClass:[TableTableViewCell class] forCellReuseIdentifier:@"cell"];
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
            [self.tableView reloadData];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _array.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSAttributedString *str = _array[indexPath.row];
    cell.text = str;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key = [NSString stringWithFormat:@"%zd",indexPath.row];
    NSNumber *value = [self.rowHeightCache objectForKey:key];
    if(value) return [value doubleValue];
    TableTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    CGFloat height = [cell calculateRowHeightWithText:_array[indexPath.row]];
    [self.rowHeightCache setObject:@(height) forKey:key];
    return height;
}





@end
