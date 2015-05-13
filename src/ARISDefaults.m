//
//  ARISDefaults.m
//  ARIS
//
//  Created by Phil Dougherty on 5/24/14.
//
//

#import "ARISDefaults.h"
#import "AppModel.h"
#import "User.h"

@interface ARISDefaults()
{
    NSUserDefaults *defaults; 
    NSMutableDictionary *defaultDefaults; //yeah good work on naming scheme there apple... 
}
@end

@implementation ARISDefaults

@synthesize fallbackGameId;
@synthesize fallbackUser;
@synthesize version;
@synthesize serverURL;

@synthesize showPlayerOnMap;

+ (ARISDefaults *) sharedDefaults
{
  static dispatch_once_t pred = 0;
  __strong static id _sharedObject = nil;
  dispatch_once(&pred, ^{ _sharedObject = [[self alloc] init]; });
  return _sharedObject;
}

- (id) init
{
    if(self = [super init])
    {
        [self loadDefaultUserDefaults];
    }
    return self;
}

- (void) loadDefaultUserDefaults
{
  _ARIS_LOG_(@"DefaultsState : Loading default defaults");

  defaultDefaults = [[NSMutableDictionary alloc] init];

  //Just load immutable settings from root.plist to find default defaults, and put them in easily accessible dictionary
  NSDictionary *settingsDict  = [NSDictionary dictionaryWithContentsOfFile:[[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Settings.bundle"] stringByAppendingPathComponent:@"Root.plist"]];
  NSArray *prefDictArray = settingsDict[@"PreferenceSpecifiers"];
  for(long i = 0; i < prefDictArray.count; i++)
  {
    if(prefDictArray[i][@"DefaultValue"]) 
        defaultDefaults[prefDictArray[i][@"Key"]] = prefDictArray[i][@"DefaultValue"];
  }
}

- (void) loadUserDefaults
{
  _ARIS_LOG_(@"DefaultsState : Loading");
  defaults = [NSUserDefaults standardUserDefaults];

  NSString *defaultServer;
  if(!(defaultServer = [defaults stringForKey:@"baseServerString"])) 
    defaultServer = defaultDefaults[@"baseServerString"];

  NSString *defaultVersion;
  if(!(defaultVersion = [defaults stringForKey:@"appVersion"])) 
    defaultVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];

  if(
    (serverURL && ![defaultServer isEqualToString:serverURL]) || //new server
    (version && ![defaultVersion isEqualToString:version]) || //new version
    [defaults boolForKey:@"clearCache"] //requested clear
    )
  _ARIS_NOTIF_SEND_(@"DEFAULTS_CLEAR",nil,nil); 
    
  serverURL = defaultServer;
  version = defaultVersion; 
  
  [defaults setObject:serverURL forKey:@"baseServerString"];
  [defaults setObject:version forKey:@"appVersion"];
  [defaults setBool:NO forKey:@"clearCache"];
  [defaults synchronize];

  showPlayerOnMap = [defaults boolForKey:@"showPlayerOnMap"];

  User *u          = [[User alloc] init];
  u.user_id        = [defaults integerForKey:@"user_id"];
  u.user_name      = [defaults objectForKey:@"user_name"];
  u.display_name   = [defaults objectForKey:@"display_name"];
  u.email          = [defaults objectForKey:@"email"];
  u.media_id       = [defaults integerForKey:@"media_id"];
  u.read_write_key = [defaults objectForKey:@"read_write_key"];

  _ARIS_LOG_(@"Defaults loaded: user_id       = %ld",u.user_id);
  _ARIS_LOG_(@"Defaults loaded: user_name     = %@",u.user_name);
  _ARIS_LOG_(@"Defaults loaded: display_name  = %@",u.display_name);
  _ARIS_LOG_(@"Defaults loaded: email         = %@",u.email);
  _ARIS_LOG_(@"Defaults loaded: media_id      = %ld",u.media_id);
  _ARIS_LOG_(@"Defaults loaded: read_write_key= %@",u.read_write_key);
  if(u.user_id) fallbackUser = u;
  else fallbackUser = nil;

  if(!fallbackGameId) fallbackGameId = [defaults integerForKey:@"game_id"]; 

  _ARIS_NOTIF_SEND_(@"DEFAULTS_UPDATED",nil,nil);  
}

- (void) saveUserDefaults
{
  _ARIS_LOG_(@"DefaultsState : Saving");

  [defaults setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"appVersion"];
  [defaults setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBuildNumber"]   forKey:@"buildNum"];
  if(_MODEL_GAME_)
      [defaults setInteger:_MODEL_GAME_.game_id forKey:@"game_id"];
  else
      [defaults setInteger:0 forKey:@"game_id"]; 
  if(_MODEL_PLAYER_)
  {
    [defaults setInteger:_MODEL_PLAYER_.user_id        forKey:@"user_id"];
    [defaults setObject: _MODEL_PLAYER_.user_name      forKey:@"user_name"];
    [defaults setObject: _MODEL_PLAYER_.display_name   forKey:@"display_name"];
    [defaults setObject: _MODEL_PLAYER_.email          forKey:@"email"];
    [defaults setInteger:_MODEL_PLAYER_.media_id       forKey:@"media_id"];
    [defaults setObject: _MODEL_PLAYER_.read_write_key forKey:@"read_write_key"];
  }
  else
  {
    [defaults setInteger:0  forKey:@"user_id"];
    [defaults setObject:@"" forKey:@"user_name"];
    [defaults setObject:@"" forKey:@"display_name"];
    [defaults setObject:@"" forKey:@"email"];
    [defaults setInteger:0  forKey:@"media_id"];
    [defaults setObject:@"" forKey:@"read_write_key"];
  }
  [defaults synchronize];
}

@end
