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


typedef void (^COGUDevWeeklyNewsManagerSuccessHandler)(void);
typedef void (^COGUDevWeeklyNewsManagerFailureHandler)(NSError* error);


@interface COGUDevWeeklyNewsManager : NSObject

/*!
 @brief Fetches all issues that were published so far asynchronously.
 @discussion The database won't be touched after fetching did succeed.
 @param success Executed after successfully fetching all issues. @see COGUDevWeeklyNewsManagerSuccessHandler
 @param failure Executed after fetching all issues failed. @see COGUDevWeeklyNewsManagerFailureHandler
 @return Opaque fetcher object that can be used to cancel an ongoing fetch.
*/
- (id)fetchAllIssuesSuccessHandler:(COGUDevWeeklyNewsManagerSuccessHandler)success failureHandler:(COGUDevWeeklyNewsManagerFailureHandler)failure;


/*!
 @brief Only fetches the latest issue asynchronously.
 @discussion The database won't be touched after fetching did succeed.
 @param success Executed after successfully fetching all issues. @see COGUDevWeeklyNewsManagerSuccessHandler
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
