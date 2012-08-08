//
//  COGUViewController.m
//  iOSDevWeekly
//
//  Created by Colin Günther on 08.08.12.
//  Copyright (c) 2012 Cogun. All rights reserved.
//

#import "COGUNewsViewController.h"


@implementation COGUNewsViewController
@synthesize newsListingControl;


#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 0;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return 0;
}


#pragma mark UITableViewDelegate



#pragma mark UIViewController

- (void)viewDidUnload;
{
    [self setNewsListingControl:nil];
    [super viewDidUnload];
}

@end
