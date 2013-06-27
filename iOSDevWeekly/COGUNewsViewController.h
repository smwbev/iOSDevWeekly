//
//  COGUViewController.h
//  iOSDevWeekly
//
//  Created by Colin Günther on 08.08.12.
//  Copyright (c) 2012 Cogun. All rights reserved.
//


#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

#import "ODRefreshControl.h"


@class COGUDevWeeklyNewsManager;


@interface COGUNewsViewController : UIViewController<UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate>;

@property (weak, nonatomic) IBOutlet UITableView *newsListingControl;

@end


@interface COGUNewsViewController ()

@property (strong, nonatomic) COGUDevWeeklyNewsManager* newsManager;
@property (strong, nonatomic) NSFetchedResultsController* fetchedNewsResultsController;
@property (strong, nonatomic) NSFetchedResultsController* fetchedMatchingNewsResultsController;
@property (strong, nonatomic) NSMutableArray* newsListingRowHeightsCache;
@property (strong, nonatomic) NSMutableArray* matchingNewsRowHeightsCache;
@property (strong, nonatomic) ODRefreshControl* newsRefreshControl;

@end


@interface COGUNewsViewController (Private)

- (void)_configureNewsListingControlAfterViewDidLoad;
- (void)_configureMatchingNewsListingControlAfterViewDidLoad;
- (void)_configureNewsRefreshControl;

- (NSFetchedResultsController*)_fetchedResultsControllerForTableView:(UITableView*)tableView;
- (NSMutableArray*)_rowHeightsCacheForTableView:(UITableView*)tableView;

@end