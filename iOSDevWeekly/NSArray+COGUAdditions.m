//
//  NSArray+COGUAdditions.m
//  iOSDevWeekly
//
//  Created by Colin Günther on 10.08.12.
//  Copyright (c) 2012 Cogun. All rights reserved.
//


#import "NSArray+COGUAdditions.h"

#import "NSMutableArray+COGUAdditions.h"


@implementation NSArray (COGUAdditions)


- (id)cogu_firstObjectPassingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate;
{
    NSUInteger indexOfFirstObjectPassingTest = [self indexOfObjectPassingTest:predicate];
    
    if (indexOfFirstObjectPassingTest == NSNotFound)
        return nil;

    id firstObjectPassingTest = [self objectAtIndex:indexOfFirstObjectPassingTest];
    return firstObjectPassingTest;
}


- (NSArray*)cogu_filteredArrayUsingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate;
{
    NSArray* filteredArray = [self cogu_mappedArrayUsingBlock:^id(id obj, NSUInteger idx, BOOL *stop) {
        return predicate(obj, idx, stop) ? obj : nil;
    }];

    return filteredArray;
}


- (NSArray*)cogu_mappedArrayUsingBlock:(id (^)(id obj, NSUInteger idx, BOOL *stop))mapper;
{
    NSMutableArray* mappedArray = [NSMutableArray arrayWithCapacity:self.count];

    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [mappedArray cogu_addObjectOrNil:mapper(obj, idx, stop)];
    }];

    return [NSArray arrayWithArray:mappedArray];
}


- (id)cogu_firstObject;
{
    return self.count == 0 ? nil : [self objectAtIndex:0];
}


#if !defined(__IPHONE_6_0) || __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
- (id)objectAtIndexedSubscript:(NSUInteger)idx;
{
    return [self objectAtIndex:idx];
}
#endif

@end
