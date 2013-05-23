//
//  TagViewController.m
//  ARIS
//
//  Created by Brian Thiel on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TagViewController.h"
#import "AppModel.h"
#import "AppServices.h"
#import "Tag.h"
#import "TagCell.h"

@interface TagViewController() <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
{
    Note *note;
    NSMutableArray *gameTagList;
    NSMutableArray *playerTagList;
    IBOutlet UITableView *tagTable;
    IBOutlet UIToolbar *addTagToolBar;
    IBOutlet UITextField *tagTextField;
}

@property (nonatomic, strong) Note *note;
@property (nonatomic, strong) NSMutableArray *gameTagList;
@property (nonatomic, strong) NSMutableArray *playerTagList;
@property (nonatomic, strong) IBOutlet UITableView *tagTable;
@property (nonatomic, strong) IBOutlet UIToolbar *addTagToolBar;
@property (nonatomic, strong) IBOutlet UITextField *tagTextField;

- (IBAction) cancelButtonTouchAction;
- (IBAction) createButtonTouchAction;

@end

@implementation TagViewController

@synthesize note;
@synthesize gameTagList;
@synthesize playerTagList;
@synthesize tagTable;
@synthesize addTagToolBar;
@synthesize tagTextField;

- (id) initWithNote:(Note *)n
{
    if(self = [super initWithNibName:@"TagViewController" bundle:nil])
    {
        gameTagList   = [[NSMutableArray alloc]initWithCapacity:5];
        playerTagList = [[NSMutableArray alloc]initWithCapacity:5];
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self refresh];
}

- (void) refresh
{
    [playerTagList removeAllObjects];
    [gameTagList removeAllObjects];
    for(int i = 0; i < [[AppModel sharedAppModel].gameTagList count];i++){
        if([(Tag *)[[AppModel sharedAppModel].gameTagList objectAtIndex:i] playerCreated]){
            [playerTagList addObject:[[AppModel sharedAppModel].gameTagList objectAtIndex:i]];
        }
        else{
            [gameTagList addObject:[[AppModel sharedAppModel].gameTagList objectAtIndex:i]];
        }
    }
    [tagTable reloadData];
}

- (void) backButtonTouchAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) cancelButtonTouchAction
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:.5];
    [self.addTagToolBar setFrame:CGRectMake(addTagToolBar.frame.origin.x, -44, 320, 44)];
    [UIView commitAnimations];
    [self.tagTextField resignFirstResponder];
}

- (void) createButtonTouchAction
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:.5];
    [self.addTagToolBar setFrame:CGRectMake(addTagToolBar.frame.origin.x, -44, 320, 44)];
    [UIView commitAnimations];
    [[AppServices sharedAppServices] addTagToNote:self.note.noteId tagName:self.tagTextField.text];
    Tag *tempTag = [[Tag alloc]init];
    tempTag.tagName = self.tagTextField.text;
    tempTag.playerCreated = YES;
    [[AppModel sharedAppModel].gameTagList addObject:tempTag];
    [self.note.tags addObject:tempTag];
    [self refresh];
    [self.tagTextField resignFirstResponder];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    if([gameTagList count] == 0 && indexPath.row == 0 && indexPath.section == 0)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        cell.textLabel.text = NSLocalizedString(@"TagViewNoGameTagsKey", @"");
        cell.detailTextLabel.text = NSLocalizedString(@"TagViewNoTagsCreatedKey", @"");
        cell.userInteractionEnabled = NO;
        cell.textLabel.font = [UIFont systemFontOfSize:17];
        cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:14];
        cell.textLabel.textColor = [UIColor darkGrayColor];
        return cell;
    }
    if([playerTagList count] == 0 && indexPath.row == 0 && indexPath.section == 2)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        cell.textLabel.text = NSLocalizedString(@"TagViewNoTagsKey", @"");
        cell.detailTextLabel.text = NSLocalizedString(@"TagViewNotCreatedKey", @"");
        cell.textLabel.font = [UIFont systemFontOfSize:17];
        cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:14];
        cell.userInteractionEnabled = NO;
        cell.textLabel.textColor = [UIColor darkGrayColor];

        return cell;
    }

    if(indexPath.row == 0 && indexPath.section == 1){
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        cell.textLabel.text = NSLocalizedString(@"TagViewCreateNewTagKey", @"");
        cell.userInteractionEnabled = YES;
        cell.textLabel.font = [UIFont systemFontOfSize:17];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.textLabel.textColor = [UIColor darkGrayColor];

        return cell;
    }

    UITableViewCell *tempCell = (TagCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (![tempCell respondsToSelector:@selector(nameLabel)])
        tempCell = nil;
    TagCell *cell = (TagCell *)tempCell;
    
    
    if (cell == nil)
    {
        // Create a temporary UIViewController to instantiate the custom cell.
        UIViewController *temporaryController = [[UIViewController alloc] initWithNibName:@"TagCell" bundle:nil];
        // Grab a pointer to the custom cell.
        cell = (TagCell *)temporaryController.view;
        // Release the temporary UIViewController.
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    if(indexPath.section == 0)
        cell.nameLabel.text = [[self.gameTagList objectAtIndex:indexPath.row]tagName];
    else if(indexPath.section == 2)
        cell.nameLabel.text = [[self.playerTagList objectAtIndex:indexPath.row] tagName];
    
    for(int i = 0; i < self.note.tags.count;i++){
        if([[(Tag *)[self.note.tags objectAtIndex:i] tagName] isEqualToString:cell.nameLabel.text]){
            
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            break;
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1)
    {
        //create new tag
        if([AppModel sharedAppModel].currentGame.allowsPlayerTags)
        {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            [UIView setAnimationDuration:.5];
            [self.addTagToolBar setFrame:CGRectMake(addTagToolBar.frame.origin.x, 0, 320, 44)];
            [UIView commitAnimations];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TagViewCannotCreateKey", @"") message: NSLocalizedString(@"TagViewNoPlayerCreatedTagsKey", @"")delegate: self cancelButtonTitle: NSLocalizedString(@"OkKey", @"") otherButtonTitles: nil];
            [alert show];
        }
    }
    else
    {
        TagCell *cell = (TagCell *)[tableView cellForRowAtIndexPath:indexPath];
        if(cell.accessoryType == UITableViewCellAccessoryCheckmark)
        {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            int tagId;
                for(int i = 0; i < self.note.tags.count;i++)
                {
                    if([[(Tag *)[self.note.tags objectAtIndex:i] tagName] isEqualToString:cell.nameLabel.text])
                    {
                        tagId = [[self.note.tags objectAtIndex:i] tagId];
                        [self.note.tags removeObjectAtIndex:i];
                        break;
                    }
                }
        
            //delete tag from note
            [[AppServices sharedAppServices]deleteTagFromNote:self.note.noteId tagId:tagId];
        }
        else{
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            //add tag to note;
            Tag *tempTag =[[Tag alloc]init];
            tempTag.tagName = cell.nameLabel.text;
            [self.note.tags addObject:tempTag];
            [[AppServices sharedAppServices]addTagToNote:self.note.noteId tagName:cell.nameLabel.text];
                   }
    }
        
    [self refresh]; }

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if([AppModel sharedAppModel].currentGame.allowsPlayerTags)
    return 3;
    else{
        return 1;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            if(self.gameTagList.count > 0)
                return [self.gameTagList count];
            else
                return 1;
            break;
        case 1:
            return 1;
            break;
        case 2:
            if(self.playerTagList.count > 0)
                return [self.playerTagList count];
            else
                return 1;            
            break;
        default:
            break;
    }
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return @"Game Tags";
            break;
        case 1:
            return @"My Tags";
            break;
        case 2:
            return @"";
            break;
        default:
            break;
    }
    return @"ERROR";
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(BOOL)shouldAutorotate
{
    return YES;
}

- (NSInteger) supportedInterfaceOrientations
{
    NSInteger mask = 0;
    if([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft])      mask |= UIInterfaceOrientationMaskLandscapeLeft;
    if([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight])     mask |= UIInterfaceOrientationMaskLandscapeRight;
    if([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortrait])           mask |= UIInterfaceOrientationMaskPortrait;
    if([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortraitUpsideDown]) mask |= UIInterfaceOrientationMaskPortraitUpsideDown;
    return mask;
}

@end
