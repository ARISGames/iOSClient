//
//  Node.h
//  ARIS
//
//  Created by Kevin Harris on 5/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NearbyObjectProtocol.h"

@interface Node : NSObject<NearbyObjectProtocol> {
	NSString *name;
	nearbyObjectKind kind;
	BOOL forcedDisplay;

	NSString *description;
	NSArray *options;
	NSInteger numberOfOptions;
}

@property(readwrite, copy) NSString *name;
@property(readwrite, assign) nearbyObjectKind kind;
@property(readwrite, assign) BOOL forcedDisplay;

@property(readwrite, copy) NSString *description;
@property(readonly) NSArray *options;
@property(readonly) NSInteger numberOfOptions;

- (void) setOptionOneText:(NSString *)fromStringValue;
- (void) setOptionOneId:(NSString *)fromStringValue;
- (void) setOptionTwoText:(NSString *)fromStringValue;
- (void) setOptionTwoId:(NSString *)fromStringValue;
- (void) setOptionThreeText:(NSString *)fromStringValue;
- (void) setOptionThreeId:(NSString *)fromStringValue;

- (void) display;

@end

@interface Node()
- (void) setOption:(SEL)selector atIndex:(NSUInteger)index fromStringValue:(NSString *)value;
@end

