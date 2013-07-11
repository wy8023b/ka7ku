//
//  Article.h
//  ka7ku
//
//  Created by wangye on 13-5-3.
//  Copyright (c) 2013年 wangye. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Article : NSObject
{
    NSString *title;
    NSString *id;
    NSString *topImg;
    NSString *author;
    NSString *addDate;
    NSString *daoDu;
    NSString *content;
    NSString *clickRate;
    bool isGood;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *id;
@property (nonatomic, retain) NSString *topImg;
@property (nonatomic, retain) NSString *author;
@property (nonatomic, retain) NSString *addDate;
@property (nonatomic, retain) NSString *daoDu;
@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) NSString *clickRate;
@property (nonatomic, assign) bool isGood;

- (id)init;
@end
