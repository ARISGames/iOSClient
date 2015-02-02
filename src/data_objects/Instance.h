//
//  Instance.h
//  ARIS
//
//  Created by David Gagnon on 4/1/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InstantiableProtocol.h"

@interface Instance : NSObject 
{
    long instance_id;
    NSString *object_type; 
    long object_id;   
    long owner_id;
    long qty; 
    BOOL infinite_qty;
}

@property (nonatomic, assign) long instance_id;
@property (nonatomic, strong) NSString *object_type;
@property (nonatomic, assign) long object_id;
@property (nonatomic, assign) long owner_id;
@property (nonatomic, assign) long qty;
@property (nonatomic, assign) BOOL infinite_qty;

- (id) initWithDictionary:(NSDictionary *)dict;
- (void) mergeDataFromInstance:(Instance *)i;
- (Instance *) copy;

- (id<InstantiableProtocol>) object;
- (NSString *) name;
- (long) icon_media_id;

@end
