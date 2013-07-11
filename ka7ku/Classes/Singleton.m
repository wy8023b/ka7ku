//
//  Singleton.m
//  ka7ku
//
//  Created by wangye on 13-6-1.
//  Copyright (c) 2013年 wangye. All rights reserved.
//

#import "Singleton.h"

@implementation Singleton
@synthesize someProperty;

#pragma mark Singleton Methods

static Singleton *sharedInstance_ = nil;

/* Using GCD and ARC
+ (id) sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance_ = [[self alloc] init];
    });
    return sharedInstance_;
}
 
- (id)init
{
 if (self = [super init]) {
 someProperty = @"default property value";
 }
 return self;
}
 
*/

- (id)init
{
    if (self = [super init]) {
        someProperty = @"default property value";
    }
    return self;
}

+ (id)sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance_ == nil) {
            sharedInstance_ = [[super allocWithZone:NULL] init];
        }
        return sharedInstance_;
    }
}
+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedInstance] retain];
}

- (id)copyWithZone
{
    return self;
}

- (id)retain
{
    return self;
}

- (unsigned)retainCount
{
    return UINT_MAX;//denotes an object that cannot be released
}

- (oneway void)release
{
    //never release
}

- (id)autorelease
{
    return self;
}

- (void)dealloc
{
    //should never be called,but just here for clarity really.
    [someProperty release];
    [super dealloc];
}

@end
