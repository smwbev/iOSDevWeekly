//
//  COGUNewsItemCell.m
//  iOSDevWeekly
//
//  Created by Colin Günther on 14.08.12.
//  Copyright (c) 2012 Cogun. All rights reserved.
//


#import "COGUNewsItemCell.h"

#import "SBLayoutManager.h"

#import "COGUDevWeeklyIssue.h"
#import "COGUDevWeeklyNewsItem.h"


@implementation COGUNewsItemCell

@synthesize titleControl;
@synthesize explanationControl;
@synthesize issueControl;
@synthesize issueBackgroundControl;
@synthesize completeIssueHintControle;
@dynamic preferredHeight;
@synthesize subviewsLayoutManager = _subviewsLayoutManager;


#pragma mark COGUNibTableCell

- (void)nibTableCellDidInitialize;
{
    [super nibTableCellDidInitialize];

    [self.subviewsLayoutManager viewIsVariableHeight:self.titleControl];
    [self.subviewsLayoutManager viewIsVariableHeight:self.explanationControl];
    [self.subviewsLayoutManager view:self.explanationControl isBelowView:self.titleControl];
    [self.subviewsLayoutManager view:self.issueControl isBelowView:self.explanationControl];
    [self.subviewsLayoutManager view:self.issueBackgroundControl isBelowView:self.explanationControl];
    [self.subviewsLayoutManager view:self.completeIssueHintControle isBelowView:self.explanationControl];
}


#pragma mark Interface

+ (CGFloat)preferredHeightWhenConfiguredWithNewsItem:(COGUDevWeeklyNewsItem*)newsItem inTableView:(UITableView*)tableView;
{
    static COGUNewsItemCell* sOffscreenCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sOffscreenCell = [self createCell];
    });

    sOffscreenCell.bounds = CGRectMake(0, 0, tableView.frame.size.width, 0);
    [sOffscreenCell configureWithNewsItem:newsItem];

    return sOffscreenCell.preferredHeight;
}


- (void)configureWithNewsItem:(COGUDevWeeklyNewsItem*)newsItem;
{
    self.titleControl.text = newsItem.title;
    self.explanationControl.text = newsItem.explanation;
    self.issueControl.text = newsItem.issue.userReadableName;

    [self.subviewsLayoutManager layout];
}


#pragma mark Public properties

- (CGFloat)preferredHeight;
{
    return CGRectGetMaxY(self.issueControl.frame);
}


#pragma mark Private properties

- (SBLayoutManager*)subviewsLayoutManager;
{
    if (_subviewsLayoutManager)
        return _subviewsLayoutManager;

    _subviewsLayoutManager = [SBLayoutManager layoutManagerWithRootView:self];

    return _subviewsLayoutManager;
}

@end
