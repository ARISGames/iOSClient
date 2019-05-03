//
//  RequirementsModel.m
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

// RULE OF THUMB:
// Merge any new object data rather than replace. Becuase 'everything is pointers' in obj c,
// we can't know what data we're invalidating by replacing a ptr

#import "RequirementsModel.h"
#import "AppModel.h"
#import "AppServices.h"

@interface RequirementsModel()
{
  NSMutableDictionary *requirementRootPackages;
  NSMutableDictionary *requirementAndPackages;
  NSMutableDictionary *requirementAtoms;
}

@end

@implementation RequirementsModel

- (id) init
{
  if(self = [super init])
  {
    [self clearGameData];
    _ARIS_NOTIF_LISTEN_(@"SERVICES_REQUIREMENT_ROOT_PACKAGES_RECEIVED",self,@selector(requirementRootPackagesReceived:),nil);
    _ARIS_NOTIF_LISTEN_(@"SERVICES_REQUIREMENT_AND_PACKAGES_RECEIVED",self,@selector(requirementAndPackagesReceived:),nil);
    _ARIS_NOTIF_LISTEN_(@"SERVICES_REQUIREMENT_ATOMS_RECEIVED",self,@selector(requirementAtomsReceived:),nil);
  }
  return self;
}

- (void) requestGameData
{
  [self requestRequirements]; //should be three different models
}
- (void) clearGameData
{
  requirementRootPackages = [[NSMutableDictionary alloc] init];
  requirementAndPackages = [[NSMutableDictionary alloc] init];
  requirementAtoms = [[NSMutableDictionary alloc] init];
  n_game_data_received = 0;
}
- (long) nGameDataToReceive
{
  return 3;
}

- (void) requestRequirements
{
  [_SERVICES_ fetchRequirementRoots];
  [_SERVICES_ fetchRequirementAnds];
  [_SERVICES_ fetchRequirementAtoms];
}

//ROOT
- (void) requirementRootPackagesReceived:(NSNotification *)notif
{
  [self updateRequirementRootPackages:[notif.userInfo objectForKey:@"requirement_root_packages"]];
}
- (void) updateRequirementRootPackages:(NSArray *)newRRPs
{
  RequirementRootPackage *newRRP;
  NSNumber *newRRPId;
  for(long i = 0; i < newRRPs.count; i++)
  {
    newRRP = [newRRPs objectAtIndex:i];
    newRRPId = [NSNumber numberWithLong:newRRP.requirement_root_package_id];
    if(![requirementRootPackages objectForKey:newRRPId]) [requirementRootPackages setObject:newRRP forKey:newRRPId];
  }
  n_game_data_received++;
  _ARIS_NOTIF_SEND_(@"MODEL_REQUIREMENT_ROOT_PACKAGES_AVAILABLE",nil,nil);
  _ARIS_NOTIF_SEND_(@"GAME_PIECE_AVAILABLE",nil,nil);
}

//AND
- (void) requirementAndPackagesReceived:(NSNotification *)notif
{
  [self updateRequirementAndPackages:[notif.userInfo objectForKey:@"requirement_and_packages"]];
}
- (void) updateRequirementAndPackages:(NSArray *)newRAPs
{
  RequirementAndPackage *newRAP;
  NSNumber *newRAPId;
  for(long i = 0; i < newRAPs.count; i++)
  {
    newRAP = [newRAPs objectAtIndex:i];
    newRAPId = [NSNumber numberWithLong:newRAP.requirement_and_package_id];
    if(![requirementAndPackages objectForKey:newRAPId]) [requirementAndPackages setObject:newRAP forKey:newRAPId];
  }
  n_game_data_received++;
  _ARIS_NOTIF_SEND_(@"MODEL_REQUIREMENT_AND_PACKAGES_AVAILABLE",nil,nil);
  _ARIS_NOTIF_SEND_(@"GAME_PIECE_AVAILABLE",nil,nil);
}

//ATOM
- (void) requirementAtomsReceived:(NSNotification *)notif
{
  [self updateRequirementAtoms:[notif.userInfo objectForKey:@"requirement_atoms"]];
}
- (void) updateRequirementAtoms:(NSArray *)newRAs
{
  RequirementAtom *newRA;
  NSNumber *newRAId;
  for(long i = 0; i < newRAs.count; i++)
  {
    newRA = [newRAs objectAtIndex:i];
    newRAId = [NSNumber numberWithLong:newRA.requirement_atom_id];
    if(![requirementAtoms objectForKey:newRAId]) [requirementAtoms setObject:newRA forKey:newRAId];
  }
  n_game_data_received++;
  _ARIS_NOTIF_SEND_(@"MODEL_REQUIREMENT_ATOMS_AVAILABLE",nil,nil);
  _ARIS_NOTIF_SEND_(@"GAME_PIECE_AVAILABLE",nil,nil);
}


- (NSArray *) andPackagesForRootPackageId:(long)requirement_root_package_id
{
  RequirementAndPackage *rap;
  NSMutableArray *and_packages = [[NSMutableArray alloc] init];
  NSArray *allAnds = [requirementAndPackages allValues];
  for(long i = 0; i < allAnds.count; i++)
  {
    rap = allAnds[i];
    if(rap.requirement_root_package_id == requirement_root_package_id)
      [and_packages addObject:rap];
  }
  return and_packages;
}

- (NSArray *) atomsForAndPackageId:(long)requirement_and_package_id
{
  RequirementAtom *a;
  NSMutableArray *atoms = [[NSMutableArray alloc] init];
  NSArray *allAtoms = [requirementAtoms allValues];
  for(long i = 0; i < allAtoms.count; i++)
  {
    a = allAtoms[i];
    if(a.requirement_and_package_id == requirement_and_package_id)
      [atoms addObject:a];
  }
  return atoms;
}


- (BOOL) evaluateRequirementRoot:(long)requirement_root_package_id
{
  if(!requirement_root_package_id) return YES;
  NSArray *ands = [self andPackagesForRootPackageId:requirement_root_package_id];
  if(ands.count == 0) return YES;
  for(int i = 0; i < ands.count; i++)
  {
    if([self evaluateRequirementAnd:((RequirementAndPackage *)ands[i]).requirement_and_package_id]) return YES;
  }
  return NO;
}
- (BOOL) evaluateRequirementAnd:(long)requirement_and_package_id
{
  if(!requirement_and_package_id) return YES;
  NSArray *atoms = [self atomsForAndPackageId:requirement_and_package_id];
  if(atoms.count == 0) return NO;
  for(int i = 0; i < atoms.count; i++)
  {
    if(![self evaluateRequirementAtom:((RequirementAtom *)atoms[i]).requirement_atom_id]) return NO;
  }
  return YES;
}
- (BOOL) evaluateRequirementAtom:(long)requirement_atom_id
{
  if(!requirement_atom_id) return YES;
  RequirementAtom *a = [self requirementAtomForId:requirement_atom_id];
  if(a.requirement_atom_id == 0) return YES; //'null' req atom

  if([a.requirement isEqualToString:@"ALWAYS_TRUE"])
  {
    return a.bool_operator == YES;
  }
  if([a.requirement isEqualToString:@"ALWAYS_FALSE"])
  {
    return a.bool_operator == NO;
  }
  if([a.requirement isEqualToString:@"PLAYER_HAS_ITEM"])
  {
    return a.bool_operator == ([_MODEL_PLAYER_INSTANCES_ qtyOwnedForItem:a.content_id] >= a.qty);
  }
  if([a.requirement isEqualToString:@"PLAYER_HAS_TAGGED_ITEM"])
  {
    return a.bool_operator == ([_MODEL_PLAYER_INSTANCES_ qtyOwnedForTag:a.content_id] >= a.qty);
  }
  if([a.requirement isEqualToString:@"GAME_HAS_ITEM"])
  {
    return a.bool_operator == ([_MODEL_GAME_INSTANCES_ qtyOwnedForItem:a.content_id] >= a.qty);
  }
  if([a.requirement isEqualToString:@"GAME_HAS_TAGGED_ITEM"])
  {
    return a.bool_operator == ([_MODEL_GAME_INSTANCES_ qtyOwnedForTag:a.content_id] >= a.qty);
  }
  if([a.requirement isEqualToString:@"GROUP_HAS_ITEM"])
  {
    return a.bool_operator == ([_MODEL_GROUP_INSTANCES_ qtyOwnedForItem:a.content_id] >= a.qty);
  }
  if([a.requirement isEqualToString:@"GROUP_HAS_TAGGED_ITEM"])
  {
    return a.bool_operator == ([_MODEL_GROUP_INSTANCES_ qtyOwnedForTag:a.content_id] >= a.qty);
  }
  if([a.requirement isEqualToString:@"PLAYER_VIEWED_ITEM"])
  {
    return a.bool_operator == [_MODEL_LOGS_ hasLogType:@"VIEW_ITEM" content:a.content_id];
  }
  if([a.requirement isEqualToString:@"PLAYER_VIEWED_PLAQUE"])
  {
    return a.bool_operator == [_MODEL_LOGS_ hasLogType:@"VIEW_PLAQUE" content:a.content_id];
  }
  if([a.requirement isEqualToString:@"PLAYER_VIEWED_DIALOG"])
  {
    return a.bool_operator == [_MODEL_LOGS_ hasLogType:@"VIEW_DIALOG" content:a.content_id];
  }
  if([a.requirement isEqualToString:@"PLAYER_VIEWED_DIALOG_SCRIPT"])
  {
    return a.bool_operator == [_MODEL_LOGS_ hasLogType:@"VIEW_DIALOG_SCRIPT" content:a.content_id];
  }
  if([a.requirement isEqualToString:@"PLAYER_VIEWED_WEB_PAGE"])
  {
    return a.bool_operator == [_MODEL_LOGS_ hasLogType:@"VIEW_WEB_PAGE" content:a.content_id];
  }
  if([a.requirement isEqualToString:@"PLAYER_RAN_EVENT_PACKAGE"])
  {
    return a.bool_operator == [_MODEL_LOGS_ hasLogType:@"RUN_EVENT_PACKAGE" content:a.content_id];
  }
  if([a.requirement isEqualToString:@"PLAYER_HAS_UPLOADED_MEDIA_ITEM"])
  {
    return a.bool_operator == ([_MODEL_LOGS_ countLogsOfType:@"UPLOAD_MEDIA_ITEM" Within:a.distance Lat:a.latitude Long:a.longitude] >= a.qty);
  }
  if([a.requirement isEqualToString:@"PLAYER_HAS_UPLOADED_MEDIA_ITEM_IMAGE"])
  {
    return a.bool_operator == ([_MODEL_LOGS_ countLogsOfType:@"UPLOAD_MEDIA_ITEM_IMAGE" Within:a.distance Lat:a.latitude Long:a.longitude] >= a.qty);
  }
  if([a.requirement isEqualToString:@"PLAYER_HAS_UPLOADED_MEDIA_ITEM_AUDIO"])
  {
    return a.bool_operator == ([_MODEL_LOGS_ countLogsOfType:@"UPLOAD_MEDIA_ITEM_AUDIO" Within:a.distance Lat:a.latitude Long:a.longitude] >= a.qty);
  }
  if([a.requirement isEqualToString:@"PLAYER_HAS_UPLOADED_MEDIA_ITEM_VIDEO"])
  {
    return a.bool_operator == ([_MODEL_LOGS_ countLogsOfType:@"UPLOAD_MEDIA_ITEM_VIDEO" Within:a.distance Lat:a.latitude Long:a.longitude] >= a.qty);
  }
  if([a.requirement isEqualToString:@"PLAYER_HAS_COMPLETED_QUEST"])
  {
    return a.bool_operator == [_MODEL_LOGS_ hasLogType:@"COMPLETE_QUEST" content:a.content_id];
  }
  if([a.requirement isEqualToString:@"PLAYER_HAS_QUEST_STARS"])
  {
    return a.bool_operator == ([_MODEL_QUESTS_ starsForCompoundQuest:a.content_id] >= a.qty);
  }
  if([a.requirement isEqualToString:@"PLAYER_HAS_RECEIVED_INCOMING_WEB_HOOK"])
  {
    return a.bool_operator == NO;
  }
  if([a.requirement isEqualToString:@"PLAYER_HAS_NOTE"])
  {
    return a.bool_operator == ([[_MODEL_NOTES_ playerNotes] count] >= a.qty);
  }
  if([a.requirement isEqualToString:@"PLAYER_HAS_NOTE_WITH_TAG"])
  {
    return a.bool_operator == NO;
  }
  if([a.requirement isEqualToString:@"PLAYER_HAS_NOTE_WITH_LIKES"])
  {
    return a.bool_operator == NO;
  }
  if([a.requirement isEqualToString:@"PLAYER_HAS_NOTE_WITH_COMMENTS"])
  {
    return a.bool_operator == NO;
  }
  if([a.requirement isEqualToString:@"PLAYER_HAS_GIVEN_NOTE_COMMENTS"])
  {
    return a.bool_operator == ([_MODEL_LOGS_ countLogsOfType:@"GIVE_NOTE_COMMENT"] >= a.qty);
  }

  return YES;
}

// null req (id == 0) NOT flyweight!!! (to allow for temporary customization safety)
- (RequirementRootPackage *) requirementRootPackageForId:(long)requirement_root_package_id
{
  if(!requirement_root_package_id) return [[RequirementRootPackage alloc] init];
  return [requirementRootPackages objectForKey:[NSNumber numberWithLong:requirement_root_package_id]];
}
- (RequirementAndPackage *) requirementAndPackageForId:(long)requirement_and_package_id
{
  if(!requirement_and_package_id) return [[RequirementAndPackage alloc] init];
  return [requirementAndPackages objectForKey:[NSNumber numberWithLong:requirement_and_package_id]];
}
- (RequirementAtom *) requirementAtomForId:(long)requirement_atom_id
{
  if(!requirement_atom_id) return [[RequirementAtom alloc] init];
  return [requirementAtoms objectForKey:[NSNumber numberWithLong:requirement_atom_id]];
}

- (void) logRequirementTree:(long)requirement_root_package_id
{
  _ARIS_LOG_(@"Root: %ld",requirement_root_package_id);
  NSArray *ands = [self andPackagesForRootPackageId:requirement_root_package_id];
  for(int i = 0; i < ands.count; i++)
    [self logRequirementAnd:((RequirementAndPackage *)ands[i]).requirement_and_package_id];
}
- (void) logRequirementAnd:(long)requirement_and_package_id
{
  _ARIS_LOG_(@"  And: %ld",requirement_and_package_id);
  NSArray *atoms = [self atomsForAndPackageId:requirement_and_package_id];
  for(int i = 0; i < atoms.count; i++)
    [self logRequirementAtom:((RequirementAtom *)atoms[i]).requirement_atom_id];
}
- (void) logRequirementAtom:(long)requirement_atom_id
{
  _ARIS_LOG_(@"    Atom: %ld",requirement_atom_id);
  RequirementAtom *a = [self requirementAtomForId:requirement_atom_id];
  if(a.bool_operator) _ARIS_LOG_(@"      Req: %@ %ld",a.requirement,a.content_id);
  else _ARIS_LOG_(@"      Req: Not %@ %ld",a.requirement,a.content_id);
}

- (NSString *) serializedName
{
  return @"requirements";
}

- (NSString *) serializeGameData
{
  NSArray *roots_a = [requirementRootPackages allValues];
  NSArray *ands_a = [requirementAndPackages allValues];
  NSArray *atoms_a = [requirementAtoms allValues];

  RequirementRootPackage *root_o;
  RequirementAndPackage *and_o;
  RequirementAtom *atom_o;

  NSMutableString *r = [[NSMutableString alloc] init];
  [r appendString:@"{\"requirement_root_packages\":["];
  for(long i = 0; i < roots_a.count; i++)
  {
    root_o = roots_a[i];
    [r appendString:[root_o serialize]];
    if(i != roots_a.count-1) [r appendString:@","];
  }
  [r appendString:@"],\"requirement_and_packages\":["];
  for(long i = 0; i < ands_a.count; i++)
  {
    and_o = ands_a[i];
    [r appendString:[and_o serialize]];
    if(i != ands_a.count-1) [r appendString:@","];
  }
  [r appendString:@"],\"requirement_atoms\":["];
  for(long i = 0; i < atoms_a.count; i++)
  {
    atom_o = atoms_a[i];
    [r appendString:[atom_o serialize]];
    if(i != atoms_a.count-1) [r appendString:@","];
  }
  [r appendString:@"]}"];
  return r;
}

- (void) deserializeGameData:(NSString *)data
{
  [self clearGameData];
  
  NSError *error = nil;
  NSDictionary *d_data = [NSJSONSerialization JSONObjectWithData:[data dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];

  NSArray *d_roots = d_data[@"requirement_root_packages"];
  for(long i = 0; i < d_roots.count; i++)
  {
    RequirementRootPackage *r = [[RequirementRootPackage alloc] initWithDictionary:d_roots[i]];
    [requirementRootPackages setObject:r forKey:[NSNumber numberWithLong:r.requirement_root_package_id]];
  }
  NSArray *d_ands = d_data[@"requirement_and_packages"];
  for(long i = 0; i < d_ands.count; i++)
  {
    RequirementAndPackage *r = [[RequirementAndPackage alloc] initWithDictionary:d_ands[i]];
    [requirementAndPackages setObject:r forKey:[NSNumber numberWithLong:r.requirement_and_package_id]];
  }
  NSArray *d_atoms = d_data[@"requirement_atoms"];
  for(long i = 0; i < d_atoms.count; i++)
  {
    RequirementAtom *r = [[RequirementAtom alloc] initWithDictionary:d_atoms[i]];
    [requirementAtoms setObject:r forKey:[NSNumber numberWithLong:r.requirement_atom_id]];
  }
  n_game_data_received = [self nGameDataToReceive];
}

- (void) dealloc
{
  _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end
