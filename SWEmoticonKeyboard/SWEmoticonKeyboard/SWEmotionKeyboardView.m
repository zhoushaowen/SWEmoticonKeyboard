//
//  SWEmotionKeyboardView.m
//  SWEmojiKeyboard
//
//  Created by zhoushaowen on 2018/1/15.
//  Copyright © 2018年 zhoushaowen. All rights reserved.
//

#import "SWEmotionKeyboardView.h"
#import "SWKeyboardPackage.h"
#import "SWEmoticon.h"
#import "SWEmotionFlowLayout.h"
#import "SWEmotionCell.h"
#import "SWEmticonMagnifierView.h"

@interface SWEmotionKeyboardView ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    NSIndexPath *_longPressIndexPath;
}
@property (nonatomic,strong) void(^emotionCallback)(SWEmoticon *emoticon);
@property (nonatomic,copy) NSArray<SWKeyboardPackage *> *packages;
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) UIView *toolbar;
@property (nonatomic,strong) UIPageControl *pageControl;
@property (nonatomic,strong) UILabel *recentLabel;
@property (nonatomic,strong) UIButton *selectedBtn;
@property (nonatomic,strong) UIButton *sendBtn;
@property (nonatomic,copy) NSArray *toolBarBtns;
@property (nonatomic,strong) SWEmticonMagnifierView *magnifierView;
@property (nonatomic) BOOL flag;

@end

@implementation SWEmotionKeyboardView

- (instancetype)init {
    return [self initWithEmoticonDidClickBlock:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithEmoticonDidClickBlock:nil];
}

- (instancetype)initWithEmoticonDidClickBlock:(void (^)(SWEmoticon *))emotionDidClickBlock {
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 258)];
    if(self){
        self.emotionCallback = emotionDidClickBlock;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self addSubview:self.collectionView];
    [self addSubview:self.toolbar];
    [self addSubview:self.pageControl];
    [self addSubview:self.recentLabel];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.toolbar.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_collectionView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_collectionView)]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_collectionView]-0-[_toolbar(38)]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_collectionView,_toolbar)]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_toolbar]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_toolbar)]];
    [self addLongPressGesture];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if(self.flag) return;
    self.flag = YES;
    [self selectedCurrentBtn:self.toolBarBtns[1]];
    [self scrollToCurrentIndex:1];
}

- (UICollectionView *)collectionView {
    if(!_collectionView){
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[SWEmotionFlowLayout new]];
        _collectionView.pagingEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1];
        [_collectionView registerClass:[SWEmotionCell class] forCellWithReuseIdentifier:@"cell"];
    }
    return _collectionView;
}

- (UIView *)toolbar {
    if(!_toolbar){
        _toolbar = [[UIView alloc] initWithFrame:CGRectZero];
        _toolbar.backgroundColor = [UIColor whiteColor];
        NSArray *imgNames = @[@"compose_emotion_table_recent",@"compose_emotion_table_default",@"compose_emotion_table_emoji",@"compose_emotion_table_langxiaohua"];
        NSMutableArray *mutableArr = [NSMutableArray arrayWithCapacity:0];
        for(int i=0;i<imgNames.count;i++){
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.adjustsImageWhenHighlighted = NO;
            btn.tag = i;
            [btn addTarget:self action:@selector(toolbarBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [_toolbar addSubview:btn];
            NSString *name = [[[NSBundle mainBundle] pathForResource:@"Emoticons.bundle" ofType:nil] stringByAppendingPathComponent:imgNames[i]];
            [btn setImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
            btn.translatesAutoresizingMaskIntoConstraints = NO;
            NSArray *hConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-offX-[btn(width)]" options:0 metrics:@{@"offX":@(45*i),@"width":@45} views:NSDictionaryOfVariableBindings(btn)];
            NSArray *vConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[btn]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(btn)];
            [NSLayoutConstraint activateConstraints:hConstraints];
            [NSLayoutConstraint activateConstraints:vConstraints];
            UIView *line = [UIView new];
            line.userInteractionEnabled = NO;
            [btn addSubview:line];
            line.backgroundColor = [UIColor colorWithRed:231/256.0 green:231/256.0 blue:231/256.0 alpha:1];
            line.translatesAutoresizingMaskIntoConstraints = NO;
            [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[line(width)]-0-|" options:0 metrics:@{@"width":@(1/[UIScreen mainScreen].scale)} views:NSDictionaryOfVariableBindings(line)]];
            [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-6-[line]-6-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(line)]];
            [mutableArr addObject:btn];
        }
        self.toolBarBtns = mutableArr;
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_toolbar addSubview:_sendBtn];
        [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        [_sendBtn setTitleColor:[UIColor colorWithRed:121/226.0 green:119/226.0 blue:121/226.0 alpha:1.0] forState:UIControlStateDisabled];
        [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sendBtn setBackgroundColor:[UIColor colorWithRed:250/226.0 green:247/226.0 blue:250/226.0 alpha:1.0]];
        _sendBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        _sendBtn.translatesAutoresizingMaskIntoConstraints = NO;
        _sendBtn.layer.shadowOpacity = 0.3f;
        _sendBtn.layer.shadowOffset = CGSizeMake(0, 3);
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_sendBtn(50)]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_sendBtn)]];
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_sendBtn]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_sendBtn)]];
        [_sendBtn addTarget:self action:@selector(sendBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _sendBtn.enabled = NO;
    }
    return _toolbar;
}

- (void)toolbarBtnClick:(UIButton *)sender {
    [self selectedCurrentBtn:sender];
    [self scrollToCurrentIndex:sender.tag];
}

- (void)selectedCurrentBtn:(UIButton *)currentBtn {
    if(self.selectedBtn == currentBtn) return;
    [self.selectedBtn setBackgroundColor:nil];
    [currentBtn setBackgroundColor:self.collectionView.backgroundColor];
    self.selectedBtn = currentBtn;
}

- (void)scrollToCurrentIndex:(NSInteger)index {
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:index] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    [self.collectionView.delegate scrollViewDidEndDecelerating:self.collectionView];
}

- (UIPageControl *)pageControl {
    if(!_pageControl){
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.pageIndicatorTintColor = [UIColor colorWithRed:206/226.0 green:203/226.0 blue:206/226.0f alpha:1.0];
        _pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:121/226.0 green:119/226.0 blue:121/226.0 alpha:1.0];
        _pageControl.userInteractionEnabled = NO;
        _pageControl.center = CGPointMake(self.frame.size.width/2.0f, self.frame.size.height - (38 + 8 + 10));
        _pageControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        _pageControl.hidesForSinglePage = YES;
    }
    return _pageControl;
}

- (UILabel *)recentLabel {
    if(!_recentLabel){
        _recentLabel = [UILabel new];
        _recentLabel.font = [UIFont systemFontOfSize:13];
        _recentLabel.textAlignment = NSTextAlignmentCenter;
        _recentLabel.textColor = [UIColor colorWithRed:121/226.0 green:119/226.0 blue:121/226.0 alpha:1.0];
        _recentLabel.text = @"最近使用的表情";
        [_recentLabel sizeToFit];
        _recentLabel.center = CGPointMake(self.frame.size.width/2.0f, self.frame.size.height - (38 + 8 + 10));
        _recentLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        _recentLabel.hidden = YES;
    }
    return _recentLabel;
}

- (NSArray<SWKeyboardPackage *> *)packages {
    if(!_packages){
        _packages = [SWKeyboardPackage loadPackages];
    }
    return _packages;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.packages.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    SWKeyboardPackage *package = self.packages[section];
    return package.emoticons.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SWEmotionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    SWKeyboardPackage *package = self.packages[indexPath.section];
    cell.emoticon = package.emoticons[indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self outputEmoticonWithIndexPath:indexPath];
}

- (void)outputEmoticonWithIndexPath:(NSIndexPath *)indexPath {
    SWKeyboardPackage *package = self.packages[indexPath.section];
    SWEmoticon *emoticon = package.emoticons[indexPath.item];
    if(indexPath.section != 0){
        [[self.packages firstObject] addFavoriteEmoticon:emoticon];
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    }
    if(self.emotionCallback){
        self.emotionCallback(emoticon);
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x/scrollView.frame.size.width;
    //当前所在的区间
    NSInteger currentSection = 0;
    NSInteger totalIndex = 0;
    NSInteger indexDuringSection = 0;
    for(int i=0;i<self.packages.count;i++){
        NSArray *arr = self.packages[i].emoticons;
        totalIndex += arr.count/21;
        if(index < totalIndex){
            currentSection = i;
            NSInteger offSet = totalIndex - index;
            indexDuringSection = arr.count/21 - offSet;
            break;
        }
    }
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:currentSection];
    itemCount /= 21;
    self.pageControl.numberOfPages = itemCount;
    self.pageControl.currentPage = indexDuringSection;
    if(currentSection == 0){
        self.recentLabel.hidden = NO;
    }else{
        self.recentLabel.hidden = YES;
    }
    [self selectedCurrentBtn:self.toolBarBtns[currentSection]];
}

- (void)sendBtnClick:(UIButton *)sender {
    if(_sendEmotionActionBlock){
        _sendEmotionActionBlock();
    }
}

- (void)setSendEmotionButtonEnable:(BOOL)enable {
    _sendBtn.enabled = enable;
    if(enable){
        [_sendBtn setBackgroundColor:[UIColor colorWithRed:11/226.0 green:95/226.0 blue:255/226.0 alpha:1.0]];
    }else{
        [_sendBtn setBackgroundColor:[UIColor colorWithRed:250/226.0 green:247/226.0 blue:250/226.0 alpha:1.0]];
    }
}

- (void)addLongPressGesture {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    longPress.minimumPressDuration = 0.35;
    //距离触摸点允许移动的最大距离范围
    longPress.allowableMovement = self.frame.size.width;
    [self addGestureRecognizer:longPress];
}

- (SWEmticonMagnifierView *)magnifierView {
    if(!_magnifierView){
        _magnifierView = [SWEmticonMagnifierView magnifierView];
        [self addSubview:_magnifierView];
    }
    return _magnifierView;
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)longPressGesture {
    switch (longPressGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            _collectionView.scrollEnabled = NO;
            _longPressIndexPath = [self longPressEmoticon:longPressGesture];
        }
            break;
            case UIGestureRecognizerStateChanged:
        {
            _longPressIndexPath = [self longPressEmoticon:longPressGesture];
        }
            break;
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateCancelled:
        {
            self.magnifierView.hidden = YES;
            self.magnifierView.emoticon = nil;
            _collectionView.scrollEnabled = YES;
            if(_longPressIndexPath){
                [self outputEmoticonWithIndexPath:_longPressIndexPath];
            }
        }
            break;
            
        default:
            break;
    }
}

- (NSIndexPath *)longPressEmoticon:(UILongPressGestureRecognizer *)longPressGesture {
    CGPoint point = [longPressGesture locationInView:_collectionView];
    NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:point];
    if(indexPath == nil) {
        self.magnifierView.hidden = YES;
        return nil;
    }
    SWEmotionCell *cell = (SWEmotionCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    if(cell.emoticon.isEmpty || cell.emoticon.isDeleteIcon){
        self.magnifierView.hidden = YES;
    }
    CGRect convertRect = [cell.btn.superview convertRect:cell.btn.frame toView:self];
    CGRect rect = self.magnifierView.frame;
    rect.origin = CGPointMake(convertRect.origin.x - (rect.size.width-convertRect.size.width)/2.0f, convertRect.origin.y - (rect.size.height - convertRect.size.height) - 10);
    self.magnifierView.frame = rect;
    self.magnifierView.emoticon = cell.emoticon;
    self.magnifierView.hidden = NO;
    return indexPath;
}




@end
