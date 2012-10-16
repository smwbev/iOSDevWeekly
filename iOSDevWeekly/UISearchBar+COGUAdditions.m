//
//  UISearchBar+COGUAdditions.m
//  iOSDevWeekly
//
//  Created by Colin Günther on 16.10.12.
//  Copyright (c) 2012 Cogun. All rights reserved.
//


#import "UISearchBar+COGUAdditions.h"

#import "UIView+COGUAdditions.h"


@implementation UISearchBar (COGUAdditions)

@dynamic cogu_returnKeyType;

- (UIReturnKeyType)cogu_returnKeyType;
{
    UIView<UITextInputTraits>* textInputView = (UIView<UITextInputTraits>*)[self cogu_firstSubviewConformingToProtocol:@protocol(UITextInputTraits)];

    return textInputView.returnKeyType;
}


- (void)setCogu_returnKeyType:(UIReturnKeyType)cogu_returnKeyType;
{
    NSArray* textInputViews = [self cogu_subviewsConformingToProtocol:@protocol(UITextInputTraits)];

    [textInputViews enumerateObjectsUsingBlock:^(UIView<UITextInputTraits>* textInputView, NSUInteger index, BOOL* stop) {
        textInputView.returnKeyType = cogu_returnKeyType;
    }];
}

@end
