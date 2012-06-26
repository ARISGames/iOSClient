//
//  WebPage.h
//  ARIS
//
//  Created by Brian Thiel on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NearbyObjectProtocol.h"


@interface WebPage : NSObject<NearbyObjectProtocol> {
    nearbyObjectKind	kind;
    int webPageId;
	NSString *name;
	NSString *url;    
	int iconMediaId; 

}

@property(readwrite, assign) int webPageId;
@property(nonatomic) NSString *name;
@property(nonatomic) NSString *url;
@property(readwrite, assign) int iconMediaId;
@property(readwrite, assign) nearbyObjectKind kind;
@property(readwrite, assign) int locationId;

@end
