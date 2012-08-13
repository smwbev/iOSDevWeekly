//
//  UIApplication+COGUAdditions.m
//  iOSDevWeekly
//
//  Created by Colin Günther on 10.08.12.
//  Copyright (c) 2012 Cogun. All rights reserved.
//


#import "UIApplication+COGUAdditions.h"


@implementation UIApplication (COGUAdditions)

+ (NSURL*)cogu_documentFolderURL;
{
    NSURL* documentFolderURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    return documentFolderURL;
}

@end
