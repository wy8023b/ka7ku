//
//  NewsViewController.h
//  tabbarNav
//
//  Created by wangye on 13-4-22.
//  Copyright (c) 2013年 wangye. All rights reserved.

#import <UIKit/UIKit.h>
#import "ServiceHelper.h"
#import "MBProgressHUD.h"
#import "EGORefreshTableHeaderView.h"//下拉刷新

@interface NewsViewController : UITableViewController<UITableViewDelegate, UITableViewDataSource,ServiceHelperDelegate,MBProgressHUDDelegate,EGORefreshTableHeaderDelegate,UIAlertViewDelegate>
{
    NSArray *dataLists;
    NSMutableArray *imgLists;
    ServiceHelper *helper;
    MBProgressHUD *loadingProcess;
    UIScrollView *_tableHeaderView;
    NSMutableArray *_tableHeaderArray;
    UIPageControl *_pageControl;
    EGORefreshTableHeaderView *refreshTableHeaderView;
    BOOL reloading;
}

@property (strong, nonatomic) NSArray *dataLists;
@property (strong, nonatomic) NSMutableArray *imgLists;
@property (nonatomic, retain) UIView *disableViewOverlay;
@property (nonatomic, retain) ServiceHelper *helper;
@property (nonatomic, retain) MBProgressHUD *loadingProcess;
@property (nonatomic, retain) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic, assign) BOOL reloading;
@property (nonatomic, retain) UIPageControl *pageControl;
@property (nonatomic, retain) UIScrollView *tableHeaderView;
- (void)showHUD:(NSString *)msg;
- (void)removeHUD;

- (void)reloadTableViewDataSource;//下拉刷新后重新加载tabledata数据
- (void)doneLoadingTableViewData;//下拉刷新重加载数据后，将隐藏刷新区域

- (NSArray *)xmlParser;
- (BOOL)cacheImgWithImgURL:(NSString *)imgURL;
@end
