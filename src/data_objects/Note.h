//
//  Note.h
//  ARIS
//
//  Created by Brian Thiel on 8/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InstantiableProtocol.h"

@interface Note : NSObject <InstantiableProtocol>
{
    long note_id;
    long user_id;
    NSString *name;
    NSString *desc;
    long media_id;
    NSDate *created;
}

@property (nonatomic, assign) long note_id;
@property (nonatomic, assign) long user_id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, assign) long media_id;
@property (nonatomic, strong) NSDate *created;

- (id) initWithDictionary:(NSDictionary *)dict;
- (void) mergeDataFromNote:(Note *)n;

@end

