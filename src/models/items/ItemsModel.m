//
//  ItemsModel.m
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

// RULE OF THUMB:
// Merge any new object data rather than replace. Becuase 'everything is pointers' in obj c,
// we can't know what data we're invalidating by replacing a ptr

#import "ItemsModel.h"
#import "AppServices.h"

@interface ItemsModel()
{
    NSMutableDictionary *items;
    long game_info_recvd;
}

@end

@implementation ItemsModel

- (id) init
{
    if(self = [super init])
    {
        [self clearGameData];
        _ARIS_NOTIF_LISTEN_(@"SERVICES_ITEMS_RECEIVED",self,@selector(itemsReceived:),nil);
    }
    return self;
}

- (void) clearGameData
{
    items = [[NSMutableDictionary alloc] init];
    game_info_recvd = 0;
}

- (BOOL) gameInfoRecvd
{
  return game_info_recvd >= 1;
}

- (void) itemsReceived:(NSNotification *)notif
{
    [self updateItems:[notif.userInfo objectForKey:@"items"]];
}

- (void) updateItems:(NSArray *)newItems
{
    Item *newItem;
    NSNumber *newItemId;
    for(long i = 0; i < newItems.count; i++)
    {
      newItem = [newItems objectAtIndex:i];
      newItemId = [NSNumber numberWithLong:newItem.item_id];
      if(![items objectForKey:newItemId]) [items setObject:newItem forKey:newItemId];
    }
    game_info_recvd++;
    _ARIS_NOTIF_SEND_(@"MODEL_ITEMS_AVAILABLE",nil,nil);
    _ARIS_NOTIF_SEND_(@"MODEL_GAME_PIECE_AVAILABLE",nil,nil);
}

- (void) requestItems
{
    [_SERVICES_ fetchItems];
}

- (NSArray *) items
{
    return [items allValues];
}

// null item (id == 0) NOT flyweight!!! (to allow for temporary customization safety)
- (Item *) itemForId:(long)item_id
{
  if(!item_id) return [[Item alloc] init];
  return [items objectForKey:[NSNumber numberWithLong:item_id]];
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end
