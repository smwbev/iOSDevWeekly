//
//  COGUNewsItemSectionHeaderView.m
//  iOSDevWeekly
//
//  Created by Colin Günther on 14.08.12.
//  Copyright (c) 2012 Cogun. All rights reserved.
//


#import "COGUNewsItemSectionHeaderView.h"

#import <QuartzCore/QuartzCore.h>


@implementation COGUNewsItemSectionHeaderView

@synthesize titleControl;


#pragma mark COGUNibView

- (void)nibViewDidInitialize;
{
    [super nibViewDidInitialize];

    self.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.layer.shadowOpacity = 0.5;
    self.layer.shadowRadius = 1.0;
    self.layer.shadowOffset = CGSizeMake(0, 1);
}

@end
