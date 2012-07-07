//
//  GameDetails.m
//  ARIS
//
//  Created by David J Gagnon on 4/18/10.
//  Copyright 2010 University of Wisconsin - Madison. All rights reserved.
//

#import "GameDetails.h"
#import "AppServices.h"
#import "AppModel.h"
#import "ARISAppDelegate.h"
#import "commentsViewController.h"
#import <MapKit/MKReverseGeocoder.h>
#import "RatingCell.h"

#include <QuartzCore/QuartzCore.h>


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




@implementation GameDetails

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


// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
        AsyncMediaImageView *mediaImageViewAlloc = [[AsyncMediaImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 200)];
        self.mediaImageView = mediaImageViewAlloc;
        //self.splashMedia = [[Media alloc] init];
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
    self.title = self.game.name;
    self.authorsLabel.text = [NSString stringWithFormat: @"%@: ", NSLocalizedString(@"GameDetailsAuthorKey", @"")];
    self.authorsLabel.text = [self.authorsLabel.text stringByAppendingString:self.game.authors];
    self.descriptionLabel.text = [NSString stringWithFormat: @"%@: ", NSLocalizedString(@"DescriptionKey", @"")]; 
    //self.descriptionLabel.text = [self.descriptionLabel.text stringByAppendingString:self.game.description];
	[descriptionWebView setBackgroundColor:[UIColor clearColor]];
    [self.segmentedControl setTitle:[NSString stringWithFormat: @"%@: %d",NSLocalizedString(@"RatingKey", @""),game.rating] forSegmentAtIndex:0];
    
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated {
	NSLog(@"GameDetails: View Will Appear, Refresh");
	
	scrollView.contentSize = CGSizeMake(contentView.frame.size.width,contentView.frame.size.height);
	
	NSString *htmlDescription = [NSString stringWithFormat:kGameDetailsHtmlTemplate, self.game.description];
    NSLog(@"Game ID = %i", self.game.gameId);
	NSLog(@"GameDetails: HTML Description: %@", htmlDescription);
	descriptionWebView.delegate = self;
    descriptionWebView.hidden = NO;
	[descriptionWebView loadHTMLString:htmlDescription baseURL:nil];
    
    [self.tableView reloadData];
}

- (void)webViewDidFinishLoad:(UIWebView *)descriptionView {
	//Content Loaded, now we can resize
	
	float nHeight = [[descriptionView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue];
	self.newHeight = nHeight;
	NSLog(@"GameDetails: Description View Calculated Height is: %f",newHeight);
	
	CGRect descriptionFrame = [descriptionView frame];	
	descriptionFrame.size = CGSizeMake(descriptionFrame.size.width,newHeight);
	[descriptionView setFrame:descriptionFrame];	
	NSLog(@"GameDetails: description UIWebView frame set to {%f, %f, %f, %f}", 
		  descriptionFrame.origin.x, 
		  descriptionFrame.origin.y, 
		  descriptionFrame.size.width,
		  descriptionFrame.size.height);
    NSArray *reloadArr = [[NSArray alloc] initWithObjects:self.descriptionIndexPath, nil];
    [tableView reloadRowsAtIndexPaths: reloadArr   
                     withRowAnimation:UITableViewRowAnimationFade];
	
	
}

//////////////////////////////////////////////////////////////////////////////////



- (BOOL)webView:(UIWebView *)webView  
shouldStartLoadWithRequest:(NSURLRequest *)request  
 navigationType:(UIWebViewNavigationType)navigationType; {  
    
    NSLog(@"GameDetails: webView Called");
    
    NSURL *requestURL = [ request URL ];  
    // Check to see what protocol/scheme the requested URL is.  
    if ( ( [ [ requestURL scheme ] isEqualToString: @"http" ]  
          || [ [ requestURL scheme ] isEqualToString: @"https" ] )  
        && ( navigationType == UIWebViewNavigationTypeLinkClicked ) ) {  
        return ![ [ UIApplication sharedApplication ] openURL: requestURL ];  
    }  
    // Auto release  
    // If request url is something other than http or https it will open  
    // in UIWebView. You could also check for the other following  
    // protocols: tel, mailto and sms  
    return YES;  
} 









//////////////////////////////////////////////////////////////////////////////////


#pragma mark -
#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section){
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
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if(section == 2) {
        return  [NSString stringWithFormat: @"%@: ", NSLocalizedString(@"DescriptionKey", @"")];
    }
    
    return @""; 
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"GamePickerVC: Cell requested for section: %d row: %d",indexPath.section,indexPath.row);
    
	NSString *CellIdentifier = [NSString stringWithFormat: @"Cell%d%d",indexPath.section,indexPath.row];
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		// Create a temporary UIViewController to instantiate the custom cell.
		UITableViewCell *tempCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                                           reuseIdentifier:CellIdentifier];
        cell = tempCell;
    }
	
    if (indexPath.section == 0 && indexPath.row == 0) {
        
        if (self.game.splashMedia) {
            [self.mediaImageView loadImageFromMedia:self.game.splashMedia];
        }
        else self.mediaImageView.image = [UIImage imageNamed:@"DefaultGameSplash.png"];
        self.mediaImageView.frame = CGRectMake(0, 0, 320, 200);
        
        cell.backgroundView = mediaImageView;
        cell.backgroundView.layer.masksToBounds = YES;
        cell.backgroundView.layer.cornerRadius = 10.0;
        cell.userInteractionEnabled = NO;
    }
    else if(indexPath.section == 1) {
        if (indexPath.row ==0) {
            if(self.game.hasBeenPlayed){
                cell.textLabel.text = NSLocalizedString(@"GameDetailsResumeKey", @"");
            }
            else{
                cell.textLabel.text = NSLocalizedString(@"GameDetailsNewGameKey", @""); 
            }
            cell.textLabel.textAlignment = UITextAlignmentCenter;
        }
        else if (indexPath.row ==1){
            if(self.game.hasBeenPlayed) {
                cell.textLabel.text = NSLocalizedString(@"GameDetailsResetKey", @"");
                cell.textLabel.textAlignment = UITextAlignmentCenter;
            } 
            else{
                cell = [self constructReviewCell];
            }
        }
        else if (indexPath.row ==2){
            cell = [self constructReviewCell];
        }
    }
    else if(indexPath.section == 2) {
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1){
        if (indexPath.row ==0) cell.backgroundColor = [UIColor colorWithRed:182/255.0 green:255/255.0 blue:154/255.0 alpha:1.0];
        if(self.game.hasBeenPlayed){
            if (indexPath.row ==1) cell.backgroundColor = [UIColor colorWithRed:255/255.0 green:153/255.0 blue:181/255.0 alpha:1.0];
        } 
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1) {
        if  (indexPath.row == 0) {
            self.game.hasBeenPlayed = YES;
            [AppModel sharedAppModel].inGame = YES;
            
            NSDictionary *dictionary = [NSDictionary dictionaryWithObject:self.game
                                                                   forKey:@"game"];
            
            [[AppServices sharedAppServices] silenceNextServerUpdate];
            NSNotification *gameSelectNotification = [NSNotification notificationWithName:@"SelectGame" object:self userInfo:dictionary];
            [[NSNotificationCenter defaultCenter] postNotification:gameSelectNotification];
            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
            [self.tableView reloadData];
        }
        else if (indexPath.row ==1) {
            if(self.game.hasBeenPlayed) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GameDetailsResetTitleKey", nil) message:NSLocalizedString(@"GameDetailsResetMessageKey", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CancelKey", @"") otherButtonTitles: NSLocalizedString(@"GameDetailsResetKey", @""), nil];
                [alert show];	
                [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
            }
            else {
                commentsViewController *commentsVC = [[commentsViewController alloc]initWithNibName:@"commentsView" bundle:nil];
                commentsVC.game = self.game;
                [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
                [self.navigationController pushViewController:commentsVC animated:YES];
            }
            
        }
        else if (indexPath.row == 2) {
            commentsViewController *commentsVC = [[commentsViewController alloc]initWithNibName:@"commentsView" bundle:nil];
            commentsVC.game = self.game;
            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
            [self.navigationController pushViewController:commentsVC animated:YES];     
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *title = [alertView title];
    NSLog(@"%@", title);
    
    if([title isEqualToString:NSLocalizedString(@"GameDetailsResetTitleKey", nil)]) {
        if (buttonIndex == 1) {
            NSLog(@"user pressed OK");
            NSLog(@"%d", self.game.gameId);
            [[AppServices sharedAppServices] startOverGame:self.game.gameId];
            self.game.hasBeenPlayed = NO;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        }
        else {
            NSLog(@"user pressed Cancel");
        }
    }
}

- (void)tableView:(UITableView *)aTableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    
}

-(CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) return 200;
    else if(indexPath.section ==2 && indexPath.row ==0){
        if(self.newHeight) return self.newHeight+30;
        else return 40;
    }
    else return 40;
}

-(UITableViewCell *)constructReviewCell{
    UIViewController *temporaryController = [[UIViewController alloc] initWithNibName:@"RatingCell" bundle:nil];
    // Grab a pointer to the custom cell
    UITableViewCell *cell = (RatingCell *)temporaryController.view;
    // Release the temporary UIViewController.
    RatingCell *ratingCell = (RatingCell *)cell;
    ratingCell.ratingView.rating = self.game.rating;
    ratingCell.reviewsLabel.text = [NSString stringWithFormat:@"%d %@",self.game.numReviews, NSLocalizedString(@"ReviewsKey", @"")];
    [ratingCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    [ratingCell.ratingView setStarImage:[UIImage imageNamed:@"small-star-halfselected.png"]
                               forState:kSCRatingViewHalfSelected];
    [ratingCell.ratingView setStarImage:[UIImage imageNamed:@"small-star-highlighted.png"]
                               forState:kSCRatingViewHighlighted];
    [ratingCell.ratingView setStarImage:[UIImage imageNamed:@"small-star-hot.png"]
                               forState:kSCRatingViewHot];
    [ratingCell.ratingView setStarImage:[UIImage imageNamed:@"small-star-highlighted.png"]
                               forState:kSCRatingViewNonSelected];
    [ratingCell.ratingView setStarImage:[UIImage imageNamed:@"small-star-selected.png"]
                               forState:kSCRatingViewSelected];
    [ratingCell.ratingView setStarImage:[UIImage imageNamed:@"small-star-hot.png"]
                               forState:kSCRatingViewUserSelected];
    ratingCell.ratingView.userInteractionEnabled = NO; 
    return cell;
}





/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

#pragma mark -
#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}




@end
