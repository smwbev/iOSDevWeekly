//
//  COGUViewController.h
//  iOSDevWeekly
//
//  Created by Colin Günther on 08.08.12.
//  Copyright (c) 2012 Cogun. All rights reserved.
//


#import <UIKit/UIKit.h>


@interface COGUNewsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>;

@property (weak, nonatomic) IBOutlet UITableView *newsListingControl;

@end
