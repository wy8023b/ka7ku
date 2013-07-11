//
//  MainViewController.m
//  tabbarNav
//
//  Created by wangye on 13-4-22.
//  Copyright (c) 2013年 wangye. All rights reserved.
//

#import "MainViewController.h"
#import "NewsViewController.h"
#import "CategoryViewController.h"
#import "AboutViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController
@synthesize tabBar1;
@synthesize tabBar2;
@synthesize tabBar3;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tabBarController.delegate = self;
    UIImage *itemImg = [UIImage imageNamed:@"home.png"];

    self.tabBar1 = [[NewsViewController alloc] initWithNibName:@"News" bundle:[NSBundle mainBundle]];
    UINavigationController *navigationController1 = [[UINavigationController alloc] initWithRootViewController:self.tabBar1];
    navigationController1.tabBarItem =[[UITabBarItem alloc] initWithTitle:@"新闻" image:itemImg tag:1];
    self.tabBar2 = [[CategoryViewController alloc] initWithNibName:@"Category" bundle:[NSBundle mainBundle]];
    UINavigationController *navigationController2 = [[UINavigationController alloc] initWithRootViewController:self.tabBar2];
    navigationController2.tabBarItem =[[UITabBarItem alloc] initWithTitle:@"分类" image:itemImg tag:2];
    self.tabBar3 = [[AboutViewController alloc] initWithNibName:@"About" bundle:[NSBundle mainBundle]];
    NSMutableArray *controllers = [[NSMutableArray alloc] initWithObjects:navigationController1,navigationController2,self.tabBar3,nil];
    //NSMutableArray *controllers = @[tabBar1,tabBar2,tabBar3];
    self.viewControllers = controllers;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma tabbar delegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    //  [self.view addSubview:viewController.view];
    //  tabBarController.selectedViewController = viewController;
    viewController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",80];
    //  viewController.tabBarItem.title = @"aaa";
}

@end
