//
//  XXBAutoPagView.h
//  XXBAutoPagingScrollView
//
//  Created by 杨小兵 on 15/3/31.
//  Copyright (c) 2015年 xiaoxiaobing. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XXBAutoPagView,XXBAutoPagViewCell;

@protocol XXBAutoPagViewDataSource <NSObject>

@required
/**
 *  一共有多少个数据
 */
- (NSInteger)numberOfCellInAutoPagView:(XXBAutoPagView *)autoPagView;
/**
 *  返回index位置对应的cell
 */
- (XXBAutoPagViewCell *)autoPagViewCell:(XXBAutoPagView *)autoPagView cellAtIndex:(NSUInteger)index;
@end

@protocol XXBAutoPagViewDelegate <NSObject>

@optional
/**
 *  第index位置cell对应的宽度
 */
- (CGFloat)autoPagView:(XXBAutoPagView *)autoPageView weightAtIndex:(NSInteger)index;
@end

@interface XXBAutoPagView : UIView
@property(nonatomic , weak)  id<XXBAutoPagViewDelegate>     delegate;
@property(nonatomic , weak)  id<XXBAutoPagViewDataSource>   dataSource;
- (void)reloadData;
@end
