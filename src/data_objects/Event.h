//
//  Event.h
//  ARIS
//
//  Created by Brian Thiel on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Event : NSObject
{
    int event_id;
	int event_package_id; 
	NSString *event;
	int content_id; 
    int qty;
}

@property(readwrite, assign) int event_id;
@property(readwrite, assign) int event_package_id;
@property(nonatomic, strong) NSString *event;
@property(readwrite, assign) int content_id;
@property(readwrite, assign) int qty;

- (id) initWithDictionary:(NSDictionary *)dict;

@end
