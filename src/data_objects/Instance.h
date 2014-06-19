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
    int instance_id;
    NSString *object_type; 
    int object_id;   
    int owner_id;
    int qty; 
    BOOL infinite_qty;
}

@property (nonatomic, assign) int instance_id;
@property (nonatomic, strong) NSString *object_type;
@property (nonatomic, assign) int object_id;
@property (nonatomic, assign) int owner_id;
@property (nonatomic, assign) int qty;
@property (nonatomic, assign) BOOL infinite_qty;

- (id) initWithDictionary:(NSDictionary *)dict;
- (void) mergeDataFromInstance:(Instance *)i;
- (Instance *) copy;

- (id<InstantiableProtocol>) object;
- (NSString *) name;
- (int) icon_media_id;

@end
