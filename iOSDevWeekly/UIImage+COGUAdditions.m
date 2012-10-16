//
//  UIImage+COGUAdditions.m
//  iOSDevWeekly
//
//  Created by Colin Günther on 16.10.12.
//  Copyright (c) 2012 Cogun. All rights reserved.
//


#import "UIImage+COGUAdditions.h"

#import <QuartzCore/QuartzCore.h>

#import "CGGeometry+COGUAdditions.h"


@implementation UIImage (COGUAdditions)

+ (UIImage*)imageWithColor:(UIColor*)color;
{
    #define IMAGE_LENGTH_IN_POINT 1.0
    static CGSize const kImageSize = {
        .width = IMAGE_LENGTH_IN_POINT,
        .height = IMAGE_LENGTH_IN_POINT
    };

    UIGraphicsBeginImageContext(kImageSize);

    [color set];

    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMakeWithSize(0.0, 0.0, kImageSize));
    
    UIImage* solidColorImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return solidColorImage;
}

@end
