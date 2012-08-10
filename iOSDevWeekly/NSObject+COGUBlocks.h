//
//  NSObject+COGUBlocks.h
//  iOSDevWeekly
//
//  Created by Colin Günther on 09.08.12.
//  Copyright (c) 2012 Cogun. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject (COGUBlocks)

@end


#define NSBlockCallSafely(blockname, __VAR_ARGS__) \
do { \
    if (blockname != nil) \
        blockname(__VAR_ARGS__); \
} while (0)
    