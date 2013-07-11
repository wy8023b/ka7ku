//
//  NSString+xmldecoding.h
//  ka7ku
//
//  Created by wangye on 13-4-28.
//  Copyright (c) 2013年 wangye. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (xmldecoding)
- (NSString *)stringByDecodingXMLEntities;
@end
