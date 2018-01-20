//
//  TableTableViewCell.m
//  SWEmojiKeyboard
//
//  Created by zhoushaowen on 2018/1/17.
//  Copyright © 2018年 zhoushaowen. All rights reserved.
//

#import "TableTableViewCell.h"

@implementation TableTableViewCell
{
    UILabel *_label;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _label = [UILabel new];
        _label.font = [UIFont systemFontOfSize:18];
        [self.contentView addSubview:_label];
        _label.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_label attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-8]]];
        [NSLayoutConstraint activateConstraints:@[[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_label attribute:NSLayoutAttributeTop multiplier:1.0 constant:-8]]];
        _label.numberOfLines = 0;
        _label.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width - 16;
    }
    return self;
}

- (void)setText:(NSAttributedString *)text {
    _text = [text copy];
    _label.attributedText = _text;
}

- (CGFloat)calculateRowHeightWithText:(NSAttributedString *)text {
    self.text = text;
    [self layoutIfNeeded];
    return CGRectGetMaxY(_label.frame) + 8;
}


@end
