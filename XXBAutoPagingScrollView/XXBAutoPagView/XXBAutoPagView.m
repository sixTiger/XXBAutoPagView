//
//  XXBAutoPagView.m
//  XXBAutoPagingScrollView
//
//  Created by 杨小兵 on 15/3/31.
//  Copyright (c) 2015年 xiaoxiaobing. All rights reserved.
//

#import "XXBAutoPagView.h"
#import "XXBAutoPagViewCell.h"

#define XXBCellMargin 10
#define XXBViewMargin 40

@interface XXBAutoPagView ()<UIScrollViewDelegate , UIGestureRecognizerDelegate>

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
    self.clipsToBounds = YES;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.autoScrollView removeFromSuperview];
    self.autoScrollView = nil;
    [self reloadData];
}
- (void)setupGesture
{
    NSArray *gestureArray = self.gestureRecognizers;
    for (UIGestureRecognizer *gesture in gestureArray)
    {
        [self removeGestureRecognizer:gesture];
    }
    UITapGestureRecognizer  *tapGesture = [[UITapGestureRecognizer alloc] init];
    [tapGesture addTarget:self action:@selector(tap:)];
    [self addGestureRecognizer:tapGesture];
    
    if(self.verticalScroll)
    {
        UISwipeGestureRecognizer *downSwip = [[UISwipeGestureRecognizer alloc] init];
        downSwip.direction = UISwipeGestureRecognizerDirectionDown;
        [downSwip addTarget:self action:@selector(downSwip:)];
        [self addGestureRecognizer:downSwip];
        
        UISwipeGestureRecognizer *upSwip = [[UISwipeGestureRecognizer alloc] init];
        upSwip.direction = UISwipeGestureRecognizerDirectionUp;
        [upSwip addTarget:self action:@selector(upSwip:)];
        [self addGestureRecognizer:upSwip];
    }
    else
    {
        UISwipeGestureRecognizer *leftSwip = [[UISwipeGestureRecognizer alloc] init];
        leftSwip.direction = UISwipeGestureRecognizerDirectionLeft;
        [leftSwip addTarget:self action:@selector(leftSwip:)];
        [self addGestureRecognizer:leftSwip];
        
        UISwipeGestureRecognizer *rightSwip = [[UISwipeGestureRecognizer alloc] init];
        rightSwip.direction = UISwipeGestureRecognizerDirectionRight;
        [rightSwip addTarget:self action:@selector(rightSwip:)];
        [self addGestureRecognizer:rightSwip];
        
    }
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
    NSInteger numberOfCells = [self.dataSource numberOfCellInAutoPagView:self];
    if (self.verticalScroll)
    {
        CGFloat cellX = [self marginForType:XXBAutoPagViewMarginTypeColumn] * 0.5;
        CGFloat cellY;
        CGFloat cellW = [self cellWidth];
        CGFloat cellH = [self cellHeight];
        // 计算所有cell的frame
        CGFloat rowMargin =[self marginForType:XXBAutoPagViewMarginTypeRow];
        for (int i = 0; i<numberOfCells; i++)
        {
            cellY = i * (cellH + rowMargin)+ rowMargin * 0.5;
            // 添加frame到数组中
            CGRect cellFrame = CGRectMake(cellX, cellY, cellW, cellH);
            [self.cellFrames addObject:[NSValue valueWithCGRect:cellFrame]];
        }
        
        self.autoScrollView.contentSize = CGSizeMake(cellW,numberOfCells * (cellH + rowMargin));
    }
    else
    {
        CGFloat cellX;
        CGFloat cellY = [self marginForType:XXBAutoPagViewMarginTypeRow] * 0.5;
        CGFloat cellW = [self cellWidth];
        CGFloat cellH = [self cellHeight];
        // 计算所有cell的frame
        CGFloat columnMargin =[self marginForType:XXBAutoPagViewMarginTypeColumn];
        for (int i = 0; i<numberOfCells; i++)
        {
            cellX = i * (cellW + columnMargin)+ columnMargin * 0.5;
            // 添加frame到数组中
            CGRect cellFrame = CGRectMake(cellX, cellY, cellW, cellH);
            [self.cellFrames addObject:[NSValue valueWithCGRect:cellFrame]];
        }
        self.autoScrollView.contentSize = CGSizeMake(numberOfCells * (cellW + columnMargin), cellH);
    }
    [self scrollViewDidScroll:self.autoScrollView];
}
- (CGFloat)cellWidth
{
    return self.autoScrollView.frame.size.width - [self marginForType:XXBAutoPagViewMarginTypeColumn];
}
- (CGFloat)cellHeight
{
    return self.autoScrollView.frame.size.height - [self marginForType:XXBAutoPagViewMarginTypeRow];
}
/**
 *  当UIScrollView滚动的时候也会调用这个方法
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
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
    if (self.verticalScroll)
    {
        if (CGRectGetMaxY(frame) > self.autoScrollView.contentOffset.y - self.autoScrollView.frame.origin.y && CGRectGetMinY(frame) < self.autoScrollView.contentOffset.y + self.autoScrollView.frame.size.height + self.bounds.size.height - CGRectGetMaxY(self.autoScrollView.frame))
        {
            return YES;
        }
        
    }
    else
    {
        if (CGRectGetMaxX(frame) > self.autoScrollView.contentOffset.x - self.autoScrollView.frame.origin.x && CGRectGetMinX(frame) < self.autoScrollView.contentOffset.x + self.autoScrollView.frame.size.width + self.bounds.size.width - CGRectGetMaxX(self.autoScrollView.frame))
        {
            return YES;
        }
    }
    return NO;
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
    if (_autoScrollView == nil)
    {
        [self setupGesture];
        CGFloat x = [self marginForType:XXBAutoPagViewMarginTypeLeft];
        CGFloat y = [self marginForType:XXBAutoPagViewMarginTypeTop];
        CGFloat w = [self autoScrollViewWidth];
        CGFloat h = [self autoScrollViewHeight];
        UIScrollView *autoScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(x, y, w, h)];
        autoScrollView.pagingEnabled = self.pagingEnabled;
        autoScrollView.delegate = self;
        autoScrollView.clipsToBounds = NO;
        autoScrollView.showsHorizontalScrollIndicator = self.showsHorizontalScrollIndicator;
        autoScrollView.showsVerticalScrollIndicator = self.showsVerticalScrollIndicator;
        [self addSubview:autoScrollView];
        _autoScrollView = autoScrollView;
    }
    return _autoScrollView;
}
-  (void)setDelegate:(id<XXBAutoPagViewDelegate>)delegate
{
    [self.autoScrollView removeFromSuperview];
    self.autoScrollView = nil;
    _delegate = delegate;
    [self reloadData];
}
- (void)setDataSource:(id<XXBAutoPagViewDataSource>)dataSource
{
    _dataSource = dataSource;
    [self.autoScrollView removeFromSuperview];
    self.autoScrollView = nil;
    [self reloadData];
}
/**
 *  cell的宽度
 */
- (CGFloat)autoScrollViewWidth
{
    CGFloat leftM = [self marginForType:XXBAutoPagViewMarginTypeLeft];
    CGFloat rightM = [self marginForType:XXBAutoPagViewMarginTypeRight];
    return (self.bounds.size.width - leftM - rightM + [self marginForType:XXBAutoPagViewMarginTypeColumn]);
}
/**
 *  cell的高度
 */
- (CGFloat)autoScrollViewHeight
{
    CGFloat topM = [self marginForType:XXBAutoPagViewMarginTypeTop];
    CGFloat bottomM = [self marginForType:XXBAutoPagViewMarginTypeBottom];
    return (self.bounds.size.height - topM - bottomM);
}
/**
 *  间距
 */
- (CGFloat)marginForType:(XXBAutoPagViewMarginType)type
{
    if ([self.delegate respondsToSelector:@selector(autoPagView:marginForType:)])
    {
        return [self.delegate autoPagView:self marginForType:type];
    }
    else
    {
        if (type == XXBAutoPagViewMarginTypeRow || type == XXBAutoPagViewMarginTypeColumn) {
            return XXBCellMargin;
        }
        return XXBViewMargin;
    }
}
- (void)setPagingEnabled:(BOOL)pagingEnabled
{
    _pagingEnabled = pagingEnabled;
    self.autoScrollView.pagingEnabled = pagingEnabled;
}
- (void)setShowsHorizontalScrollIndicator:(BOOL)showsHorizontalScrollIndicator
{
    _showsHorizontalScrollIndicator = showsHorizontalScrollIndicator;
    self.autoScrollView.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator;
}
- (void)setShowsVerticalScrollIndicator:(BOOL)showsVerticalScrollIndicator
{
    _showsVerticalScrollIndicator = showsVerticalScrollIndicator;
    self.autoScrollView.showsVerticalScrollIndicator = showsVerticalScrollIndicator;
}
- (void)setVerticalScroll:(BOOL)verticalScroll
{
    if (_verticalScroll == verticalScroll )
        return;
    _verticalScroll = verticalScroll;
    [self setupGesture];
    [self reloadData];
}
- (void)nextPage
{
    if (self.verticalScroll)
    {
        if (self.autoScrollView.contentOffset.y + self.autoScrollView.bounds.size.height < self.autoScrollView.contentSize.height)
        {
            self.userInteractionEnabled = NO;
            [self performSelector:@selector(animationControl) withObject:nil afterDelay:0.25];
            [self.autoScrollView setContentOffset:CGPointMake(self.autoScrollView.contentOffset.x,self.autoScrollView.contentOffset.y + self.autoScrollView.bounds.size.height) animated:YES];
        }
    }
    else
    {
        if (self.autoScrollView.contentOffset.x + self.autoScrollView.bounds.size.width < self.autoScrollView.contentSize.width)
        {
            self.userInteractionEnabled = NO;
            [self performSelector:@selector(animationControl) withObject:nil afterDelay:0.25];
            [self.autoScrollView setContentOffset:CGPointMake(self.autoScrollView.contentOffset.x + self.autoScrollView.bounds.size.width, self.autoScrollView.contentOffset.y) animated:YES];
        }
    }
}
- (void)privatePage
{
    if (self.verticalScroll)
    {
        if (self.autoScrollView.contentOffset.y > 0)
        {
            self.userInteractionEnabled = NO;
            [self performSelector:@selector(animationControl) withObject:nil afterDelay:0.25];
            [self.autoScrollView setContentOffset:CGPointMake(self.autoScrollView.contentOffset.x,self.autoScrollView.contentOffset.y - self.autoScrollView.bounds.size.height) animated:YES];
        }
    }
    else
    {
        if (self.autoScrollView.contentOffset.x > 0)
        {
            self.userInteractionEnabled = NO;
            [self performSelector:@selector(animationControl) withObject:nil afterDelay:0.25];
            [self.autoScrollView setContentOffset:CGPointMake(self.autoScrollView.contentOffset.x - self.autoScrollView.bounds.size.width, self.autoScrollView.contentOffset.y) animated:YES];
        }
    }
}
- (void)animationControl
{
    self.userInteractionEnabled = YES;
}
#pragma mark - 处理手势

- (void)tap:(UIGestureRecognizer *)tapGesture
{
    CGPoint tapPoint = [tapGesture locationInView:self];
    if (self.verticalScroll)
    {
        if (tapPoint.y < self.center.y)
        {
            [self privatePage];
        }
        else
        {
            [self nextPage];
        }
    }
    else
    {
        if (tapPoint.x < self.center.x)
        {
            [self privatePage];
        }
        else
        {
            [self nextPage];
        }
    }
}
- (void)leftSwip:(UISwipeGestureRecognizer *)leftSwip
{
    [self nextPage];
}
- (void)rightSwip:(UISwipeGestureRecognizer *)leftSwip
{
    [self privatePage];
}
- (void)downSwip:(UISwipeGestureRecognizer *)topSwip
{
    [self privatePage];
}
- (void)upSwip:(UISwipeGestureRecognizer *)bottomSwip
{
    [self nextPage];
}
@end
