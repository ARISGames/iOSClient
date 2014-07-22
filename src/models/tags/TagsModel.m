//
//  TagsModel.m
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

// RULE OF THUMB:
// Merge any new object data rather than replace. Becuase 'everything is pointers' in obj c, 
// we can't know what data we're invalidating by replacing a ptr

#import "TagsModel.h"
#import "AppServices.h"

@interface TagsModel()
{
    NSMutableDictionary *tags;
}

@end

@implementation TagsModel

- (id) init
{
    if(self = [super init])
    {
        [self clearGameData];
        _ARIS_NOTIF_LISTEN_(@"SERVICES_TAGS_RECEIVED",self,@selector(tagsReceived:),nil);
    }
    return self;
}

- (void) clearGameData
{
    tags = [[NSMutableDictionary alloc] init];
}

- (void) tagsReceived:(NSNotification *)notif
{
    [self updateTags:[notif.userInfo objectForKey:@"tags"]];
}

- (void) updateTags:(NSArray *)newTags
{
    Tag *newTag;
    NSNumber *newTagId;
    for(int i = 0; i < newTags.count; i++)
    {
      newTag = [newTags objectAtIndex:i];
      newTagId = [NSNumber numberWithInt:newTag.tag_id];
      if(![tags objectForKey:newTagId]) [tags setObject:newTag forKey:newTagId];
    }
    _ARIS_NOTIF_SEND_(@"MODEL_TAGS_AVAILABLE",nil,nil);   
    _ARIS_NOTIF_SEND_(@"MODEL_GAME_PIECE_AVAILABLE",nil,nil);       
}

- (void) requestTags
{
    [_SERVICES_ fetchTags];
}

// null webpage (id == 0) NOT flyweight!!! (to allow for temporary customization safety)
- (Tag *) tagForId:(int)tag_id
{
  if(!tag_id) return [[Tag alloc] init];
  return [tags objectForKey:[NSNumber numberWithInt:tag_id]];
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);                                 
}

@end
