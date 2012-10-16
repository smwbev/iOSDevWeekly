//
//  UIView+COGUAdditions.h
//  iOSDevWeekly
//
//  Created by Colin Günther on 16.10.12.
//  Copyright (c) 2012 Cogun. All rights reserved.
//


#import <UIKit/UIKit.h>


@interface UIView (COGUAdditions)

/*!
 @brief Returns all subviews conforming to passed protocol.
 @discussion  The object order can change with every method call even when the view hierarchy is left unchanged. @see -[NSObject conformsToProtocol:]

 @param protocol The protocol that the returned subviews need to conform to.
 @return Array containing all conforming subviews.
 @return Empty array when there are no conforming subviews.
*/
- (NSArray*)cogu_subviewsConformingToProtocol:(Protocol*)protocol;

/*!
 @brief Returns the first subview that conforms to the passed protocol.
 @discussion The first subview returned can change over multiple method calls even when the view hierarchy is left unchanged.

 @param protocol The protocol that the returned subview needs to conform to.
 @return The first UIView object that conforms to the passed protocol or nil if there is no subview conforming to the passed protocol.
*/
- (UIView*)cogu_firstSubviewConformingToProtocol:(Protocol*)protocol;


/*!
 @brief Executes a given block on each subview.
 @discussion The subviews are enumerated depth-first.
             The root view doesn't take part in the enumeration process.

 @param block The block to apply to each subview. Must not be nil.
        @param subview A subview of the root view.
        @param stop A reference to a boolean value. The block can set the value to YES to stop further processing of the array. The stop argument is an out-only argument. You should only ever set this Boolean to YES within the Block.
*/
- (void)cogu_enumerateSubviewsDepthFirstUsingBlock:(void (^)(UIView* subview, BOOL* stop))block;


@end
