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


- (void)cogu_addObject:(id)anObject times:(NSUInteger)times;
{
    for (NSUInteger i = 0; i < times; i++)
        [self addObject:anObject];
}


- (id)cogu_objectAtLazyInitializedIndex:(NSUInteger)index defaultObject:(id)defaultObject;
{
    NSUInteger objectCount = self.count;
    if (index >= objectCount) {
        [self cogu_replaceObjectAtLazyInitializedIndex:index withObject:defaultObject];
        return defaultObject;
    }

    id object = [self objectAtIndex:index];
    if (object != [NSNull null])
        return object;

    [self cogu_replaceObjectAtLazyInitializedIndex:index withObject:defaultObject];
    return defaultObject;
}


- (void)cogu_replaceObjectAtLazyInitializedIndex:(NSUInteger)index withObject:(id)anObject;
{
    NSUInteger objectCount = self.count;
    if (index < objectCount)
        return [self replaceObjectAtIndex:index withObject:anObject];

    NSUInteger placeholderObjectCount = index - objectCount;
    id placeholderObject = [NSNull null];
    [self cogu_addObject:placeholderObject times:placeholderObjectCount];

    [self insertObject:anObject atIndex:index];
}


- (id)cogu_objectAtLazyInitializedIndexPath:(NSIndexPath*)indexPath defaultObject:(id)defaultObject;
{
    NSUInteger numberOfSubArrays = indexPath.length - 1;
    NSMutableArray* subArray = self;
    for (NSUInteger indexPosition = 0; indexPosition < numberOfSubArrays; indexPosition++)
        subArray = [subArray cogu_objectAtLazyInitializedIndex:[indexPath indexAtPosition:indexPosition] defaultObject:[NSMutableArray array]];

    id object = [subArray cogu_objectAtLazyInitializedIndex:[indexPath indexAtPosition:numberOfSubArrays] defaultObject:defaultObject];

    return object;
}


- (void)cogu_replaceObjectAtLazyInitializedIndexPath:(NSIndexPath*)indexPath withObject:(id)anObject;
{
    NSUInteger numberOfSubArrays = indexPath.length - 1;
    NSMutableArray* subArray = self;
    for (NSUInteger indexPosition = 0; indexPosition < numberOfSubArrays; indexPosition++)
        subArray = [subArray cogu_objectAtLazyInitializedIndex:[indexPath indexAtPosition:indexPosition] defaultObject:[NSMutableArray array]];

    [subArray cogu_replaceObjectAtLazyInitializedIndex:[indexPath indexAtPosition:numberOfSubArrays] withObject:anObject];
}

@end
