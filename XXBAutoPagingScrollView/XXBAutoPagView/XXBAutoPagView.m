//
//  XXBAutoPagView.m
//  XXBAutoPagingScrollView
//
//  Created by 杨小兵 on 15/3/31.
//  Copyright (c) 2015年 xiaoxiaobing. All rights reserved.
//

#import "XXBAutoPagView.h"
#import "XXBAutoPagViewCell.h"

@interface XXBAutoPagView ()<UIScrollViewDelegate>

/**
 *  所有cell的frame数据
 */
@property (nonatomic, strong) NSMutableArray        *cellFrames;
/**
 *  正在展示的cell
 */
@property (nonatomic, strong) NSMutableDictionary   *displayingCells;
/**
 *  缓存池用字典包裹一层Set
 */
@property(nonatomic , strong)NSMutableDictionary    *reusableCellDict;
/**
 *  华东的cell
 */
@property(nonatomic , weak)UIScrollView             *autoScrollView;
@end

@implementation XXBAutoPagView
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupAutoPagView];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setupAutoPagView];
    }
    return self;
}
- (void)setupAutoPagView
{
    self.backgroundColor = [UIColor yellowColor];
}
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [self reloadData];
}
/**
 *  刷新数据
 */
- (void)reloadData
{
    // 清空之前的所有数据
    // 移除正在正在显示cell
    [self.displayingCells.allValues makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.displayingCells removeAllObjects];
    [self.cellFrames removeAllObjects];
    [self.reusableCellDict removeAllObjects];
    // cell的总数
    if ([self.dataSource respondsToSelector:@selector(numberOfCellInAutoPagView:)])
    {
       NSLog(@"-----------------");
    }
    else
    {
        NSLog(@"++++++++++");
    }
    NSLog(@"++++%@",self.dataSource);
    NSInteger numberOfCells = [self.dataSource numberOfCellInAutoPagView:self];
    
    // cell的宽度
    CGFloat cellW = [self cellWidth];
    CGFloat cellH = [self cellHeight];
    // 计算所有cell的frame
    for (int i = 0; i<numberOfCells; i++)
    {
        CGFloat cellX = i * cellW;
        CGFloat cellY = 0;
        
        // 添加frame到数组中
        CGRect cellFrame = CGRectMake(cellX, cellY, cellW, cellH);
        [self.cellFrames addObject:[NSValue valueWithCGRect:cellFrame]];
    }
    self.autoScrollView.backgroundColor = [UIColor redColor];
    self.autoScrollView.contentSize = CGSizeMake(numberOfCells * [self cellWidth], cellH);
}
- (CGFloat)cellWidth
{
    return self.autoScrollView.frame.size.width;
}
- (CGFloat)cellHeight
{
    return self.autoScrollView.frame.size.height;
}
/**
 *  当UIScrollView滚动的时候也会调用这个方法
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 向数据源索要对应位置的cell
    NSUInteger numberOfCells = self.cellFrames.count;
    for (int index = 0; index<numberOfCells; index++)
    {
        // 取出i位置的frame
        CGRect cellFrame = [self.cellFrames[index] CGRectValue];
        
        // 优先从字典中取出i位置的cell
        XXBAutoPagViewCell *cell = self.displayingCells[@(index)];
        
        // 判断i位置对应的frame在不在屏幕上（能否看见）
        if ([self isInScreen:cellFrame])
        { // 在屏幕上
            if (cell == nil) {
                cell = [self.dataSource autoPagViewCell:self cellAtIndex:index];
                cell.frame = cellFrame;
                [self.autoScrollView addSubview:cell];
                
                // 存放到字典中
                self.displayingCells[@(index)] = cell;
            }
        }
        else
        {  // 不在屏幕上
            if (cell)
            {
                // 从scrollView和字典中移除
                [cell removeFromSuperview];
                [self.displayingCells removeObjectForKey:@(index)];
                if(cell.identifier)
                {
                    // 存放进缓存池
                    NSMutableSet *cellSet = [self.reusableCellDict valueForKey:cell.identifier];
                    if (cellSet == nil)
                    {
                        cellSet = [NSMutableSet set];
                        [self.reusableCellDict setValue:cellSet forKey:cell.identifier];
                        
                    }
                    [cellSet addObject:cell];
                }
            }
        }
    }
}

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    __block XXBAutoPagViewCell *reusableCell = nil;
    NSMutableSet *cellSet = [self.reusableCellDict valueForKey:identifier];
    reusableCell = [cellSet anyObject];
    if (reusableCell)
    { // 从缓存池中移除
        [cellSet removeObject:reusableCell];
    }
    return reusableCell;
}
#pragma mark - 私有方法
/**
 *  判断一个frame有无显示在屏幕上
 */
- (BOOL)isInScreen:(CGRect)frame
{
    return YES;
}

#pragma -懒加载
- (NSMutableArray *)cellFrames
{
    if (_cellFrames == nil) {
        self.cellFrames = [NSMutableArray array];
    }
    return _cellFrames;
}

- (NSMutableDictionary *)displayingCells
{
    if (_displayingCells == nil) {
        self.displayingCells = [NSMutableDictionary dictionary];
    }
    return _displayingCells;
}
- (NSMutableDictionary *)reusableCellDict
{
    if (_reusableCellDict == nil) {
        _reusableCellDict = [NSMutableDictionary dictionary];
    }
    return _reusableCellDict;
}
- (UIScrollView *)autoScrollView
{
    if (_autoScrollView == nil) {
        UIScrollView *autoScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
        autoScrollView.center = self.center;
        [self addSubview:autoScrollView];
        autoScrollView.delegate = self;
        _autoScrollView = autoScrollView;
    }
    return _autoScrollView;
}
-  (void)setDelegate:(id<XXBAutoPagViewDelegate>)delegate
{
    _delegate = delegate;
    [self reloadData];
}
- (void)setDataSource:(id<XXBAutoPagViewDataSource>)dataSource
{
    _dataSource = dataSource;
    [self reloadData];
}
@end
