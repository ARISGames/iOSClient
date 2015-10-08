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
  long event_id;
  long event_package_id;
  NSString *event;
  long content_id;
  long qty;
  NSString *script;
}

@property(readwrite, assign) long event_id;
@property(readwrite, assign) long event_package_id;
@property(nonatomic, strong) NSString *event;
@property(readwrite, assign) long content_id;
@property(readwrite, assign) long qty;
@property(nonatomic, strong) NSString *script;

- (id) initWithDictionary:(NSDictionary *)dict;
- (NSString *) serialize;

@end

