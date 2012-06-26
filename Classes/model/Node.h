//
//  Node.h
//  ARIS
//
//  Created by David J Gagnon on 8/31/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NearbyObjectProtocol.h"
#import "QRCodeProtocol.h"
#import "NodeOption.h"

@interface Node : NSObject <NearbyObjectProtocol,QRCodeProtocol> {
	nearbyObjectKind	kind;
	int					nodeId;
	NSString			*name;
	NSString			*text;
	int					mediaId;
	int					iconMediaId;

	NSMutableArray		*options;
	NSInteger			numberOfOptions;

	NSString			*answerString;
	NSInteger			nodeIfCorrect;
	NSInteger			nodeIfIncorrect;
	
	BOOL forcedDisplay; //We only need this for the proto, might be good to define a new one
}

@property(readwrite, assign) nearbyObjectKind kind;
- (nearbyObjectKind) kind;
@property(readwrite, assign) int nodeId;
@property(copy, readwrite) NSString *name;
@property(copy, readwrite) NSString *text;
@property(readwrite, assign) int mediaId;
@property(readwrite, assign) int iconMediaId;
@property(readwrite, assign) int locationId;


@property(readonly) NSMutableArray *options;
@property(readonly) NSInteger numberOfOptions;

@property(readwrite, copy)		NSString	*answerString;
@property(readwrite, assign)	NSInteger	nodeIfCorrect;
@property(readwrite, assign)	NSInteger	nodeIfIncorrect;

- (NSInteger) numberOfOptions;
- (void) addOption: (NodeOption *)newOption;
- (void) display;

@property(readwrite, assign) BOOL forcedDisplay; //see note above


@end

