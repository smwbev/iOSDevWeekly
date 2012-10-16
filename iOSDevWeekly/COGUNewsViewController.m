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
#import "UISearchBar+COGUAdditions.h"

#import "COGUDevWeeklyCategory.h"
#import "COGUDevWeeklyIssue.h"
#import "COGUDevWeeklyNewsItem.h"
#import "COGUDevWeeklyNewsManager.h"
#import "COGUNewsItemCell.h"
#import "COGUNewsItemSectionHeaderView.h"


@implementation COGUNewsViewController

@synthesize newsListingControl;
@synthesize fetchedNewsResultsController = _fetchedNewsResultsController;
@synthesize fetchedMatchingNewsResultsController = _fetchedMatchingNewsResultsController;
@synthesize newsManager = _newsManager;
@synthesize newsListingRowHeightsCache = _newsListingRowHeightsCache;
@synthesize matchingNewsRowHeightsCache = _matchingNewsRowHeightsCache;


#pragma mark UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText;
{
    NSPredicate* matchingNewsItemPredicate = [NSPredicate predicateWithFormat:@"(title CONTAINS[cd] %@) OR (explanation CONTAINS[cd] %@)", searchText, searchText];
    [self.fetchedMatchingNewsResultsController.fetchRequest setPredicate:matchingNewsItemPredicate];
    [self.fetchedMatchingNewsResultsController performFetch:nil];
    [self.matchingNewsRowHeightsCache removeAllObjects];
    [self.searchDisplayController.searchResultsTableView reloadData];
}


#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    NSFetchedResultsController* controller = [self _fetchedResultsControllerForTableView:tableView];
    NSUInteger sectionCount = controller.sections.count;
    if (sectionCount > NSIntegerMax)
        return NSIntegerMax;

    return (NSInteger)sectionCount;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    NSFetchedResultsController* controller = [self _fetchedResultsControllerForTableView:tableView];
    id<NSFetchedResultsSectionInfo> sectionInfo = controller.sections[(NSUInteger)section];
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

    COGUDevWeeklyNewsItem* newsItem = [[self _fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath];
    [cell configureWithNewsItem:newsItem];

    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    return [COGUNewsItemSectionHeaderView preferredSize].height;
}


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [self _fetchedResultsControllerForTableView:tableView].sections[(NSUInteger)section];
    NSString* sectionName = [[sectionInfo objects].cogu_firstObject category].userReadableName;

    COGUNewsItemSectionHeaderView* view = [COGUNewsItemSectionHeaderView createView];
    view.titleControl.text = sectionName;

    return view;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSMutableArray* rowHeightsCache = [self _rowHeightsCacheForTableView:tableView];
    NSNumber* cachedHeightNumber = [rowHeightsCache cogu_objectAtLazyInitializedIndexPath:indexPath defaultObject:@(NAN)];

    if (![cachedHeightNumber isEqualToNumber:@(NAN)])
        return cachedHeightNumber.floatValue;

    NSFetchedResultsController* controller = [self _fetchedResultsControllerForTableView:tableView];
    COGUDevWeeklyNewsItem* newsItem = [controller objectAtIndexPath:indexPath];
    CGFloat rowHeight = [COGUNewsItemCell preferredHeightWhenConfiguredWithNewsItem:newsItem inTableView:tableView];

    [rowHeightsCache cogu_replaceObjectAtLazyInitializedIndexPath:indexPath withObject:@(rowHeight)];

    return rowHeight;
}


#pragma mark UIViewController

- (void)viewDidLoad;
{
    [self _configureNewsListingControlAfterViewDidLoad];
    [self _configureMatchingNewsListingControlAfterViewDidLoad];
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


- (NSFetchedResultsController*)fetchedMatchingNewsResultsController;
{
    if (_fetchedMatchingNewsResultsController)
        return _fetchedMatchingNewsResultsController;

    NSFetchRequest* fetchNewsItemsRequest = [[NSFetchRequest alloc] initWithEntityName:@"NewsItem"];
    fetchNewsItemsRequest.sortDescriptors = @[
    [NSSortDescriptor sortDescriptorWithKey:@"category.type" ascending:YES],
    [NSSortDescriptor sortDescriptorWithKey:@"issue.number" ascending:NO]
    ];
    _fetchedMatchingNewsResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchNewsItemsRequest managedObjectContext:self.newsManager.devWeeklyManagedObjectContext sectionNameKeyPath:@"category.type" cacheName:nil];

    return _fetchedMatchingNewsResultsController;
}


- (NSMutableArray*)newsListingRowHeightsCache;
{
    if (_newsListingRowHeightsCache)
        return _newsListingRowHeightsCache;

    NSUInteger numberOfSections = (NSUInteger)self.newsListingControl.numberOfSections;
    _newsListingRowHeightsCache = [NSMutableArray arrayWithCapacity:numberOfSections];

    return _newsListingRowHeightsCache;
}


- (NSMutableArray*)matchingNewsRowHeightsCache;
{
    if (_matchingNewsRowHeightsCache)
        return _matchingNewsRowHeightsCache;

    NSUInteger numberOfSections = (NSUInteger)self.searchDisplayController.searchResultsTableView.numberOfSections;
    _matchingNewsRowHeightsCache = [NSMutableArray arrayWithCapacity:numberOfSections];

    return _matchingNewsRowHeightsCache;
}

@end


#pragma mark -

@implementation COGUNewsViewController (Private)

- (void)_configureNewsListingControlAfterViewDidLoad;
{
    self.newsListingControl.rowHeight = [COGUNewsItemCell preferredCellHeight];
}


- (void)_configureMatchingNewsListingControlAfterViewDidLoad;
{
    self.searchDisplayController.searchBar.placeholder = NSLocalizedString(@"Livesearch", nil);
    self.searchDisplayController.searchBar.cogu_returnKeyType = UIReturnKeyDone;
}


- (NSFetchedResultsController*)_fetchedResultsControllerForTableView:(UITableView*)tableView;
{
    if (tableView == self.newsListingControl)
        return self.fetchedNewsResultsController;

    if (tableView == self.searchDisplayController.searchResultsTableView)
        return self.fetchedMatchingNewsResultsController;

    ZAssert(NO, @"Must pass a known tableView");
    return nil;
}


- (NSMutableArray*)_rowHeightsCacheForTableView:(UITableView*)tableView;
{
    if (tableView == self.newsListingControl)
        return self.newsListingRowHeightsCache;

    if (tableView == self.searchDisplayController.searchResultsTableView)
        return self.matchingNewsRowHeightsCache;

    ZAssert(NO, @"Must pass a known tableView");
    return nil;
}

@end
