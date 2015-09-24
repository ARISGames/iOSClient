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
    long tag_id;
  NSString *tag;
  long media_id;
  long visible;
  long curated;
  long sort_index;
}

@property(readwrite, assign) long tag_id;
@property(nonatomic, strong) NSString *tag;
@property(readwrite, assign) long media_id;
@property(readwrite, assign) long visible;
@property(readwrite, assign) long curated;
@property(readwrite, assign) long sort_index;

- (id) initWithDictionary:(NSDictionary *)dict;

@end
