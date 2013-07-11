//
//  categoryDetailViewController.h
//  ka7ku
//
//  Created by wangye on 13-5-2.
//  Copyright (c) 2013年 wangye. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceHelper.h"
#import "MBProgressHUD.h"

@interface CategoryDetailViewController : UITableViewController<UITableViewDataSource,UITableViewDelegate,ServiceHelperDelegate,MBProgressHUDDelegate>
{
    NSString *catogeryId;
    NSString *catogeryName;
    UINavigationController *nav;
    NSArray *dataLists;
    NSMutableArray *imgLists;
    ServiceHelper *helper;
    MBProgressHUD *loadingProcess;
}
@property (nonatomic, copy) NSString *catogeryId;
@property (nonatomic, retain)NSString *catogeryName;
@property (strong, nonatomic) NSArray *dataLists;

@property (strong, nonatomic) NSMutableArray *imgLists;
@property (nonatomic, retain) MBProgressHUD *loadingProcess;
@property (nonatomic, retain) UINavigationController *nav;

- (void)showHUD:(NSString *)msg;
- (void)removeHUD;

- (NSArray *)xmlParser:(NSString *)filePath;
- (BOOL)cacheImgWithImgURL:(NSString *)imgURL;
@end
