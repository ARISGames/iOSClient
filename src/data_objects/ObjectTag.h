//
//  ObjectTag.h
//  ARIS
//
//  Created by Brian Thiel on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObjectTag : NSObject
{
    long object_tag_id;
	NSString *object_type;
	long object_id;
	long tag_id;
}

@property(readwrite, assign) long object_tag_id;
@property(nonatomic, strong) NSString *object_type;
@property(readwrite, assign) long object_id;
@property(readwrite, assign) long tag_id;

- (id) initWithDictionary:(NSDictionary *)dict;

@end
