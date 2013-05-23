//
//  GameDetailsViewController.m
//  ARIS
//
//  Created by David J Gagnon on 4/18/10.
//  Copyright 2010 University of Wisconsin - Madison. All rights reserved.
//

#import <MapKit/MKReverseGeocoder.h>
#import "GameDetailsViewController.h"
#import "AppServices.h"
#import "AppModel.h"
#import "ARISAppDelegate.h"
#import "commentsViewController.h"
#import "RatingCell.h"

#import "ARISAlertHandler.h"

#import <QuartzCore/QuartzCore.h>

NSString *const kGameDetailsHtmlTemplate =
@"<html>"
@"<head>"
@"	<title>Aris</title>"
@"	<style type='text/css'><!--"
@"	body {"
@"		background-color: transparent;"
@"		color: #000000;"
@"		font-size: 17px;"
@"		font-family: Helvetia, Sans-Serif;"
@"		margin: 0px;"
@"	}"
@"	a {color: #FFFFFF; text-decoration: underline; }"
@"	--></style>"
@"</head>"
@"<body>%@</body>"
@"</html>";

@interface GameDetailsViewController()
{
    id<GameDetailsViewControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation GameDetailsViewController

@synthesize descriptionIndexPath;
@synthesize descriptionWebView;
@synthesize game;
@synthesize tableView;
@synthesize titleLabel;
@synthesize authorsLabel;
@synthesize descriptionLabel;
@synthesize locationLabel;
@synthesize scrollView;
@synthesize contentView;
@synthesize segmentedControl, newHeight, mediaImageView;

- (id)initWithGame:(Game *)g delegate:(id<GameDetailsViewControllerDelegate>)d
{
    if(self = [super initWithNibName:@"GameDetailsViewController" bundle:nil])
    {
        delegate = d;
        self.game = g;
        
        //THIS NEXT LINE IS AWFUL. NEEDS REFACTOR.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewDidIntentionallyAppear) name:@"PlayerSettingsDidDismiss" object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BackButtonKey", @"")
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(backButtonTouched)];
    
	self.navigationItem.leftBarButtonItem = backButton;
    self.mediaImageView = [[AsyncMediaImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];

    self.title = self.game.name;
    self.authorsLabel.text = [NSString stringWithFormat:@"%@: ", NSLocalizedString(@"GameDetailsAuthorKey", @"")];
    self.authorsLabel.text = [self.authorsLabel.text stringByAppendingString:self.game.authors];
    self.descriptionLabel.text = [NSString stringWithFormat:@"%@: ", NSLocalizedString(@"DescriptionKey", @"")];

	[descriptionWebView setBackgroundColor:[UIColor clearColor]];
    [self.segmentedControl setTitle:[NSString stringWithFormat:@"%@: %d",NSLocalizedString(@"RatingKey", @""),game.rating] forSegmentAtIndex:0];
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
	scrollView.contentSize = CGSizeMake(contentView.frame.size.width,contentView.frame.size.height);
	
	NSString *htmlDescription = [NSString stringWithFormat:kGameDetailsHtmlTemplate, self.game.gdescription];
	descriptionWebView.delegate = self;
    descriptionWebView.hidden = NO;
	[descriptionWebView loadHTMLString:htmlDescription baseURL:nil];
    
    [self.tableView reloadData];
}

- (void)viewDidIntentionallyAppear
{
    if([AppModel sharedAppModel].skipGameDetails)
    {
        [AppModel sharedAppModel].skipGameDetails = 0;
        [self playGame];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)descriptionView
{
	float nHeight = [[descriptionView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue] + 3;
	self.newHeight = nHeight;
	
	CGRect descriptionFrame = [descriptionView frame];	
	descriptionFrame.size = CGSizeMake(descriptionFrame.size.width,newHeight);
	[descriptionView setFrame:descriptionFrame];
    [tableView reloadRowsAtIndexPaths:[[NSArray alloc] initWithObjects:self.descriptionIndexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *requestURL = [request URL];  

    if(([[requestURL scheme] isEqualToString:@"http"] ||
        [[requestURL scheme] isEqualToString:@"https"]) &&
       (navigationType == UIWebViewNavigationTypeLinkClicked))
        return ![[UIApplication sharedApplication] openURL:requestURL];

    return YES;  
} 

#pragma mark -
#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch(section)
    {
        case 0:
            return 1;
            break;
        case 1:
            if(self.game.hasBeenPlayed) return 3;
            else return 2;
            break;
        case 2:
            return 1;
            break;
    }
    return 0; //Should never get here
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 2) return  [NSString stringWithFormat:@"%@: ", NSLocalizedString(@"DescriptionKey", @"")];
    
    return @""; 
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
	NSString *CellIdentifier = [NSString stringWithFormat: @"Cell%d%d",indexPath.section,indexPath.row];
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];;
	
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        if(self.game.splashMedia) [self.mediaImageView loadMedia:self.game.splashMedia];
        else self.mediaImageView.image = [UIImage imageNamed:@"DefaultGameSplash.png"];
        self.mediaImageView.frame = CGRectMake(0, 0, 320, 200);
        
        cell.backgroundView = mediaImageView;
        cell.backgroundView.layer.masksToBounds = YES;
        cell.backgroundView.layer.cornerRadius = 10.0;
        cell.userInteractionEnabled = NO;
    }
    else if(indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            if(self.game.hasBeenPlayed) cell.textLabel.text = NSLocalizedString(@"GameDetailsResumeKey", @"");
            else                        cell.textLabel.text = NSLocalizedString(@"GameDetailsNewGameKey", @""); 
            cell.textLabel.textAlignment = UITextAlignmentCenter;
        }
        else if (indexPath.row ==1)
        {
            if(self.game.hasBeenPlayed)
            {
                cell.textLabel.text = NSLocalizedString(@"GameDetailsResetKey", @"");
                cell.textLabel.textAlignment = UITextAlignmentCenter;
            } 
            else
                cell = [self constructReviewCell];
        }
        else if (indexPath.row ==2)
            cell = [self constructReviewCell];
    }
    else if(indexPath.section == 2)
    {
        descriptionIndexPath = [indexPath copy];
        cell.userInteractionEnabled = NO;
        CGRect descriptionFrame = [descriptionWebView frame];
        descriptionWebView.opaque = NO;
        descriptionWebView.backgroundColor = [UIColor clearColor];
        descriptionFrame.origin.x = 15;
        descriptionFrame.origin.y = 15;
        [descriptionWebView setFrame:descriptionFrame];
        [cell.contentView addSubview:descriptionWebView];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        if(indexPath.row == 0)
            cell.backgroundColor = [UIColor colorWithRed:182/255.0 green:255/255.0 blue:154/255.0 alpha:1.0];
        if(indexPath.row == 1 && self.game.hasBeenPlayed)
            cell.backgroundColor = [UIColor colorWithRed:255/255.0 green:153/255.0 blue:181/255.0 alpha:1.0];
    }
}

- (void) playGame
{
    self.game.hasBeenPlayed = YES;
    [delegate gameDetailsWereConfirmed:self.game];
}

- (void) backButtonTouched
{
    [delegate gameDetailsWereCanceled:self.game];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1)
    {
        if(indexPath.row == 0)
        {
            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
            [self playGame];
            [self.tableView reloadData];
        }
        else if(indexPath.row ==1)
        {
            if(self.game.hasBeenPlayed)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GameDetailsResetTitleKey", nil) message:NSLocalizedString(@"GameDetailsResetMessageKey", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CancelKey", @"") otherButtonTitles:NSLocalizedString(@"GameDetailsResetKey", @""), nil];
                [alert show];	
                [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
            }
            else
            {
                commentsViewController *commentsVC = [[commentsViewController alloc] initWithNibName:@"commentsView" bundle:nil];
                commentsVC.game = self.game;
                [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
                [self.navigationController pushViewController:commentsVC animated:YES];
            }
        }
        else if(indexPath.row == 2)
        {
            commentsViewController *commentsVC = [[commentsViewController alloc] initWithNibName:@"commentsView" bundle:nil];
            commentsVC.game = self.game;
            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
            [self.navigationController pushViewController:commentsVC animated:YES];     
        }
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSString *title = [alertView title];
    
    if([title isEqualToString:NSLocalizedString(@"GameDetailsResetTitleKey", nil)])
    {
        if (buttonIndex == 1)
        {
            [[AppServices sharedAppServices] startOverGame:self.game.gameId];
            self.game.hasBeenPlayed = NO;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

-(CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if     (indexPath.section == 0 && indexPath.row == 0)                   return 200;
    else if(indexPath.section == 2 && indexPath.row == 0 && self.newHeight) return self.newHeight+30;
    
    return 40;
}

-(UITableViewCell *)constructReviewCell
{
    UITableViewCell *cell = (RatingCell *)[[UIViewController alloc] initWithNibName:@"RatingCell" bundle:nil].view;
    
    RatingCell *ratingCell = (RatingCell *)cell;
    ratingCell.ratingView.rating = self.game.rating;
    ratingCell.ratingView.userInteractionEnabled = NO;
    ratingCell.reviewsLabel.text = [NSString stringWithFormat:@"%d %@",self.game.numReviews, NSLocalizedString(@"ReviewsKey", @"")];
    [ratingCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    [ratingCell.ratingView setStarImage:[UIImage imageNamed:@"small-star-halfselected.png"] forState:kSCRatingViewHalfSelected];
    [ratingCell.ratingView setStarImage:[UIImage imageNamed:@"small-star-highlighted.png"]  forState:kSCRatingViewHighlighted];
    [ratingCell.ratingView setStarImage:[UIImage imageNamed:@"small-star-hot.png"]          forState:kSCRatingViewHot];
    [ratingCell.ratingView setStarImage:[UIImage imageNamed:@"small-star-highlighted.png"]  forState:kSCRatingViewNonSelected];
    [ratingCell.ratingView setStarImage:[UIImage imageNamed:@"small-star-selected.png"]     forState:kSCRatingViewSelected];
    [ratingCell.ratingView setStarImage:[UIImage imageNamed:@"small-star-hot.png"]          forState:kSCRatingViewUserSelected];
    
    return cell;
}

@end
