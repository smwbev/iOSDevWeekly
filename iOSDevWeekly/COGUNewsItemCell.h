//
//  COGUNewsItemCell.h
//  iOSDevWeekly
//
//  Created by Colin Günther on 14.08.12.
//  Copyright (c) 2012 Cogun. All rights reserved.
//


#import "COGUNibTableCell.h"


@class COGUDevWeeklyNewsItem;
@class SBLayoutManager;


@interface COGUNewsItemCell : COGUNibTableCell

/*!
 @brief Calculates the preferred cell height.
 @discussion To support dynamic cell heights a table view needs the cell height <b>before</b> the first cell ever gets created. This method allows to calculate the height for each cell individually depending on the passed news item.
 @param newsItem Contains the content the cell will use for its height calculations. Is allowed to be nil.
 @param tabelView The tableView which is asking for the cell height. This is mainly used to correctly adapt to changes in table view frames (e.g. portrait mode vs. landscape mode).
 @return The height of the cell when it is configured with the news item.
*/
+ (CGFloat)preferredHeightWhenConfiguredWithNewsItem:(COGUDevWeeklyNewsItem*)newsItem inTableView:(UITableView*)tableView;

@property (weak, nonatomic) IBOutlet UILabel *titleControl;
@property (weak, nonatomic) IBOutlet UILabel *explanationControl;
@property (weak, nonatomic) IBOutlet UILabel *issueControl;
@property (weak, nonatomic) IBOutlet UIView *issueBackgroundControl;
@property (weak, nonatomic) IBOutlet UIImageView *completeIssueHintControle;
@property (nonatomic) CGFloat preferredHeight;


/*!
 @brief Configures the cell and lays out the subviews accordingly.
 @discussion The cell knows best what information it can display and how to display it. So as this is somewhat against the MVC pattern it improves readability of code.
 @param newsItem Contains the content the cell will configure itself with.
*/
- (void)configureWithNewsItem:(COGUDevWeeklyNewsItem*)newsItem;

@end


@interface COGUNewsItemCell ()

@property (strong, nonatomic) SBLayoutManager* subviewsLayoutManager;

@end