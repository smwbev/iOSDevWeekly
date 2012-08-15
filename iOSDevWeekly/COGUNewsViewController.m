//
//  COGUViewController.m
//  iOSDevWeekly
//
//  Created by Colin Günther on 08.08.12.
//  Copyright (c) 2012 Cogun. All rights reserved.
//

#import "COGUNewsViewController.h"

#import "NSArray+COGUAdditions.h"
#import "NSMutableArray+COGUAdditions.h"

#import "COGUDevWeeklyCategory.h"
#import "COGUDevWeeklyIssue.h"
#import "COGUDevWeeklyNewsItem.h"
#import "COGUDevWeeklyNewsManager.h"
#import "COGUNewsItemCell.h"
#import "COGUNewsItemSectionHeaderView.h"


@implementation COGUNewsViewController

@synthesize newsListingControl;
@synthesize newsListingHeaderControl = _newsListingHeaderControl;
@synthesize fetchedNewsResultsController = _fetchedNewsResultsController;
@synthesize newsManager = _newsManager;
@synthesize newsListingRowHeightsCache = _newsListingRowHeightsCache;


#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    NSUInteger sectionCount = self.fetchedNewsResultsController.sections.count;
    if (sectionCount > NSIntegerMax)
        return NSIntegerMax;

    return (NSInteger)sectionCount;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    id<NSFetchedResultsSectionInfo> sectionInfo = self.fetchedNewsResultsController.sections[(NSUInteger)section];
    NSUInteger rowsCount = [sectionInfo numberOfObjects];
    if (rowsCount > NSIntegerMax)
        rowsCount = NSIntegerMax;

    static NSInteger const kMaxVisibleRowsPerSectionCount = 3;
    rowsCount = MIN(rowsCount, kMaxVisibleRowsPerSectionCount);

    return (NSInteger)rowsCount;
}


#pragma mark UITableViewDelegate

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    COGUNewsItemCell* cell = [tableView dequeueReusableCellWithIdentifier:[COGUNewsItemCell reuseIdentifier]];
    if (cell == nil)
        cell = [COGUNewsItemCell createCell];

    COGUDevWeeklyNewsItem* newsItem = [self.fetchedNewsResultsController objectAtIndexPath:indexPath];
    [cell configureWithNewsItem:newsItem];

    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    return [COGUNewsItemSectionHeaderView preferredSize].height;
}


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
    id<NSFetchedResultsSectionInfo> sectionInfo = self.fetchedNewsResultsController.sections[(NSUInteger)section];
    NSString* sectionName = [[sectionInfo objects].cogu_firstObject category].userReadableName;

    COGUNewsItemSectionHeaderView* view = [COGUNewsItemSectionHeaderView createView];
    view.titleControl.text = sectionName;

    return view;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSNumber* cachedHeightNumber = [self.newsListingRowHeightsCache cogu_objectAtLazyInitializedIndexPath:indexPath defaultObject:@(NAN)];

    if (![cachedHeightNumber isEqualToNumber:@(NAN)])
        return cachedHeightNumber.floatValue;

    COGUDevWeeklyNewsItem* newsItem = [self.fetchedNewsResultsController objectAtIndexPath:indexPath];
    CGFloat rowHeight = [COGUNewsItemCell preferredHeightWhenConfiguredWithNewsItem:newsItem inTableView:tableView];

    [self.newsListingRowHeightsCache cogu_replaceObjectAtLazyInitializedIndexPath:indexPath withObject:@(rowHeight)];

    return rowHeight;
}


#pragma mark UIViewController

- (void)viewDidLoad;
{
    [self _configureNewsListingControlAfterViewDidLoad];
    [self.newsManager prefillIssuesDatabaseIfEmptySuccessHandler:^(id context) {
        [self.fetchedNewsResultsController performFetch:nil];
        [self.newsListingControl reloadData];
    } failureHandler:^(NSError *error) {
        // TODO: implement error handling
    }];
}


- (void)viewDidUnload;
{
    self.newsListingControl = nil;
    self.fetchedNewsResultsController = nil;

    [self setNewsListingHeaderControl:nil];
    [super viewDidUnload];
}


#pragma mark Private properties

- (COGUDevWeeklyNewsManager*)newsManager;
{
    if (_newsManager)
        return _newsManager;

    _newsManager = [[COGUDevWeeklyNewsManager alloc] init];

    return _newsManager;
}


- (NSFetchedResultsController*)fetchedNewsResultsController;
{
    if (_fetchedNewsResultsController)
        return _fetchedNewsResultsController;

    NSFetchRequest* fetchNewsItemsRequest = [[NSFetchRequest alloc] initWithEntityName:@"NewsItem"];
    fetchNewsItemsRequest.sortDescriptors = @[
        [NSSortDescriptor sortDescriptorWithKey:@"category.type" ascending:YES],
        [NSSortDescriptor sortDescriptorWithKey:@"issue.number" ascending:NO]
     ];
    _fetchedNewsResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchNewsItemsRequest managedObjectContext:self.newsManager.devWeeklyManagedObjectContext sectionNameKeyPath:@"category.type" cacheName:@"fetchedDevWeeklyNewsResults.cache"];

    return _fetchedNewsResultsController;
}


- (NSMutableArray*)newsListingRowHeightsCache;
{
    if (_newsListingRowHeightsCache)
        return _newsListingRowHeightsCache;

    NSUInteger numberOfSections = (NSUInteger)self.newsListingControl.numberOfSections;
    _newsListingRowHeightsCache = [NSMutableArray arrayWithCapacity:numberOfSections];

    return _newsListingRowHeightsCache;
}

@end


#pragma mark -

@implementation COGUNewsViewController (Private)

- (void)_configureNewsListingControlAfterViewDidLoad;
{
    self.newsListingControl.rowHeight = [COGUNewsItemCell preferredCellHeight];
    self.newsListingControl.tableHeaderView = self.newsListingHeaderControl;
}

@end