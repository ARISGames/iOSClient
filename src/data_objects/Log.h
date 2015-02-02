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
    long log_id;
    NSString *event_type;
    long content_id;
    long qty;
    CLLocation *location;
}

@property (nonatomic, assign) long log_id;
@property (nonatomic, strong) NSString *event_type;
@property (nonatomic, assign) long content_id;
@property (nonatomic, assign) long qty;
@property (nonatomic, strong) CLLocation *location;

- (id) initWithDictionary:(NSDictionary *)dict;

@end
