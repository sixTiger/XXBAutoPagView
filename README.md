# XXBAutoPagView
## 自动分页的ScrollView
 * 可以多出来两侧的图片
 * 优化了内存添加了引用机制
 * 支持横向和纵向的两个方向的滚动
 * 支持添加和删除
 
- 使用起来非常的简单
创建代码如下<br>

```objective-c
- (void)setupAutoPageView
{
    // 创建一个 XXBAutoPagView
    XXBAutoPagView *autoPageView = [[XXBAutoPagView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:autoPageView];
    // 设置数据源和代理
    autoPageView.dataSource = self;
    autoPageView.delegate = self;
    // 是否允许分页
    autoPageView.pagingEnabled = YES;
    autoPageView.showsHorizontalScrollIndicator = NO;
    autoPageView.showsVerticalScrollIndicator = NO;
    autoPageView.verticalScroll = NO;
    _autoPageView = autoPageView;
}
```
数据源方法如下<br>
```objective-c
/**
 *  一共有多少个数据
 */
- (NSInteger)numberOfCellInAutoPagView:(XXBAutoPagView *)autoPagView;
/**
 *  返回index位置对应的cell
 */
- (XXBAutoPagViewCell *)autoPagViewCell:(XXBAutoPagView *)autoPagView cellAtIndex:(NSUInteger)index;
```
代理方法如下<br>
```objective-c
/**
 *  cell 上下左右的边距
 */
- (CGFloat)autoPagView:(XXBAutoPagView *)autoPagView marginForType:(XXBAutoPagViewMarginType)type;
/**
 *  cell 被点击
 */
- (void)autoPagView:(XXBAutoPagView *)autoPagView didSelectedCellAtIndex:(NSInteger)index;
```
## 示例图片<br>

![image](./image/1.PNG)<br>

![image](./image/2.PNG)<br>

## 动态示例效果
![image](./image/autoPageView.gif)<br>
