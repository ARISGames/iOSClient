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

- (void) requestGameData
{
  [self requestWebPages];
}
- (void) clearGameData
{
    webPages = [[NSMutableDictionary alloc] init];
    n_game_data_received = 0;
}
- (long) nGameDataToReceive
{
  return 1;
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
    n_game_data_received++;
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

- (NSString *) serializeModel
{
  NSArray *web_pages_a = [webPages allValues];
  WebPage *w_o;

  NSMutableString *r = [[NSMutableString alloc] init];
  [r appendString:@"{\"web_pages\":["];
  for(long i = 0; i < web_pages_a.count; i++)
  {
    w_o = web_pages_a[i];
    [r appendString:[w_o serialize]];
    if(i != web_pages_a.count-1) [r appendString:@","];
  }
  [r appendString:@"]}"];
  return r;
}

- (void) deserializeModel:(NSString *)data
{

}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end
