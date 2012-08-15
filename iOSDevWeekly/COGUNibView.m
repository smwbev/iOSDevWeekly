//
//  COGUNibView.m
//  iOSDevWeekly
//
//  Created by Colin Günther on 14.08.12.
//  Copyright (c) 2012 Cogun. All rights reserved.
//


#import "COGUNibView.h"

#import "NSArray+COGUAdditions.h"


@implementation COGUNibView

+ (id)createView;
{
    COGUNibView* view = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil][0];

    [view nibViewDidInitialize];

    return view;
}


+ (CGSize)preferredSize;
{
    return [[self createView] frame].size;
}


- (void)nibViewDidInitialize;
{
}

@end
