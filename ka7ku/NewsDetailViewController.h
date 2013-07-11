//
//  NewsDetailViewController.h
//  ka7ku
//
//  Created by wangye on 13-4-30.
//  Copyright (c) 2013年 wangye. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "ServiceHelper.h"
#import "Article.h"

@class UIScrollView;
@interface NewsDetailViewController : UIViewController<UIScrollViewDelegate,ServiceHelperDelegate,MBProgressHUDDelegate>
{
    //UILabel *titleLabel;
    UILabel *addDateLabel;
    UILabel *authorLabel;
    UIImageView *imageView;
    UIScrollView *scrollView;
    NSString *contentId;
    ServiceHelper *helper;
    MBProgressHUD *loadingProcess;
    
    Article *currentArticle;
    NSArray *pContent;//文章内容段落数组存储
    float currentOffsetY;//scrollview contentsizeY
    NSInteger goodCount;
}

@property (nonatomic, copy) NSString *articleId;
@property (nonatomic, retain) MBProgressHUD *loadingProcess;
@property (nonatomic, assign) id<ServiceHelperDelegate> serviceHelperDelegate;
@property (nonatomic, retain) UIWebView *webContent;

@property (nonatomic, retain) Article *currentArticle;
@property (nonatomic, retain) UILabel *addDateLabel;
@property (nonatomic, retain) UILabel *authorLabel;
@property (nonatomic, retain) NSArray *pContent;
@property (nonatomic,assign) float currentOffsetY;
@property (nonatomic,assign) NSInteger goodCount;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIScrollView *scrollView;


- (void)initWithArticleId:(NSString *)articleId;
- (void)xmlParserWithString:(NSString *)xmlString;
- (UIView *)ContentUITextView;
- (void)fillContentView;
@end
