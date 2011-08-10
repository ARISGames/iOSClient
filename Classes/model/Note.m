//
//  Note.m
//  ARIS
//
//  Created by Brian Thiel on 8/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Note.h"
#import "ARISAppDelegate.h"
#import "AppModel.h"
#import "NoteViewController.h"


@implementation Note
@synthesize iconMediaId,noteId,name,text,kind;
-(nearbyObjectKind) kind { return NearbyObjectWebPage; }

- (Note *) init {
    self = [super init];
    if (self) {
		kind = NearbyObjectNote;
        iconMediaId = 4;
    }
    return self;	
}



- (void) display{
	NSLog(@"Note: Display Self Requested");
	
	//Create a reference to the delegate using the application singleton.
	ARISAppDelegate *appDelegate = (ARISAppDelegate *) [[UIApplication sharedApplication] delegate];
    
	NoteViewController *notesViewController = [[NoteViewController alloc] initWithNibName:@"NoteViewController" bundle: [NSBundle mainBundle]];
	notesViewController.note = self;
	[appDelegate displayNearbyObjectView:notesViewController];
	[notesViewController release];
}



- (void) dealloc {

	[super dealloc];
}

- (NSString *) name {
    return self.name;
}

- (int)	iconMediaId {
    return 4; 
}

@end
