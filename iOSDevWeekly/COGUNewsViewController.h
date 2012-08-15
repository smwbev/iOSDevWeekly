//
//  COGUViewController.h
//  iOSDevWeekly
//
//  Created by Colin Günther on 08.08.12.
//  Copyright (c) 2012 Cogun. All rights reserved.
//


#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>


@class COGUDevWeeklyNewsManager;


@interface COGUNewsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>;

@property (weak, nonatomic) IBOutlet UITableView *newsListingControl;
@property (strong, nonatomic) IBOutlet UIView *newsListingHeaderControl;

@end


@interface COGUNewsViewController ()

@property (strong, nonatomic) COGUDevWeeklyNewsManager* newsManager;
@property (strong, nonatomic) NSFetchedResultsController* fetchedNewsResultsController;
@property (strong, nonatomic) NSMutableArray* newsListingRowHeightsCache;

@end


@interface COGUNewsViewController (Private)

- (void)_configureNewsListingControlAfterViewDidLoad;

@end