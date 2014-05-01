//
//  Instance.h
//  ARIS
//
//  Created by David Gagnon on 4/1/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameObjectProtocol.h"

@interface Instance : NSObject <GameObjectProtocol>
{
    int instance_id;
    NSObject<GameObjectProtocol> *object;
    int qty;
    BOOL infiniteQty;
}

@property (nonatomic, assign) int instance_id;
@property (nonatomic, strong) NSObject<GameObjectProtocol> *object;
@property (nonatomic, assign) int qty;
@property (nonatomic, assign) BOOL infiniteQty;

@end
