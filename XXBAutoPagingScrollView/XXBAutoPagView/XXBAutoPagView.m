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

/**
 *  存放cell的frame的模型
 */
@interface XXBAutoCellFrame : NSObject

/**
 *  下标
 */
@property(nonatomic , assign)NSInteger index;

/**
 *  frame
 */
@property(nonatomic , assign)CGRect frame;
@end
@implementation XXBAutoCellFrame
- (BOOL)isEqual:(XXBAutoCellFrame *)other
{
    return self.index == other.index;
}
@end

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
    [self reloadFrame];
    [self scrollViewDidScroll:self.autoScrollView];
}
/**
 *  在index处添加一个cell
 *
 *  @param index 要添加的地方
 */
- (void)addCellAtIndex:(NSInteger )index
{
#warning 有问题  差点动画效果
    //    [self reloadFrame];
    //    [self scrollViewDidScroll:self.autoScrollView];
    [self reloadData];
    [self nextPage];
}
/**
 *  在index处删除一个cell
 *
 *  @param index 要删除的index
 */
- (void)deleteCellAtIndex:(NSInteger)index
{
    //    // 取出i位置的frame
    //    CGRect cellFrame = [self.cellFrames[index] CGRectValue];
    //    // 优先从字典中取出i位置的cell
    //    XXBAutoPagViewCell *cell = self.displayingCells[@(index)];
    //    // 判断i位置对应的frame在不在屏幕上（能否看见）
    //    if ([self isInScreen:cellFrame])
    //    { // 在屏幕上
    //        if (cell)
    //        {
    //            // 从scrollView和字典中移除
    //            [cell removeFromSuperview];
    //            [self.displayingCells removeObjectForKey:@(index)];
    //            if(cell.identifier)
    //            {
    //                // 存放进缓存池
    //                NSMutableSet *cellSet = [self.reusableCellDict valueForKey:cell.identifier];
    //                if (cellSet == nil)
    //                {
    //                    cellSet = [NSMutableSet set];
    //                    [self.reusableCellDict setValue:cellSet forKey:cell.identifier];
    //
    //                }
    //                [UIView animateWithDuration:0.15 animations:^{
    //
    //                    [cellSet addObject:cell];
    //                }];
    //            }
    //        }
    //    }
    //    [self reloadFrame];
    //    [self scrollViewDidScroll:self.autoScrollView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self reloadData];
    });
}

- (void)reloadFrame
{
    // cell的总数
    NSInteger numberOfCells = [self.dataSource numberOfCellInAutoPagView:self];
    for (NSInteger i = 0; i<numberOfCells; i++)
    {
        XXBAutoCellFrame *autoCellFrame = [[XXBAutoCellFrame alloc] init] ;
        autoCellFrame.index = i;
        autoCellFrame.frame = [self autoPagViewCellFrameOfIndex:i];
        // 添加frame到数组中
        [self.cellFrames addObject:autoCellFrame];
    }
    if (self.verticalScroll)
    {
        CGFloat cellW = [self cellWidth];
        CGFloat cellH = [self cellHeight];
        // 计算所有cell的frame
        CGFloat rowMargin =[self marginForType:XXBAutoPagViewMarginTypeRow];
        self.autoScrollView.contentSize = CGSizeMake(cellW,numberOfCells * (cellH + rowMargin));
    }
    else
    {
        CGFloat cellW = [self cellWidth];
        CGFloat cellH = [self cellHeight];
        // 计算所有cell的frame
        CGFloat columnMargin =[self marginForType:XXBAutoPagViewMarginTypeColumn];
        self.autoScrollView.contentSize = CGSizeMake(numberOfCells * (cellW + columnMargin), cellH);
    }
}
//对应index的frame
- (CGRect)autoPagViewCellFrameOfIndex:(NSInteger)index
{
    if (self.verticalScroll)
    {
        CGFloat cellX = [self marginForType:XXBAutoPagViewMarginTypeColumn] * 0.5;
        CGFloat cellY;
        CGFloat cellW = [self cellWidth];
        CGFloat cellH = [self cellHeight];
        // 计算所有cell的frame
        CGFloat rowMargin =[self marginForType:XXBAutoPagViewMarginTypeRow];
        cellY = index * (cellH + rowMargin)+ rowMargin * 0.5;
        return  CGRectMake(cellX, cellY, cellW, cellH);
    }
    else
    {
        CGFloat cellX;
        CGFloat cellY = [self marginForType:XXBAutoPagViewMarginTypeRow] * 0.5;
        CGFloat cellW = [self cellWidth];
        CGFloat cellH = [self cellHeight];
        // 计算所有cell的frame
        CGFloat columnMargin =[self marginForType:XXBAutoPagViewMarginTypeColumn];
        cellX = index * (cellW + columnMargin) + columnMargin * 0.5;
        // 添加frame到数组中
        return  CGRectMake(cellX, cellY, cellW, cellH);
    }
    
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
        CGRect cellFrame = [self.cellFrames[index] frame];
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
/**
 *  重新设置AotoPageView的Frame
 *
 *  @param index 开始的index
 */
- (void)resetAotoPageViewFrameFromIndex:(NSInteger)index
{
    // 向数据源索要对应位置的cell
    NSUInteger numberOfCells = self.cellFrames.count;
    for (; index<numberOfCells; index++)
    {
        // 取出i位置的frame
        CGRect cellFrame = [self.cellFrames[index] frame];
        // 优先从字典中取出i位置的cell
        XXBAutoPagViewCell *cell = self.displayingCells[@(index)];
        // 判断i位置对应的frame在不在屏幕上（能否看见）
        if ([self isInScreen:cellFrame])
        { // 在屏幕上
            if (cell == nil) {
                cell = [self.dataSource autoPagViewCell:self cellAtIndex:index];
                cell.frame = cellFrame;
                [UIView animateWithDuration:0.25 animations:^{
                    [self.autoScrollView addSubview:cell];
                }];
                // 存放到字典中
                self.displayingCells[@(index)] = cell;
            }
            else
            {
                [UIView animateWithDuration:0.25 animations:^{
                    cell.frame = cellFrame;
                }];
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
- (XXBAutoPagViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier
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
- (XXBAutoPagViewCell *)autoPageCellWithIdex:(NSInteger)index
{
    return [self.displayingCells objectForKey:@(index)];
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
        CGFloat x = [self marginForType:XXBAutoPagViewMarginTypeLeft] - [self marginForType:XXBAutoPagViewMarginTypeColumn] * 0.5;
        CGFloat y = [self marginForType:XXBAutoPagViewMarginTypeTop] - [self marginForType:XXBAutoPagViewMarginTypeRow] * 0.5;
        CGFloat w = [self autoScrollViewWidth];
        CGFloat h = [self autoScrollViewHeight];
        UIScrollView *autoScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(x, y, w, h)];
        autoScrollView.pagingEnabled = self.pagingEnabled;
        autoScrollView.delegate = self;
        autoScrollView.clipsToBounds = NO;
        autoScrollView.backgroundColor = [UIColor redColor];
        autoScrollView.showsHorizontalScrollIndicator = self.showsHorizontalScrollIndicator;
        autoScrollView.showsVerticalScrollIndicator = self.showsVerticalScrollIndicator;
        autoScrollView.alwaysBounceHorizontal = !self.verticalScroll;
        autoScrollView.alwaysBounceVertical = self.verticalScroll;
        [self addSubview:autoScrollView];
        _autoScrollView = autoScrollView;
    }
    return _autoScrollView;
}
-  (void)setDelegate:(id<XXBAutoPagViewDelegate>)delegate
{
    _delegate = delegate;
}
- (void)setDataSource:(id<XXBAutoPagViewDataSource>)dataSource
{
    _dataSource = dataSource;
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
    
    self.autoScrollView.alwaysBounceHorizontal = !self.verticalScroll;
    self.autoScrollView.alwaysBounceVertical = self.verticalScroll;
    [self setupGesture];
}
/**
 *  下一页
 */
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
/**
 *  上一页
 */
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
    if (CGRectContainsPoint(self.autoScrollView.frame, tapPoint))
    {
        if ([self.delegate respondsToSelector:@selector(autoPagView:didSelectedCellAtIndex:)])
        {
            NSInteger index = self.autoScrollView.contentOffset.x/self.autoScrollView.bounds.size.width;
            if (self.verticalScroll)
            {
                index = self.autoScrollView.contentOffset.x/self.autoScrollView.bounds.size.height;
            }
            [self.delegate autoPagView:self didSelectedCellAtIndex:index];
        }
        return;
    }
    
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
