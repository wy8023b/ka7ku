//
//  NSString+xmldecoding.m
//  ka7ku
//
//  Created by wangye on 13-4-28.
//  Copyright (c) 2013年 wangye. All rights reserved.
//

#import "NSString+xmldecoding.h"

@implementation NSString (xmldecoding)

- (NSString *)stringByDecodingXMLEntities {
    
    NSUInteger myLength = [self length];
    NSUInteger ampIndex = [self rangeOfString:@"&" options:NSLiteralSearch].location;
    
    // Short-circuit if there are no ampersands.
    if (ampIndex == NSNotFound) {
        return self;
    }
    // Make result string with some extra capacity.
    
    NSMutableString *result = [NSMutableString stringWithCapacity:(myLength * 1.25)];
    // First iteration doesn't need to scan to & since we did that already, but for code simplicity's sake we'll do it again with the scanner.
    NSScanner *scanner = [NSScanner scannerWithString:self];
    
    [scanner setCharactersToBeSkipped:nil];
    
    NSCharacterSet *boundaryCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@" \t\n\r;"];
    
    do {
        // Scan up to the next entity or the end of the string.
        NSString *nonEntityString;
        if ([scanner scanUpToString:@"&" intoString:&nonEntityString]) {
            [result appendString:nonEntityString];
        }
        if ([scanner isAtEnd]) {
            return result;
        }
        // Scan either a HTML or numeric character entity reference.
        if ([scanner scanString:@"&middot;" intoString:NULL])
            [result appendString:@"*"];
        else if ([scanner scanString:@"&mdash;" intoString:NULL])
            [result appendString:@"-"];
        else if ([scanner scanString:@"&amp;" intoString:NULL])
            [result appendString:@"&"];
        else if ([scanner scanString:@"&apos;" intoString:NULL])
            [result appendString:@"'"];
        else if ([scanner scanString:@"&ldquo;" intoString:NULL])
            [result appendString:@"\""];
        else if ([scanner scanString:@"&rdquo;" intoString:NULL])
            [result appendString:@"\""];
        else if ([scanner scanString:@"&nbsp;" intoString:NULL])
            [result appendString:@""];
        else if ([scanner scanString:@"&hellip;" intoString:NULL])
            [result appendString:@"..."];
        else if ([scanner scanString:@"&lt;" intoString:NULL])
             [result appendString:@"<"];
        else if ([scanner scanString:@"&gt;" intoString:NULL])
             [result appendString:@">"];
        else if ([scanner scanString:@"&#" intoString:NULL]) {
                 BOOL gotNumber;
                 unsigned charCode;
                 NSString *xForHex = @"";
                 
                 // Is it hex or decimal?
                 if ([scanner scanString:@"x" intoString:&xForHex]) {
                     gotNumber = [scanner scanHexInt:&charCode];
                 }
                 else {
                     gotNumber = [scanner scanInt:(int*)&charCode];
                 }
                 
                 if (gotNumber) {
                     [result appendFormat:@"%u", charCode];
                     
                     [scanner scanString:@";" intoString:NULL];
                 }
                 else {
                     NSString *unknownEntity = @"";
                     
                     [scanner scanUpToCharactersFromSet:boundaryCharacterSet intoString:&unknownEntity];
                     
                     
                     [result appendFormat:@"&#%@%@", xForHex, unknownEntity];
                     
                     //[scanner scanUpToString:@";" intoString:&unknownEntity];
                     //[result appendFormat:@"&#%@%@;", xForHex, unknownEntity];
                     NSLog(@"Expected numeric character entity but got &#%@%@;", xForHex, unknownEntity);
                     
                 }
                 
             }
             else {
                 NSString *amp;
                 
                 [scanner scanString:@"&" intoString:&amp];      //an isolated & symbol
                 [result appendString:amp];
                 
                 
             }
             
             }
             while (![scanner isAtEnd]);
             
             return result;
             }
@end
