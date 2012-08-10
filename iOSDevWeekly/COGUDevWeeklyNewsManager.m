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
#import "NSObject+COGUBlocks.h"
#import "NSMutableArray+COGUAdditions.h"


static NSString* const kDevWeekylBaseURLString = @"http://iosdevweekly.com";
static NSString* const kDevWeeklyIssuesPath = @"/issues";


@implementation COGUDevWeeklyNewsManager

@synthesize devWeeklyClient = _devWeeklyClient;


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

    return kDevWeeklyIssuesPath;
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


#pragma mark - Private properties

- (AFHTTPClient*)devWeeklyClient;
{
    if (_devWeeklyClient)
        return _devWeeklyClient;
    
    NSURL* devWeeklyBaseURL = [NSURL URLWithString:kDevWeekylBaseURLString];
    _devWeeklyClient = [[AFHTTPClient alloc] initWithBaseURL:devWeeklyBaseURL];
    
    return _devWeeklyClient;
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

@end
