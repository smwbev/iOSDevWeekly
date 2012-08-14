//
//  COGUNewsItemCell.h
//  iOSDevWeekly
//
//  Created by Colin Günther on 14.08.12.
//  Copyright (c) 2012 Cogun. All rights reserved.
//

#import "COGUNibTableCell.h"

@interface COGUNewsItemCell : COGUNibTableCell

@property (weak, nonatomic) IBOutlet UILabel *titleControl;
@property (weak, nonatomic) IBOutlet UILabel *explanationControl;
@property (weak, nonatomic) IBOutlet UILabel *issueControl;

@end
