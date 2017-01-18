//
//  ARTargetsModel.m
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

// RULE OF THUMB:
// Merge any new object data rather than replace. Becuase 'everything is pointers' in obj c,
// we can't know what data we're invalidating by replacing a ptr

#import "ARTargetsModel.h"
#import "AppModel.h"
#import "AppServices.h"
#import "SBJson.h"

@interface ARTargetsModel() <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
  NSMutableDictionary *ar_targets;
  
  NSMutableData *xmlData;
  NSURLRequest *xmlRequest;
  NSURLConnection *xmlConnection;
  
  NSMutableData *datData;
  NSURLRequest *datRequest;
  NSURLConnection *datConnection;
}

@end

@implementation ARTargetsModel

@synthesize xmlURL;
@synthesize datURL;

- (id) init
{
  if(self = [super init])
  {
    [self clearGameData];
    _ARIS_NOTIF_LISTEN_(@"SERVICES_AR_TARGETS_RECEIVED",self,@selector(arTargetsReceived:),nil);
  }
  return self;
}

- (void) requestGameData
{
  [self requestARTargets];
  [self loadTargetDB];
}
- (void) clearGameData
{
  ar_targets = [[NSMutableDictionary alloc] init];
  n_game_data_received = 0;
}
- (long) nGameDataToReceive
{
  return 3;
}

- (void) arTargetsReceived:(NSNotification *)notif
{
  [self updateARTargets:notif.userInfo[@"ar_targets"]];
}

- (void) updateARTargets:(NSArray *)newARTargets
{
  ARTarget *newARTarget;
  NSNumber *newARTargetId;
  for(long i = 0; i < newARTargets.count; i++)
  {
    newARTarget = [newARTargets objectAtIndex:i];
    newARTargetId = [NSNumber numberWithLong:newARTarget.ar_target_id];
    if(!ar_targets[newARTargetId]) [ar_targets setObject:newARTarget forKey:newARTargetId];
  }
  n_game_data_received++;
  _ARIS_NOTIF_SEND_(@"MODEL_AR_TARGETS_AVAILABLE",nil,nil);
  _ARIS_NOTIF_SEND_(@"GAME_PIECE_AVAILABLE",nil,nil);
}

- (void) requestARTargets
{
  [_SERVICES_ fetchARTargets];
}

// null ar_target (id == 0) NOT flyweight!!! (to allow for temporary customization safety)
- (ARTarget *) arTargetForId:(long)ar_target_id
{
  if(!ar_target_id) return [[ARTarget alloc] init];
  return ar_targets[[NSNumber numberWithLong:ar_target_id]];
}

- (NSString *) serializedName
{
  return @"ar_targets";
}

- (NSString *) serializeGameData
{
  NSArray *ar_targets_a = [ar_targets allValues];
  ARTarget *s_o;

  NSMutableString *r = [[NSMutableString alloc] init];
  [r appendString:@"{\"ar_targets\":["];
  for(long i = 0; i < ar_targets_a.count; i++)
  {
    s_o = ar_targets_a[i];
    [r appendString:[s_o serialize]];
    if(i != ar_targets_a.count-1) [r appendString:@","];
  }
  [r appendString:@"]}"];
  return r;
}

- (void) deserializeGameData:(NSString *)data
{
  [self clearGameData];
  SBJsonParser *jsonParser = [[SBJsonParser alloc] init];

  NSDictionary *d_data = [jsonParser objectWithString:data];
  NSArray *d_ar_targets = d_data[@"ar_targets"];
  for(long i = 0; i < d_ar_targets.count; i++)
  {
    ARTarget *s = [[ARTarget alloc] initWithDictionary:d_ar_targets[i]];
    [ar_targets setObject:s forKey:[NSNumber numberWithLong:s.ar_target_id]];
  }
  n_game_data_received = [self nGameDataToReceive];
}

- (void) loadTargetDB
{
  NSURL *xmlUrl = [[NSURL alloc] initWithString:@""];
  xmlData = [[NSMutableData alloc] initWithCapacity:2048];
  xmlRequest = [NSURLRequest requestWithURL:xmlUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
  xmlConnection = [[NSURLConnection alloc] initWithRequest:xmlRequest delegate:self];
  
  NSURL *datUrl = [[NSURL alloc] initWithString:@""];
  datData = [[NSMutableData alloc] initWithCapacity:2048];
  datRequest = [NSURLRequest requestWithURL:datUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
  datConnection = [[NSURLConnection alloc] initWithRequest:datRequest delegate:self];
}

- (void) connection:(NSURLConnection *)c didReceiveData:(NSData *)d
{
  if(c == xmlConnection) [xmlData appendData:d];
  if(c == datConnection) [datData appendData:d];
}

- (void) connection:(NSURLConnection *)c didFailWithError:(NSError *)error
{
  if(c == xmlConnection)
  {
    n_game_data_received++;
    _ARIS_NOTIF_SEND_(@"MODEL_AR_TARGET_DB_XML_AVAILABLE",nil,nil);
    _ARIS_NOTIF_SEND_(@"GAME_PIECE_AVAILABLE",nil,nil);
  }
  if(c == datConnection)
  {
    n_game_data_received++;
    _ARIS_NOTIF_SEND_(@"MODEL_AR_TARGET_DB_DAT_AVAILABLE",nil,nil);
    _ARIS_NOTIF_SEND_(@"GAME_PIECE_AVAILABLE",nil,nil);
  }
}

- (void) connectionDidFinishLoading:(NSURLConnection*)c
{
  NSString *g = [NSString stringWithFormat:@"%ld",_MODEL_GAME_.game_id]; //game_id as string
  NSString *newFolder = _ARIS_LOCAL_URL_FROM_PARTIAL_PATH_(g);
  
  if(![[NSFileManager defaultManager] fileExistsAtPath:newFolder isDirectory:nil])
    [[NSFileManager defaultManager] createDirectoryAtPath:newFolder withIntermediateDirectories:YES attributes:nil error:nil];
  
  if(c == xmlConnection)
  {
    NSString *partial_url = [NSString stringWithFormat:@"%@/vuforiadb.xml",g];
    xmlURL = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@",_ARIS_LOCAL_URL_FROM_PARTIAL_PATH_(partial_url)]];
    [xmlData writeToURL:xmlURL options:nil error:nil];
    [xmlURL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:nil];
    xmlConnection = nil;
    xmlData = nil;
    n_game_data_received++;
    
    _ARIS_NOTIF_SEND_(@"MODEL_AR_TARGET_DB_XML_AVAILABLE",nil,nil);
    _ARIS_NOTIF_SEND_(@"GAME_PIECE_AVAILABLE",nil,nil);
  }
  if(c == datConnection)
  {
    NSString *partial_url = [NSString stringWithFormat:@"%@/vuforiadb.dat",g];
    datURL = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@",_ARIS_LOCAL_URL_FROM_PARTIAL_PATH_(partial_url)]];
    [datData writeToURL:datURL options:nil error:nil];
    [datURL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:nil];
    datConnection = nil;
    datData = nil;
    n_game_data_received++;
    _ARIS_NOTIF_SEND_(@"MODEL_AR_TARGET_DB_DAT_AVAILABLE",nil,nil);
    _ARIS_NOTIF_SEND_(@"GAME_PIECE_AVAILABLE",nil,nil);
  }
}

- (void) dealloc
{
  if(xmlConnection) [xmlConnection cancel];
  if(datConnection) [datConnection cancel];
  _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end
