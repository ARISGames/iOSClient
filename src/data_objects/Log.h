//
//  Log.h
//  ARIS
//
//  Created by David Gagnon on 4/1/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>

@interface Log : NSObject 
{
    int log_id;
    NSString *event_type;
    int content_id;
    int qty;
    CLLocation *location;
}

@property (nonatomic, assign) int log_id;
@property (nonatomic, strong) NSString *event_type;
@property (nonatomic, assign) int content_id;
@property (nonatomic, assign) int qty;
@property (nonatomic, strong) CLLocation *location;

- (id) initWithDictionary:(NSDictionary *)dict;

@end
