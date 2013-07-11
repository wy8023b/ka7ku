//
//  MainViewController.h
//  tabbarNav
//
//  Created by wangye on 13-4-22.
//  Copyright (c) 2013年 wangye. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewsViewController;
@class CategoryViewController;
@class AboutViewController;
@interface MainViewController : UITabBarController<UITabBarControllerDelegate>{
    NewsViewController *tabBar1;
    CategoryViewController *tabBar2;
    AboutViewController *tabBar3;
}
@property (nonatomic, retain) NewsViewController *tabBar1;
@property (nonatomic, retain) CategoryViewController *tabBar2;
@property (nonatomic, retain) AboutViewController *tabBar3;

@end
