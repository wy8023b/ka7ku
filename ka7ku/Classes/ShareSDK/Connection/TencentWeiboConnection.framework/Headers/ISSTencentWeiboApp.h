//
//  Created by ShareSDK.cn on 13-1-14.
//  官网地址:http://www.ShareSDK.cn
//  技术支持邮箱:support@sharesdk.cn
//  官方微信:ShareSDK   （如果发布新版本的话，我们将会第一时间通过微信将版本更新内容推送给您。如果使用过程中有任何问题，也可以通过微信与我们取得联系，我们将会在24小时内给予回复）
//  商务QQ:4006852216
//  Copyright (c) 2013年 ShareSDK.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ShareSDKCoreService/ShareSDKCoreService.h>
#import "ISSTencentWeiboAuthSession.h"
#import "SSTencentWeiboUser.h"
#import "SSTencentWeiboErrorInfo.h"
#import "SSTencentWeiboTweet.h"

/**
 *	@brief	新浪微博请求方式
 */
typedef enum
{
	SSTecentWeiboRequestMethodGet = 0, /**< GET方式 */
	SSTecentWeiboRequestMethodPost = 1, /**< POST方式 */
	SSTecentWeiboRequestMethodMultipartPost = 2 /**< Multipart POST方式，用于上传文件的api接口 */
}
SSTecentWeiboRequestMethod;

@protocol ISSTencentWeiboApp <ISSCOpenApp>

/**
 *	@brief	获取授权帐号
 *
 *	@return	授权帐号
 */
- (id<ISSCAccount>)account;

/**
 *	@brief	获取应用Key
 *
 *	@return	应用Key
 */
- (NSString *)appKey;

/**
 *	@brief	获取应用密钥
 *
 *	@return	应用密钥
 */
- (NSString *)appSecret;

/**
 *	@brief	获取应用回调地址
 *
 *	@return	应用回调地址
 */
- (NSString *)redirectUri;

/**
 *	@brief	授权应用
 *
 *	@return	授权会话
 */
- (id<ISSTencentWeiboAuthSession>)authorize;

/**
 *	@brief	注册用户信息
 *
 *	@param 	user 	用户信息
 *
 *	@return	YES 表示注册成功， NO 表示注册失败
 */
- (BOOL)registerUser:(SSTencentWeiboUser *)user;

/**
 *	@brief	注销用户信息
 *
 *	@param 	user 	用户信息
 *
 *	@return	YES 表示注销成功， NO 表示注销失败
 */
- (BOOL)unregisterUser:(SSTencentWeiboUser *)user;

/**
 *	@brief	获取注册用户信息
 *
 *	@param 	uid 	用户ID
 *
 *	@return	返回用户信息，nil表示尚未注册
 */
- (SSTencentWeiboUser *)getUser:(NSString *)uid;

/**
 *	@brief	获取默认注册用户
 *
 *	@return	默认注册用户
 */
- (SSTencentWeiboUser *)defaultUser;

/**
 *	@brief	设置默认注册用户
 *
 *	@param 	defaultUser 	默认注册用户
 */
- (void)setDefaultUser:(SSTencentWeiboUser *)defaultUser;

/**
 *	@brief	检测用户是否已授权
 *
 *	@param 	error 	错误信息
 *
 *	@return	YES 表示没有授权，NO 表示已授权
 */
- (BOOL)checkUnauthWithError:(SSTencentWeiboErrorInfo *)error;

/**
 *	@brief	设置凭证
 *
 *	@param 	credential 	授权凭证信息
 */
- (void)setCredential:(SSTencentWeiboCredential *)credential;

/**
 *	@brief	调用开放平台API
 *
 *	@param 	path 	路径
 *	@param 	params 	请求参数
 *  @param  user    授权用户,如果传入nil则表示默认的授权用户
 *  @param  result  返回回调
 *  @param  fault   失败回调
 */
- (void)api:(NSString *)path
     method:(SSTecentWeiboRequestMethod)method
     params:(id<ISSCParameters>)params
       user:(SSTencentWeiboUser *)user
     result:(void(^)(id responder))result
      fault:(void(^)(SSTencentWeiboErrorInfo *error))fault;

/**
 *	@brief	显示默认授权用户信息
 *
 *  @param  result  回调方法
 */
- (void)showMe:(void(^)(BOOL result, SSTencentWeiboUser *userInfo, SSTencentWeiboErrorInfo *error))result;

/**
 *	@brief	获取用户信息
 *
 *	@param 	openid 	openId
 *  @param  result  回调方法
 */
- (void)showUserInfoWithOpenid:(NSString *)openid
                        result:(void(^)(BOOL result, SSTencentWeiboUser *userInfo, SSTencentWeiboErrorInfo *error))result;

/**
 *	@brief	获取用户信息
 *
 *	@param 	name 	用户昵称
 *  @param  result  回调方法
 */
- (void)showUserInfoWithName:(NSString *)name
                      result:(void(^)(BOOL result, SSTencentWeiboUser *userInfo, SSTencentWeiboErrorInfo *error))result;


/**
 *	@brief	发送普通微博信息
 *
 *	@param 	content 	内容
 *  @param  result  回调方法
 */
- (void)addTweetWithContent:(NSString *)content
                     result:(void(^)(SSCShareSessionState state, SSTencentWeiboTweet *tweet, SSTencentWeiboErrorInfo *error))result;

/**
 *	@brief	发送带有图片的微博信息
 *
 *	@param 	content 	内容
 *	@param 	pic 	图片
 *  @param  result  回调方法
 */
- (void)addPicTweetWithContent:(NSString *)content
                           pic:(id<ISSCAttachment>)pic
                        result:(void(^)(SSCShareSessionState state, SSTencentWeiboTweet *tweet, SSTencentWeiboErrorInfo *error))result;

/**
 *	@brief	获取偶像列表
 *
 *	@param 	startIndex 	起始位置（第一页:填0，继续向下翻页：填【reqnum*（page-1）】）
 *	@param 	reqnum 	请求个数(1-30)
 */
- (void)idollistWithStartIndex:(NSInteger)startIndex
                        reqnum:(NSInteger)reqnum
                        result:(void(^)(BOOL result, NSArray *users, BOOL hasNext, SSTencentWeiboErrorInfo *error))result;


/**
 *	@brief	收听某用户
 *
 *	@param 	name 	用户名称
 *  @param  result  返回回调
 */
- (void)addFriendWithName:(NSString *)name
                   result:(void(^)(BOOL result, SSTencentWeiboErrorInfo *error))result;

/**
 *	@brief	收听某用户
 *
 *	@param 	openid 	用户id
 *  @param  result  返回回调
 */
- (void)addFriendWithOpenId:(NSString *)openid
                     result:(void(^)(BOOL result, SSTencentWeiboErrorInfo *error))result;


@end
