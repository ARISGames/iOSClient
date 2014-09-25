//
//  Scene.m
//  ARIS
//
//  Created by David Gagnon on 4/1/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "Scene.h"
#import "NSDictionary+ValidParsers.h"

@implementation Scene

@synthesize scene_id;
@synthesize name; 

- (id) init
{
    if(self = [super init])
    {
        self.scene_id = 0;
        self.name = @""; 
    }
    return self;
}

- (id) initWithDictionary:(NSDictionary *)dict
{
    if(self = [super init])
    {
        self.scene_id = [dict validIntForKey:@"scene_id"];
        self.name = [dict validStringForKey:@"name"];
    }
    return self;
}

//To comply w/ instantiable protocol. should get default image later.
- (int) icon_media_id
{
    return 0;
}

@end

