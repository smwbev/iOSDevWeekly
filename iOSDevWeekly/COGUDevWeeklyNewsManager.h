//
//  COGUNewsFetcher.h
//  iOSDevWeekly
//
//  Created by Colin Günther on 08.08.12.
//  Copyright (c) 2012 Cogun. All rights reserved.
//


/*!
 @brief This class manages fetching of iOS Dev Weekly issues and is providing methods to update the database accordingly.
*/


#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>


/*!
 @brief Block that is executed on success.
 @discussion The passed context object depends on the method where the block was passed to. For more information about the passed context object look at the method specification where the block is passed to.
 @param context An object of arbitrary value. May be nil.
*/
typedef void (^COGUDevWeeklyNewsManagerSuccessHandler)(id context);


/*!
 @brief Block that is executed on failure.
 @param error Contains more information describing the error leading to the failure. May be nil.
 */
typedef void (^COGUDevWeeklyNewsManagerFailureHandler)(NSError* error);


@class AFHTTPClient;
@class COGUDevWeeklyCategory;
@class COGUDevWeeklyIssue;
@class COGUDevWeeklyNewsItem;
@class GDataXMLDocument;
@class GDataXMLElement;


@interface COGUDevWeeklyNewsManager : NSObject


/*!
 @brief Provides access to the dev weekly issues
 @discussion Only access this context on the main queue. For long fetching operations the main thread might be blocked for quiet some time thus leading to an unresponding user interface.
*/
@property (strong, nonatomic, readonly) NSManagedObjectContext* devWeeklyManagedObjectContext;


/*!
 @brief Fetches and adds all dev weekly issues to the database.
 @discussion Prefilling will happen only when there are no dev weekly issues in the database yet. After successfully prefilling the database all dev weekly issues are going to be persisted, too. When there are dev weekly issues in the database before calling this method, no prefilling will be performed, but it is counted as successful prefilling nonetheless.
 @param success Executed after successfully prefilling the database. Must not be nil.
 The context object is of type NSNumber and contains the count of dev weekly issues that were fetched and added. The context object is never nil. @see COGUDevWeeklyNewsManagerSuccessHandler.

 @param failure Executed after prefilling the database failed. Must not be nil. All changes to the database are rolled back to the state before starting the prefill operation. The error object may be nil. @see COGUDevWeeklyNewsManagerFailureHandler
*/
- (void)prefillIssuesDatabaseIfEmptySuccessHandler:(COGUDevWeeklyNewsManagerSuccessHandler)success failureHandler:(COGUDevWeeklyNewsManagerFailureHandler)failure;


/*!
 @brief Tests whether syncing the local database with the website is needed at all asynchronously.
 @discussion Whether syncing is needed or not can be determined in the success handler only. When the failure handler is executed there is no implicit evidence contained that syncing is needed/not needed. You have to decide on yourself what to do in the failure case.
 @param success Executed after the need for syncing could be determined successfully.
 The context object is of type NSNumber an contains a boolean value with the following meanings:
  YES: Syncing is needed.
  NO: Syncing is not needed.

 The context object is never nil. @see COGUDevWeeklyNewsManagerSuccessHandler
 @param failure Executed after determine the need for syncing faild. The error object may be nil. @see COGUDevWeeklyNewsManagerFailureHandler
*/
- (void)isSyncingIssuesDatabaseWithDevWeeklyNeededSuccessHandler:(COGUDevWeeklyNewsManagerSuccessHandler)success failureHandler:(COGUDevWeeklyNewsManagerFailureHandler)failure;


/*!
 @brief Synchronizes the local database with the iOS Dev Weekly website.
 @discussion Syncing is done even if there is no need for, because we have all dev weekly issues in the local database already. Please use @see isSyncingIssuesDatabaseWithDevWeeklyNeededSuccessHandler:failureHandler: before you call this method.
 After successfully syncing the local database with all dev weekly issues from the iOS Dev Weekly website they are going to be persisted, too.  After successfully syncing, the local dev weekly issue count is equal to the dev weekly issue count on the website.
 @param success Executed after successfully syncing the database with the website.
 The context object is of type NSNumber and contains the count of issues that were added to the local database. The count is within the range of [0; current number of issues on the website]. The context object is never nil. @see COGUDevWeeklyNewsManagerSuccessHandler
 @param failure Executed after syncing the database with the website failed. All changes to the database are rolled back to the state before starting the sync operation. The error object may be nil. @see COGUDevWeeklyNewsManagerFailureHandler
*/
- (void)syncIssuesDatabaseWithDevWeeklySuccessHandler:(COGUDevWeeklyNewsManagerSuccessHandler)success failureHandler:(COGUDevWeeklyNewsManagerFailureHandler)failure;


/*!
 @brief Returns the number of issues currently in the database.
 @param error If an error occurs, upon return contains an NSError object that describes the problem. Pass nil if you aren't interested in error information.
 @return Number of issues in database or nil if there was an error.
*/
- (NSNumber*)numberOfIssuesInDatabaseError:(NSError**)error;


/*!
 @brief Fetches all issues that were published so far asynchronously.
 @discussion The database won't be touched after fetching did succeed.
 @param success Executed after successfully fetching all issues.
 The context object is of type NSArray and contains objects of type GDataXMLDocument and represents the parsed iOS Dev Weekly HTML pages. The context object is never nil. @see COGUDevWeeklyNewsManagerSuccessHandler

 @param failure Executed after fetching all issues failed. The error object may be nil. @see COGUDevWeeklyNewsManagerFailureHandler
 @return Opaque fetcher object that can be used to cancel an ongoing fetch.
*/
- (id)fetchAllIssuesSuccessHandler:(COGUDevWeeklyNewsManagerSuccessHandler)success failureHandler:(COGUDevWeeklyNewsManagerFailureHandler)failure;


/*!
 @brief Adds an issue to the database.
 @discussion After adding the issue to the database you need to perform a database sync, otherwise data may get lost on an app crash.
 @param issueDocument Will be added to the database. Must not be nil.
 @param error If an error occurs, upon return contains an NSError object that describes the problem. Pass nil if you aren't interested in error information.
 @return YES if the issue was added, otherwise NO.
*/
- (BOOL)addIssueToDatabase:(GDataXMLDocument*)issueDocument error:(NSError**)error;


/*!
 @brief Adds issues to the database and persists them afterwards.
 @discussion After adding the issues to the database you don't need to perform a database sync as it is part of this method already.
 @param issueDocuments Array of issue documents of type GDataXMLDocument that will be added to the database. Must not be nil.
 @param error If an error occurs, upon return contains an NSError object that describes the problem. Pass nil if you aren't interested in error information.
 @return YES if the issues were added, otherwise NO.
 */
- (BOOL)addIssuesToDatabaseAndPersists:(NSArray*)issueDocuments error:(NSError**)error;


/*!
 @brief Syncs all entities to disc.
 @param error If an error occurs, upon return contains an NSError object that describes the problem. Pass nil if you aren't interested in error information.
 @return YES if persisting succeeded, otherwise NO.
*/
- (BOOL)persistDatabaseError:(NSError**)error;


/*!
 @brief Only fetches the latest dev weekly issue asynchronously.
 @discussion The database won't be touched after fetching did succeed.
 @param success Executed after successfully fetching the latest dev weekly issue.
 The context object is of type GDataXMLDocument and represents the latest parsed iOS Dev Weekly HTML page. The context object is never nil. @see COGUDevWeeklyNewsManagerSuccessHandler
 @param failure Executed after fetching the latest dev weekly issues failed. The error object may be nil. @see COGUDevWeeklyNewsManagerFailureHandler
 @return Opaque fetcher object that can be used to cancel an ongoing fetch.
*/
- (id)fetchLatestIssueOnlySuccessHandler:(COGUDevWeeklyNewsManagerSuccessHandler)success failureHandler:(COGUDevWeeklyNewsManagerFailureHandler)failure;


/*!
 @brief Only fetches the number of dev weekly issues on the website asynchronously.
 @discussion The database won't be touched after fetching did succeed.
 @success Executed after successfully fetching the number of dev weekly issues on the website.
 The context object is of type NSNumber whose value is the number of dev weekly issues on the website. The value is in the range of [0; current number of dev weekly issues]. The context object is never nil. @see COGUDevWeeklyNewsManagerSuccessHandler
 @param failure Executed after fetching the number of dev weekly issues failed. The error object may be nil. @see COGUDevWeeklyNewsManagerFailureHandler
 @return Opaque fetcher object that can be used to cancel an ongoing fetch.
*/
- (id)fetchNumberOfIssuesOnWebsiteSuccessHandler:(COGUDevWeeklyNewsManagerSuccessHandler)success failureHandler:(COGUDevWeeklyNewsManagerFailureHandler)failure;


/*!
 @brief Cancels the fetching process.
 @discussion After canceling the passed fetcher there will be no calls to associated handler blocks.
 @param fetcher Opaque object that is used to identify the fetching process to cancel.
*/
- (void)cancelFetcher:(id)fetcher;


/*!
 @brief Purges the database to oblivion.
 @discussion This method is intended for unit tests where you want to start from scratch.
*/
- (void)removeDatabase;

@end


@interface COGUDevWeeklyNewsManager ()

@property (strong, nonatomic) AFHTTPClient* devWeeklyClient;
@property (strong, nonatomic) NSPersistentStoreCoordinator* devWeeklyStoreCoordinator;
@property (strong, nonatomic) NSURL* devWeeklyStoreURL;
@property (strong, nonatomic) NSManagedObjectContext* devWeeklyManagedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel* devWeeklyManagedObjectModel;
@property (strong, nonatomic) NSDateFormatter* devWeeklyPublishingDateFormatter;

@end


@interface COGUDevWeeklyNewsManager (Private)

/**
 @brief Fetches the iOS Dev Weekly landing page.
 @param success Executed on success. The context object is of type GDataXMLDocument and represents the parsed landing page HTML. The context object is never nil.
 @param failure Executed on failure. The error object may be nil.
*/
- (void)_fetchLandingPageSuccessHandler:(COGUDevWeeklyNewsManagerSuccessHandler)success failureHandler:(COGUDevWeeklyNewsManagerFailureHandler)failure;


/**
 @brief Extracts the relative path to the issues listing.
 @param landingPageDocument The iOS Dev Weekly landing page document containing the path to the issue listing. Must not be nil. @see -[self _fetchLandingPageSuccessHandler:success:failure:]
 @return Relative path that can be used to fetch the issue listing using the dev weekly client.
 @return nil No path could be extracted.
*/
- (NSString*)_pathToIssuesListingFromLandingPage:(GDataXMLDocument*)landingPageDocument;


/**
 @brief Extracts the relative paths to all issues.
 @param issuesListingDocument The iOS Dev Weekly issue listing document containing the paths to all issues. Must not be nil. @see -[self _fetchIssuesListingWithPath:success:failure:]
 @return Collection of NSString objects with each one containing the relative path to an issue. A relative path can be used to fetch the associated issue using the dev weekly client.
 @return nil No paths could be extracted.
*/
- (NSArray*)_pathsToIssuesFromIssuesListing:(GDataXMLDocument*)issuesListingDocument;


/**
 @brief Fetches an iOS Dev Weekly HTML page.
 @param path The relative path to the page to be fetched. Must not be nil.
 @param success Executed on success. The context object is of type GDataXMLDocumend and represents the parsed HTML page. The context object is never nil.
 @param failure Executed on failure. The error object may be nil.
 */
- (void)_fetchHTMLPageWithPath:(NSString*)path successHandler:(COGUDevWeeklyNewsManagerSuccessHandler)success failureHandler:(COGUDevWeeklyNewsManagerFailureHandler)failure;


/**
 @brief Fetches or creates the issue entity for the passed issue HTML document.
 @return Object if fetching or creating succeeded. Nil, otherwise.
*/
- (COGUDevWeeklyIssue*)_fetchOrCreateIssueEntityForIssue:(GDataXMLDocument*)issue error:(NSError**)error;


/**
 @brief Configures the passed issue entity with information from the passed issue HTML document.
 @return YES if configuration succeeded. NO, otherwise.
*/
- (BOOL)_configureIssueEntity:(COGUDevWeeklyIssue*)issueEntity withIssue:(GDataXMLDocument*)issue error:(NSError**)error;


/**
 @brief Extracts the news category node elements from the passed issue HTML document.
 @return Array with objects of type GDataXMLElement. Nil, if there was an error.
*/
- (NSArray*)_categoryElementsInIssue:(GDataXMLDocument*)issue error:(NSError**)error;


/**
 @brief Fetches or creates the category entity for the passed category node element.
 @return Object if fetching or creating succeeded. Nil, otherwise.
*/
- (COGUDevWeeklyCategory*)_fetchOrCreateCategoryEntityForCategory:(GDataXMLElement*)category error:(NSError**)error;


/**
 @brief Configures the passed category entity with information from the passed category node element.
 @return YES if configuration succeeded. NO, otherwise.
*/
- (BOOL)_configureCategoryEntity:(COGUDevWeeklyCategory*)categoryEntity withCategory:(GDataXMLElement*)category issueEntity:(COGUDevWeeklyIssue*)issueEntity error:(NSError**)error;


/**
 @brief Extracts the news item headline node elements from the passed category node element.
 @return Array with objects of type GDataXMLElement. Nil, if there was an error.
*/
- (NSArray*)_newsItemHeadlineElementsInCategory:(GDataXMLElement*)category error:(NSError**)error;


/**
 @brief Creates the news item entity for the passed news item headline node element.
 @return Object if creating succeeded. Nil, otherwise.
*/
- (COGUDevWeeklyNewsItem*)_createNewsItemEntityForNewsItemHeadline:(GDataXMLElement*)newsItemHeadline error:(NSError**)error;

/**
 @brief Configures the passed news item entity with information from the passed news item headline node element.
 @return YES if configuration succeeded. NO, otherwise.
*/
- (BOOL)_configureNewsItemEntity:(COGUDevWeeklyNewsItem*)newsItemEntity withNewsItemHeadline:(GDataXMLElement*)newsItemHeadline error:(NSError**)error;

/**
 @brief Extracts the number of the passed issue HTML document.
 @return Object if extraction succeeded. Nil, otherwise.
*/
- (NSNumber*)_numberOfIssue:(GDataXMLDocument*)issue error:(NSError**)error;


/**
 @brief Extracts the publishing date of the passed issue HTML document.
 @return Object if extraction succeeded. Nil, otherwise.
*/
- (NSDate*)_publishingDateOfIssue:(GDataXMLDocument*)issue error:(NSError**)error;


/**
 @brief Extracts any specifics of the passed issue HTML document.
 @return Object if extraction succeeded. Nil, otherwise.
 */
- (NSString*)_specificsOfIssue:(GDataXMLDocument*)issue error:(NSError**)error;


/**
 @brief Extracts the user readable name of the passed issue HTML document.
 @return Object if extraction succeeded. Nil, otherwise.
 */
- (NSString*)_userReadableNameOfIssue:(GDataXMLDocument*)issue error:(NSError**)error;


/**
 @brief Extracts the type of the passed category node element.
 @return Object if extraction succeeded. Nil, otherwise.
*/
- (NSString*)_typeOfCategory:(GDataXMLElement*)category error:(NSError**)error;


/**
 @brief Extracts the user readable name of the passed category node element.
 @return Object if extraction succeeded. Nil, otherwise.
*/
- (NSString*)_userReadableNameOfCategory:(GDataXMLElement*)category error:(NSError**)error;


/**
 @brief Extracts the title of the passed news item headline node element.
 @return Object if extraction succeeded. Nil, otherwise.
 */
- (NSString*)_titleOfNewsItemHeadline:(GDataXMLElement*)headline error:(NSError**)error;


/**
 @brief Extracts the news item explanation of the passed news item headline node element.
 @return Object if extraction succeeded. Nil, otherwise.
 */
- (NSString*)_explanationForNewsItemHeadline:(GDataXMLElement*)headline error:(NSError**)error;


/**
 @brief Extracts the URL for the complete news item text of the passed news item headline node element.
 @return Object if extraction succeeded. Nil, otherwise.
 */
- (NSString*)_completeTextUrlForNewsItemHeadline:(GDataXMLElement*)headline error:(NSError**)error;

@end
