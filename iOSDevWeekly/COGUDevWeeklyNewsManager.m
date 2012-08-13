//
//  COGUNewsFetcher.m
//  iOSDevWeekly
//
//  Created by Colin Günther on 08.08.12.
//  Copyright (c) 2012 Cogun. All rights reserved.
//


#import "COGUDevWeeklyNewsManager.h"

#import "AFNetworking.h"
#import "GDataXMLNode.h"

#import "NSArray+COGUAdditions.h"
#import "NSObject+COGUAdditions.h"
#import "NSMutableArray+COGUAdditions.h"
#import "NSString+COGUAdditions.h"
#import "UIApplication+COGUAdditions.h"

#import "COGUDevWeeklyIssue.h"
#import "COGUDevWeeklyCategory.h"
#import "COGUDevWeeklyNewsItem.h"


static NSString* const kDevWeeklyBaseURLString = @"http://iosdevweekly.com";
static NSString* const kDevWeeklyDatabaseFilename = @"news.sqlite";

static NSString* const kAllIssuesFetcher = @"AllIssuesFetcher";


@implementation COGUDevWeeklyNewsManager

@synthesize devWeeklyClient = _devWeeklyClient;
@synthesize devWeeklyStoreCoordinator = _devWeeklyStoreCoordinator;
@synthesize devWeeklyStoreURL = _devWeeklyStoreURL;
@synthesize devWeeklyManagedObjectContext = _devWeeklyManagedObjectContext;
@synthesize devWeeklyManagedObjectModel = _devWeeklyManagedObjectModel;
@synthesize devWeeklyPublishingDateFormatter = _devWeeklyPublishingDateFormatter;


- (id)fetchAllIssuesSuccessHandler:(COGUDevWeeklyNewsManagerSuccessHandler)success failureHandler:(COGUDevWeeklyNewsManagerFailureHandler)failure;
{
    [self _fetchLandingPageSuccessHandler:^(GDataXMLDocument* landingPage) {
        NSString* issuesListingPath = [self _pathToIssuesListingFromLandingPage:landingPage];
        if (issuesListingPath.length == 0) {
            NSBlockCallSafely(failure, nil);
            return;
        }

        [self _fetchHTMLPageWithPath:issuesListingPath successHandler:^(GDataXMLDocument* issuesListing) {
            NSArray* pathsToIssues = [self _pathsToIssuesFromIssuesListing:issuesListing];
            if (pathsToIssues.count == 0) {
                NSBlockCallSafely(failure, nil);
                return;
            }

            NSMutableArray* issueDocumentsInOriginalOrder = [pathsToIssues mutableCopy];
            NSMutableArray* fetchIssuesErrors = [NSMutableArray arrayWithCapacity:pathsToIssues.count];
            dispatch_group_t fetchIssuesGroup = dispatch_group_create();
            [pathsToIssues enumerateObjectsUsingBlock:^(NSString* issuePath, NSUInteger idx, BOOL *stop) {
                dispatch_group_enter(fetchIssuesGroup);
                [self _fetchHTMLPageWithPath:issuePath successHandler:^(GDataXMLDocument* issue) {
                    [issueDocumentsInOriginalOrder cogu_replaceObject:issuePath withObject:issue];
                    dispatch_group_leave(fetchIssuesGroup);
                } failureHandler:^(NSError *error) {
                    [fetchIssuesErrors cogu_addObjectOrNil:error];
                    dispatch_group_leave(fetchIssuesGroup);
                }];
            }];

            dispatch_group_notify(fetchIssuesGroup, dispatch_get_main_queue(), ^{
                if (fetchIssuesErrors.count > 0)
                    NSBlockCallSafely(failure, [fetchIssuesErrors objectAtIndex:0]);
                else
                    NSBlockCallSafely(success, issueDocumentsInOriginalOrder);
            
                dispatch_release(fetchIssuesGroup);
            });
        } failureHandler:^(NSError *error) {
            NSBlockCallSafely(failure, error);
        }];
    } failureHandler:^(NSError *error) {
        NSBlockCallSafely(failure, error);
    }];

    return kAllIssuesFetcher;
}


- (BOOL)addIssueToDatabase:(GDataXMLDocument*)issueDocument error:(NSError**)error;
{
    NSAssert(issueDocument != nil, nil);

    COGUDevWeeklyIssue* issueEntity = [self _fetchOrCreateIssueEntityForIssue:issueDocument error:error];
    if (issueEntity == nil)
        return NO;

    BOOL configuredIssueSuccessfully = [self _configureIssueEntity:issueEntity withIssue:issueDocument error:error];

    if (configuredIssueSuccessfully)
        NSDereferenceAndAssignSafely(error, nil);


    return configuredIssueSuccessfully;
}


- (BOOL)addIssuesToDatabaseAndPersists:(NSArray*)issueDocuments error:(NSError**)error;
{
    NSAssert(issueDocuments != nil, nil);
    static BOOL const kAddingToDatabaseFailed = NO;
    __block BOOL addingToDatabaseSucceeded = kAddingToDatabaseFailed;
    [issueDocuments enumerateObjectsUsingBlock:^(GDataXMLDocument* issueDocument, NSUInteger idx, BOOL *stop) {
        NSAssert([issueDocument isMemberOfClass:[GDataXMLDocument class]], nil);
        addingToDatabaseSucceeded = [self addIssueToDatabase:issueDocument error:error];
        *stop = !addingToDatabaseSucceeded;
    }];

    if (!addingToDatabaseSucceeded)
        return kAddingToDatabaseFailed;

    addingToDatabaseSucceeded = [self persistDatabaseError:error];

    if (!addingToDatabaseSucceeded)
        return kAddingToDatabaseFailed;

    NSDereferenceAndAssignSafely(error, nil);
    return addingToDatabaseSucceeded;
}


- (BOOL)persistDatabaseError:(NSError**)error;
{
    return [self.devWeeklyManagedObjectContext save:error];
}


- (id)fetchLatestIssueOnlySuccessHandler:(COGUDevWeeklyNewsManagerSuccessHandler)success failureHandler:(COGUDevWeeklyNewsManagerFailureHandler)failure;
{
    // TODO: implement
    return nil;
}


- (void)cancelFetcher:(id)fetcher;
{
    // TODO: implement
}


- (void)removeDatabase;
{
    NSError* removalError = nil;
    [[NSFileManager defaultManager] removeItemAtURL:self.devWeeklyStoreURL error:&removalError];
}


#pragma mark - Private properties

- (AFHTTPClient*)devWeeklyClient;
{
    if (_devWeeklyClient)
        return _devWeeklyClient;
    
    NSURL* devWeeklyBaseURL = [NSURL URLWithString:kDevWeeklyBaseURLString];
    _devWeeklyClient = [[AFHTTPClient alloc] initWithBaseURL:devWeeklyBaseURL];
    
    return _devWeeklyClient;
}


- (NSPersistentStoreCoordinator*)devWeeklyStoreCoordinator;
{
    if (_devWeeklyStoreCoordinator)
        return _devWeeklyStoreCoordinator;

    _devWeeklyStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.devWeeklyManagedObjectModel];

    // setting up the coordinator
    NSDictionary* options = @{
        NSMigratePersistentStoresAutomaticallyOption : @YES,
        NSInferMappingModelAutomaticallyOption : @YES
    };
    NSError* addingError = nil;
    [_devWeeklyStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:self.devWeeklyStoreURL options:options error:&addingError];

    return _devWeeklyStoreCoordinator;
}


- (NSURL*)devWeeklyStoreURL;
{
    if (_devWeeklyStoreURL)
        return _devWeeklyStoreURL;

    _devWeeklyStoreURL = [[UIApplication cogu_documentFolderURL] URLByAppendingPathComponent:kDevWeeklyDatabaseFilename];

    return _devWeeklyStoreURL;
}


- (NSManagedObjectContext*)devWeeklyManagedObjectContext;
{
    if (_devWeeklyManagedObjectContext)
        return _devWeeklyManagedObjectContext;

    _devWeeklyManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    _devWeeklyManagedObjectContext.persistentStoreCoordinator = self.devWeeklyStoreCoordinator;

    return _devWeeklyManagedObjectContext;
}


- (NSManagedObjectModel*)devWeeklyManagedObjectModel;
{
    if (_devWeeklyManagedObjectModel)
        return _devWeeklyManagedObjectModel;

    _devWeeklyManagedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"news.momd" withExtension:nil]];

    return _devWeeklyManagedObjectModel;
}


- (NSDateFormatter*)devWeeklyPublishingDateFormatter;
{
    if (_devWeeklyPublishingDateFormatter)
        return _devWeeklyPublishingDateFormatter;

    _devWeeklyPublishingDateFormatter = [[NSDateFormatter alloc] init];
    _devWeeklyPublishingDateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    _devWeeklyPublishingDateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    _devWeeklyPublishingDateFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

    return _devWeeklyPublishingDateFormatter;
}

@end


#pragma mark -

@implementation COGUDevWeeklyNewsManager (Private)

- (void)_fetchLandingPageSuccessHandler:(COGUDevWeeklyNewsManagerSuccessHandler)success failureHandler:(COGUDevWeeklyNewsManagerFailureHandler)failure;
{
    [self _fetchHTMLPageWithPath:@"" successHandler:success failureHandler:failure];
}


- (NSString*)_pathToIssuesListingFromLandingPage:(GDataXMLDocument*)landingPageDocument;
{
    NSAssert(landingPageDocument != nil, nil);
    NSArray* pathToIssuesCandidates = [landingPageDocument nodesForXPath:@"//a" error:nil];
    GDataXMLElement* pathToIssuesElement = [pathToIssuesCandidates cogu_firstObjectPassingTest:^BOOL(GDataXMLElement* pathToIssuesCandidate, NSUInteger idx, BOOL *stop) {
        return [pathToIssuesCandidate.stringValue.lowercaseString isEqualToString:@"browse the archive"];
    }];

    NSString* pathToIssues = [pathToIssuesElement attributeForName:@"href"].stringValue;
    return pathToIssues;
}


- (NSArray*)_pathsToIssuesFromIssuesListing:(GDataXMLDocument*)issuesListingDocument;
{
    NSAssert(issuesListingDocument != nil, nil);
    NSArray* pathToIssueCandidates = [issuesListingDocument nodesForXPath:@"//h4//a" error:nil];

    NSArray* pathsToIssues = [pathToIssueCandidates cogu_mappedArrayUsingBlock:^id(GDataXMLElement* pathToIssueCandidate, NSUInteger idx, BOOL *stop) {
        return [pathToIssueCandidate attributeForName:@"href"].stringValue;
    }];
        
    return pathsToIssues;
}


- (void)_fetchHTMLPageWithPath:(NSString*)path successHandler:(COGUDevWeeklyNewsManagerSuccessHandler)success failureHandler:(COGUDevWeeklyNewsManagerFailureHandler)failure;
{
    NSAssert(path != nil, nil);
    [self.devWeeklyClient getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, NSData* pageHTML) {
        NSAssert(pageHTML != nil, nil);
        
        NSError* parsePageHtmlError = nil;
        GDataXMLDocument* htmlDocument = [[GDataXMLDocument alloc] initWithHTMLData:pageHTML error:&parsePageHtmlError];
        
        if (htmlDocument)
            NSBlockCallSafely(success, htmlDocument);
        else
            NSBlockCallSafely(failure, parsePageHtmlError);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSBlockCallSafely(failure, error);
    }];
}


- (COGUDevWeeklyIssue*)_fetchOrCreateIssueEntityForIssue:(GDataXMLDocument*)issue error:(NSError**)error;
{
    NSNumber* issueNumber = [self _numberOfIssue:issue error:error];
    if (issueNumber == nil)
        return nil;

    NSFetchRequest* fetchIssueRequest = [[self.devWeeklyManagedObjectModel fetchRequestFromTemplateWithName:@"fetchIssueRequest" substitutionVariables:@{@"NUMBER" : issueNumber}] copy];
    COGUDevWeeklyIssue* issueEntity = [self.devWeeklyManagedObjectContext executeFetchRequest:fetchIssueRequest error:error].cogu_firstObject;

    if (issueEntity) {
        NSDereferenceAndAssignSafely(error, nil);
        return issueEntity;
    }

    if (NSDereferenceSafely(error) != nil)
        return nil;

    NSDate* issuePublishingDate = [self _publishingDateOfIssue:issue error:error];
    if (issuePublishingDate == nil)
        return nil;

    NSDereferenceAndAssignSafely(error, nil);

    issueEntity = [NSEntityDescription insertNewObjectForEntityForName:@"Issue" inManagedObjectContext:self.devWeeklyManagedObjectContext];

    issueEntity.number = issueNumber;
    issueEntity.publishingDate = issuePublishingDate;

    return issueEntity;
}


- (BOOL)_configureIssueEntity:(COGUDevWeeklyIssue*)issueEntity withIssue:(GDataXMLDocument*)issue error:(NSError**)error;
{
    static BOOL const kConfiguringCategoryEntitiesFailed = NO;
    __block BOOL configuringCategoryEntitiesSucceeded = kConfiguringCategoryEntitiesFailed;

    NSArray* issueCategoryElements = [self _categoryElementsInIssue:issue error:error];
    if (issueCategoryElements.count == 0)
        return kConfiguringCategoryEntitiesFailed;
    
    [issueCategoryElements enumerateObjectsUsingBlock:^(GDataXMLElement* issueCategoryElement, NSUInteger idx, BOOL *stop) {
        COGUDevWeeklyCategory* issueCategoryEntity = [self _fetchOrCreateCategoryEntityForCategory:issueCategoryElement error:error];
        if (issueCategoryEntity == nil)
            configuringCategoryEntitiesSucceeded = kConfiguringCategoryEntitiesFailed;
        else
            configuringCategoryEntitiesSucceeded = [self _configureCategoryEntity:issueCategoryEntity withCategory:issueCategoryElement issueEntity:issueEntity error:error];

        *stop = !configuringCategoryEntitiesSucceeded;
    }];
    
    return configuringCategoryEntitiesSucceeded;
}


- (NSArray*)_categoryElementsInIssue:(GDataXMLDocument*)issue error:(NSError**)error;
{
    NSArray* categoryElementCandidates = [issue nodesForXPath:@"//h3" error:error];
    if (categoryElementCandidates.count == 0)
        return nil;

    NSRange rangeContainingCategoryElementsOnly = NSMakeRange(0, categoryElementCandidates.count - 1);
    NSArray* categoryElements = [categoryElementCandidates subarrayWithRange:rangeContainingCategoryElementsOnly];
    if (categoryElements.count == 0)
        return nil;

    NSDereferenceAndAssignSafely(error, nil);

    return categoryElements;
}


- (COGUDevWeeklyCategory*)_fetchOrCreateCategoryEntityForCategory:(GDataXMLElement*)category error:(NSError**)error;
{
    NSString* categoryType = [self _typeOfCategory:category error:error];
    if (categoryType.length == 0)
        return nil;

    NSFetchRequest* fetchCategoryRequest = [[self.devWeeklyManagedObjectModel fetchRequestFromTemplateWithName:@"fetchCategoryRequest" substitutionVariables:@{@"TYPE" : categoryType}] copy];
    COGUDevWeeklyCategory* categoryEntity = [self.devWeeklyManagedObjectContext executeFetchRequest:fetchCategoryRequest error:error].cogu_firstObject;
    
    if (categoryEntity) {
        NSDereferenceAndAssignSafely(error, nil);
        return categoryEntity;
    }
    
    if (NSDereferenceSafely(error) != nil)
        return nil;

    NSString* categoryUserReadableName = [self _userReadableNameOfCategory:category error:error];
    if (categoryUserReadableName.length == 0)
        return nil;

    NSDereferenceAndAssignSafely(error, nil);

    categoryEntity = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.devWeeklyManagedObjectContext];

    categoryEntity.type = categoryType;
    categoryEntity.userReadableName = categoryUserReadableName;
    
    return categoryEntity;
}


- (BOOL)_configureCategoryEntity:(COGUDevWeeklyCategory*)categoryEntity withCategory:(GDataXMLElement*)category issueEntity:(COGUDevWeeklyIssue*)issueEntity error:(NSError**)error;
{
    static BOOL const kConfiguringNewsItemEntitiesFailed = NO;
    __block BOOL configuringNewsItemEntitiesSucceeded = kConfiguringNewsItemEntitiesFailed;

    NSArray* newsItemHeadlineElements = [self _newsItemHeadlineElementsInCategory:category error:error];
    if (newsItemHeadlineElements.count == 0)
        return kConfiguringNewsItemEntitiesFailed;
    
    [newsItemHeadlineElements enumerateObjectsUsingBlock:^(GDataXMLElement* newsItemHeadlineElement, NSUInteger idx, BOOL *stop) {
        COGUDevWeeklyNewsItem* newsItemEntity = [self _createNewsItemEntityForNewsItemHeadline:newsItemHeadlineElement error:error];
        if (newsItemEntity == nil)
            configuringNewsItemEntitiesSucceeded = kConfiguringNewsItemEntitiesFailed;
        else
            configuringNewsItemEntitiesSucceeded = [self _configureNewsItemEntity:newsItemEntity withNewsItemHeadline:newsItemHeadlineElement error:error];

        newsItemEntity.issue = issueEntity;
        newsItemEntity.category = categoryEntity;

        *stop = !configuringNewsItemEntitiesSucceeded;
    }];
    
    return configuringNewsItemEntitiesSucceeded;
}


- (NSArray*)_newsItemHeadlineElementsInCategory:(GDataXMLElement*)category error:(NSError**)error;
{
    NSArray* categorySiblingElements = [category nodesForXPath:@"following-sibling::*" error:error];
    if (categorySiblingElements.count == 0)
        return nil;

    NSArray* newsItemHeadlineElements = [categorySiblingElements cogu_mappedArrayUsingBlock:^id(GDataXMLElement* siblingElement, NSUInteger idx, BOOL *stop) {
        if ([siblingElement.name isEqualToString:@"h4"])
            return siblingElement;

        if ([siblingElement.name isEqualToString:@"h3"])
            *stop = YES;

        return nil;
    }];

    return newsItemHeadlineElements;
}


- (COGUDevWeeklyNewsItem*)_createNewsItemEntityForNewsItemHeadline:(GDataXMLElement*)newsItemHeadline error:(NSError**)error;
{
    COGUDevWeeklyNewsItem* newsItemEntity = [NSEntityDescription insertNewObjectForEntityForName:@"NewsItem" inManagedObjectContext:self.devWeeklyManagedObjectContext];

    NSDereferenceAndAssignSafely(error, nil);
    
    return newsItemEntity;
}


- (BOOL)_configureNewsItemEntity:(COGUDevWeeklyNewsItem*)newsItemEntity withNewsItemHeadline:(GDataXMLElement*)newsItemHeadline error:(NSError**)error;
{
    NSString* title = [self _titleOfNewsItemHeadline:newsItemHeadline error:error];
    if (title.length == 0)
        // The title is a required attribute of the newsItemEntity
        return NO;

    NSString* explanation = [self _explanationForNewsItemHeadline:newsItemHeadline error:error];
    if (explanation == nil && NSDereferenceSafely(error) != nil)
        return NO;

    NSString* completeTextUrl = [self _completeTextUrlForNewsItemHeadline:newsItemHeadline error:error];
    if (completeTextUrl == nil && NSDereferenceSafely(error) != nil)
        return NO;

    NSDereferenceAndAssignSafely(error, nil);

    newsItemEntity.title = title;
    newsItemEntity.explanation = explanation;
    newsItemEntity.completeTextUrl = completeTextUrl;

    return YES;
}


- (NSNumber*)_numberOfIssue:(GDataXMLDocument*)issue error:(NSError**)error;
{
    GDataXMLElement* issueHeaderTwo = (GDataXMLElement*)[issue firstNodeForXPath:@"//h2" error:error];
    if (issueHeaderTwo == nil)
        return nil;

    NSArray* issueHeaderTwoComponents = [issueHeaderTwo.stringValue componentsSeparatedByString:@" - "];
    if (issueHeaderTwoComponents.count < 2)
        return nil;

    NSString* issueNumberComponent = issueHeaderTwoComponents[0];
    NSString* issueNumberOnlyComponent = issueNumberComponent.cogu_stringByMergingAllDigits;
    if (issueNumberOnlyComponent.length == 0)
        return nil;

    NSNumber* issueNumber = @(issueNumberOnlyComponent.integerValue);
    return issueNumber;
}


- (NSDate*)_publishingDateOfIssue:(GDataXMLDocument*)issue error:(NSError**)error;
{
    GDataXMLElement* issueHeaderTwo = (GDataXMLElement*)[issue firstNodeForXPath:@"//h2" error:error];
    if (issueHeaderTwo == nil)
        return nil;

    NSArray* issueHeaderTwoComponents = [issueHeaderTwo.stringValue componentsSeparatedByString:@" - "];
    if (issueHeaderTwoComponents.count < 2)
        return nil;

    NSString* issuePublishingDateOnlyComponent = issueHeaderTwoComponents[1];

    __block NSDate* issuePublishingDate = nil;
    NSArray* possibleDateFormats = @[@"d'th' MMMM yyyy", @"d'st' MMMM yyyy", @"d'nd' MMMM yyyy", @"d'rd' MMMM yyyy"];
    [possibleDateFormats enumerateObjectsUsingBlock:^(NSString* dateFormat, NSUInteger idx, BOOL *stop) {
        self.devWeeklyPublishingDateFormatter.dateFormat = dateFormat;
        issuePublishingDate = [self.devWeeklyPublishingDateFormatter dateFromString:issuePublishingDateOnlyComponent];
        *stop = issuePublishingDate != nil;
    }];

    NSDereferenceAndAssignSafely(error, nil);

    return issuePublishingDate;
}


- (NSString*)_typeOfCategory:(GDataXMLElement*)category error:(NSError**)error;
{
    NSString* userReadableNameOfCategory = [self _userReadableNameOfCategory:category error:error];
    if (userReadableNameOfCategory.length == 0)
        return nil;

    NSDereferenceAndAssignSafely(error, nil);

    NSString* type = [userReadableNameOfCategory.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    return type;
}


- (NSString*)_userReadableNameOfCategory:(GDataXMLElement*)category error:(NSError**)error;
{
    NSString* userReadableName = category.stringValue;
    return userReadableName;
}


- (NSString*)_titleOfNewsItemHeadline:(GDataXMLElement*)headline error:(NSError**)error;
{
    GDataXMLElement* headlineLinkElement = (GDataXMLElement*)[headline firstNodeForXPath:@"a" error:error];
    if (headlineLinkElement == nil)
        return nil;

    NSDereferenceAndAssignSafely(error, nil);

    NSString* title = headlineLinkElement.stringValue;
    return title;
}


- (NSString*)_explanationForNewsItemHeadline:(GDataXMLElement*)headline error:(NSError**)error;
{
    GDataXMLElement* siblingElement = (GDataXMLElement*)[headline firstNodeForXPath:@"following-sibling::*" error:error];
    if (siblingElement == nil)
        return nil;

    if (![siblingElement.name isEqualToString:@"p"])
        return nil;

    NSDereferenceAndAssignSafely(error, nil);

    NSString* explanation = siblingElement.stringValue;
    return explanation;
}


- (NSString*)_completeTextUrlForNewsItemHeadline:(GDataXMLElement*)headline error:(NSError**)error;
{
    GDataXMLElement* headlineLinkElement = (GDataXMLElement*)[headline firstNodeForXPath:@"a" error:error];
    if (headlineLinkElement == nil)
        return nil;

    NSDereferenceAndAssignSafely(error, nil);

    NSString* completeTextUrl = [headlineLinkElement attributeForName:@"href"].stringValue;
    return completeTextUrl;
}
@end
