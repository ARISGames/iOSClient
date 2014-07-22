//
//  TagsModel.h
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

#import <Foundation/Foundation.h>
#import "Tag.h"

@interface TagsModel : NSObject
{
}

- (Tag *) tagForId:(int)tag_id;
- (void) requestTags;
- (void) clearGameData;

@end
