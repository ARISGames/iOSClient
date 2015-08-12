//
//  DialogsModel.m
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

// RULE OF THUMB:
// Merge any new object data rather than replace. Becuase 'everything is pointers' in obj c,
// we can't know what data we're invalidating by replacing a ptr

#import "DialogsModel.h"
#import "AppModel.h"
#import "AppServices.h"

@interface DialogsModel()
{
  NSMutableDictionary *dialogs;
  NSMutableDictionary *dialogCharacters;
  NSMutableDictionary *dialogScripts;
  NSMutableDictionary *dialogOptions;
}

@end

@implementation DialogsModel

- (id) init
{
  if(self = [super init])
  {
    [self clearGameData];
    _ARIS_NOTIF_LISTEN_(@"SERVICES_DIALOGS_RECEIVED",self,@selector(dialogsReceived:),nil);
    _ARIS_NOTIF_LISTEN_(@"SERVICES_DIALOG_CHARACTERS_RECEIVED",self,@selector(dialogCharactersReceived:),nil);
    _ARIS_NOTIF_LISTEN_(@"SERVICES_DIALOG_SCRIPTS_RECEIVED",self,@selector(dialogScriptsReceived:),nil);
    _ARIS_NOTIF_LISTEN_(@"SERVICES_DIALOG_OPTIONS_RECEIVED",self,@selector(dialogOptionsReceived:),nil);
    _ARIS_NOTIF_LISTEN_(@"SERVICES_PLAYER_SCRIPT_OPTIONS_RECEIVED",self,@selector(playerScriptOptionsReceived:),nil);
  }
  return self;
}

- (void) requestGameData
{
  [self requestDialogs]; //should be split up into multiple models...
}
- (void) clearGameData
{
  dialogs = [[NSMutableDictionary alloc] init];
  dialogCharacters = [[NSMutableDictionary alloc] init];
  dialogScripts = [[NSMutableDictionary alloc] init];
  dialogOptions = [[NSMutableDictionary alloc] init];
  n_game_data_received = 0;
}
- (long) nGameDataToReceive
{
  return 4;
}

- (void) dialogsReceived:(NSNotification *)notif          { [self updateDialogs:[notif.userInfo objectForKey:@"dialogs"]]; }
- (void) dialogCharactersReceived:(NSNotification *)notif { [self updateDialogCharacters:[notif.userInfo objectForKey:@"dialogCharacters"]]; }
- (void) dialogScriptsReceived:(NSNotification *)notif    { [self updateDialogScripts:[notif.userInfo objectForKey:@"dialogScripts"]]; }
- (void) dialogOptionsReceived:(NSNotification *)notif    { [self updateDialogOptions:[notif.userInfo objectForKey:@"dialogOptions"]]; }
- (void) playerScriptOptionsReceived:(NSNotification *)notif
{
  //Doesn't actually affect the model. just conforms services list to flyweight, and re-sends it out
  NSMutableArray *flyweightOptions = [[NSMutableArray alloc] init];
  NSArray *servicesOptions = notif.userInfo[@"options"];
  for(long i = 0; i < servicesOptions.count; i++)
  {
    DialogOption *o = [self optionForId:((DialogOption *)servicesOptions[i]).dialog_option_id];
    if(o) [flyweightOptions addObject:o];
  }

  NSDictionary *uInfo = @{@"options":flyweightOptions,
    @"dialog_id":notif.userInfo[@"dialog_id"],
    @"dialog_script_id":notif.userInfo[@"dialog_script_id"]};
  _ARIS_NOTIF_SEND_(@"MODEL_PLAYER_SCRIPT_OPTIONS_AVAILABLE",nil,uInfo);
}

- (void) updateDialogs:(NSArray *)newDialogs
{
  Dialog *newDialog;
  NSNumber *newDialogId;
  for(long i = 0; i < newDialogs.count; i++)
  {
    newDialog = [newDialogs objectAtIndex:i];
    newDialogId = [NSNumber numberWithLong:newDialog.dialog_id];
    if(![dialogs objectForKey:newDialogId]) [dialogs setObject:newDialog forKey:newDialogId];
  }
  n_game_data_received++;
  _ARIS_NOTIF_SEND_(@"MODEL_DIALOGS_AVAILABLE",nil,nil);
  _ARIS_NOTIF_SEND_(@"MODEL_GAME_PIECE_AVAILABLE",nil,nil);
}
- (void) updateDialogCharacters:(NSArray *)newDialogCharacters
{
  DialogCharacter *newDialogCharacter;
  NSNumber *newDialogCharacterId;
  for(long i = 0; i < newDialogCharacters.count; i++)
  {
    newDialogCharacter = [newDialogCharacters objectAtIndex:i];
    newDialogCharacterId = [NSNumber numberWithLong:newDialogCharacter.dialog_character_id];
    if(![dialogCharacters objectForKey:newDialogCharacterId]) [dialogCharacters setObject:newDialogCharacter forKey:newDialogCharacterId];
  }
  n_game_data_received++;
  _ARIS_NOTIF_SEND_(@"MODEL_DIALOG_CHARACTERS_AVAILABLE",nil,nil);
  _ARIS_NOTIF_SEND_(@"MODEL_GAME_PIECE_AVAILABLE",nil,nil);
}
- (void) updateDialogScripts:(NSArray *)newDialogScripts
{
  DialogScript *newDialogScript;
  NSNumber *newDialogScriptId;
  for(long i = 0; i < newDialogScripts.count; i++)
  {
    newDialogScript = [newDialogScripts objectAtIndex:i];
    newDialogScriptId = [NSNumber numberWithLong:newDialogScript.dialog_script_id];
    if(![dialogScripts objectForKey:newDialogScriptId]) [dialogScripts setObject:newDialogScript forKey:newDialogScriptId];
  }
  n_game_data_received++;
  _ARIS_NOTIF_SEND_(@"MODEL_DIALOG_SCRIPTS_AVAILABLE",nil,nil);
  _ARIS_NOTIF_SEND_(@"MODEL_GAME_PIECE_AVAILABLE",nil,nil);
}
- (void) updateDialogOptions:(NSArray *)newDialogOptions
{
  DialogOption *newDialogOption;
  NSNumber *newDialogOptionId;
  for(long i = 0; i < newDialogOptions.count; i++)
  {
    newDialogOption = [newDialogOptions objectAtIndex:i];
    newDialogOptionId = [NSNumber numberWithLong:newDialogOption.dialog_option_id];
    if(![dialogOptions objectForKey:newDialogOptionId]) [dialogOptions setObject:newDialogOption forKey:newDialogOptionId];
  }
  n_game_data_received++;
  _ARIS_NOTIF_SEND_(@"MODEL_DIALOG_OPTIONS_AVAILABLE",nil,nil);
  _ARIS_NOTIF_SEND_(@"MODEL_GAME_PIECE_AVAILABLE",nil,nil);
}

- (void) requestDialogs
{
  [_SERVICES_ fetchDialogs];
  [_SERVICES_ fetchDialogCharacters];
  [_SERVICES_ fetchDialogScripts];
  [_SERVICES_ fetchDialogOptions];
}
- (void) requestPlayerOptionsForDialogId:(long)dialog_id scriptId:(long)dialog_script_id
{
  if([_MODEL_GAME_.network_level isEqualToString:@"LOCAL"])
  {
    NSMutableArray *pops = [[NSMutableArray alloc] init];
    NSDictionary *uInfo = @{@"options":pops,
      @"dialog_id":[NSNumber numberWithLong:dialog_id],
      @"dialog_script_id":[NSNumber numberWithLong:dialog_script_id]};
    NSArray *os = [dialogOptions allValues];
    for(int i = 0; i < os.count; i++)
    {
      DialogOption *o = os[i];
      if(o.dialog_id == dialog_id &&
          o.parent_dialog_script_id == dialog_script_id &&
          [_MODEL_REQUIREMENTS_ evaluateRequirementRoot:o.requirement_root_package_id])
        [pops addObject:o];
    }
    _ARIS_NOTIF_SEND_(@"SERVICES_PLAYER_SCRIPT_OPTIONS_RECEIVED", nil, uInfo);
  }
  else [_SERVICES_ fetchOptionsForPlayerForDialog:dialog_id script:dialog_script_id];
}

// null dialog/character/script (id == 0) NOT flyweight!!! (to allow for temporary customization safety)
- (Dialog *) dialogForId:(long)dialog_id
{
  if(!dialog_id) return [[Dialog alloc] init];
  return [dialogs objectForKey:[NSNumber numberWithLong:dialog_id]];
}
- (DialogCharacter *) characterForId:(long)dialog_character_id
{
  if(!dialog_character_id) return [[DialogCharacter alloc] init];
  return [dialogCharacters objectForKey:[NSNumber numberWithLong:dialog_character_id]];
}
- (DialogScript *) scriptForId:(long)dialog_script_id
{
  if(!dialog_script_id) return [[DialogScript alloc] init];
  return [dialogScripts objectForKey:[NSNumber numberWithLong:dialog_script_id]];
}
- (DialogOption *) optionForId:(long)dialog_option_id
{
  if(!dialog_option_id) return [[DialogOption alloc] init];
  return [dialogOptions objectForKey:[NSNumber numberWithLong:dialog_option_id]];
}

- (void) dealloc
{
  _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end
