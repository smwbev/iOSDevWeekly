//
//  COGUDevWeeklyIssue.h
//  iOSDevWeekly
//
//  Created by Colin Günther on 08.08.12.
//  Copyright (c) 2012 Cogun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class COGUDevWeeklyNews;

@interface COGUDevWeeklyIssue : NSManagedObject

@property (nonatomic, retain) NSDate * publishingDate;
@property (nonatomic, retain) NSString * userReadableName;
@property (nonatomic, retain) NSOrderedSet *news;
@end

@interface COGUDevWeeklyIssue (CoreDataGeneratedAccessors)

- (void)insertObject:(COGUDevWeeklyNews *)value inNewsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromNewsAtIndex:(NSUInteger)idx;
- (void)insertNews:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeNewsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInNewsAtIndex:(NSUInteger)idx withObject:(COGUDevWeeklyNews *)value;
- (void)replaceNewsAtIndexes:(NSIndexSet *)indexes withNews:(NSArray *)values;
- (void)addNewsObject:(COGUDevWeeklyNews *)value;
- (void)removeNewsObject:(COGUDevWeeklyNews *)value;
- (void)addNews:(NSOrderedSet *)values;
- (void)removeNews:(NSOrderedSet *)values;
@end
