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
    int object_tag_id;
	NSString *object_type;
	int object_id; 
	int tag_id; 
}

@property(readwrite, assign) int object_tag_id;
@property(nonatomic, strong) NSString *object_type;
@property(readwrite, assign) int object_id;
@property(readwrite, assign) int tag_id;

- (id) initWithDictionary:(NSDictionary *)dict;

@end
