//
//  Game.h
//  ARIS
//
//  Created by Ben Longoria on 2/16/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Game : NSObject {
	int gameId;
	NSString *site;
	NSString *name;
	int pcMediaId;
}

@property(readwrite, assign) int gameId;
@property(copy, readwrite) NSString *site;
@property(copy, readwrite) NSString *name;
@property(readwrite, assign) int pcMediaId;


@end
