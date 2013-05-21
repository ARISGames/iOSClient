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
#import "Item.h"
#import "Node.h"
#import "Npc.h"
#import "Note.h"

@implementation Location

@synthesize locationId;
@synthesize name;
@synthesize latlon;
@synthesize gameObject;
@synthesize errorRange;
@synthesize qty;
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
        self.latlon     = [[CLLocation alloc] initWithLatitude:[dict validDoubleForKey:@"latitude"]
                                                            longitude:[dict validDoubleForKey:@"longitude"]];
        self.coordinate = self.latlon.coordinate;
        
        NSString *otype = [dict validObjectForKey:@"type"];
        int oid         = [dict validIntForKey:@"type_id"];
        if([otype isEqualToString:@"Node"])
            self.gameObject = [[AppModel sharedAppModel] nodeForNodeId:oid];
        if([otype isEqualToString:@"Item"])       self.gameObject = [[AppModel sharedAppModel] itemForItemId:oid];
        if([otype isEqualToString:@"Npc"])        self.gameObject = [[AppModel sharedAppModel] npcForNpcId:oid];
        if([otype isEqualToString:@"WebPage"])    self.gameObject = [[AppModel sharedAppModel] webPageForWebPageID:oid];
        if([otype isEqualToString:@"PlayerNote"])
        {
            if(!(self.gameObject = [[AppModel sharedAppModel] noteForNoteId:oid playerListYesGameListNo:YES]))
                 self.gameObject = [[AppModel sharedAppModel] noteForNoteId:oid playerListYesGameListNo:NO];
        }
        
        self.qty               = [dict validIntForKey:@"item_qty"];
        self.hidden            = [dict validBoolForKey:@"hidden"];
        self.forcedDisplay     = [dict validBoolForKey:@"force_view"];
        self.showTitle         = [dict validBoolForKey:@"show_title"];
        self.wiggle            = [dict validBoolForKey:@"wiggle"];
        self.allowsQuickTravel = [dict validBoolForKey:@"allow_quick_travel"];
        self.errorRange        = [dict validIntForKey:@"error"]; if(self.errorRange < 0) self.errorRange = 9999999999;
        self.deleteWhenViewed  = [dict validBoolForKey:@"delete_when_viewed"];
        
        if(self.gameObject.type == GameObjectNote)
        {
            if(((Note *)self.gameObject).showOnList) self.allowsQuickTravel = YES;
            else                                     self.allowsQuickTravel = NO;
        }
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
    self.qty                         == ob.qty &&
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
    c.latlon            = self.latlon;
    c.locationId        = self.locationId;
    c.gameObject        = self.gameObject;
    c.errorRange        = self.errorRange;
    c.qty               = self.qty;
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
