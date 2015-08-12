//
//  WebPagesModel.h
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

#import <Foundation/Foundation.h>
#import "ARISModel.h"
#import "WebPage.h"

@interface WebPagesModel : ARISModel

- (WebPage *) webPageForId:(long)web_page_id;
- (void) requestWebPages;

@end

