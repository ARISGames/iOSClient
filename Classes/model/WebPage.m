//
//  WebPage.m
//  ARIS
//
//  Created by Brian Thiel on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WebPage.h"
#import "ARISAppDelegate.h"
#import "AppModel.h"
#import "webpageViewController.h"


@implementation WebPage
@synthesize iconMediaId,webPageId,name,url,kind,locationId;
-(nearbyObjectKind) kind { return NearbyObjectWebPage; }

- (WebPage *) init {
    self = [super init];
    if (self) {
		kind = NearbyObjectWebPage;
        iconMediaId = 4;
    }
    return self;	
}



- (void) display{
	NSLog(@"WebPage: Display Self Requested");
	
	//Create a reference to the delegate using the application singleton.
	ARISAppDelegate *appDelegate = (ARISAppDelegate *) [[UIApplication sharedApplication] delegate];
    
	webpageViewController *webPageViewController = [[webpageViewController alloc] initWithNibName:@"webpageViewController" bundle: [NSBundle mainBundle]];
	webPageViewController.webPage = self;
	[appDelegate displayNearbyObjectView:webPageViewController];
}




- (NSString *) name {
    return self.name;
}

- (int)	iconMediaId {
    return 4; 
}

@end
