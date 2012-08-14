//
//  COGUNibTableCell.h
//  iOSDevWeekly
//
//  Created by Colin Günther on 14.08.12.
//  Copyright (c) 2012 Cogun. All rights reserved.
//


/*!
 @brief This class makes loading and using nib based UITableViewCells easier.
 @discussion For every new custom UITableViewCell you intend to you use you need to create a new class that inherits from COGUNibTableCell in some way. Then you need to create a corresponding nib using the same name as your custom UITableViewCell class. This is to make automatic detection of the correct nib file possible. In the nib file you then create a UITableViewCell object and set it to the same class as your custom UITableViewCell. You also need to make sure that the reuse identifier is set to the name of the class. After that you are set up to design the interface of your custom cell and establish IBOutlet-connections.
 Note: The cell nib file is expected to reside in the main bundle.
*/

#import <UIKit/UIKit.h>

@interface COGUNibTableCell : UITableViewCell

/*!
 @brief Creates a new cell object using the corresponding nib file.
 @return The cell object or nil if there was an error.
*/
+ (id)createCell;


/*!
 @brief Returns the reuse identifier for the cell.
 @discussion The reuse identifier is derived from the class name of the receiver.
 @return The reuse identifier that is specific to the receiver. Is never nil.
*/
+ (NSString*)reuseIdentifier;


/*!
 @brief Returns the preferred cell height.
 @return Number representing the preferred cell height.
*/
+ (CGFloat)preferredCellHeight;

@end
