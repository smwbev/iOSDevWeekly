//
//  NSObject+COGUAdditions
//  iOSDevWeekly
//
//  Created by Colin Günther on 09.08.12.
//  Copyright (c) 2012 Cogun. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject (COGUAdditions)

@end


#define NSBlockCallSafely(blockname, __VAR_ARGS__) \
do { \
    if (blockname != nil) \
        blockname(__VAR_ARGS__); \
} while (0)


#define NSDereferenceSafely(pointername) \
(pointername == nil ? nil : *pointername)

#define NSDereferenceAndAssignSafely(pointername, value) \
pointername == nil ? nil : (*pointername = (__typeof__(*pointername))value)

// Provided by James Webster on StackOverFlow to allow using boolean literals (@YES and @NO)
// http://stackoverflow.com/a/11686024
#ifndef __IPHONE_6_0
#if __has_feature(objc_bool)
#undef YES
#undef NO
#define YES __objc_yes
#define NO __objc_no
#endif
#endif