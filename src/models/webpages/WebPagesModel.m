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
#import "AppServices.h"

@interface WebPagesModel()
{
    NSMutableDictionary *webPages;
    long game_info_recvd;
}

@end

@implementation WebPagesModel

- (id) init
{
    if(self = [super init])
    {
        [self clearGameData];
        _ARIS_NOTIF_LISTEN_(@"SERVICES_WEB_PAGES_RECEIVED",self,@selector(webPagesReceived:),nil);
    }
    return self;
}

- (void) clearGameData
{
    webPages = [[NSMutableDictionary alloc] init];
    game_info_recvd = 0;
}

- (BOOL) gameInfoRecvd
{
  return game_info_recvd >= 1;
}

- (void) webPagesReceived:(NSNotification *)notif
{
    [self updateWebPages:[notif.userInfo objectForKey:@"webPages"]];
}

- (void) updateWebPages:(NSArray *)newWebPages
{
    WebPage *newWebPage;
    NSNumber *newWebPageId;
    for(long i = 0; i < newWebPages.count; i++)
    {
      newWebPage = [newWebPages objectAtIndex:i];
      newWebPageId = [NSNumber numberWithLong:newWebPage.web_page_id];
      if(![webPages objectForKey:newWebPageId]) [webPages setObject:newWebPage forKey:newWebPageId];
    }
    _ARIS_NOTIF_SEND_(@"MODEL_WEB_PAGES_AVAILABLE",nil,nil);
    _ARIS_NOTIF_SEND_(@"MODEL_GAME_PIECE_AVAILABLE",nil,nil);
    game_info_recvd = YES;
}

- (void) requestWebPages
{
    [_SERVICES_ fetchWebPages];
}

// null webpage (id == 0) NOT flyweight!!! (to allow for temporary customization safety)
- (WebPage *) webPageForId:(long)web_page_id
{
  if(!web_page_id) return [[WebPage alloc] init];
  return [webPages objectForKey:[NSNumber numberWithLong:web_page_id]];
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end
