//
//  Tag.h
//  ARIS
//
//  Created by Brian Thiel on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tag : NSObject
{
    int tag_id;
	NSString *tag;
	int media_id; 
	int player_created; 
	int visible; 
	int sort_index; 
}

@property(readwrite, assign) int tag_id;
@property(nonatomic, strong) NSString *tag;
@property(readwrite, assign) int media_id;
@property(readwrite, assign) int player_created;
@property(readwrite, assign) int visible;
@property(readwrite, assign) int sort_index;

- (id) initWithDictionary:(NSDictionary *)dict;

@end
