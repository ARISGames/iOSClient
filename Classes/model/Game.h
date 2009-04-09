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
	NSString *name;
}

@property(readwrite, assign) int gameId;
@property(copy, readwrite) NSString *name;

@end
