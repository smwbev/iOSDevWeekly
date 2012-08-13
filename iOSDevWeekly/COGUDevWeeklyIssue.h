//
//  COGUDevWeeklyIssue.h
//  iOSDevWeekly
//
//  Created by Colin Günther on 13.08.12.
//  Copyright (c) 2012 Cogun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class COGUDevWeeklyNewsItem;

@interface COGUDevWeeklyIssue : NSManagedObject

@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSDate * publishingDate;
@property (nonatomic, retain) NSString * userReadableName;
@property (nonatomic, retain) NSString * specifics;
@property (nonatomic, retain) NSOrderedSet *newsItems;
@end

@interface COGUDevWeeklyIssue (CoreDataGeneratedAccessors)

- (void)insertObject:(COGUDevWeeklyNewsItem *)value inNewsItemsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromNewsItemsAtIndex:(NSUInteger)idx;
- (void)insertNewsItems:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeNewsItemsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInNewsItemsAtIndex:(NSUInteger)idx withObject:(COGUDevWeeklyNewsItem *)value;
- (void)replaceNewsItemsAtIndexes:(NSIndexSet *)indexes withNewsItems:(NSArray *)values;
- (void)addNewsItemsObject:(COGUDevWeeklyNewsItem *)value;
- (void)removeNewsItemsObject:(COGUDevWeeklyNewsItem *)value;
- (void)addNewsItems:(NSOrderedSet *)values;
- (void)removeNewsItems:(NSOrderedSet *)values;
@end
