//
//  Note.m
//  ARIS
//
//  Created by Brian Thiel on 8/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Note.h"
#import "ARISAppDelegate.h"
#import "AppModel.h"
#import "NoteViewController.h"

@implementation Note
@synthesize mediaArray, creatorId,noteId,parentNoteId,parentRating,shared,text,title,kind,averageRating,numRatings;

-(nearbyObjectKind) kind { return NearbyObjectNote; }

- (Note *) init {
    self = [super init];
    if (self) {
		kind = NearbyObjectNote;
        iconMediaId = 36;
    }
    return self;	
}



- (void) display{
	NSLog(@"WebPage: Display Self Requested");
	
	//Create a reference to the delegate using the application singleton.
	ARISAppDelegate *appDelegate = (ARISAppDelegate *) [[UIApplication sharedApplication] delegate];
    
	NoteViewController *notesViewController = [[NoteViewController alloc] initWithNibName:@"NoteViewController" bundle: [NSBundle mainBundle]];
	notesViewController.note = self;
	[appDelegate displayNearbyObjectView:notesViewController];
	[notesViewController release];
}



- (void) dealloc {
	[mediaArray release];
	[text release];
    [title release];
	[super dealloc];
}

- (NSString *) name {
    return self.name;
}

- (int)	iconMediaId {
    return 36; 
}

@end
