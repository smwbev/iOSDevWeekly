//
//  UISearchBar+COGUAdditions.h
//  iOSDevWeekly
//
//  Created by Colin Günther on 16.10.12.
//  Copyright (c) 2012 Cogun. All rights reserved.
//


#import <UIKit/UIKit.h>


@interface UISearchBar (COGUAdditions)

/*!
 @brief The contents of the return key.
 @discussion see -[UITextInputTraits returnKeyType]
*/
@property (assign, nonatomic) UIReturnKeyType cogu_returnKeyType;

@end
