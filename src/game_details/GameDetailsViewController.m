//
//  GameDetailsViewController.m
//  ARIS
//
//  Created by David J Gagnon on 4/18/10.
//  Copyright 2010 University of Wisconsin - Madison. All rights reserved.
//

#import "GameDetailsViewController.h"
#import "AppServices.h"
#import "AppModel.h"
#import "commentsViewController.h"
#import "RatingCell.h"
#import "Game.h"

#import "ARISAlertHandler.h"
#import "ARISTemplate.h"
#import "ARISWebView.h"
#import "ARISMediaView.h"

#import "StateControllerProtocol.h"

#import <QuartzCore/QuartzCore.h>

@interface GameDetailsViewController() <ARISMediaViewDelegate, ARISWebViewDelegate, StateControllerProtocol, UIWebViewDelegate>
{
    ARISMediaView *mediaView;
    ARISWebView *descriptionView;
    UIButton *startButton;
    UIButton *resetButton; 
    UIButton *rateButton;  
    
   	Game *game; 
    id<GameDetailsViewControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation GameDetailsViewController

- (id) initWithGame:(Game *)g delegate:(id<GameDetailsViewControllerDelegate>)d
{
    if(self = [super init])
    {
        delegate = d;
        game = g;
        
        //THIS NEXT LINE IS AWFUL. NEEDS REFACTOR.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewDidIntentionallyAppear) name:@"PlayerSettingsDidDismiss" object:nil];
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    mediaView = [[ARISMediaView alloc] initWithDelegate:self];
    descriptionView = [[ARISWebView alloc] initWithDelegate:self];
    
    startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    resetButton = [UIButton buttonWithType:UIButtonTypeCustom]; 
    rateButton = [UIButton buttonWithType:UIButtonTypeCustom]; 
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0,0,19,19);
    [backButton setImage:[UIImage imageNamed:@"arrowBack"] forState:UIControlStateNormal];
    backButton.accessibilityLabel = @"Back Button";
    [backButton addTarget:self action:@selector(backButtonTouched) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    [self.view addSubview:mediaView];
    [self.view addSubview:descriptionView]; 
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [mediaView setFrame:CGRectMake(0,0,self.view.bounds.size.width,200) withMode:ARISMediaDisplayModeAspectFit];
    descriptionView.frame = CGRectMake(15, 15, self.view.bounds.size.width-30, 10); 
         
}

- (void) refreshFromGame
{
    self.title = game.name; 
    
    if(![game.desc isEqualToString:@""])
        [descriptionView loadHTMLString:[NSString stringWithFormat:[ARISTemplate ARISHtmlTemplate], game.desc] baseURL:nil];
    
    if(game.splashMedia) [mediaView setMedia:game.splashMedia];
    else                 [mediaView setImage:[UIImage imageNamed:@"DefaultGameSplash"]]; 
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if([AppModel sharedAppModel].skipGameDetails)
    {
        [AppModel sharedAppModel].skipGameDetails = 0;
        [self playGame];
    }
}

- (void) ARISWebViewDidFinishLoad:(ARISWebView *)wv
{
    float newHeight = [[descriptionView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue];
    [wv setFrame:CGRectMake(wv.frame.origin.x, wv.frame.origin.y, wv.frame.size.width, newHeight)];
    [tableView reloadData];
}

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *requestURL = [request URL];  

    if(([[requestURL scheme] isEqualToString:@"http"] ||
        [[requestURL scheme] isEqualToString:@"https"]) &&
       (navigationType == UIWebViewNavigationTypeLinkClicked))
        return ![[UIApplication sharedApplication] openURL:requestURL];

    return YES;  
} 

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch(section)
    {
        case 0:
            return 1;
            break;
        case 1:
            if(game.hasBeenPlayed) return 3;
            else return 2;
            break;
        case 2:
            return 1;
            break;
        case 3:
            return 1;
            break;
    }
    return 0; //Should never get here
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @""; 
}

- (UITableViewCell *) tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
	NSString *CellIdentifier = [NSString stringWithFormat: @"Cell%d%d",indexPath.section,indexPath.row];
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];;
	
    if(indexPath.section == 0 && indexPath.row == 0)
    {
        cell.backgroundView = mediaView;
        cell.userInteractionEnabled = NO;
    }
    else if(indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            if(game.hasBeenPlayed) cell.textLabel.text = NSLocalizedString(@"GameDetailsResumeKey", @"");
            else                        cell.textLabel.text = NSLocalizedString(@"GameDetailsNewGameKey", @""); 
            cell.textLabel.font = [ARISTemplate ARISButtonFont];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        }
        else if (indexPath.row ==1)
        {
            if(game.hasBeenPlayed)
            {
                cell.textLabel.text = NSLocalizedString(@"GameDetailsResetKey", @"");
                cell.textLabel.font = [ARISTemplate ARISButtonFont];
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
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
        descriptionView.opaque = NO;
        descriptionView.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:descriptionView];
    }
    else if (indexPath.section == 3)
    {
        // MG:
        cell.textLabel.text = NSLocalizedString(@"Download Game", @"");
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        if(indexPath.row == 0)//Start/Resume
        {
            cell.backgroundColor = [UIColor ARISColorLightBlue];
            cell.textLabel.textColor = [UIColor whiteColor];
        }
        else if(indexPath.row == 1 && game.hasBeenPlayed)//Reset
        {
            cell.backgroundColor = [UIColor ARISColorRed];
            cell.textLabel.textColor = [UIColor whiteColor];
        }
        else if((indexPath.row == 1 && !game.hasBeenPlayed) || indexPath.row == 2)//Ratings
        {
            cell.backgroundColor = [UIColor ARISColorOffWhite];
        }
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section //hides empty cells at bottom
{
    return 0.01f;
}

- (void) playGame
{
    game.hasBeenPlayed = YES;
    [delegate gameDetailsWereConfirmed:game];
}

- (void) backButtonTouched
{
    [delegate gameDetailsWereCanceled:game];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1)
    {
        if(indexPath.row == 0)
        {
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            [self playGame];
            [tableView reloadData];
        }
        else if(indexPath.row ==1)
        {
            if(game.hasBeenPlayed)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GameDetailsResetTitleKey", nil) message:NSLocalizedString(@"GameDetailsResetMessageKey", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CancelKey", @"") otherButtonTitles:NSLocalizedString(@"GameDetailsResetKey", @""), nil];
                [alert show];	
                [tableView deselectRowAtIndexPath:indexPath animated:NO];
            }
            else
            {
                commentsViewController *commentsVC = [[commentsViewController alloc] initWithNibName:@"commentsView" bundle:nil];
                commentsVC.game = game;
                [tableView deselectRowAtIndexPath:indexPath animated:NO];
                [self.navigationController pushViewController:commentsVC animated:YES];
            }
        }
        else if(indexPath.row == 2)
        {
            commentsViewController *commentsVC = [[commentsViewController alloc] initWithNibName:@"commentsView" bundle:nil];
            commentsVC.game = game;
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
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
            [[AppServices sharedAppServices] startOverGame:game.gameId];
            game.hasBeenPlayed = NO;
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

- (CGFloat) tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if     (indexPath.section == 0 && indexPath.row == 0)                   return 220;
    else if(indexPath.section == 2 && indexPath.row == 0 && newHeight) return newHeight+30;
    
    return 40;
}

- (UITableViewCell *) constructReviewCell
{
    /*
    UITableViewCell *cell = (RatingCell *)[[ARISViewController alloc] initWithNibName:@"RatingCell" bundle:nil].view;
    
    RatingCell *ratingCell = (RatingCell *)cell;

    ratingCell.ratingView.rating = game.rating;
    ratingCell.ratingView.userInteractionEnabled = NO;
    ratingCell.reviewsLabel.text = [NSString stringWithFormat:@"%d %@",game.numReviews, NSLocalizedString(@"ReviewsKey", @"")];
    [ratingCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    [ratingCell.ratingView setStarImage:[UIImage imageNamed:@"small-star-highlighted.png"] forState:kSCRatingViewHighlighted];
    [ratingCell.ratingView setStarImage:[UIImage imageNamed:@"small-star-selected.png"]    forState:kSCRatingViewHot];
    [ratingCell.ratingView setStarImage:[UIImage imageNamed:@"small-star-highlighted.png"] forState:kSCRatingViewNonSelected];
    [ratingCell.ratingView setStarImage:[UIImage imageNamed:@"small-star-selected.png"]    forState:kSCRatingViewSelected];
    [ratingCell.ratingView setStarImage:[UIImage imageNamed:@"small-star-selected.png"]    forState:kSCRatingViewUserSelected];
    
    return cell;
         */ 
    return nil;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
