//
//  AppDelegate.h
//  ka7ku
//
//  Created by wangye on 13-4-21.
//  Copyright (c) 2013年 wangye. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Reachability;
@class MainViewController;
@interface AppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate>
{
    Reachability* hostReach;
}
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MainViewController *mainViewController;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
