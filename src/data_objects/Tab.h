//
//  Tab.h
//  ARIS
//
//  Created by Brian Thiel on 8/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tab : NSObject
{
    long tab_id;
    NSString *type;
    NSString *name; 
    long icon_media_id; 
    long content_id;
    NSString *info;
    long sort_index;
}

@property (nonatomic, assign) long tab_id;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *name; 
@property (nonatomic, assign) long icon_media_id; 
@property (nonatomic, assign) long content_id;
@property (nonatomic, strong) NSString *info; 
@property (nonatomic, assign) long sort_index;

- (id) initWithDictionary:(NSDictionary *)dict;
- (NSString *) keyString;

@end
