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
 @brief Only fetches the latest issue asynchronously.
 @discussion The database won't be touched after fetching did succeed.
 @param success Executed after successfully fetching the latest issue. The context object is nil always. @see COGUDevWeeklyNewsManagerSuccessHandler
 @param failure Executed after fetching all issues failed. @see COGUDevWeeklyNewsManagerFailureHandler
 @return Opaque fetcher object that can be used to cancel an ongoing fetch.
*/
- (id)fetchLatestIssueOnlySuccessHandler:(COGUDevWeeklyNewsManagerSuccessHandler)success failureHandler:(COGUDevWeeklyNewsManagerFailureHandler)failure;

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
