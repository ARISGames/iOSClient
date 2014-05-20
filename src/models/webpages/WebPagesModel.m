//
//  WebPagesModel.m
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

// RULE OF THUMB:
// Merge any new object data rather than replace. Becuase 'everything is pointers' in obj c, 
// we can't know what data we're invalidating by replacing a ptr

#import "WebPagesModel.h"

@interface WebPagesModel()
{
    NSMutableDictionary *webPages;
}

@end

@implementation WebPagesModel

- (id) init
{
    if(self = [super init])
    {
        [self clearGameData];
  _ARIS_NOTIF_LISTEN_(@"GameWebPagesReceived",self,@selector(gameWebPagesReceived:),nil);
    }
    return self;
}

- (void) clearGameData
{
    webPages = [[NSMutableDictionary alloc] init];
}

- (void) gameWebPagesReceived:(NSNotification *)notif
{
    [self updateWebPages:[notif.userInfo objectForKey:@"webPages"]];
}

- (void) updateWebPages:(NSArray *)newWebPages
{
    WebPage *newWebPage;
    NSNumber *newWebPageId;
    for(int i = 0; i < newWebPages.count; i++)
    {
      newWebPage = [newWebPages objectAtIndex:i];
      newWebPageId = [NSNumber numberWithInt:newWebPage.web_page_id];
      if(![webPages objectForKey:newWebPageId]) [webPages setObject:newWebPage forKey:newWebPageId];
    }
}

- (WebPage *) webPageForId:(int)web_page_id
{
  return [webPages objectForKey:[NSNumber numberWithInt:web_page_id]];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
