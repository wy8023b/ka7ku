//
//  CategoryViewController.m
//  tabbarNav
//
//  Created by wangye on 13-4-22.
//  Copyright (c) 2013年 wangye. All rights reserved.
//

#import "CategoryViewController.h"
#import "SoapHelper.h"
#import "GDataXMLNode.h"
#import "NSString+xmldecoding.h"
#import "NewsDetailViewController.h"
#import "CategoryDetailViewController.h"

@interface CategoryViewController ()

@end

@implementation CategoryViewController
@synthesize dataLists;
@synthesize imgLists;
@synthesize loadingProcess=_loadingProcess;

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//
//    }
//    return self;
//}
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
    //[super viewDidLoad];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.allowsSelection = YES;
    self.tableView.scrollEnabled = YES;
    self.title = @"分类";
    helper=[[ServiceHelper alloc] initWithDelegate:self];
    [self showHUD:@"loading data..."];//显示动画
    //NSMutableArray *arr=[NSMutableArray array];
    //[arr addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"123",@"Id", nil]];
    //NSString *soapMsg=[SoapHelper arrayToDefaultSoapMessage:arr methodName:@"GetTypes"];//GetCategoryList
    //执行同步并取得结果
    //NSString *xml=[helper syncServiceMethod:@"GetTypes" soapMessage:soapMsg];//stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //NSData *data = [[xml stringByDecodingXMLEntities] dataUsingEncoding:NSUTF8StringEncoding];
    //NSString *filePath = [path stringByAppendingPathComponent:@"GetCategorys.xml"];
    //BOOL iSuccess = [self saveXmlToCache:data withPath:filePath];
    //if(iSuccess){
        //NSLog(@"下载并存储xml成功！");
        //NSLog(@"%@",filePath);
        //NSLog(@"%@",[xml stringByDecodingXMLEntities]);
    //}
    /*服务端分类xml没有根节点 需要增加<channels></channels>,这里临时用本地xml结构替代*/
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"GetCategorys" ofType:@"xml"];
    self.dataLists = [self xmlParser:filePath];
    //self.dataLists = [self xmlParser];
    if(self.imgLists.count>0){
        //NSLog(@"解析xml成功！");
        for (int i = 0 ; i<self.imgLists.count; i++) {
            if([self cacheImgWithImgURL:[imgLists objectAtIndex:i]])
            {
                continue;
            }
        }
    }
    [self removeHUD];//移除动画
    // Do any additional setup after loading the view from its nib.
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
    //根结点 channels
    GDataXMLElement *rootElement = [doc rootElement];
    //子节点 channel
    NSArray *channels = [rootElement children];
    NSMutableArray *needsContent = [[NSMutableArray alloc] init];
    self.imgLists = [[NSMutableArray alloc] init];
    //遍历叶节点查找关键字
    /*<?xml version="1.0" encoding="utf-8"?>
     <channel>
     <id>19</id>
     <imgUrl>/UpLoadFiles/20130409/2013040915542317.png</imgUrl>
     <title>It健康</title>
     <memo>健身、疾病、心理等健康信息</memo>
     </channel>
     <channel>
     <id>20</id>
     <imgUrl>/UpLoadFiles/20130409/2013040915564628.png</imgUrl>
     <title>It人物</title>
     <memo>从事IT行业的具有影响的人物介绍、以及其成功的经验历</memo>
     </channel>
     <channel>
     <id>48</id>
     <imgUrl>/UpLoadFiles/20130409/2013040915572389.png</imgUrl>
     <title>It幽默</title><memo>休闲娱乐幽默的IT事、IT人、IT的幽默主角...</memo>
     </channel>
     <channel>
     <id>50</id>
     <imgUrl>/UpLoadFiles/20130409/2013040916040356.png</imgUrl>
     <title>It新闻</title>
     <memo>从新IT行业的新闻资讯内容</memo>
     </channel>
     <channel>
     <id>56</id>
     <imgUrl>/UpLoadFiles/20130409/2013040916043010.png</imgUrl>
     <title>It励志</title>
     <memo>It平凡人生、自己的奋斗、拼搏，一样精彩...</memo>
     </channel>
     <channel>
     <id>24</id>
     <imgUrl>/UpLoadFiles/20130409/2013040916053932.png</imgUrl>
     <title>It产品</title>
     <memo>产品、IT周边的最新动态和介绍...</memo>
     </channel>*/
    for(int i = 0; i<channels.count;i++)
    {
        GDataXMLElement *channel = [channels objectAtIndex:i];
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:[channels count]];
        NSString *id = [[[channel elementsForName:@"id"] objectAtIndex:0] stringValue];;
        NSString *title = [[[channel elementsForName:@"title"] objectAtIndex:0] stringValue];
        NSString *memo = [[[channel elementsForName:@"memo"] objectAtIndex:0] stringValue];
        NSString *imgURL = [[[channel elementsForName:@"imgUrl"] objectAtIndex:0] stringValue];
        [dic setObject:id forKey:@"id"];
        [dic setObject:title forKey:@"title"];
        [dic setObject:memo forKey:@"memo"];
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
    _loadingProcess.dimBackground=YES;
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
#pragma mark Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataLists count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CategoryCellIdentifier = @"CategoryCellIdentifier";
    UITableViewCell *CategoryCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CategoryCellIdentifier];
    [tableView dequeueReusableCellWithIdentifier:CategoryCellIdentifier];
    NSUInteger row = [indexPath row];
    NSDictionary *rowData = [self.dataLists objectAtIndex:row];
    //create table cell
    CategoryCell.frame = CGRectMake(0,0,320, 100);
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 100, 100)];
    NSString *imgURL = [self.imgLists objectAtIndex:row];
    NSString *fliePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [[imgURL lastPathComponent] stringByDeletingPathExtension];
    NSString *extension = [imgURL pathExtension];
    img.image = [self loadImage:fileName ofType:extension inDirectory:fliePath];
    
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(120, 20, 160, 30)];
    labelTitle.font = [UIFont boldSystemFontOfSize:15];
    labelTitle.textColor = [UIColor blueColor];
    labelTitle.text = [rowData objectForKey:@"title"];
    UILabel *labelContent = [[UILabel alloc] initWithFrame:CGRectMake(120, 50, 160, 40)];
    labelContent.font =[UIFont systemFontOfSize:13];
    labelContent.text = [rowData objectForKey:@"memo"];
    labelContent.numberOfLines = 0;
    labelContent.lineBreakMode = NSLineBreakByCharWrapping;
    
    [CategoryCell addSubview:labelTitle];
    [CategoryCell addSubview:labelContent];
    [CategoryCell addSubview:img];
    CategoryCell.selectionStyle = UITableViewCellSelectionStyleNone;
    CategoryCell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    return CategoryCell;
}
#pragma mark Table Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 110.0;
}

//- (NSIndexPath *)tableView:(UITableView *)tableView
//  willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    return nil;
//}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger section = [indexPath section];
    if (section==0) {
        NSUInteger row = [indexPath row];
        NSDictionary *rowData = [self.dataLists objectAtIndex:row];
        CategoryDetailViewController *detailView = [[CategoryDetailViewController alloc] initWithNibName:@"CategoryDetail" bundle:[NSBundle mainBundle]];
        detailView.catogeryId = [rowData objectForKey:@"id"];
        detailView.catogeryName =[rowData objectForKey:@"title"];
        [self.navigationController pushViewController: detailView animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView
accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self tableView:tableView didSelectRowAtIndexPath:indexPath];
}
@end
