//
//  NewsViewController.m
//  tabbarNav
//
//  Created by wangye on 13-4-22.
//  Copyright (c) 2013年 wangye. All rights reserved.
//
#import "NewsViewController.h"
#import "CustomCell.h"
#import "SoapHelper.h"
#import "GDataXMLNode.h"
#import "NSString+xmldecoding.h"
#import "NewsDetailViewController.h"

@interface NewsViewController ()

@end

@implementation NewsViewController
@synthesize dataLists;
@synthesize imgLists;
@synthesize loadingProcess=_loadingProcess;
@synthesize helper = _helper;
@synthesize refreshTableHeaderView=_refreshTableHeaderView;
@synthesize reloading = _reloading;
//@synthesize searchBar;

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
    self.title = @"新闻";
    [self initRefreshHeader];
    [self initSearchBar];
    _helper=[[ServiceHelper alloc] initWithDelegate:self];
    [self showHUD:@"数据加载中..."];//显示动画
    [self requestXmlData];
    //[self removeHUD];//移除动画
}
#pragma mark -
#pragma mark 异步请求结果
-(void)requestXmlData
{
    NSMutableArray *arr=[NSMutableArray array];
    [arr addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"123",@"Id", nil]];
    NSString *soapMsg=[SoapHelper arrayToDefaultSoapMessage:arr methodName:@"GetNewsList"];
    [_helper asynServiceMethod:@"GetNewsList" soapMessage:soapMsg];
}
-(void)finishSuccessRequest:(NSString *)xml
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSData *data = [[xml stringByDecodingXMLEntities] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *filePath = [path stringByAppendingPathComponent:@"GetNewsList.xml"];
    BOOL iSuccess = [self saveXmlToCache:data withPath:filePath];
    if(iSuccess){
        self.dataLists = [self xmlParser:filePath];
        if(self.imgLists.count>0){
            for (int i = 0 ; i<self.imgLists.count; i++) {
                if([self cacheImgWithImgURL:[imgLists objectAtIndex:i]])
                {
                    continue;
                }
            }
        }
    }
    [self.tableView reloadData];
    [self removeHUD];
}

- (void)finishFailRequest:(NSError *)error
{
    NSLog(@"%@",error);
    [self removeHUD];
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"请求数据失败" message:@"网络请求数据异常！稍后再试!" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil];
    [av show];
    
}
//初始化刷新区域位置
- (void)initRefreshHeader{
    if(_refreshTableHeaderView ==nil){
        
        EGORefreshTableHeaderView *view =[[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
        view.delegate = self;
        [self.tableView addSubview:view];
        _refreshTableHeaderView = view;
    }
    //  update the last update date
    [_refreshTableHeaderView refreshLastUpdatedDate];
}
#pragma mark Data Source Loading / Reloading Methods

-(void)reloadTableViewDataSource{
    
    //  should be calling your tableviews data source model to reload
    //  put here just for demo
    [self requestXmlData];
    //[self.tableView reloadData];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        NSString *category =@"IT励志";
        NSString *like = [[[article elementsForName:@"click"] objectAtIndex:0] stringValue];
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
        //if([self cacheImgWithImgURL:imgURL]){
        //    [dic setObject:imgURL forKey:@"imgURL"];}
        //else{
        //    [dic setObject:@"defaultImag.jpg" forKey:@"imgURL"];
        //}
        [needsContent insertObject:dic atIndex:i];
    }
    return needsContent;
}

//解析本地xml
- (NSArray *)xmlParser
{
    NSString *fliePath = [[NSBundle mainBundle] pathForResource:@"GetNewsList" ofType:@"xml"];
    NSData *data = [NSData dataWithContentsOfFile:fliePath];
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
        NSString *adddate = [[[article elementsForName:@"adddate"] objectAtIndex:0] stringValue];
        NSString *category =@"IT励志";
        NSString *like = [[[article elementsForName:@"click"] objectAtIndex:0] stringValue];
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
	[_loadingProcess hide:YES];
    [_loadingProcess removeFromSuperViewOnHide];
}

//图片存储到本地缓存
- (BOOL)cacheImgWithImgURL:(NSString *)imgURL
{
    UIImage *image = [self getImageFromURL:imgURL];
    NSString *fliePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [[imgURL lastPathComponent] stringByDeletingPathExtension];
    NSString *extension = [imgURL pathExtension];
    if ([self saveImage:image withFileName:fileName ofType:extension inDirectory:fliePath])
    {return YES;}
    else
    {return NO;}
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

#pragma mark -
#pragma mark SearchBar Method

- (void)initSearchBar
{
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame: CGRectMake(0.0, 0.0, self.view.bounds.size.width, 40)];
    searchBar.placeholder=@"Enter Name";
    searchBar.delegate = self;
    self.tableView.tableHeaderView = searchBar;
    searchBar.keyboardType = UIKeyboardTypeDefault;
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [self.view addSubview:searchBar];
    /*用于修改serachBar的背景图片
    UIImage *img = [[UIImage imageNamed: @"searchBar_bg.png"]stretchableImageWithLeftCapWidth:0 topCapHeight:22];
    UIImageView *v = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
    [v setImage:img];
    v.bounds = CGRectMake(0, 0, searchbar.frame.size.width, searchbar.frame.size.height);
    
    NSArray *subs = searchbar.subviews;
    for (int i = 0; i < [subs count]; i++) {
        id subv = [searchbar.subviews objectAtIndex:i];
        if ([subv isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
        {
            CGRect viewRect = [subv frame];
            [v setFrame:viewRect];
            [searchbar insertSubview:v atIndex:i];
        }
    }
     */
}
/*开始输入检索关键字*/
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    searchBar.showsCancelButton = YES;
    for(id cc in [searchBar subviews])
    {
        if([cc isKindOfClass:[UIButton class]])
        {
            UIButton *sbtn = (UIButton *)cc;
            [sbtn setTitle:@"取消"  forState:UIControlStateNormal];
            //[sbtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
    }
    self.tableView.allowsSelection = NO;
    self.tableView.scrollEnabled = NO;
    [self searchBar:searchBar activate:YES];
}

/*输入检索关键字结束*/
-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    self.tableView.allowsSelection = YES;
    self.tableView.scrollEnabled = YES;
}

/*取消按钮*/
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    searchBar.text=@"";
    self.tableView.allowsSelection = YES;
    self.tableView.scrollEnabled = YES;
    [self searchBar:searchBar activate:NO];
    
}

- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText {
    // We don't want to do anything until the user clicks
    // the 'Search' button.
    // If you wanted to display results as the user types
    // you would do that here.
}
/*键盘搜索按钮*/
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    // Do the search and show the results in tableview
    // Deactivate the UISearchBar
    
    // You'll probably want to do this on another thread
    // SomeService is just a dummy class representing some
    // api that you are using to do the search
    //数据查询处理
    //NSArray *results = [SomeService doSearch:searchBar.text];
    
    //[self searchBar:searchBar activate:NO];
    
    //[self.tableData removeAllObjects];
    //[self.tableData addObjectsFromArray:results];
    //[self.tableView reloadData];
    [self doSearch:searchBar];
}
//搜索遮蔽特效
- (void)searchBar:(UISearchBar *)searchBar activate:(BOOL) active{
    if (!active) {
        [self.disableViewOverlay removeFromSuperview];
        [searchBar resignFirstResponder];
    } else {
        self.disableViewOverlay = [[UIView alloc]
                                   initWithFrame:CGRectMake(0.0f,40.0f,320.0f,416.0f)];
        self.disableViewOverlay.backgroundColor=[UIColor blackColor];
        self.disableViewOverlay.alpha = 0;
        [self.view addSubview:self.disableViewOverlay];
        
        [UIView beginAnimations:@"FadeIn" context:nil];
        [UIView setAnimationDuration:0.5];
        self.disableViewOverlay.alpha = 0.6;
        [UIView commitAnimations];
    }
    [searchBar setShowsCancelButton:active animated:YES];
}

/*搜索*/
- (void)doSearch:(UISearchBar *)searchBar{
    //...
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"信息查询" message:@"抱歉，查询功能尚未开通！谢谢！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"好", nil];
    [alert show];
    
}

#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataLists count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CustomCellIdentifier = @"CustomCellIdentifier";
    
    static BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:@"CustomCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CustomCellIdentifier];
        nibsRegistered = YES;
    }
    
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    CGSize labelSize = [cell.contentLabel.text
                        sizeWithFont:[UIFont systemFontOfSize:12]
                                   constrainedToSize:CGSizeMake(160, 45)
                                       lineBreakMode:NSLineBreakByCharWrapping];
    cell.contentLabel.numberOfLines = 0;//表示label可以多行显示    
    cell.contentLabel.lineBreakMode = NSLineBreakByCharWrapping;//换行模式，与上面的计算保持一致。
    cell.contentLabel.frame = CGRectMake(cell.contentLabel.frame.origin.x, cell.contentLabel.frame.origin.y, cell.contentLabel.frame.size.width, labelSize.height);//保持原来Label的位置和宽度，只是改变高度。
    
    NSUInteger row = [indexPath row];
    NSDictionary *rowData = [self.dataLists objectAtIndex:row];
    NSString *category = [rowData objectForKey:@"category"];
    NSString *like = [rowData objectForKey:@"like"];
    cell.addDate = [NSString stringWithFormat:@"[%@]  %@  %@人喜欢",category,[rowData objectForKey:@"adddate"],like];
    cell.title = [rowData objectForKey:@"title"];    
    cell.content = [rowData objectForKey:@"content"];
    NSString *imgURL = [self.imgLists objectAtIndex:row];
    NSString *fliePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [[imgURL lastPathComponent] stringByDeletingPathExtension];
    NSString *extension = [imgURL pathExtension];
    cell.image = [self loadImage:fileName ofType:extension inDirectory:fliePath];
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    return cell;
}
#pragma mark Table Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120.0;
}

//- (NSIndexPath *)tableView:(UITableView *)tableView
//  willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    return nil;
//}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
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
@end
