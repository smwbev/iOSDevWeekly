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

@end
