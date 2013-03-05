//
//  Location.m
//  ARIS
//
//  Created by David Gagnon on 2/26/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "Location.h"
#import "ARISAppDelegate.h"
#import "AppModel.h"
#import "Item.h"
#import "Node.h"
#import "Npc.h"
#import "Note.h"

@implementation Location

@synthesize locationId;
@synthesize name;
@synthesize iconMediaId;
@synthesize location;
@synthesize error;
@synthesize object;
@synthesize objectType;
@synthesize objectId;
@synthesize hidden;
@synthesize forcedDisplay;
@synthesize allowsQuickTravel, showTitle;
@synthesize qty,delegate,wiggle,deleteWhenViewed;

- (nearbyObjectKind)kind
{
	nearbyObjectKind returnValue = NearbyObjectNil;
	if ([self.objectType isEqualToString:@"Node"])       returnValue = NearbyObjectNode;
	if ([self.objectType isEqualToString:@"Npc"])        returnValue = NearbyObjectNPC;
	if ([self.objectType isEqualToString:@"Item"])       returnValue = NearbyObjectItem;
	if ([self.objectType isEqualToString:@"Player"])     returnValue = NearbyObjectPlayer;
    if ([self.objectType isEqualToString:@"WebPage"])    returnValue = NearbyObjectWebPage;
    if ([self.objectType isEqualToString:@"PlayerNote"]) returnValue = NearbyObjectNote;
    if ([self.objectType isEqualToString:@"AugBubble"])  returnValue = NearbyObjectPanoramic;
	return returnValue;
}

- (int)iconMediaId
{
	if (iconMediaId != 0) return iconMediaId;
    return [[self object] iconMediaId];
}

- (NSObject<NearbyObjectProtocol> *)object
{
    if(deleteWhenViewed == 1)
    {
        NSArray *locs = [AppModel sharedAppModel].currentGame.locationsModel.currentLocations;
        Location *loc;
        for(int i = 0; i < [locs count]; i++)
        {
            if((loc = (Location *)[locs objectAtIndex:i]).locationId == self.locationId)
                [[AppModel sharedAppModel].currentGame.locationsModel modifyQuantity:(loc.qty*-1) forLocationId:loc.locationId];
        }
    }	
    if (self.kind == NearbyObjectItem)
    {
        [[AppModel sharedAppModel] itemForItemId:objectId].locationId = self.locationId; 		
        [[AppModel sharedAppModel] itemForItemId:objectId].qty = self.qty;
		return [[AppModel sharedAppModel] itemForItemId:objectId];
	}
	if (self.kind == NearbyObjectNode)
    {
        [[AppModel sharedAppModel] nodeForNodeId: objectId].locationId = self.locationId;
		return [[AppModel sharedAppModel] nodeForNodeId: objectId]; 
	}
    if (self.kind == NearbyObjectWebPage)
    {
        [[AppModel sharedAppModel] webPageForWebPageID: objectId].locationId = self.locationId;
		return [[AppModel sharedAppModel] webPageForWebPageID: objectId]; 
	}
    if (self.kind == NearbyObjectPanoramic)
    {
        [[AppModel sharedAppModel]panoramicForPanoramicId: objectId].locationId = self.locationId;
		return [[AppModel sharedAppModel] panoramicForPanoramicId: objectId]; 
	}
    if (self.kind == NearbyObjectNPC)
    {
        [[AppModel sharedAppModel]npcForNpcId: objectId].locationId = self.locationId;
		return [[AppModel sharedAppModel] npcForNpcId: objectId]; 
	}
    if (self.kind == NearbyObjectNote)
    {
        Note * note    = [[AppModel sharedAppModel] noteForNoteId:objectId playerListYesGameListNo:NO];
        if(!note) note = [[AppModel sharedAppModel] noteForNoteId:objectId playerListYesGameListNo:YES];
        if(!note) NSLog(@"this shouldn't happen");
        return note;
    }
	else return nil;
}

- (void)display
{
	[self.object display];
}

- (BOOL)compareTo:(Location *)other
{
    return     [self.name isEqualToString:other.name] &&
    self.locationId                    == other.locationId &&
    self.iconMediaId                   == other.iconMediaId &&
    self.location.coordinate.latitude  == other.location.coordinate.latitude &&
    self.location.coordinate.longitude == other.location.coordinate.longitude &&
    self.objectId                      == other.objectId &&
    self.hidden                        == other.hidden &&
    self.forcedDisplay                 == other.forcedDisplay &&
    self.allowsQuickTravel             == other.allowsQuickTravel &&
    self.showTitle                     == other.showTitle &&
    self.wiggle                        == other.wiggle &&
    self.deleteWhenViewed              == other.deleteWhenViewed &&
    self.qty                           == other.qty;
}

- (Location *)copy
{
    Location *c = [[Location alloc] init];
    c.name              = self.name;
    c.locationId        = self.locationId;
    c.iconMediaId       = self.iconMediaId;
    c.location          = self.location;
    c.objectType        = self.objectType;
    c.objectId          = self.objectId;
    c.hidden            = self.hidden;
    c.error             = self.error;
    c.forcedDisplay     = self.forcedDisplay;
    c.allowsQuickTravel = self.allowsQuickTravel;
    c.showTitle         = self.showTitle;
    c.wiggle            = self.wiggle;
    c.deleteWhenViewed  = self.deleteWhenViewed;
    c.qty               = self.qty;
    return c;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Location- Id:%d\tName:%@\tType:%@",self.locationId,self.name,self.objectType];
}

@end
