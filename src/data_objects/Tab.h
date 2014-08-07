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
    int tab_id;
    NSString *type;
    NSString *name; 
    int icon_media_id; 
    int content_id;
    NSString *info;
    int sort_index;
}

@property (nonatomic, assign) int tab_id;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *name; 
@property (nonatomic, assign) int icon_media_id; 
@property (nonatomic, assign) int content_id;
@property (nonatomic, strong) NSString *info; 
@property (nonatomic, assign) int sort_index;

- (id) initWithDictionary:(NSDictionary *)dict;
- (NSString *) keyString;

@end
