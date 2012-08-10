//
//  iOSDevWeeklyTests.h
//  iOSDevWeeklyTests
//
//  Created by Colin Günther on 08.08.12.
//  Copyright (c) 2012 Cogun. All rights reserved.
//


#import <SenTestingKit/SenTestingKit.h>


@class COGUDevWeeklyNewsManager;


@interface iOSDevWeeklyTests : SenTestCase

@property (strong, nonatomic) COGUDevWeeklyNewsManager* newsManager;

@end
