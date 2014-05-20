//
//  Instance.h
//  ARIS
//
//  Created by David Gagnon on 4/1/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Instance : NSObject 
{
    int instance_id;
    NSString *type; 
    NSObject *object;
    int qty;
    BOOL infinite_qty;
}

@property (nonatomic, assign) int instance_id;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSObject *object;
@property (nonatomic, assign) int qty;
@property (nonatomic, assign) BOOL infinite_qty;

- (id) initWithDictionary:(NSDictionary *)dict;
- (Instance *) copy;

@end
