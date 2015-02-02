//
//  WebPagesModel.h
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

#import <Foundation/Foundation.h>
#import "WebPage.h"

@interface WebPagesModel : NSObject
{
}

- (WebPage *) webPageForId:(long)web_page_id;
- (void) requestWebPages;
- (void) clearGameData;

@end
