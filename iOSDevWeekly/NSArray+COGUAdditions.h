//
//  NSArray+COGUAdditions.h
//  iOSDevWeekly
//
//  Created by Colin Günther on 10.08.12.
//  Copyright (c) 2012 Cogun. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface NSArray (COGUAdditions)

/*!
 @brief Returns the first object in the array that passes a test in a given Block.
 @discussion This method is a wrapper about -[NSArray indexOfObjectPassingTest:] so you can look there for more information.
 If the block parameter is nil this method will raise an exception.
 @param predicate The block to apply to elements in the array.
 The block takes three arguments:
 obj The element in the array.
 idx The index of the element in the array.
 stop A reference to a Boolean value. The block can set the value to YES to stop further processing of the array. The stop argument is an out-only argument. You should only ever set this Boolean to YES within the Block.
 The Block returns a Boolean value that indicates whether obj passed the test.

 @return The first object in the array that passes the test specified by predicate. If no objects in the array pass the test, returns nil.
*/
- (id)cogu_firstObjectPassingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate;


/*!
 @brief Evaluates a test in a given block against each object in the receiving array and returns a new array containing the objects for which the block returns true.
 @discussion If the block parameter is nil this method will raise an exception.
 @param predicate The block used to evaluate the receiving array’s elements.
 The block takes three arguments:
 obj The element in the array.
 idx The index of the element in the array.
 stop A reference to a Boolean value. The block can set the value to YES to stop further processing of the array. The stop argument is an out-only argument. You should only ever set this Boolean to YES within the Block.
 The Block returns a Boolean value that indicates whether obj passed the test.
 
 @return A new array containing the objects in the receiving array for which the block returns true.
 */
- (NSArray*)cogu_filteredArrayUsingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate;


/*!
 @brief Applies a mapper in a block against each object in the receiving array and returns a new array containing the mapped objects.
 @discussion If you map an element to nil the element will have no mapped equivalent in the new array leading to a decrease in element count in the new array. If you want to ensure same element count between the original and the new array your mapper should return [NSNull null] instead.
 If the block parameter is nil this method will raise an exception.

 @param mapper The block used to map the receiving array’s elements.
 The block takes three arguments:
 obj The element in the array.
 idx The index of the element in the array.
 stop A reference to a Boolean value. The block can set the value to YES to stop further processing of the array. The stop argument is an out-only argument. You should only ever set this Boolean to YES within the Block.
 The Block returns the mapped object.
 
 @return A new array containing the objects in the receiving array for which the block returns true.
 */
- (NSArray*)cogu_mappedArrayUsingBlock:(id (^)(id obj, NSUInteger idx, BOOL *stop))mapper;

@end
