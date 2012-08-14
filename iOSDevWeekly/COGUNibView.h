//
//  COGUNibView.h
//  iOSDevWeekly
//
//  Created by Colin Günther on 14.08.12.
//  Copyright (c) 2012 Cogun. All rights reserved.
//


/*!
 @brief This class makes loading and using nib based UIViews easier.
 @discussion For every new custom UIView you intend to you use you need to create a new class that inherits from COGUNibView in some way. Then you need to create a corresponding nib using the same name as your custom UIView class. This is to make automatic detection of the correct nib file possible. In the nib file you then create a UIView object and set it to the same class as your custom UIView. After that you are set up to design the interface of your custom view and establish IBOutlet-connections.
 Note: The view nib file is expected to reside in the main bundle.
*/


#import <UIKit/UIKit.h>


@interface COGUNibView : UIView

/*!
 @brief Creates a new view object using the corresponding nib file.
 @return The view object or nil if there was an error.
 */
+ (id)createView;


/*!
 @brief Returns the preferred view size.
 @return Size of view.
*/
+ (CGSize)preferredSize;


/*!
 @brief Called when creating the view from the nib file is finished.
 @discussion There are times where you want to run some customization to the view right after it was initialized. Override this method in the custom subclass to implement such behaviour. This method is called only ones during the life-time of the receiver.
 Note: You have to call -[super nibViewDidInitialize] in your custom implementation of this method <b>before</b> writing your own code.
*/
- (void)nibViewDidInitialize;

@end
