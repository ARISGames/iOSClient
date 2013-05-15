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
    BOOL hasViewed;
}

@property(readwrite, copy) NSString *text;
@property(readwrite, assign) NSInteger nodeId;
@property(readwrite, assign) BOOL hasViewed;

- (NodeOption *) initWithText:(NSString *)optionText andNodeId: (int)optionNodeId
                 andHasViewed:(BOOL)hasViewedB;
@end