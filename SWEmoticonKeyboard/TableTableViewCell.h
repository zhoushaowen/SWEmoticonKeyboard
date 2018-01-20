//
//  TableTableViewCell.h
//  SWEmojiKeyboard
//
//  Created by zhoushaowen on 2018/1/17.
//  Copyright © 2018年 zhoushaowen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableTableViewCell : UITableViewCell

@property (nonatomic,copy) NSAttributedString *text;

- (CGFloat)calculateRowHeightWithText:(NSAttributedString *)text;

@end
