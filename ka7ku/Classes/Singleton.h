//
//  Singleton.h
//  ka7ku
//
//  Created by wangye on 13-6-1.
//  Copyright (c) 2013年 wangye. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Singleton : NSObject
{
    NSString *someProperty;
}

@property (nonatomic,retain) NSString *someProperty;

+ (id)sharedInstance;

@end
