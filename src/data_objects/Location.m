//
//  Location.m
//  ARIS
//
//  Created by David Gagnon on 2/26/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "Location.h"
#import "NSDictionary+ValidParsers.h"
#import "AppModel.h"
#import "Game.h"
#import "Item.h"
#import "Node.h"
#import "WebPage.h"
#import "Note.h"
#import "Player.h"
#import "Npc.h"
#import "Note.h"

@implementation Location

@synthesize locationId;
@synthesize name;
@synthesize latlon;
@synthesize gameObject;
@synthesize errorRange;
@synthesize qty;
@synthesize infiniteQty;
@synthesize hidden;
@synthesize forcedDisplay;
@synthesize allowsQuickTravel;
@synthesize showTitle;
@synthesize wiggle;
@synthesize deleteWhenViewed;

//MKAnnotation stuff
@synthesize coordinate;
@synthesize title;
@synthesize subtitle;
@synthesize nearbyOverlay;

- (Location *) init
{
    if(self = [super init])
    {
        
    }
    return self;
}

- (Location *) initWithDictionary:(NSDictionary *)dict
{
    if(self = [super init])
    {
        self.locationId = [dict validIntForKey:@"location_id"];
        self.name       = [dict validObjectForKey:@"name"];
        self.latlon     = [[CLLocation alloc] initWithLatitude:[dict validDoubleForKey:@"latitude"] longitude:[dict validDoubleForKey:@"longitude"]];
        
        NSString *otype = [dict validObjectForKey:@"type"];
        int oid         = [dict validIntForKey:@"type_id"];
        if([otype isEqualToString:@"Node"])       self.gameObject = [[AppModel sharedAppModel].currentGame nodeForNodeId:oid];
        if([otype isEqualToString:@"Item"])       self.gameObject = [[AppModel sharedAppModel].currentGame itemForItemId:oid];
        if([otype isEqualToString:@"Npc"])        self.gameObject = [[AppModel sharedAppModel].currentGame npcForNpcId:oid];
        if([otype isEqualToString:@"WebPage"])    self.gameObject = [[AppModel sharedAppModel].currentGame webpageForWebpageId:oid];
        if([otype isEqualToString:@"PlayerNote"]) self.gameObject = [[AppModel sharedAppModel].currentGame.notesModel noteForId:oid];
        if([otype isEqualToString:@"Player"])     self.gameObject = [[Player alloc] init];
        
        self.qty               = [dict validIntForKey:@"item_qty"];
        self.infiniteQty       = self.qty < 0;
        self.hidden            = [dict validBoolForKey:@"hidden"];
        self.forcedDisplay     = [dict validBoolForKey:@"force_view"];
        self.showTitle         = [dict validBoolForKey:@"show_title"];
        self.wiggle            = [dict validBoolForKey:@"wiggle"];
        self.allowsQuickTravel = [dict validBoolForKey:@"allow_quick_travel"];
        self.errorRange        = [dict validIntForKey:@"error"]; if(self.errorRange < 0) self.errorRange = 9999999999;
        self.deleteWhenViewed  = [dict validBoolForKey:@"delete_when_viewed"];
        
        if(self.gameObject.type == GameObjectNote)
        {
            if(((Note *)self.gameObject).publicToList) self.allowsQuickTravel = YES;
            else                                       self.allowsQuickTravel = NO;
        }
        
        self.coordinate = self.latlon.coordinate;
        if(!self.hidden && self.errorRange > 0)
            self.nearbyOverlay = [MKCircle circleWithCenterCoordinate:self.coordinate radius:self.errorRange];  
    }
    return self;
}

- (BOOL) compareTo:(Location *)ob
{
    return     [self.name isEqualToString:ob.name] &&
    self.latlon.coordinate.latitude  == ob.latlon.coordinate.latitude &&
    self.latlon.coordinate.longitude == ob.latlon.coordinate.longitude &&
    self.locationId                  == ob.locationId &&
    self.gameObject.type             == ob.gameObject.type &&
    self.errorRange                  == ob.errorRange &&
    (self.qty == ob.qty || (self.qty < 0 && ob.qty < 0)) &&
    self.infiniteQty                 == ob.infiniteQty && 
    self.hidden                      == ob.hidden &&
    self.forcedDisplay               == ob.forcedDisplay &&
    self.allowsQuickTravel           == ob.allowsQuickTravel &&
    self.showTitle                   == ob.showTitle &&
    self.wiggle                      == ob.wiggle &&
    self.deleteWhenViewed            == ob.deleteWhenViewed;
}

- (Location *)copy
{
    Location *c = [[Location alloc] init];
    c.name              = self.name;
    c.latlon            = self.latlon;
    c.locationId        = self.locationId;
    c.gameObject        = self.gameObject;
    c.errorRange        = self.errorRange;
    c.qty               = self.qty;
    c.infiniteQty       = self.infiniteQty; 
    c.hidden            = self.hidden;
    c.forcedDisplay     = self.forcedDisplay;
    c.allowsQuickTravel = self.allowsQuickTravel;
    c.showTitle         = self.showTitle;
    c.wiggle            = self.wiggle;
    c.deleteWhenViewed  = self.deleteWhenViewed;
    return c;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Location- Id:%d\tName:%@\tObjectName:%@",self.locationId,self.name,self.gameObject.name];
}

@end
