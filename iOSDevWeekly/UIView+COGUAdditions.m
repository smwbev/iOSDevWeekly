//
//  UIView+COGUAdditions.m
//  iOSDevWeekly
//
//  Created by Colin Günther on 16.10.12.
//  Copyright (c) 2012 Cogun. All rights reserved.
//


#import "UIView+COGUAdditions.h"


@implementation UIView (COGUAdditions)

- (NSArray*)cogu_subviewsConformingToProtocol:(Protocol*)protocol;
{
    NSMutableArray* subviewsConformingToProtocol = [NSMutableArray array];

    [self cogu_enumerateSubviewsDepthFirstUsingBlock:^(UIView* subview, BOOL* stop) {
        if ([subview conformsToProtocol:protocol])
            [subviewsConformingToProtocol addObject:subview];
    }];

    return [subviewsConformingToProtocol copy];
}


- (UIView*)cogu_firstSubviewConformingToProtocol:(Protocol*)protocol;
{
    __block UIView* conformingSubview = nil;

    [self cogu_enumerateSubviewsDepthFirstUsingBlock:^(UIView *subview, BOOL *stop) {
        if (![subview conformsToProtocol:protocol])
            return;

        conformingSubview = subview;
        *stop = YES;
    }];

    return conformingSubview;
}


- (void)cogu_enumerateSubviewsDepthFirstUsingBlock:(void (^)(UIView* subview, BOOL* stop))block;
{
    ZAssert(block != nil, @"Block must not be nil");

    [self.subviews enumerateObjectsUsingBlock:^(UIView* subview, NSUInteger index, BOOL* stop) {
        block(subview, stop);
        [subview cogu_enumerateSubviewsDepthFirstUsingBlock:block];
    }];
}

@end
