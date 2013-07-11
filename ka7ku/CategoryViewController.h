//
//  CategoryViewController.h
//  tabbarNav
//
//  Created by wangye on 13-4-22.
//  Copyright (c) 2013年 wangye. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceHelper.h"
#import "MBProgressHUD.h"

@interface CategoryViewController : UITableViewController<UITableViewDataSource,UITableViewDelegate,ServiceHelperDelegate,MBProgressHUDDelegate>
{
    NSArray *dataLists;
    NSMutableArray *imgLists;
    ServiceHelper *helper;
    MBProgressHUD *loadingProcess;
}
@property (strong, nonatomic) NSArray *dataLists;
@property (strong, nonatomic) NSMutableArray *imgLists;
@property (nonatomic, retain) MBProgressHUD *loadingProcess;

- (void)showHUD:(NSString *)msg;
- (void)removeHUD;

- (NSArray *)xmlParser:(NSString *)filePath;
- (BOOL)cacheImgWithImgURL:(NSString *)imgURL;
@end
