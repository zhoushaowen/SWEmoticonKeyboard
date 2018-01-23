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
#import "YYFPSLabel.h"
#import "SWTextAttachment.h"
#import <NSAttributedString+YYText.h>

@interface TableViewController ()
{
    NSArray *_array;
    YYFPSLabel *_fpsLabel;
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
    _fpsLabel = [YYFPSLabel new];
    [_fpsLabel sizeToFit];
    CGRect rect = _fpsLabel.frame;
    rect.origin.x = 20;
    rect.origin.y = self.view.frame.size.height - 20 - rect.size.height;
    _fpsLabel.frame = rect;
    _fpsLabel.alpha = 0;
    [[UIApplication sharedApplication].keyWindow addSubview:_fpsLabel];
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
                NSMutableAttributedString *mutableAttriStr = [attriStr mutableCopy];
                //编译NSAttributedString,找出其中包含NSAttachmentAttributeName的属性字符串
                [attriStr enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, attriStr.length) options:NSAttributedStringEnumerationReverse usingBlock:^(SWTextAttachment*  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
                    if([value isKindOfClass:[SWTextAttachment class]]){
                        UIFont *font = [attriStr attribute:NSFontAttributeName atIndex:range.location effectiveRange:NULL];
                        CGFloat size = font.lineHeight?:17;
                        //YYLabel不能显示系统的NSTextAttachment,需要使用YYLabel自带方法创建包含NSTextAttachment的属性字符串
                        NSAttributedString *emotionAttri = [NSAttributedString attachmentStringWithContent:value.image contentMode:UIViewContentModeScaleToFill attachmentSize:value.bounds.size alignToFont:[UIFont systemFontOfSize:size] alignment:YYTextVerticalAlignmentBottom];
                        [mutableAttriStr replaceCharactersInRange:range withAttributedString:emotionAttri];
                    }
                }];
                [mutableArr addObject:[mutableAttriStr copy]];
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

#pragma UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (_fpsLabel.alpha == 0) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            _fpsLabel.alpha = 1;
        } completion:NULL];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        if (_fpsLabel.alpha != 0) {
            [UIView animateWithDuration:1 delay:2 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                _fpsLabel.alpha = 0;
            } completion:NULL];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (_fpsLabel.alpha != 0) {
        [UIView animateWithDuration:1 delay:2 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            _fpsLabel.alpha = 0;
        } completion:NULL];
    }
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    if (_fpsLabel.alpha == 0) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            _fpsLabel.alpha = 1;
        } completion:^(BOOL finished) {
        }];
    }
}




@end
