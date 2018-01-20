//
//  SWEmotionFlowLayout.m
//  SWEmojiKeyboard
//
//  Created by zhoushaowen on 2018/1/15.
//  Copyright © 2018年 zhoushaowen. All rights reserved.
//

#import "SWEmotionFlowLayout.h"

@interface SWEmotionFlowLayout ()

@property (nonatomic,copy) NSArray<UICollectionViewLayoutAttributes *> *attributes;
@property (nonatomic,copy) NSArray<NSArray<UICollectionViewLayoutAttributes *> *> *array;

@end

@implementation SWEmotionFlowLayout

- (void)prepareLayout {
    [super prepareLayout];
    self.sectionInset = UIEdgeInsetsMake(0, 0, 40, 0);
    self.attributes = [self createAttributes];
}

- (NSArray<UICollectionViewLayoutAttributes *> *)createAttributes {
    NSMutableArray *attributesArr = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *mutableArr = [NSMutableArray arrayWithCapacity:0];
    NSInteger count = 0;
    for(int i=0;i<[self.collectionView numberOfSections];i++){
        NSMutableArray *mutableArr2 = [NSMutableArray arrayWithCapacity:0];
        for(int j=0;j<[self.collectionView numberOfItemsInSection:i];j++){
            UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:j inSection:i]];
            CGFloat width = self.collectionView.frame.size.width/7.0f;
            CGFloat height = (self.collectionView.frame.size.height - self.sectionInset.bottom)/3.0f;
            attribute.size = CGSizeMake(width, height);
            NSInteger index = count/21;
            count ++;
            CGFloat x = (j % 21 % 7)*width + index*self.collectionView.frame.size.width;
            CGFloat y = (j % 21 / 7)*height;
            attribute.frame = CGRectMake(x, y, attribute.size.width, attribute.size.height);
            [attributesArr addObject:attribute];
            [mutableArr2 addObject:attribute];
        }
        [mutableArr addObject:mutableArr2];
    }
    self.array = mutableArr;
    return [attributesArr copy];
}

- (CGSize)collectionViewContentSize {
    CGSize size = self.collectionView.frame.size;
    NSInteger count = 0;
    for(int i=0;i<[self.collectionView numberOfSections];i++){
        for(int j=0;j<[self.collectionView numberOfItemsInSection:i];j++){
            count ++;
        }
    }
    count = count/21;
    return CGSizeMake(size.width*count, size.height);
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *arr = self.array[indexPath.section];
    return arr[indexPath.item];
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return [self.attributes filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes*  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return CGRectIntersectsRect(evaluatedObject.frame, rect);
    }]];
}













@end
