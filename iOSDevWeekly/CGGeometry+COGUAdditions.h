//
//  CGGeometry+COGUAdditions.h
//  iOSDevWeekly
//
//  Created by Colin Günther on 16.10.12.
//  Copyright (c) 2012 Cogun. All rights reserved.
//


#ifndef iOSDevWeekly_CGGeometry_COGUAdditions_h
#define iOSDevWeekly_CGGeometry_COGUAdditions_h

#include <CoreGraphics/CGGeometry.h>


/* Make a rect from `(x, y; size)'. */
CG_INLINE CGRect CGRectMakeWithSize(CGFloat x, CGFloat y, CGSize size);


/*** Definitions of inline functions. ***/

CG_INLINE CGRect
CGRectMakeWithSize(CGFloat x, CGFloat y, CGSize size)
{
    CGRect rect = CGRectMake(x, y, size.width, size.height);
    return rect;
}

#endif
