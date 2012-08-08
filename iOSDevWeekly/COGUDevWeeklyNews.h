//
//  COGUDevWeeklyNews.h
//  iOSDevWeekly
//
//  Created by Colin Günther on 08.08.12.
//  Copyright (c) 2012 Cogun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class COGUDevWeeklyCategory, COGUDevWeeklyIssue;

@interface COGUDevWeeklyNews : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * explanation;
@property (nonatomic, retain) NSString * completeTextUrl;
@property (nonatomic, retain) COGUDevWeeklyIssue *issue;
@property (nonatomic, retain) COGUDevWeeklyCategory *category;

@end
