//
//  NSString+COGUAdditions.m
//  iOSDevWeekly
//
//  Created by Colin Günther on 12.08.12.
//  Copyright (c) 2012 Cogun. All rights reserved.
//

#import "NSString+COGUAdditions.h"

@implementation NSString (COGUAdditions)

- (NSString*)cogu_stringByMergingAllDigits;
{
    NSCharacterSet* digitsOnly = [NSCharacterSet decimalDigitCharacterSet];
    return [self stringByTrimmingCharactersInSet:digitsOnly.invertedSet];
}

@end
