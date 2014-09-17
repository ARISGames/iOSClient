//
//  Scene.h
//  ARIS
//
//  Created by David Gagnon on 4/1/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>

@interface Scene : NSObject
{
    int scene_id;
    NSString *name; 
}

@property (nonatomic, assign) int scene_id;
@property (nonatomic, strong) NSString *name; 

- (id) initWithDictionary:(NSDictionary *)dict;

@end
