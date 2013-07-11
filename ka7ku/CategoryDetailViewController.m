//
//  categoryDetailViewController.m
//  ka7ku
//
//  Created by wangye on 13-5-2.
//  Copyright (c) 2013年 wangye. All rights reserved.
//

#import "CategoryDetailViewController.h"
#import "NewsDetailViewController.h"
#import "SoapHelper.h"
#import "GDataXMLNode.h"
#import "NSString+xmldecoding.h"
#import "EGORefreshTableHeaderView.h"

@interface CategoryDetailViewController ()<EGORefreshTableHeaderDelegate>
{
    EGORefreshTableHeaderView *refreshTableHeaderView;
    BOOL reloading;
}
@property (nonatomic, retain) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic, assign) BOOL reloading;

- (void)reloadTableViewDataSource;//下拉刷新后重新加载tabledata数据
- (void)doneLoadingTableViewData;//下拉刷新重加载数据后，将隐藏刷新区域

@end

@implementation CategoryDetailViewController
@synthesize catogeryId;
@synthesize catogeryName;
@synthesize dataLists;
@synthesize imgLists;
@synthesize loadingProcess = _loadingProcess;
@synthesize refreshTableHeaderView = _refreshTableHeaderView;
@synthesize reloading = _reloading;
@synthesize nav;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.allowsSelection = YES;
    self.tableView.scrollEnabled = YES;
    self.title = self.catogeryName;
    [self initRefreshTableHeaderView];
    [self showHUD:@"数据加载中..."];
    [self requestData];
}

- (void)requestData{
    helper=[[ServiceHelper alloc] initWithDelegate:self];
    NSMutableArray *arr=[NSMutableArray array];
    [arr addObject:[NSDictionary dictionaryWithObjectsAndKeys:self.catogeryId,@"typeid", nil]];
    NSString *soapMsg=[SoapHelper arrayToDefaultSoapMessage:arr methodName:@"GetNewsListByTypeId"];//执行同步并取得结果
    [helper asynServiceMethod:@"GetNewsListByTypeId" soapMessage:soapMsg];
}

- (void)finishSuccessRequest:(NSString *)xml
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSData *data = [[xml stringByDecodingXMLEntities] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *filePath = [path stringByAppendingPathComponent:@"GetNewsListByTypeId.xml"];
    BOOL iSuccess = [self saveXmlToCache:data withPath:filePath];
    if(iSuccess){
    }
    self.dataLists = [self xmlParser:filePath];
    if(self.imgLists.count>0){
        for (int i = 0 ; i<self.imgLists.count; i++) {
            if([self cacheImgWithImgURL:[imgLists objectAtIndex:i]])
            {
                continue;
            }
        }
    }
    [self.tableView reloadData];
    [self removeHUD];//移除动画
}

- (void)finishFailRequest:(NSError *)error
{
    NSLog(@"%@",error);
    [self removeHUD];
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"请求数据失败" message:@"网络请求数据异常！稍后再试!" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil];
    [av show];
    
}

-(void)initRefreshTableHeaderView
{
    if (_refreshTableHeaderView == nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f-self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
        view.delegate = self;
        _refreshTableHeaderView = view;
        [self.tableView addSubview:_refreshTableHeaderView];
    }
}

#pragma mark Data Source Loading / Reloading Methods

-(void)reloadTableViewDataSource{
    
    //  should be calling your tableviews data source model to reload
    //  put here just for demo
    _reloading =YES;
}

-(void)doneLoadingTableViewData{
    
    //  model should call this when its done loading
    _reloading =NO;
    [_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [_refreshTableHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [_refreshTableHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    
    [self reloadTableViewDataSource];//重新加载数据源
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];//3s 实际应用应根据网络请求加载的数据时间为准
    
}

-(BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    
    return _reloading; // should return if data source model is reloading
    
}

-(NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
    return [NSDate date]; // should return date data source was last changed
    
}

//解析网络缓存xml
- (NSArray *)xmlParser:(NSString *)FilePath
{
    if(![[NSFileManager defaultManager] fileExistsAtPath:FilePath]){
        return nil;
    }
    NSData *data = [NSData dataWithContentsOfFile:FilePath];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:data options:0 error:nil];
    //根结点 articles
    GDataXMLElement *rootElement = [doc rootElement];
    //子节点 article
    NSArray *articles = [rootElement children];
    NSMutableArray *needsContent = [[NSMutableArray alloc] init];
    self.imgLists = [[NSMutableArray alloc] init];
    //遍历叶节点查找关键字
    for(int i = 0; i<articles.count;i++)
    {
        GDataXMLElement *article = [articles objectAtIndex:i];
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:[articles count]];
        NSString *id = [[[article elementsForName:@"id"] objectAtIndex:0] stringValue];;
        NSString *title = [[[article elementsForName:@"title"] objectAtIndex:0] stringValue];
        NSString *like = [[[article elementsForName:@"click"] objectAtIndex:0] stringValue];
        NSString *category = self.catogeryName;
        NSString *adddate = [[[article elementsForName:@"adddate"] objectAtIndex:0] stringValue];
        NSString *content = [[[article elementsForName:@"content"] objectAtIndex:0] stringValue];
        NSString *imgURL = [[[article elementsForName:@"topimg"] objectAtIndex:0] stringValue];
        [dic setObject:id forKey:@"id"];
        [dic setObject:title forKey:@"title"];
        [dic setObject:category forKey:@"category"];
        [dic setObject:like forKey:@"like"];
        [dic setObject:adddate forKey:@"adddate"];
        [dic setObject:content forKey:@"content"];
        [self.imgLists addObject:imgURL];
        [needsContent insertObject:dic atIndex:i];
    }
    return needsContent;
}

//存储xml文件到本地缓存
- (BOOL)saveXmlToCache:(NSData *)xmlData withPath:(NSString *)filePath
{
    BOOL iSuccess = NO;
    //NSData *data = [NSData dataWithContentsOfFile:filePath];
    BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    NSError *error = nil;
    if (!fileExist) {
        [xmlData writeToFile:filePath atomically:YES];
        iSuccess = YES;
    }
    else
    {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        [xmlData writeToFile:filePath atomically:YES];
        iSuccess = YES;
    }
    return iSuccess;
}

//图片存储到本地缓存
- (BOOL)cacheImgWithImgURL:(NSString *)imgURL
{
    UIImage *image = [self getImageFromURL:imgURL];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath=[path stringByAppendingPathComponent:[imgURL lastPathComponent]];
    //判断缓存区域是否有该图片缓存
    BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (!fileExist) {
        NSString *fileName = [[imgURL lastPathComponent] stringByDeletingPathExtension];
        NSString *extension = [imgURL pathExtension];
        if ([self saveImage:image withFileName:fileName ofType:extension inDirectory:filePath])
        {
            return YES;
        }
        else{
            return NO;
            NSLog(@"save image %@ failed!!",imgURL);
        }
    }else{
        return YES;
    }
}

-(UIImage *) getImageFromURL:(NSString *)imgURL {
    NSString *imgLocate = [defaultWebSite stringByAppendingFormat:@"%@",imgURL];
    UIImage * result;
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgLocate]];
    result = [UIImage imageWithData:data];
    return result;
}

-(BOOL) saveImage:(UIImage *)image withFileName:(NSString *)imageName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath {
    if ([[extension lowercaseString] isEqualToString:@"png"]) {
        [UIImagePNGRepresentation(image) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"png"]] options:NSAtomicWrite error:nil];
        return YES;
    } else if ([[extension lowercaseString] isEqualToString:@"jpg"] || [[extension lowercaseString] isEqualToString:@"jpeg"]) {
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"jpg"]] options:NSAtomicWrite error:nil];
        return YES;
    } else {
        NSLog(@"文件后缀不认识");
        return NO;
    }
}

-(UIImage *) loadImage:(NSString *)fileName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath {
    UIImage * result = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.%@", directoryPath, fileName, extension]];
    
    return result;
}

- (void)showHUD:(NSString *)msg{
    _loadingProcess = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_loadingProcess];
    [self.view bringSubviewToFront:_loadingProcess];
    _loadingProcess.delegate = self;
    _loadingProcess.labelText = msg;
    _loadingProcess.dimBackground=NO;
    [_loadingProcess show:YES];
    
}
- (void)removeHUD{
	[_loadingProcess hide:YES afterDelay:1.0f];
    [_loadingProcess removeFromSuperViewOnHide];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return self.dataLists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CategoryListCellIdentifier = @"CategoryListCellIdentifier";
    UITableViewCell *CategoryCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CategoryListCellIdentifier];
    [tableView dequeueReusableCellWithIdentifier:CategoryListCellIdentifier];
    NSUInteger row = [indexPath row];
    NSDictionary *rowData = [self.dataLists objectAtIndex:row];
    //cell frame
    CategoryCell.frame = CGRectMake(0,0,320, 120);
    //top img
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 100, 100)];
    NSString *imgURL = [self.imgLists objectAtIndex:row];
    NSString *fliePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [[imgURL lastPathComponent] stringByDeletingPathExtension];
    NSString *extension = [imgURL pathExtension];
    img.image = [self loadImage:fileName ofType:extension inDirectory:fliePath];
    //title label
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(120, 10, 160, 35)];
    labelTitle.font = [UIFont boldSystemFontOfSize:13];
    labelTitle.textAlignment = NSTextAlignmentLeft;
    labelTitle.textColor = [UIColor blueColor];
    labelTitle.numberOfLines = 2;
    labelTitle.lineBreakMode = NSLineBreakByCharWrapping;
    labelTitle.text = [rowData objectForKey:@"title"];
    //content label
    UILabel *labelContent = [[UILabel alloc] initWithFrame:CGRectMake(120, 45, 160, 45)];
    labelContent.font =[UIFont systemFontOfSize:12];
    labelContent.textAlignment = NSTextAlignmentLeft;
    labelContent.numberOfLines = 0;
    labelContent.lineBreakMode = NSLineBreakByCharWrapping;
    labelContent.text = [rowData objectForKey:@"content"];
    //adddate label
    UILabel *labeladddate = [[UILabel alloc] initWithFrame:CGRectMake(120, 95, 160, 15)];
    labeladddate.font =[UIFont systemFontOfSize:12];
    labeladddate.textAlignment = NSTextAlignmentLeft;
    labeladddate.numberOfLines = 0;
    labeladddate.lineBreakMode = NSLineBreakByCharWrapping;
    NSString *category = [rowData objectForKey:@"category"];
    NSString *like = [rowData objectForKey:@"like"];
    labeladddate.text = [NSString stringWithFormat:@"[%@]  %@  %@人喜欢",category,[rowData objectForKey:@"adddate"],like];
    //add into  CategoryCell
    [CategoryCell addSubview:img];
    [CategoryCell addSubview:labelTitle];
    [CategoryCell addSubview:labelContent];
    [CategoryCell addSubview:labeladddate];
    
    CategoryCell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    return CategoryCell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120.0;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
    
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    NSUInteger section = [indexPath section];
    if (section==0) {
        NSUInteger row = [indexPath row];
        NSDictionary *rowData = [self.dataLists objectAtIndex:row];
        NewsDetailViewController *detailView = [[NewsDetailViewController alloc] initWithNibName:@"NewsDetail" bundle:[NSBundle mainBundle]];
        detailView.articleId = [rowData objectForKey:@"id"];
        [self.navigationController pushViewController: detailView animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView
accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self tableView:tableView didSelectRowAtIndexPath:indexPath];
}
@end
