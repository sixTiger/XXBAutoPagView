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
/**
 *  cell 被点击
 */
- (void)autoPagView:(XXBAutoPagView *)autoPagView didSelectedCellAtIndex:(NSInteger)index;
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
/**
 *  根据标识返回重用的cell
 *
 *  @param identifir 重用标示
 *
 *  @return 可以重用的cell;
 */
- (XXBAutoPagViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;
/**
 *  根据indexcell
 *
 *  @param index 需要的index
 *
 *  @return 返回的cell
 */
- (XXBAutoPagViewCell *)autoPageCellWithIdex:(NSInteger)index;
/**
 *  在index处添加一个按钮
 *
 *  @param index 要添加的地方
 */
- (void)addCellAtIndex:(NSInteger )index;
/**
 *  在index处添加一个按钮
 *
 *  @param index 要添加的地方
 */
- (void)deleteCellAtIndex:(NSInteger )index;
@end
