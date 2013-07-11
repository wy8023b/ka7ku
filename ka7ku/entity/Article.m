//
//  Article.m
//  ka7ku
//
//  Created by wangye on 13-5-3.
//  Copyright (c) 2013年 wangye. All rights reserved.
//

#import "Article.h"

@implementation Article
@synthesize title = _title;
@synthesize id = _id;
@synthesize topImg = _topImg;
@synthesize daoDu = _daoDu;
@synthesize clickRate = _clickRate;
@synthesize content = _content;
@synthesize addDate = _addDate;
@synthesize author = _author;
@synthesize isGood = _isGood;

- (id)init
{
    if (self = [super init]) {
        self.title = title;
        self.id = id;
        self.addDate = addDate;
        self.author = author;
        self.topImg = topImg;
        self.content = content;
        self.clickRate = clickRate;
        self.daoDu = daoDu;
        self.isGood = isGood;
    }
    return self;
}
@end
