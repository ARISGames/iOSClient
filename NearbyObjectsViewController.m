//
//  NearbyObjectsViewController.m
//  ARIS
//
//  Created by David J Gagnon on 2/13/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import "NearbyObjectsViewController.h"
#import "AppModel.h"
#import "ARISAppDelegate.h"
#import "AppServices.h"
#import "NearbyObjectCell.h"


@implementation NearbyObjectsViewController

@synthesize oldNearbyLocationList;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.tabBarItem.image = [UIImage imageNamed:@"73-radar"];
		self.title = NSLocalizedString(@"NearbyObjectsTabKey",@"");	
		self.navigationItem.title = NSLocalizedString(@"NearbyObjectsTitleKey",@"");
		NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
	//	[dispatcher addObserver:self selector:@selector(refreshViewFromModel) name:@"PlayerMoved" object:nil];		
		[dispatcher addObserver:self selector:@selector(refreshViewFromModel) name:@"NewLocationListReady" object:nil];			
		
		self.oldNearbyLocationList = [NSMutableArray arrayWithCapacity:5];
    }
    return self;
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

- (void)viewDidAppear:(BOOL)animated {
	[self refresh];
	
	[[RootViewController sharedRootViewController].tutorialViewController dismissTutorialPopupWithType:tutorialPopupKindNearbyTab];
	
	NSLog(@"NearbyObjectsViewController: viewDidAppear");
}

-(void)dismissTutorial{
	[[RootViewController sharedRootViewController].tutorialViewController dismissTutorialPopupWithType:tutorialPopupKindNearbyTab];
}

- (void)refresh {
	NSLog(@"NearbyObjectsViewController: refresh requested");
	if ([AppModel sharedAppModel].loggedIn && ([AppModel sharedAppModel].currentGame.gameId != 0 && [AppModel sharedAppModel].playerId != 0)) [[AppServices sharedAppServices] fetchLocationList];
}

- (void)refreshViewFromModel{
	NSLog(@"NearbyBar: refreshViewFromModel");
	
	ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if (![AppModel sharedAppModel].playerLocation) {
		NSLog(@"NearbyBar: Waiting for the player location before continuing to refresh. Returning");
		return;
	}
	
	NSMutableArray *nearbyLocationList = [NSMutableArray arrayWithCapacity:5];
	NSObject <NearbyObjectProtocol> *forcedDisplayItem = nil;
	
	
	//Filter out the locations that meet some basic requirements
	for(Location *location in [AppModel sharedAppModel].locationList) {
        if(location.error == -1) location.error = 9999999999;
		if ([[AppModel sharedAppModel].playerLocation distanceFromLocation:location.location] > location.error) continue;
		else if (location.kind == NearbyObjectItem && location.qty ==0 ) continue;
		else if (location.kind == NearbyObjectPlayer) continue;
		else [nearbyLocationList addObject:location];
	}
	
	//Check if anything is new since last time
	BOOL newItem = NO;	//flag to see if at least one new item is in list
	for (Location *location in nearbyLocationList) {		
		BOOL match = NO;
		for (Location *oldLocation in oldNearbyLocationList) {
			if (oldLocation.locationId == location.locationId) match = YES;	
		}
		if (match == NO) {
			if (location.forcedDisplay) forcedDisplayItem = location; 
			newItem = YES;
		}
	}
	
	//If we have something new, alert the user
	if (newItem) {
        if(![RootViewController sharedRootViewController].tabBarController.modalViewController)
        {
            //alert only if u are on quest,map,inventory, or nearby objects screen
            [appDelegate playAudioAlert:@"pingtone" shouldVibrate:YES]; 
		}
        
		if (![AppModel sharedAppModel].hasSeenNearbyTabTutorial) {
			[[RootViewController sharedRootViewController].tutorialViewController showTutorialPopupPointingToTabForViewController:self.navigationController  
												type:tutorialPopupKindNearbyTab 
												title:@"Something Nearby"  
												message:@"There is something nearby! Touch below to see what it is."];
			[AppModel sharedAppModel].hasSeenNearbyTabTutorial = YES;
            [self performSelector:@selector(dismissTutorial) withObject:nil afterDelay:5.0];
		}
	}
	
	//If we have a force display, do it
	if (forcedDisplayItem) {
		[forcedDisplayItem display];
	}
	
	if ([nearbyLocationList count] == 0) { 
		NSLog(@"NearbyBar: refreshViewFromModel: nearbyLocationList was 0");
		self.navigationController.tabBarItem.badgeValue = nil;
		[[RootViewController sharedRootViewController] showNearbyTab:NO];
	}
	else {
		NSLog(@"NearbyBar: refreshViewFromModel: nearbyLocationList was > 0");
		self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",[nearbyLocationList count]];
		[[RootViewController sharedRootViewController] showNearbyTab:YES];

	}
	
	
	//Save this nearby list
	self.oldNearbyLocationList = nearbyLocationList;
	
	//Refresh the table
	[nearbyTable reloadData];
	
} 


#pragma mark UITableView Data Source and Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSLog(@"NearbyObjectsVC: numberOfRows: %d",[self.oldNearbyLocationList count]);
	return [self.oldNearbyLocationList count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	static NSString *CellIdentifier = @"Cell";
    NearbyObjectCell *cell = (NearbyObjectCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if (cell == nil) {
		// Create a temporary UIViewController to instantiate the custom cell.
		UIViewController *temporaryController = [[UIViewController alloc] initWithNibName:@"NearbyObjectCell" bundle:nil];
		// Grab a pointer to the custom cell.
		cell = (NearbyObjectCell *)temporaryController.view;
		// Release the temporary UIViewController.
	}
	

	Location *l;
	l = [self.oldNearbyLocationList objectAtIndex:indexPath.row];
	NSLog(@"NearbyObjectsVC: cellForRowAtIndexPath: Text Label is: %@",l.name);
	
	if (l.kind == NearbyObjectItem && l.qty > 1) cell.title.text = [NSString stringWithFormat:@"%@ (x%d)",l.name,l.qty];
	else cell.title.text = l.name;
	
	Media *iconMedia = [[AppModel sharedAppModel] mediaForMediaId: l.iconMediaId];
        [cell.iconView loadImageFromMedia:iconMedia];
 
	
	return cell;

}

// Customize the height of each row

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
	
	Location<NearbyObjectProtocol> *l;
	l = [self.oldNearbyLocationList objectAtIndex:indexPath.row];
    l.delegate = self;
	[l display];
}



@end
