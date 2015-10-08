//
//  TagsModel.h
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

#import <Foundation/Foundation.h>
#import "ARISModel.h"
#import "Tag.h"
#import "ObjectTag.h"

@interface TagsModel : ARISModel

- (NSArray *) tags;
- (Tag *) tagForId:(long)tag_id;
- (ObjectTag *) objectTagForId:(long)object_tag_id;
- (NSArray *) tagsForObjectType:(NSString*)t id:(long)object_id;
- (NSArray *) objectIdsOfType:(NSString *)t tag:(long)tag_id;
- (void) removeTagsFromObjectType:(NSString*)t id:(long)object_id;
- (void) requestTags;

@end

