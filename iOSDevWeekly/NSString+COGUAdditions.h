//
//  NSString+COGUAdditions.h
//  iOSDevWeekly
//
//  Created by Colin Günther on 12.08.12.
//  Copyright (c) 2012 Cogun. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface NSString (COGUAdditions)

/*!
 @brief Merges all digits in a string to form a new string consisting of one consecutive number.
 @discussion This method creates a new string that contains all digits contained in the receiver. The ordering of the digits will be untouched.
 @example @"26th octobre of 2012" -> @"262012"
 @example @"3.141" -> @"3141"
 @return A new string containing only digits. If there are no digits in the receiver an empty string will be returned.
*/
- (NSString*)cogu_stringByMergingAllDigits;

@end
