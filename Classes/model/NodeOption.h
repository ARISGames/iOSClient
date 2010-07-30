//
//  Option.h
//  ARIS
//
//  Created by Kevin Harris on 5/18/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NodeOption : NSObject {
	NSString *text;
	NSInteger nodeId;
}

@property(readwrite, copy) NSString *text;
@property(readwrite, assign) NSInteger nodeId;


- (NodeOption *) initWithText:(NSString *)text andNodeId: (int)nodeId;

@end