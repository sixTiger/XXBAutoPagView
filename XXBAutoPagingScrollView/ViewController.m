//
//  ViewController.m
//  XXBAutoPagingScrollView
//
//  Created by 杨小兵 on 15/3/31.
//  Copyright (c) 2015年 xiaoxiaobing. All rights reserved.
//

#import "ViewController.h"
#import "XXBAutoPagView.h"
#import "XXBAutoPagViewCell.h"

@interface ViewController ()<XXBAutoPagViewDataSource , XXBAutoPagViewDelegate,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet XXBAutoPagView *autoPageView;
@property(nonatomic , strong)NSMutableArray *dataSourceArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.autoPageView.hidden = YES;
    [self setupAutoPageView];
    [self setButtons];

}
- (void)setButtons
{
    UIButton *addbutton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [addbutton addTarget:self action:@selector(addbuttonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addbutton];
    addbutton.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 50, 50, 50);
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [deleteButton addTarget:self action:@selector(deleteButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deleteButton];
    deleteButton.frame = CGRectMake(55, [UIScreen mainScreen].bounds.size.height - 50, 50, 50);
}
- (void)addbuttonClick
{
    NSLog(@"add");
    [self.dataSourceArray addObject:@""];
    [self.autoPageView addCellAtIndex:2];
}
- (void)deleteButtonClick
{
    [self.dataSourceArray removeLastObject];
    [self.autoPageView deleteCellAtIndex:0];
}
- (void)setupAutoPageView
{
    XXBAutoPagView *autoPageView = [[XXBAutoPagView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:autoPageView];
    
    autoPageView.dataSource = self;
    autoPageView.delegate = self;
    autoPageView.pagingEnabled = YES;
    autoPageView.showsHorizontalScrollIndicator = NO;
    autoPageView.showsVerticalScrollIndicator = NO;
    autoPageView.verticalScroll = NO;
    _autoPageView = autoPageView;
}
- (void)autoPagView:(XXBAutoPagView *)autoPagView didSelectedCellAtIndex:(NSInteger)index
{
    NSLog(@"%@",@(index));
}
- (NSInteger)numberOfCellInAutoPagView:(XXBAutoPagView *)autoPagView
{
    return self.dataSourceArray.count;
}
- (XXBAutoPagViewCell *)autoPagViewCell:(XXBAutoPagView *)autoPagView cellAtIndex:(NSUInteger)index
{
    XXBAutoPagViewCell *autoCell = [[XXBAutoPagViewCell alloc] init];
    autoCell.backgroundColor = [UIColor colorWithRed:(arc4random_uniform(255)/255.0) green:(arc4random_uniform(255)/255.0) blue:(arc4random_uniform(255)/255.0) alpha:1.0];
    autoCell.title = [NSString stringWithFormat:@"第%@个cell",@(index)];
    return autoCell;
}
- (CGFloat)autoPagView:(XXBAutoPagView *)autoPagView marginForType:(XXBAutoPagViewMarginType)type
{
    switch (type) {
        case XXBAutoPagViewMarginTypeTop:
        {
            return 40;
            break;
        }
        case XXBAutoPagViewMarginTypeBottom:
        {
            return 40;
            break;
        }
        case XXBAutoPagViewMarginTypeLeft:
        {
            return 30;
            break;
        }
        case XXBAutoPagViewMarginTypeRight:
        {
            return 30;
            break;
        }
        case XXBAutoPagViewMarginTypeColumn:
        {
            return 10;
            break;
        }
        case XXBAutoPagViewMarginTypeRow:
            
        {
            return 10;
            break;
        }
        default:
        {
            return 0;
            break;
        }
    }
    return 0;
}
- (NSMutableArray *)dataSourceArray
{
    if (_dataSourceArray == nil)
    {
        _dataSourceArray = [NSMutableArray array];
        [_dataSourceArray addObject:@"0000"];
        [_dataSourceArray addObject:@"1111"];
    }
    return _dataSourceArray;
}
@end
