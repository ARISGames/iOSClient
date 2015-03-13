//
//  TagsModel.h
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

#import <Foundation/Foundation.h>
#import "Tag.h"
#import "ObjectTag.h"

@interface TagsModel : NSObject
{
}

- (NSArray *) tags;
- (Tag *) tagForId:(long)tag_id;
- (ObjectTag *) objectTagForId:(long)object_tag_id;
- (NSArray *) tagsForObjectType:(NSString*)t id:(long)object_id;
- (void) removeTagsFromObjectType:(NSString*)t id:(long)object_id;
- (void) requestTags;
- (void) clearGameData;

@end
