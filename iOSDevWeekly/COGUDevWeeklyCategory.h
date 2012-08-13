//
//  COGUDevWeeklyCategory.h
//  iOSDevWeekly
//
//  Created by Colin Günther on 13.08.12.
//  Copyright (c) 2012 Cogun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class COGUDevWeeklyNewsItem;

@interface COGUDevWeeklyCategory : NSManagedObject

@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * userReadableName;
@property (nonatomic, retain) NSOrderedSet *newsItems;
@end

@interface COGUDevWeeklyCategory (CoreDataGeneratedAccessors)

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
