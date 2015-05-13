//
//  User.h
//  ARIS
//
//  Created by David Gagnon on 5/30/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface User : NSObject
{
    long user_id;
    NSString *user_name;
    NSString *display_name;
    NSString* email;
    long media_id;
    NSString *read_write_key;
    CLLocation *location;
}

@property (nonatomic, assign) long user_id;
@property (nonatomic, strong) NSString *user_name;
@property (nonatomic, strong) NSString *display_name;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, assign) long media_id;
@property (nonatomic, strong) NSString *read_write_key;
@property (nonatomic, strong) CLLocation *location;

- (id) initWithDictionary:(NSDictionary *)dict;
- (User *) mergeDataFromUser:(User *)u;

@end
