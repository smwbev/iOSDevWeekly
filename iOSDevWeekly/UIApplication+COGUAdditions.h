//
//  UIApplication+COGUAdditions.h
//  iOSDevWeekly
//
//  Created by Colin Günther on 10.08.12.
//  Copyright (c) 2012 Cogun. All rights reserved.
//


#import <UIKit/UIKit.h>


@interface UIApplication (COGUAdditions)

/*!
 @brief Returns the URL to the applications document folder.
 @return URL to the applications document folder
*/
+ (NSURL*)cogu_documentFolderURL;

@end
