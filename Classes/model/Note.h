//
//  Note.h
//  ARIS
//
//  Created by Brian Thiel on 8/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NearbyObjectProtocol.h"


@interface Note : NSObject<NearbyObjectProtocol> {
    nearbyObjectKind	kind;
    int noteId;
	NSString *text;
    NSString *name;
	int iconMediaId; 
    
}

@property(readwrite, assign) int noteId;
@property(nonatomic, retain) NSString *text;
@property(nonatomic, retain) NSString *name;

@property(readwrite, assign) int iconMediaId;
@property(readwrite, assign) nearbyObjectKind kind;

@end
