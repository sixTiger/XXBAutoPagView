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

@interface ViewController ()<XXBAutoPagViewDataSource , XXBAutoPagViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    XXBAutoPagView *autoPageView = [[XXBAutoPagView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:autoPageView];
    
    autoPageView.dataSource = self;
    autoPageView.delegate = self;
}
- (NSInteger)numberOfCellInAutoPagView:(XXBAutoPagView *)autoPagView
{
    return 10;
}
- (XXBAutoPagViewCell *)autoPagViewCell:(XXBAutoPagView *)autoPagView cellAtIndex:(NSUInteger)index
{
    XXBAutoPagViewCell *autoCell = [[XXBAutoPagViewCell alloc] init];
    autoCell.backgroundColor = [UIColor colorWithRed:(arc4random_uniform(255)/255.0) green:(arc4random_uniform(255)/255.0) blue:(arc4random_uniform(255)/255.0) alpha:1.0];
    return autoCell;
}
@end
