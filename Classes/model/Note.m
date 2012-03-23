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
#import "NoteEditorViewController.h"
#import "NoteDetailsViewController.h"
#import "NearbyObjectsViewController.h"
#import "NoteContent.h"

 NSString *const kNoteContentTypeAudio = @"AUDIO";
 NSString *const kNoteContentTypeVideo = @"VIDEO";
 NSString *const kNoteContentTypePhoto = @"PHOTO";
 NSString *const kNoteContentTypeText = @"TEXT";

@implementation Note
@synthesize comments,contents, creatorId,noteId,parentNoteId,parentRating,shared,text,title,kind,averageRating,numRatings,username,delegate,dropped,showOnMap,showOnList,userLiked,hasImage,hasAudio,tags,tagSection,tagName,latitude,longitude;

-(nearbyObjectKind) kind { return NearbyObjectNote; }

- (Note *) init {
    self = [super init];
    if (self) {
		kind = NearbyObjectNote;
        iconMediaId = 71;
        self.comments = [NSMutableArray arrayWithCapacity:5];
        self.contents = [NSMutableArray arrayWithCapacity:5];
        self.tags = [NSMutableArray arrayWithCapacity:5];
    }
    return self;	
}



- (void) display{
	NSLog(@"WebPage: Display Self Requested");
	
	//Create a reference to the delegate using the application singleton.
    ARISAppDelegate *appDelegate = (ARISAppDelegate *) [[UIApplication sharedApplication] delegate];
    

        //open up note viewer
        NoteDetailsViewController *dataVC = [[NoteDetailsViewController alloc] initWithNibName:@"NoteDetailsViewController" bundle:nil];
        dataVC.note = self;
        dataVC.delegate = self;
    [appDelegate displayNearbyObjectView:dataVC];

    [dataVC release];

}

-(BOOL)isUploading{
    for (int i = 0;i < [self.contents count]; i++) {
        if ([[(NoteContent *)[self.contents objectAtIndex:i]type] isEqualToString:@"UPLOAD"]) {
            return  YES;
        }
    }
    return  NO;
}

- (void) dealloc {
    [super dealloc];

	[comments release];
    [contents release];
	[text release];
    [title release];
    [username release];
}

- (NSString *) name {
    return self.name;
}

- (int)	iconMediaId {
    return 71; 
}

@end
