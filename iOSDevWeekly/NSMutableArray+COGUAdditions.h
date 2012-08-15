//
//  NSMutableArray+COGUAdditions.h
//  iOSDevWeekly
//
//  Created by Colin Günther on 10.08.12.
//  Copyright (c) 2012 Cogun. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface NSMutableArray (COGUAdditions)

/*!
 @brief Inserts a given object at the end of the receiver.
 @discussion This method is a wrapper around -[NSMutableArray addObject:]. It will permit nil objects to be passed. Nil objects will be discarded and won't be transformed into [NSNull null] objects.
 @see -[NSMutableArray addObject:].
 @param anObject The object to add to the end of the receiver's content. This value may be nil.
 */
- (void)cogu_addObjectOrNil:(id)anObject;


/*!
 @brief Replaces the old object with anObject.
 @discussion It is assumed that the receiver contains distinctive objects only. Otherwise the first object equal to oldObject will be replaced (@see -[NSArray indexOfObject:]).
 @see -[NSMutableArray replaceObjectAtIndex:withObject]
 @param oldObject The object to be replaced. If this object isn't contained in the receiver the receiver remains unchanged.
 @param anObject The object with which to replace the object in the receiver. This value must not be nil.
 <b>Important</b> Raises an NSInvalidArgumentException if anObject is nil.
*/
- (void)cogu_replaceObject:(id)oldObject withObject:(id)anObject;


/*!
 @brief Inserts a given object at the end of the receiver over and over again until it matches the passed times number.
 @param anObject The object to add to the end of the receiver's content. This value must not be nil.
 <b>Important</b> Raises an NSInvalidArgumentException if anObject is nil.

 @param times Tells the receiver how often to add the passed object.
*/
- (void)cogu_addObject:(id)anObject times:(NSUInteger)times;


/*!
 @brief Returns an object in the receiver at an arbitrary index.
 @discussion If the index is not within the bounds of the receiver, the receiver will add placeholder objects until the index is within the bounds. After that the receiver inserts the default object at the index and returns it.
 @param index An index into the receiver. Is allowed to be out of bounds.
 @param defaultObject An object that will be added at the index if the index is out of bounds or if the index points to a placeholder object.
 <b>Important</b> Raises an NSInvalidArgumentException if defaultObject is nil and the index is out of bounds.

 @return The object located at the index.
*/
- (id)cogu_objectAtLazyInitializedIndex:(NSUInteger)index defaultObject:(id)defaultObject;


/*!
 @brief Replaces the object at index with anObject.
 @discussion If the passed index is not within the bounds of the receiver, the receiver will add placeholder objects until the index is within the bounds. After that the receiver inserts the passed object at the passed index.
 @param index The index of the object to be replaced. This value is allowed to exceed the bounds.
 @param anObject The object with which to replace the object at the passed index. This value must not be nil.
 <b>Important</b> Raises an NSInvalidArgumentException if anObject is nil.
*/
- (void)cogu_replaceObjectAtLazyInitializedIndex:(NSUInteger)index withObject:(id)anObject;


/*!
 @brief Returns an object in the receiver at an arbitrary index path.
 @discussion If the index path is not within the bounds of the receiver, the receiver will add placeholder objects until the index path is within the bounds. After that the receiver inserts the default object at the index path and returns it.
 @param indexPath An index path into the receiver. Is allowed to be out of bounds.
 @param defaultObject An object that will be added at the index path if the index path is out of bounds or the if the index path points to a placeholder object.
 <b>Important</b> Raises an NSInvalidArgumentException if defaultObject is nil and the index path is out of bounds.

 @return The object located at the index path.
 */
- (id)cogu_objectAtLazyInitializedIndexPath:(NSIndexPath*)indexPath defaultObject:(id)defaultObject;


/*!
 @brief Replaces the object at indexPath with anObject.
 @discussion If the index path is not within the bounds of the receiver, the receiver will add placeholder objects until the index path is within the bounds. After that the receiver inserts the object at the index path.
 @param indexPath The index path of the object to be replaced. This value is allowed to exceed the bounds.
 @param anObject The object with which to replace the object at the index path. This value must not be nil.
 <b>Important</b> Raises an NSInvalidArgumentException if anObject is nil.
 */
- (void)cogu_replaceObjectAtLazyInitializedIndexPath:(NSIndexPath*)indexPath withObject:(id)anObject;

@end
