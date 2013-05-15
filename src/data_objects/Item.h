//
//  Item.h
//  ARIS
//
//  Created by David Gagnon on 4/1/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameObjectProtocol.h"

enum
{
	ItemTypeNormal = 0,
    ItemTypeWebPage = 1,
    ItemTypeAttribute = 2
};
typedef UInt32 ItemType;

@interface Item : NSObject <GameObjectProtocol>
{
	int itemId;
	NSString *name;
    NSString *text;
    ItemType itemType;
	int mediaId;
	int iconMediaId;
	int qty;
	int maxQty;
    int weight;
	BOOL dropable;
	BOOL destroyable;
    BOOL tradeable;
    NSString *url;
}

@property (nonatomic, assign) int itemId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, assign) ItemType itemType;
@property (nonatomic, assign) int mediaId;
@property (nonatomic, assign) int iconMediaId;
@property (nonatomic, assign) int qty;
@property (nonatomic, assign) int maxQty;
@property (nonatomic, assign) int weight;
@property (nonatomic, assign) BOOL dropable;
@property (nonatomic, assign) BOOL destroyable;
@property (nonatomic, assign) BOOL tradeable;
@property (nonatomic, strong) NSString *url;

@end
