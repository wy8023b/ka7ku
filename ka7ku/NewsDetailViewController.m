//
//  NewsDetailViewController.m
//  ka7ku
//  未加载实际数据
//  Created by wangye on 13-4-30.
//  Copyright (c) 2013年 wangye. All rights reserved.
//
#import "SoapHelper.h"
#import "NewsDetailViewController.h"
#import "GDataXMLNode.h"
#import "NSString+xmldecoding.h"
#import <ShareSDK/ShareSDK.h>

@interface NewsDetailViewController ()
@end

@implementation NewsDetailViewController
@synthesize addDateLabel = _addDateLabel;
@synthesize authorLabel = _authorLabel;
@synthesize pContent = _pContent;
@synthesize currentOffsetY = _currentOffsetY;
@synthesize goodCount = _goodCount;
@synthesize imageView = _imageView;
@synthesize scrollView =_scrollView;
@synthesize articleId = _articleId;
@synthesize loadingProcess =_loadingProcess;
@synthesize serviceHelperDelegate=_serviceHelperDelegate;
@synthesize currentArticle = _currentArticle;

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
    _serviceHelperDelegate = self;
    [self showHUD:@"数据读取中..."];
    _currentOffsetY = 250;
    [self initWithArticleId:_articleId];
    // Do any additional setup after loading the view from its nib.
}

- (void)initWithArticleId:(NSString *)articleId
{
    //根据传递的contentID请求webservice调用获取返回数据并根据返回的数据进行xml解析
    helper=[[ServiceHelper alloc] initWithDelegate:_serviceHelperDelegate];
    NSMutableArray *arr=[NSMutableArray array];
    [arr addObject:[NSDictionary dictionaryWithObjectsAndKeys:_articleId,@"id", nil]];
    NSString *soapMsg=[SoapHelper arrayToDefaultSoapMessage:arr methodName:@"GetArticleById"];
    [helper asynServiceMethod:@"GetArticleById" soapMessage:soapMsg];
}

#pragma 异步调用数据信息
- (void)finishSuccessRequest:(NSString *)xml
{
    [self xmlParserWithString:xml];
    [self fillContentView];
    [self.view addSubview:_scrollView];
    [self removeHUD];
}

- (void)finishFailRequest:(NSError *)error
{
    NSLog(@"%@",error);
    [self removeHUD];
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"请求数据失败" message:@"网络请求数据异常！稍后再试!" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil];
    [av show];
    
}
- (void)fillContentView
{
    [self navgationItemModify];
    [self initAuthorLabel];
    [self initAddDateLabel];
    [self initImageView];
    [self initScrollView];
    [_scrollView addSubview:_addDateLabel];
    [_scrollView addSubview:_authorLabel];
    [_scrollView addSubview:_imageView];
    [_scrollView addSubview:[self ContentUITextView]];
    [_scrollView addSubview:[self goodButton]];
    [_scrollView addSubview:[self concernButton]];
    [_scrollView addSubview:[self shareButtonView]];
    _currentOffsetY+=80;
    [_scrollView setContentSize:CGSizeMake(self.view.frame.size.width, _currentOffsetY)];
}

- (void)navgationItemModify
{
    CGRect frame = CGRectMake(0, 0, 320, 44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:13];
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor blueColor];
    label.text = _currentArticle.title;
    self.navigationItem.titleView = label;
}

- (void)initAddDateLabel
{
    _addDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(190, 15, 110, 30)];
    _addDateLabel.textAlignment = NSTextAlignmentLeft;
    _addDateLabel.font = [UIFont systemFontOfSize:12];
    NSString *label = [NSString stringWithFormat:@"发表于：%@",_currentArticle.addDate];
    _addDateLabel.text = label;
}

- (void)initAuthorLabel
{
    _authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 189, 30)];
    _authorLabel.textAlignment = NSTextAlignmentRight;
    _authorLabel.font = [UIFont boldSystemFontOfSize:13];
    _authorLabel.textColor = [UIColor redColor];
    NSString *label = [NSString stringWithFormat:@"%@",_currentArticle.author];
    _authorLabel.text = label;
}

- (void)initImageView
{
    float imgWidth = 190;
    float imgHeight = 190;
    CGSize imgViewSize  = {imgWidth,imgHeight};
    CGPoint origin = {self.view.center.x-imgWidth/2,50};
    CGRect imgViewRect = {origin,imgViewSize};
    _imageView = [[UIImageView alloc] initWithFrame:imgViewRect];
    NSString *imgLocate = [defaultWebSite stringByAppendingFormat:@"%@",_currentArticle.topImg];
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgLocate]];
    _imageView.image = [UIImage imageWithData:data];
}

- (void)initScrollView
{
    _scrollView.delegate = self;
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0, 320, 400)];
    _scrollView.pagingEnabled = YES;
}

- (UIView *)ContentUITextView
{
    UIView *content = [[UIView alloc] init];
    if (_pContent == nil || _pContent.count==0) {
        UILabel *text = [[UILabel alloc] init];
        text.text = @"没有内容!";
        [content addSubview:text];
    }else
    {
        
        for (int i = 0; i<_pContent.count; i++) {
            id p  = [_pContent objectAtIndex:i];
            if ([p isKindOfClass:[NSString class]]) {
                UILabel *strText = [[UILabel alloc] init];
                strText.text = [NSString stringWithFormat:@"    %@",p];
                strText.numberOfLines = 0;
                strText.textAlignment = NSTextAlignmentLeft;
                strText.font = [UIFont systemFontOfSize:13];
                //float width = 280;
                CGSize constrainSize = {280,2000};
                CGSize nSize = [[strText text] sizeWithFont:strText.font constrainedToSize: constrainSize lineBreakMode:NSLineBreakByClipping];
                CGPoint point = {20,_currentOffsetY};
                CGRect rect = {point,nSize};
                strText.frame = rect;
                [content addSubview:strText];
                _currentOffsetY += nSize.height+10;
                [_scrollView setContentSize:CGSizeMake(self.view.frame.size.width, _currentOffsetY)];
            }
            else if ([p isKindOfClass:[NSMutableDictionary class]])
            {
                NSString *imgUrl = [defaultWebSite stringByAppendingFormat:@"%@",[p objectForKey:@"imgURL"]];
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrl]]];
                NSString *imgSize = [p objectForKey:@"imgSize"];//width: 136px; height: 199px
                float width = [[imgSize substringWithRange:NSMakeRange(7, 3)] floatValue];
                float height = [[imgSize substringWithRange:NSMakeRange(22, 3)] floatValue];
                UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
                CGSize size = {width>280?280:width,roundf(height*280/width)};
                //NSLog(@"current Image size , width : %f,Height : %f",size.width,size.height);
                CGPoint point = {20,_currentOffsetY};
                CGRect rect = {point,size};
                imgView.frame = rect;
                [content addSubview:imgView];
                _currentOffsetY+=roundf(height*280/width)+10;
                [_scrollView setContentSize:CGSizeMake(self.view.frame.size.width, _currentOffsetY)];
            }
        }
    }
    return content;
}

-(UIButton *)goodButton
{
    UIButton *btnGood = [UIButton buttonWithType:UIButtonTypeCustom];
    btnGood.tag = 101;
    CGPoint btnGoodOffSet = CGPointMake(30, _currentOffsetY);
    CGSize btnGoodSize = CGSizeMake(80, 30);
    CGRect rect = {btnGoodOffSet,btnGoodSize};
    btnGood.frame = rect;
    _goodCount = [self goodCount:_articleId];
    NSString *btnGoodTitle = [NSString stringWithFormat:@"不错 [%d]",_goodCount];
    btnGood.backgroundColor = [[UIColor alloc] initWithRed:0.9 green:0.5 blue:0.2 alpha:1.0];
    [btnGood setTitle:btnGoodTitle forState:UIControlStateNormal];
    btnGood.titleLabel.font = [UIFont fontWithName:@"helvetica" size:12];
    [btnGood addTarget:self action:@selector(isGoodButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    return btnGood;
}

-(UIButton *)concernButton
{
    UIButton *btnConcern = [UIButton buttonWithType:UIButtonTypeCustom];
    btnConcern.frame = CGRectMake(120, _currentOffsetY, 80, 30);
    btnConcern.backgroundColor = [[UIColor alloc] initWithRed:0.2 green:0.8 blue:0.0 alpha:1.0];
    [btnConcern setTitle:@"关注 [0]" forState:UIControlStateNormal];
    btnConcern.titleLabel.font = [UIFont fontWithName:@"helvetica" size:12];
    return btnConcern;
}

- (void)isGoodButtonTouched:(id)sender
{
    NSInteger returnValue = [self goodCount:_articleId];
    if (_goodCount==returnValue) {
        _goodCount++;
        UIButton *btntemp = (UIButton *)[_scrollView viewWithTag:101];
        NSString *btnGoodTitle = [NSString stringWithFormat:@"不错 [%d]",_goodCount];
        [btntemp setTitle:btnGoodTitle forState:UIControlStateNormal];
        [self showHUD:@"您已评价成功！"];
    }else if(_goodCount>returnValue)
    {
        [self showHUD:@"您已评价过，不用再评价！"];
    }else{
        [self showHUD:@"评价失败！"];
    }
    [self removeHUD];
}

- (NSUInteger)goodCount:(NSString *)articleId
{
    helper=[[ServiceHelper alloc] initWithDelegate:_serviceHelperDelegate];
    NSMutableArray *arr=[NSMutableArray array];
    [arr addObject:[NSDictionary dictionaryWithObjectsAndKeys:_articleId,@"articleid", nil]];
    NSString *soapMsg=[SoapHelper arrayToDefaultSoapMessage:arr methodName:@"AddArticleClickGood"];
    NSString *returnValue=[helper syncServiceMethod:@"AddArticleClickGood" soapMessage:soapMsg];
    return returnValue.integerValue;
}

- (UIButton *)shareButtonView
{
    UIButton *shareSinaWB = [UIButton buttonWithType:UIButtonTypeCustom];
    shareSinaWB.frame = CGRectMake(210, _currentOffsetY, 80, 30);
    shareSinaWB.tag = 111;
    shareSinaWB.backgroundColor = [[UIColor alloc] initWithRed:0.4 green:0.6 blue:0.0 alpha:1.0];
    [shareSinaWB setTitle:@"分享" forState:UIControlStateNormal];
    shareSinaWB.titleLabel.font = [UIFont fontWithName:@"helvetica" size:12];
    [shareSinaWB addTarget:self action:@selector(shareButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    return shareSinaWB;
}
- (IBAction)shareButtonTouched:(id)sender
{
    NSArray *shareLists = [ShareSDK getShareListWithType:ShareTypeSinaWeibo,
                           ShareTypeSohuWeibo,ShareTypeTencentWeibo,
                           ShareTypeWeixiSession,ShareTypeWeixiTimeline,
                           ShareType163Weibo,ShareTypeQQSpace,
                           ShareTypeDouBan,ShareTypeRenren,
                           ShareTypeKaixin,ShareTypeMail,
                           ShareTypeSMS,nil];
    /*
    ShareTypeSinaWeibo = 1, 新浪微博
	ShareTypeTencentWeibo = 2, 腾讯微博
	ShareTypeSohuWeibo = 3, 搜狐微博 
    ShareType163Weibo = 4, 网易微博 
	ShareTypeDouBan = 5, 豆瓣社区 
	ShareTypeQQSpace = 6, QQ空间 
	ShareTypeRenren = 7, 人人网 
	ShareTypeKaixin = 8, 开心网 
	ShareTypePengyou = 9, 朋友网 
	ShareTypeFacebook = 10, Facebook 
	ShareTypeTwitter = 11, Twitter 
	ShareTypeEvernote = 12, 印象笔记 
	ShareTypeFoursquare = 13, Foursquare 
	ShareTypeGooglePlus = 14, Google＋ 
	ShareTypeInstagram = 15, Instagram 
	ShareTypeLinkedIn = 16, LinkedIn 
	ShareTypeTumbir = 17, Tumbir 
    ShareTypeMail = 18, 邮件分享 
	ShareTypeSMS = 19, 短信分享 
	ShareTypeAirPrint = 20, 打印 
	ShareTypeCopy = 21, 拷贝 
    ShareTypeWeixiSession = 22, 微信好友 
	ShareTypeWeixiTimeline = 23, 微信朋友圈 
    ShareTypeQQ = 24, QQ 
    ShareTypeInstapaper = 25, Instapaper 
    ShareTypePocket = 26, Pocket 
    ShareTypeYouDaoNote = 27, 有道云笔记 
    ShareTypeSohuKan = 28, 搜狐随身看 
    ShareTypeAny = 99 任意平台 
     */
    //创建分享内容
    NSString *urlString = [NSString stringWithFormat:@"http://www.ka7ku.com/ArticleView.aspx?id=%@",_currentArticle.id];
    NSString *imagePath = [NSString stringWithFormat:@"%@/%@",imageCachePath,[_currentArticle.topImg lastPathComponent]];
    NSString *shareContent = [NSString stringWithFormat:@"《%@》 %@  %@", _currentArticle.title,[_currentArticle.daoDu substringToIndex:50],urlString];
    id<ISSContent> publishContent = [ShareSDK content:shareContent
                                       defaultContent:@""
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:_currentArticle.title
                                                  url:urlString
                                          description:@""
                                            mediaType:SSPublishContentMediaTypeNews];
    //创建分享选项
    //id<ISSShareOptions> shareOptions =[ShareSDK customShareListWithType:<#(id), ...#>, nil];
    id<ISSShareOptions> shareOptions = [ShareSDK defaultShareOptionsWithTitle:@"内容分享"
                                                              oneKeyShareList:shareLists qqButtonHidden:YES
                                                        wxSessionButtonHidden:NO
                                                       wxTimelineButtonHidden:NO
                                                         showKeyboardOnAppear:YES
                                                            shareViewDelegate:nil
                                                          friendsViewDelegate:nil
                                                        picViewerViewDelegate:nil];
    //创建分享菜单
    [ShareSDK showShareActionSheet:nil
                         shareList:shareLists
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions:shareOptions
                            result:^(ShareType type,SSPublishContentState state,id<ISSStatusInfo> statusInfo,id<ICMErrorInfo> error,BOOL end){
        if(state == SSPublishContentStateSuccess){
            [self showHUD:@"分享成功！"];
            [self removeHUD];
        }
        else if(state == SSPublishContentStateFail){
            [self showHUD:@"分享失败！"];
            [self removeHUD];
            NSLog(@"分享失败，错误码:%d,错误描述:%@",[error errorCode],[error description]);
        }
    }];
}
//xml 数据解析
- (void)xmlParserWithString:(NSString *)xmlString
{
    _currentArticle = [[Article alloc] init];
    NSError *error;
    NSString *xml = [xmlString stringByDecodingXMLEntities];
    NSData *data = [xml dataUsingEncoding:NSUTF8StringEncoding];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:data options:0 error:&error];
    _currentArticle.title = [[[doc nodesForXPath:@"/article/title" error:&error] objectAtIndex:0] stringValue];
    _currentArticle.addDate = [[[doc nodesForXPath:@"/article/adddate" error:&error] objectAtIndex:0] stringValue];
    _currentArticle.id = [[[doc nodesForXPath:@"/article/id" error:&error] objectAtIndex:0] stringValue];
    _currentArticle.author = [[[doc nodesForXPath:@"/article/author" error:&error] objectAtIndex:0] stringValue];
    _currentArticle.topImg = [[[doc nodesForXPath:@"/article/topimg" error:&error] objectAtIndex:0] stringValue];
    _currentArticle.daoDu = [[[doc nodesForXPath:@"/article/daodu" error:&error] objectAtIndex:0] stringValue];
    NSArray *contentArray = [[[doc nodesForXPath:@"/article/content" error:&error] objectAtIndex:0] children];
    //<p></p>段落节点处理
    NSUInteger pCount = [contentArray count];
    NSMutableArray *pArray = [[NSMutableArray alloc] init];
    //NSMutableString *c = [NSMutableString string];
    if (pCount>0)
    {
        for (NSUInteger i=0; i<pCount; i++) {
            GDataXMLNode *pChild = [contentArray objectAtIndex:i];
            GDataXMLNode *currentNode = [[pChild children] objectAtIndex:0];
            NSString *currentString = [currentNode stringValue];
            if ([currentString hasSuffix:@"<br/>"]||[currentString hasSuffix:@"<BR/>"])
            {
                [currentString substringWithRange: NSMakeRange(0, currentString.length-5)];
            }
            if ([self isSpanNode:currentNode])//<span></span>和<span>嵌套文字的处理
            {
                while ([currentNode childCount]>0)
                {
                    GDataXMLNode *aNode = currentNode;
                    currentNode = [currentNode childAtIndex:0];
                    if([self isImgNode:currentNode])//<img />的处理
                    {
                        if([currentNode childCount] == 0){
                            NSMutableArray *imgArray = [[NSMutableArray alloc] init];
                            NSArray *imgs = [aNode children];
                            for (GDataXMLElement *img in imgs) {
                                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                                NSString *url = [[img attributeForName:@"src"] stringValue];
                                //NSLog(@"%@",url);
                                [dic setObject:url forKey:@"imgURL"];
                                NSString *size = [[img attributeForName:@"style"] stringValue];
                                [dic setObject:size forKey:@"imgSize"];
                                [imgArray addObject:dic];
                            }
                            [pArray addObjectsFromArray:imgArray];
                        }
                        else
                        {
                            //图片<img />还有子节点或者嵌套情况处理
                        }
                    }
                }
                NSString *p = [currentString copy];
                if (![p isEqualToString:@""]) {
                    [pArray addObject:p];
                }
            }else if([self isImgNode:currentNode])//<img />的处理
            {
                if([currentNode childCount] == 0){
                    NSMutableArray *imgArray = [[NSMutableArray alloc] init];
                    NSArray *imgs = [pChild children];
                    for (GDataXMLElement *img in imgs) {
                        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                        NSString *url = [[img attributeForName:@"src"] stringValue];
                        //NSLog(@"%@",url);
                        [dic setObject:url forKey:@"imgURL"];
                        NSString *size = [[img attributeForName:@"style"] stringValue];
                        [dic setObject:size forKey:@"imgSize"];
                        [imgArray addObject:dic];
                    }
                    [pArray addObjectsFromArray:imgArray];
                }
                else
                {
                    //图片<img />还有子节点或者嵌套情况处理
                }
                
            }
            else//既有<span></span>又有图片<img />在一个<p></p>节点内
            {
                
            }
        }
    }
    _pContent = pArray;
    //self.currentArticle.content = c;
}

//判断是否为span节点
- (BOOL)isSpanNode:(GDataXMLNode *)CurrrentNode
{
    if ([[CurrrentNode name] isEqualToString:@"span"]) {
        return YES;
    }
    return NO;
}
//判断是否为img节点
- (BOOL)isImgNode:(GDataXMLNode *)CurrrentNode
{
    if ([[CurrrentNode name] isEqualToString:@"img"]) {
        return YES;
    }
    return NO;
}

- (void)showHUD:(NSString *)msg
{
    _loadingProcess = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_loadingProcess];
    [self.view bringSubviewToFront:_loadingProcess];
    _loadingProcess.delegate = self;
    _loadingProcess.labelText = msg;
    _loadingProcess.dimBackground=NO;
    [_loadingProcess show:YES];
}

- (void)removeHUD
{
    [_loadingProcess hide:YES afterDelay:1.0];
	//[_loadingProcess hide:YES];
    [_loadingProcess removeFromSuperViewOnHide];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
