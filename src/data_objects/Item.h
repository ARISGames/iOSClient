//
//  Item.h
//  ARIS
//
//  Created by David Gagnon on 4/1/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameObjectProtocol.h"

typedef enum
{
	ItemTypeNormal = 0,
    ItemTypeWebPage = 1,
    ItemTypeAttribute = 2
} ItemType;

@interface ItemTag : NSObject
{
    NSString *name;
    int media_id;
}
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) int media_id;
@end

@interface Item : NSObject <GameObjectProtocol>
{
	int itemId;
	NSString *name;
    NSString *idescription;
    ItemType itemType;
	int mediaId;
	int iconMediaId;
	int qty;
	int maxQty;
    BOOL infiniteQty;
    int weight;
	BOOL dropable;
	BOOL destroyable;
    NSString *url;
    NSMutableArray *tags;
}

@property (nonatomic, assign) int itemId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *idescription;
@property (nonatomic, assign) ItemType itemType;
@property (nonatomic, assign) int mediaId;
@property (nonatomic, assign) int iconMediaId;
@property (nonatomic, assign) int qty;
@property (nonatomic, assign) int maxQty;
@property (nonatomic, assign) BOOL infiniteQty;
@property (nonatomic, assign) int weight;
@property (nonatomic, assign) BOOL dropable;
@property (nonatomic, assign) BOOL destroyable;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSMutableArray *tags;

@end
