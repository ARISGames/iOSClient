//
//  Overlay.m
//  ARIS
//
//

#import "Overlay.h"
#import "AppModel.h"
#import "ARISAppDelegate.h"
 
@implementation Overlay

@synthesize overlayId;
@synthesize index;
@synthesize name;
@synthesize description;
@synthesize alpha;
@synthesize sort_order;
@synthesize tileX;
@synthesize tileY;
@synthesize tileZ;
@synthesize tileFileName;
@synthesize tileMediaID;
@synthesize tilePath;
@synthesize num_tiles;
@synthesize tileImage;


- (id) init{
	if ((self = [super init])) {
		self.tileX = [NSMutableArray array];
        self.tileY = [NSMutableArray array];
        self.tileZ = [NSMutableArray array];
        self.tileFileName = [NSMutableArray array];
        self.tileMediaID = [NSMutableArray array];
        self.tilePath = [NSMutableArray array];
        self.tileImage = [NSMutableArray array];
	}
	return self;
}

@end
