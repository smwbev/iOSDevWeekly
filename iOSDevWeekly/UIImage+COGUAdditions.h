//
//  UIImage+COGUAdditions.h
//  iOSDevWeekly
//
//  Created by Colin Günther on 16.10.12.
//  Copyright (c) 2012 Cogun. All rights reserved.
//


#import <UIKit/UIKit.h>


@interface UIImage (COGUAdditions)

/*!
 @brief Creates a 1x1 pt sized image filled with the passed color.
 @discussion Only solid colors are supported. When passing a pattern color the behaviour is undefined.
   Code is inspired by http://stackoverflow.com/questions/990976/how-to-create-a-colored-1x1-uiimage-on-the-iphone-dynamically
 @parameter color Used to fill the image. Must not be nil.
 @return UIImage object that is filled with the passed color.
*/
+ (UIImage*)imageWithColor:(UIColor*)color;

@end
