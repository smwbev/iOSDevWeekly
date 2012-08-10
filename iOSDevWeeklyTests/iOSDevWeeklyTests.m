//
//  iOSDevWeeklyTests.m
//  iOSDevWeeklyTests
//
//  Created by Colin Günther on 08.08.12.
//  Copyright (c) 2012 Cogun. All rights reserved.
//


#import "iOSDevWeeklyTests.h"

#import "COGUDevWeeklyNewsManager.h"


@implementation iOSDevWeeklyTests

- (void)setUp
{
    [super setUp];
    self.newsManager = [[COGUDevWeeklyNewsManager alloc] init];
}


- (void)tearDown
{
    [super tearDown];
    self.newsManager = nil;
}


- (void)testFetchingAllWeeklyNewsIssues;
{
    dispatch_semaphore_t testCompleted = dispatch_semaphore_create(0);

    [self.newsManager fetchAllIssuesSuccessHandler:^(id context){
        STAssertNotNil(context, nil);
        dispatch_semaphore_signal(testCompleted);
    } failureHandler:^(NSError *error) {
        STFail(@"Failed to fetch all issues (error: %@)", error);
        dispatch_semaphore_signal(testCompleted);
    }];

    while (dispatch_semaphore_wait(testCompleted, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
    
    dispatch_release(testCompleted);
}

@end
