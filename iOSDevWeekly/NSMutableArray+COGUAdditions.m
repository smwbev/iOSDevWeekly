//
//  NSMutableArray+COGUAdditions.m
//  iOSDevWeekly
//
//  Created by Colin Günther on 10.08.12.
//  Copyright (c) 2012 Cogun. All rights reserved.
//


#import "NSMutableArray+COGUAdditions.h"


@implementation NSMutableArray (COGUAdditions)

- (void)cogu_addObjectOrNil:(id)anObject;
{
    if (anObject == nil)
        return;

    [self addObject:anObject];
}


- (void)cogu_replaceObject:(id)oldObject withObject:(id)anObject;
{
    NSUInteger indexOfObjectToBeReplaced = [self indexOfObject:oldObject];
    if (indexOfObjectToBeReplaced == NSNotFound)
        return;

    [self replaceObjectAtIndex:indexOfObjectToBeReplaced withObject:anObject];
}

@end
