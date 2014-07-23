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

- (Tag *) tagForId:(int)tag_id;
- (ObjectTag *) objectTagForId:(int)object_tag_id;
- (NSArray *) tagsForObjectType:(NSString*)t id:(int)object_id;
- (void) requestTags;
- (void) clearGameData;

@end
