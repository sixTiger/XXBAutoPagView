//
//  XXBAutoPagViewCell.m
//  XXBAutoPagingScrollView
//
//  Created by 杨小兵 on 15/3/31.
//  Copyright (c) 2015年 xiaoxiaobing. All rights reserved.
//

#import "XXBAutoPagViewCell.h"

@interface XXBAutoPagViewCell ()
@property(nonatomic , weak)UILabel *titleLable;
@end
@implementation XXBAutoPagViewCell
- (void)setTitle:(NSString *)title
{
    _title = [title copy];
    self.titleLable.text = _title;
}
- (UILabel *)titleLable
{
    if (_titleLable == nil) {
        UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, self.bounds.size.width - 10, 44)];
        [self addSubview:titleLable];
        titleLable.autoresizingMask = (1 << 6) - 1;
        _titleLable = titleLable;
    }
    return _titleLable;
}
@end
