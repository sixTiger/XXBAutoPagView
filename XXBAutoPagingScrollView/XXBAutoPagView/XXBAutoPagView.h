//
//  XXBAutoPagView.h
//  XXBAutoPagingScrollView
//
//  Created by 杨小兵 on 15/3/31.
//  Copyright (c) 2015年 xiaoxiaobing. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    XXBAutoPagViewMarginTypeTop,          //顶部
    XXBAutoPagViewMarginTypeBottom,       //底部
    XXBAutoPagViewMarginTypeLeft,         //左边
    XXBAutoPagViewMarginTypeRight,        //右边
    XXBAutoPagViewMarginTypeColumn,       //每一列
    XXBAutoPagViewMarginTypeRow,          //每一行
} XXBAutoPagViewMarginType;

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
/**
 *  cell 上下左右的边距
 */
- (CGFloat)autoPagView:(XXBAutoPagView *)autoPagView marginForType:(XXBAutoPagViewMarginType)type;
@end

@interface XXBAutoPagView : UIView
@property(nonatomic , weak) IBOutlet id<XXBAutoPagViewDelegate>     delegate;
@property(nonatomic , weak) IBOutlet id<XXBAutoPagViewDataSource>   dataSource;
/**
 *  是否分页
 */
@property(nonatomic , assign)BOOL pagingEnabled;
/**
 * 是否显示水平滚动条
 */
@property(nonatomic , assign)BOOL showsHorizontalScrollIndicator;
/**
 * 是否显示垂直滚动条
 */
@property(nonatomic , assign)BOOL showsVerticalScrollIndicator;
// 是否垂直滚动 默认是否
@property(nonatomic , assign)BOOL verticalScroll;
- (void)reloadData;
@end
