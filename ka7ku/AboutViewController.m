//
//  AboutViewController.m
//  tabbarNav
//
//  Created by wangye on 13-4-22.
//  Copyright (c) 2013年 wangye. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"关于";
        UIImage *itemImg = [UIImage imageNamed:@"home.png"];
        UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:self.title image:itemImg tag:3];
        self.tabBarItem = item;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
