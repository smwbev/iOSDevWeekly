//
//  COGUDevWeeklyNewsItem.h
//  iOSDevWeekly
//
//  Created by Colin Günther on 10.08.12.
//  Copyright (c) 2012 Cogun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class COGUDevWeeklyCategory, COGUDevWeeklyIssue;

@interface COGUDevWeeklyNewsItem : NSManagedObject

@property (nonatomic, retain) NSString * completeTextUrl;
@property (nonatomic, retain) NSString * explanation;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) COGUDevWeeklyCategory *category;
@property (nonatomic, retain) COGUDevWeeklyIssue *issue;

@end
