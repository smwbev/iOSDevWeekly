//
//  COGUNewsFetcher.h
//  iOSDevWeekly
//
//  Created by Colin Günther on 08.08.12.
//  Copyright (c) 2012 Cogun. All rights reserved.
//


/*!
 @brief This class manages fetching of iOS Dev Weekly issues and will update the database accordingly.
*/


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
@class GDataXMLDocument;


@interface COGUDevWeeklyNewsManager : NSObject

/*!
 @brief Fetches all issues that were published so far asynchronously.
 @discussion The database won't be touched after fetching did succeed.
 @param success Executed after successfully fetching all issues. The context object is nil always. @see COGUDevWeeklyNewsManagerSuccessHandler
 @param failure Executed after fetching all issues failed. @see COGUDevWeeklyNewsManagerFailureHandler
 @return Opaque fetcher object that can be used to cancel an ongoing fetch.
*/
- (id)fetchAllIssuesSuccessHandler:(COGUDevWeeklyNewsManagerSuccessHandler)success failureHandler:(COGUDevWeeklyNewsManagerFailureHandler)failure;


/*!
 @brief Only fetches the latest issue asynchronously.
 @discussion The database won't be touched after fetching did succeed.
 @param success Executed after successfully fetching all issues. The context object is nil always. @see COGUDevWeeklyNewsManagerSuccessHandler
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

@end


@interface COGUDevWeeklyNewsManager ()

@property (strong, nonatomic) AFHTTPClient* devWeeklyClient;

@end


@interface COGUDevWeeklyNewsManager (Private)

/**
 @brief Fetches the iOS Dev Weekly landing page.
 @param success Executed on success. The context object is of type GDataXMLDocument and represents the parsed landing page HTML. The context object may be nil.
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

@end
