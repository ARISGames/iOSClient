//
//  AttributesViewController.m
//  ARIS
//
//  Created by Brian Thiel on 6/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AttributesViewController.h"
#import "AppServices.h"
#import "Media.h"
#import "AsyncMediaImageView.h"
#import "AppModel.h"

@implementation AttributesViewController
@synthesize attributes,iconCache,attributesTable,pcImage,nameLabel,groupLabel,addGroupButton,newAttrsSinceLastView;
//Override init for passing title and icon to tab bar
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
        self.title = NSLocalizedString(@"PlayerTitleKey",@"");
        self.tabBarItem.image = [UIImage imageNamed:@"123-id-card"];
        NSMutableArray *iconCacheAlloc = [[NSMutableArray alloc] initWithCapacity:[[AppModel sharedAppModel].attributes count]];
        self.iconCache = iconCacheAlloc;
		//register for notifications
		NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
		[dispatcher addObserver:self selector:@selector(refreshViewFromModel) name:@"NewInventoryReady" object:nil];
		[dispatcher addObserver:self selector:@selector(silenceNextUpdate) name:@"SilentNextUpdate" object:nil];
        
    }
    return self;
}

- (void)silenceNextUpdate
{
	silenceNextServerUpdateCount++;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
    self.pcImage.layer.cornerRadius = 10.0;
}

- (void)viewDidAppear:(BOOL)animated {
	
	[self refresh];
	self.nameLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"AttributesViewNameKey", @""), [AppModel sharedAppModel].userName];
    self.groupLabel.text = NSLocalizedString(@"AttributesViewGroupKey", @"");
	silenceNextServerUpdateCount = 0;
    if ([AppModel sharedAppModel].currentGame.pcMediaId != 0) {
		//Load the image from the media Table
		Media *pcMedia = [[AppModel sharedAppModel] mediaForMediaId:[AppModel sharedAppModel].currentGame.pcMediaId];
		[pcImage loadImageFromMedia: pcMedia];
        
	}
	//else [pcImage updateViewWithNewImage:[UIImage imageNamed:@"profile.png"]];
}

-(void)refresh {
	[[AppServices sharedAppServices] fetchInventory];
    [self refreshViewFromModel];
}

-(void)refreshViewFromModel {
	NSLog(@"AttributesVC: Refresh View from Model");
	
    if (silenceNextServerUpdateCount < 1) {
        NSArray *newAttributes = [[AppModel sharedAppModel].attributes allValues];
        //Check if anything is new since last time
        int newAttrs = 0;
        UIViewController *topViewController =  [[self navigationController] topViewController];
        for (Item *attr in newAttributes) {
            BOOL match = NO;
            for (Item *existingAttr in self.attributes) {
                if (existingAttr.itemId == attr.itemId) match = YES;
                if ((existingAttr.itemId == attr.itemId) && (existingAttr.qty < attr.qty)){
                    if([topViewController respondsToSelector:@selector(updateQuantityDisplay)])
                        [[[self navigationController] topViewController] respondsToSelector:@selector(updateQuantityDisplay)];
                    
                    [[RootViewController sharedRootViewController] enqueueNotificationWithTitle:NSLocalizedString(@"AttributeReceivedKey", @"")
                                                                                      andPrompt:[NSString stringWithFormat:@"%d %@ %@",attr.qty - existingAttr.qty,attr.name,@" added"]];
                }
            }
            
            if (match == NO) {
                if([topViewController respondsToSelector:@selector(updateQuantityDisplay)])
                    [[[self navigationController] topViewController] respondsToSelector:@selector(updateQuantityDisplay)];
                
                [[RootViewController sharedRootViewController] enqueueNotificationWithTitle: NSLocalizedString(@"AttributeReceivedKey", @"")
                                                                                  andPrompt:[NSString stringWithFormat:@"%d %@ %@",attr.qty,attr.name,@" added"]];
                newAttrs++;
            }
        }
        if (newAttrs > 0) {
            newAttrsSinceLastView += newAttrs;
            self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",newAttrsSinceLastView];
            
            //Vibrate and Play Sound
            [((ARISAppDelegate *)[[UIApplication sharedApplication] delegate]) playAudioAlert:@"inventoryChange" shouldVibrate:YES];
        }
        else if (newAttrsSinceLastView < 1) self.tabBarItem.badgeValue = nil;
    }
    else {
        newAttrsSinceLastView = 0;
        self.tabBarItem.badgeValue = nil;
    }
    
	self.attributes = [[AppModel sharedAppModel].attributes allValues];
	[attributesTable reloadData];
	
	if (silenceNextServerUpdateCount>0) silenceNextServerUpdateCount--;
}

-(IBAction)groupButtonPressed {
    
}

- (UITableViewCell *) getCellContentView:(NSString *)cellIdentifier {
	CGRect IconFrame = CGRectMake(5, 5, 50, 50);
	CGRect Label1Frame = CGRectMake(70, 22, 240, 20);
	CGRect Label2Frame = CGRectMake(70, 39, 240, 20);
    CGRect Label3Frame = CGRectMake(70, 5, 240, 20);
	UILabel *lblTemp;
	UIImageView *iconViewTemp;
	
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
	
	//Setup Cell
	UIView *transparentBackground = [[UIView alloc] initWithFrame:CGRectZero];
    transparentBackground.backgroundColor = [UIColor clearColor];
    cell.backgroundView = transparentBackground;
	
	//Initialize Label with tag 1.
	lblTemp = [[UILabel alloc] initWithFrame:Label1Frame];
	lblTemp.tag = 1;
	//lblTemp.textColor = [UIColor whiteColor];
	lblTemp.backgroundColor = [UIColor clearColor];
	[cell.contentView addSubview:lblTemp];
	
	//Initialize Label with tag 2.
	lblTemp = [[UILabel alloc] initWithFrame:Label2Frame];
	lblTemp.tag = 2;
	lblTemp.font = [UIFont systemFontOfSize:11];
	lblTemp.textColor = [UIColor darkGrayColor];
	lblTemp.backgroundColor = [UIColor clearColor];
	[cell.contentView addSubview:lblTemp];
	
	//Init Icon with tag 3
	iconViewTemp = [[AsyncMediaImageView alloc] initWithFrame:IconFrame];
	iconViewTemp.tag = 3;
	iconViewTemp.backgroundColor = [UIColor clearColor];
	[cell.contentView addSubview:iconViewTemp];
    
    //Init Icon with tag 4
    lblTemp = [[UILabel alloc] initWithFrame:Label3Frame];
	lblTemp.tag = 4;
	lblTemp.font = [UIFont boldSystemFontOfSize:11];
	lblTemp.textColor = [UIColor darkGrayColor];
	lblTemp.backgroundColor = [UIColor clearColor];
    //lblTemp.textAlignment = UITextAlignmentRight;
	[cell.contentView addSubview:lblTemp];
    
	return cell;
}


#pragma mark PickerViewDelegate selectors

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // return 2;
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [attributes count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
	if(cell == nil) cell = [self getCellContentView:@"Cell"];
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor colorWithRed:233.0/255.0
                                                       green:233.0/255.0
                                                        blue:233.0/255.0
                                                       alpha:1.0];
    
	Item *item = [attributes objectAtIndex: [indexPath row]];
	
	UILabel *lblTemp1 = (UILabel *)[cell viewWithTag:1];
	lblTemp1.text = item.name;
    lblTemp1.font = [UIFont boldSystemFontOfSize:18.0];
    
    UILabel *lblTemp2 = (UILabel *)[cell viewWithTag:2];
    lblTemp2.text = item.description;
	AsyncMediaImageView *iconView = (AsyncMediaImageView *)[cell viewWithTag:3];
    
    UILabel *lblTemp3 = (UILabel *)[cell viewWithTag:4];
    if(item.qty > 1)
        lblTemp3.text = [NSString stringWithFormat:@"%@: %d",NSLocalizedString(@"QuantityKey", @""),item.qty];
    else
        lblTemp3.text = nil;
    iconView.hidden = NO;
    
	if (item.iconMediaId != 0) {
        Media *iconMedia;
        if([self.iconCache count] < indexPath.row){
            iconMedia = [self.iconCache objectAtIndex:indexPath.row];
            [iconView updateViewWithNewImage:[UIImage imageWithData:iconMedia.image]];
        }
        else{
            iconMedia = [[AppModel sharedAppModel] mediaForMediaId: item.iconMediaId];
            [self.iconCache  addObject:iconMedia];
            [iconView loadImageFromMedia:iconMedia];
        }
	}
    cell.userInteractionEnabled = NO;
	return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    //if(section==0)return  @"Group";
    // else
    return NSLocalizedString(@"AttributesAttributesTitleKey", @"");
}

// Customize the height of each row
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	
}

#pragma mark Memory Management
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

@end
