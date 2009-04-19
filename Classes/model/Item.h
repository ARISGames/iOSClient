//
//  Item.h
//  ARIS
//
//  Created by David Gagnon on 4/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Item : NSObject {
	int itemId;
	int locationId; //null if in the player's inventory
	NSString *name;
	NSString *description;
	NSString *type;
	NSString *mediaURL;
	NSString *iconURL;
}

@property(readwrite, assign) int itemId;
@property(readwrite, assign) int locationId;
@property(copy, readwrite) NSString *name;
@property(copy, readwrite) NSString *description;
@property(copy, readwrite) NSString *type;
@property(copy, readwrite) NSString *mediaURL;
@property(copy, readwrite) NSString *iconURL;

/*
- (Item*)initWithId:(int)id andName:(NSString*)newName andDescription:(NSString)newDescription 
							andType:(NSString)newType andMediaURL:(NSString)newMediaURL
							andIconURL:(NSString)newIconURL;

- (UIViewController*)showModalDetailsView;
*/


@end
