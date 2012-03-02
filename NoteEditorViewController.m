//
//  NoteViewController.m
//  ARIS
//
//  Created by Brian Thiel on 8/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NoteEditorViewController.h"
#import "TitleAndDecriptionFormViewController.h"
#import "ARISAppDelegate.h"
#import "AppServices.h"
#import "InventoryListViewController.h"
#import "GPSViewController.h"
#import "CameraViewController.h"
#import "AudioRecorderViewController.h"
#import "TextViewController.h"
#import "AsyncMediaImageView.h"
#import "Media.h"
#import "ImageViewer.h"
#import "ARISMoviePlayerViewController.h"
#import "DropOnMapViewController.h"
#import "NoteCommentViewController.h"
#import "NoteDetailsViewController.h"
#import "AppModel.h"
#import "NoteContentCell.h"
#import "UIImage+Scale.h"
#import "TagViewController.h"
#import "UploadingCell.h"
#import "ARISAppDelegate.h"

@implementation NoteEditorViewController
@synthesize textBox,textField,note, delegate, hideKeyboardButton,libraryButton,cameraButton,audioButton, typeControl,viewControllers, scrollView,pageControl,publicButton,textButton,mapButton, contentTable,soundPlayer,noteValid,noteChanged, noteDropped, vidThumbs,startWithView,actionSheet,sharingLabel;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        viewControllers = [[NSMutableArray alloc] initWithCapacity:10];
        NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
      /*  [dispatcher addObserver:self selector:@selector(updateTable) name:@"ImageReady" object:nil];*/
       
        [dispatcher addObserver:self selector:@selector(refreshViewFromModel) name:@"NewNoteListReady" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(movieFinishedCallback:)
													 name:MPMoviePlayerPlaybackDidFinishNotification
												   object:nil];
        self.soundPlayer = [[AVPlayer alloc] init];
        self.hidesBottomBarWhenPushed = YES;
        self.noteValid = NO;
        self.vidThumbs = [[NSMutableDictionary alloc] initWithCapacity:5];
        startWithView = 0;
        actionSheet = [[UIActionSheet alloc]initWithTitle:@"Sharing" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"List Only",@"Map Only",@"Both",@"Don't Share", nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [textBox release];
    [textField release];
    [note release];
    [hideKeyboardButton release];
    [libraryButton release];
    [cameraButton release];
    [audioButton release];
    [typeControl release];
    [viewControllers release];
    [scrollView release];
    [pageControl release];
    [publicButton release];
    [textButton release];
    [mapButton release];
    [contentTable release];
    [soundPlayer release];
    [actionSheet release];
    [delegate release];
    [vidThumbs release];
    [sharingLabel release];
    
    [super dealloc];
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    if(startWithView == 0){
    if(self.note.noteId != 0){
    self.textField.text = self.note.title;
    }
    if(self.note.dropped)self.mapButton.selected = YES;   
    else self.mapButton.selected = NO;
    
    if(self.noteChanged){
    self.noteChanged = NO;
   // [self refresh];
    [contentTable reloadData];
    }

   }
    else if(startWithView == 1){
        [self cameraButtonTouchAction];
    }
    else if(startWithView == 2){
        [self textButtonTouchAction];
    }
    else if(startWithView == 3){
        [self audioButtonTouchAction];
    }
    startWithView = 0;
    if(!self.note.showOnMap && !self.note.showOnList){
        self.sharingLabel.text = @"None";
    }
    else if(self.note.showOnMap && !self.note.showOnList){
        self.sharingLabel.text = @"Map Only";

    }
    else if(!self.note.showOnMap && self.note.showOnList){
        self.sharingLabel.text = @"List Only";

    }
    else if(self.note.showOnMap && self.note.showOnList){
        self.sharingLabel.text = @"List & Map";
    }        
    [self refreshViewFromModel];
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = 
	[[UIBarButtonItem alloc] initWithTitle:@"Done"
									 style: UIBarButtonItemStyleDone
									target:self 
									action:@selector(backButtonTouchAction:)];
   
    if(self.note.noteId == 0){
        self.note = [[Note alloc]init];
        self.note.creatorId = [AppModel sharedAppModel].playerId;
        self.note.username = [AppModel sharedAppModel].userName;
        self.note.noteId = [[AppServices sharedAppServices] createNote];
        if(self.note.noteId == 0){[self backButtonTouchAction:[[[UIButton alloc]init]autorelease]];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Create Note Failed" message:@"Cannot create a note while offline" delegate:self.delegate cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            [alert release];
        }
        if(![AppModel sharedAppModel].isGameNoteList)
        [[AppModel sharedAppModel].playerNoteList setObject:self.note forKey:[NSNumber numberWithInt:self.note.noteId]];
        else
               [[AppModel sharedAppModel].gameNoteList setObject:self.note forKey:[NSNumber numberWithInt:self.note.noteId]]; 
    }
    else self.noteValid = YES;
    //self.contentTable.editing = YES;
    scrollView.delegate = self;
    pageControl.currentPage = 0;
    pageControl.numberOfPages = numPages;
    
    UIBarButtonItem *tagButton = [[UIBarButtonItem alloc] initWithTitle:@"Tag" style:UIBarButtonItemStylePlain target:self action:@selector(tagButtonTouchAction)]; 
          self.navigationItem.rightBarButtonItem = tagButton;
    
    
    [[AVAudioSession sharedInstance] setDelegate: self];

    if([self.delegate isKindOfClass:[NoteCommentViewController class]]) {
        self.publicButton.hidden = YES;
        self.mapButton.hidden = YES;
        self.textButton.frame = CGRectMake(self.textButton.frame.origin.x, self.textButton.frame.origin.y, self.textButton.frame.size.width*1.5, self.textButton.frame.size.height);
        self.libraryButton.frame = CGRectMake(self.libraryButton.frame.origin.x, self.libraryButton.frame.origin.y, self.libraryButton.frame.size.width*1.5, self.libraryButton.frame.size.height);
        self.audioButton.frame = CGRectMake(self.textButton.frame.size.width-2, self.audioButton.frame.origin.y, self.audioButton.frame.size.width*1.5, self.audioButton.frame.size.height);
        self.cameraButton.frame = CGRectMake(self.textButton.frame.size.width-2, self.cameraButton.frame.origin.y, self.cameraButton.frame.size.width*1.5, self.cameraButton.frame.size.height);
    }
    if([self.delegate isKindOfClass:[GPSViewController class]]){
        self.note.dropped = YES;   
    }
    
}
-(void)viewWillDisappear:(BOOL)animated{
        [self.soundPlayer pause];
    startWithView = 0;

    if([self.delegate isKindOfClass:[GPSViewController class]]){
        [[AppServices sharedAppServices]updateServerDropNoteHere:self.note.noteId atCoordinate:[AppModel sharedAppModel].playerLocation.coordinate];
    }

}
-(void)tagButtonTouchAction{
    TagViewController *tagView = [[TagViewController alloc]initWithNibName:@"TagViewController" bundle:nil];
    tagView.note = self.note;
    [self.navigationController pushViewController:tagView animated:YES];
    [tagView release];
}
- (IBAction)backButtonTouchAction: (id) sender{
   
    if(!self.noteValid){ [[AppServices sharedAppServices]deleteNoteWithNoteId:self.note.noteId];
        if(![AppModel sharedAppModel].isGameNoteList)
             [[AppModel sharedAppModel].playerNoteList removeObjectForKey:[NSNumber numberWithInt:self.note.noteId]];  
        else
            [[AppModel sharedAppModel].gameNoteList removeObjectForKey:[NSNumber numberWithInt:self.note.noteId]];  
    }
    else{
    if([self.delegate isKindOfClass:[NoteDetailsViewController class]]){
        [[AppServices sharedAppServices] updateNoteWithNoteId:self.note.noteId title:self.textField.text publicToMap:self.note.showOnMap publicToList:self.note.showOnList];
        self.note.title = self.textField.text;
          if(![AppModel sharedAppModel].isGameNoteList)
        [[AppModel sharedAppModel].playerNoteList setObject:self.note forKey:[NSNumber numberWithInt:self.note.noteId]];   
        else
            [[AppModel sharedAppModel].gameNoteList setObject:self.note forKey:[NSNumber numberWithInt:self.note.noteId]];   
        [self.delegate setNote:self.note];
    }
    self.note.title = self.textField.text;
        if(([note.title length] == 0)) note.title = @"New Note";
          if(![AppModel sharedAppModel].isGameNoteList)
    [[AppModel sharedAppModel].playerNoteList setObject:self.note forKey:[NSNumber numberWithInt:self.note.noteId]];   
          else
              [[AppModel sharedAppModel].gameNoteList setObject:self.note forKey:[NSNumber numberWithInt:self.note.noteId]];   
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)previewButtonTouchAction{

    NoteDetailsViewController *dataVC = [[[NoteDetailsViewController alloc] initWithNibName:@"NoteDetailsViewController" bundle:nil]autorelease];
    dataVC.note = self.note;
    dataVC.delegate = self;
    [self.navigationController pushViewController:dataVC animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
}
-(void)updateTable{
    [contentTable reloadData];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.textField resignFirstResponder];
    self.noteValid = YES;
    
    self.note.title = self.textField.text;
    if([note.title length] == 0) note.title = @"New Note";

    [[AppServices sharedAppServices] updateNoteWithNoteId:self.note.noteId title:self.note.title publicToMap:self.note.showOnMap publicToList:self.note.showOnList];
    //[self.delegate refresh];
    if(![AppModel sharedAppModel].isGameNoteList)
        [[AppModel sharedAppModel].playerNoteList setObject:self.note forKey:[NSNumber numberWithInt:self.note.noteId]];
    else
        [[AppModel sharedAppModel].gameNoteList setObject:self.note forKey:[NSNumber numberWithInt:self.note.noteId]]; 

    return YES;
}

-(void)cameraButtonTouchAction{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    CameraViewController *cameraVC = [[CameraViewController alloc] initWithNibName:@"Camera" bundle:nil];
    if(startWithView == 0)
    cameraVC.backView = self;
    else cameraVC.backView = self.delegate;
    cameraVC.parentDelegate = self.delegate;
    cameraVC.showVid = YES;
        cameraVC.editView = self;
    cameraVC.noteId = self.note.noteId;

    [self.navigationController pushViewController:cameraVC animated:NO];
    [cameraVC release];
    }
}
-(void)audioButtonTouchAction{
    BOOL audioHWAvailable = [[AVAudioSession sharedInstance] inputIsAvailable];
    if(audioHWAvailable){
    AudioRecorderViewController *audioVC = [[AudioRecorderViewController alloc] initWithNibName:@"AudioRecorderViewController" bundle:nil];
        if(startWithView == 0)
            audioVC.backView = self;
        else audioVC.backView = self.delegate;
    audioVC.parentDelegate = self.delegate;
    audioVC.noteId = self.note.noteId;
        audioVC.editView = self;
   
    [self.navigationController pushViewController:audioVC animated:NO];
    [audioVC release];
    } 
}
-(void)libraryButtonTouchAction{
    CameraViewController *cameraVC = [[CameraViewController alloc] initWithNibName:@"Camera" bundle:nil];
    if(startWithView == 0)
        cameraVC.backView = self;
    else cameraVC.backView = self.delegate;

    cameraVC.showVid = NO;
    cameraVC.parentDelegate = self.delegate;
    cameraVC.noteId = self.note.noteId;
    cameraVC.editView = self;

    [self.navigationController pushViewController:cameraVC animated:NO];
    [cameraVC release];
}
-(void)textButtonTouchAction{
    TextViewController *textVC = [[TextViewController alloc] initWithNibName:@"TextViewController" bundle:nil];
    textVC.noteId = self.note.noteId;
    if(startWithView == 0)
    textVC.backView = self;
    else textVC.backView = self.delegate;
    textVC.index = [self.note.contents count];
    textVC.editView = self;

    [self.navigationController pushViewController:textVC animated:NO];
    [textVC release];
}

-(void)mapButtonTouchAction{
    if(self.note.dropped){
        
        self.mapButton.selected = NO;
        self.note.dropped = NO;
        [[AppServices sharedAppServices]deleteNoteLocationWithNoteId:self.note.noteId];

    }
    else{
    DropOnMapViewController *mapVC = [[DropOnMapViewController alloc] initWithNibName:@"DropOnMapViewController" bundle:nil] ;
    mapVC.noteId = self.note.noteId;
    mapVC.delegate = self;
    self.noteValid = YES;
        self.mapButton.selected = YES;

    [self.navigationController pushViewController:mapVC animated:NO];
    [mapVC release];
    }
}
-(void)publicButtonTouchAction{
    self.noteValid = YES;
    if(actionSheet) [actionSheet release];
    actionSheet = [[UIActionSheet alloc]initWithTitle:@"Sharing" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"List Only",@"Map Only",@"Both",@"Don't Share", nil];
        [actionSheet showInView:self.view];

   /* if(self.publicButton.selected){
    self.publicButton.selected = NO;
        self.note.shared = NO;
    }
    else {
        self.publicButton.selected = YES;
        self.note.shared = YES;}
    
    [[AppServices sharedAppServices] updateNoteWithNoteId:self.note.noteId title:self.textField.text andShared:self.note.shared];*/
}
-(void)willPresentActionSheet:(UIActionSheet *)actionSheet{
   }
-(void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            self.note.showOnList = YES;
            self.note.showOnMap = NO;
            self.sharingLabel.text = @"List Only";
            break;
        case 1:
        {
            self.note.showOnList = NO;
            self.note.showOnMap = YES;
            self.sharingLabel.text = @"Map Only";
            if(!noteDropped){
                [[AppServices sharedAppServices]updateServerDropNoteHere:self.note.noteId atCoordinate:[AppModel sharedAppModel].playerLocation.coordinate];
                self.note.dropped = YES;
                self.mapButton.selected = YES;
            }
            break;
        }
        case 2:{
            self.note.showOnList = YES;
            self.note.showOnMap = YES;
            self.sharingLabel.text = @"List & Map";
            if(!noteDropped){
                if(!noteDropped){
                    [[AppServices sharedAppServices]updateServerDropNoteHere:self.note.noteId atCoordinate:[AppModel sharedAppModel].playerLocation.coordinate];
                    self.note.dropped = YES;
                    self.mapButton.selected = YES;
                }
            }
            break;
        }
        case 3:
            self.note.showOnList = NO;
            self.note.showOnMap = NO;
            self.sharingLabel.text = @"None";
            break;
        default:
            break;
   
    }
    [[AppServices sharedAppServices] updateNoteWithNoteId:self.note.noteId title:self.textField.text publicToMap:self.note.showOnMap publicToList:self.note.showOnList];

    }
- (void)viewDidAppear:(BOOL)animated {
	NSLog(@"NoteViewController: View Appeared");	
   // [self.contentTable reloadData];
}


-(void)refresh {
	NSLog(@"NoteViewController: Refresh Requested");
    
    //register for notifications
    NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
    [dispatcher addObserver:self selector:@selector(removeLoadingIndicator) name:@"NewContentListReady" object:nil];
    //self.publicButton.selected = self.note.shared;
    ///Server Call here
    //[self showLoadingIndicator];
}

#pragma mark custom methods, logic
-(void)showLoadingIndicator{
	UIActivityIndicatorView *activityIndicator = 
	[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	/*UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	[activityIndicator release];
	[[self navigationItem] setRightBarButtonItem:barButton];
	[barButton release];*/
	[activityIndicator startAnimating];    
    
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if([self.note.contents count] == 0 && indexPath.row == 0) return UITableViewCellEditingStyleNone;
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if([[[self.note.contents objectAtIndex:indexPath.row] getUploadState] isEqualToString:@"uploadStateDONE"]){
    [[AppServices sharedAppServices]deleteNoteContentWithContentId:[[self.note.contents objectAtIndex:indexPath.row] getContentId]];
    }
    else{
            [[AppModel sharedAppModel].uploadManager deleteContentFromNoteId:self.note.noteId andFileURL:[[[self.note.contents objectAtIndex:indexPath.row]getMedia] url]];

    }
    [self.note.contents removeObjectAtIndex:indexPath.row];

}

-(void)removeLoadingIndicator{
    [[self navigationItem] setRightBarButtonItem:nil];
    [contentTable reloadData];
}
- (void)tableView:(UITableView *)tableView 

didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    [contentTable reloadData];
}
- (void)refreshViewFromModel {
	NSLog(@"NoteViewController: Refresh View from Model");
    [self addUploadsToNote];
    [contentTable reloadData];
    //unregister for notifications
    
}

-(void)addUploadsToNote{
    self.note = [[AppModel sharedAppModel] noteForNoteId: self.note.noteId playerListYesGameListNo:YES];
    for(int x = [self.note.contents count]-1; x >= 0; x--){
        if(![[[self.note.contents objectAtIndex:x] getUploadState] isEqualToString:@"uploadStateDONE"])
            [self.note.contents removeObjectAtIndex:x];
    }
    
    NSMutableDictionary *uploads = [AppModel sharedAppModel].uploadManager.uploadContents;
    NSArray *uploadContentForNote = [[uploads objectForKey:[NSNumber numberWithInt:self.note.noteId]]allValues];
    [self.note.contents addObjectsFromArray:uploadContentForNote];
    NSLog(@"NoteEditorVC: Added %d upload content(s) to note",[uploadContentForNote count]);

}
#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if([self.note.contents count] == 0) return 1;
	return [self.note.contents count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"NoteEditorVC: Cell requested for section: %d row: %d",indexPath.section,indexPath.row);
    
    NSArray *reloadArr = [[NSArray alloc]init];
    
	static NSString *CellIdentifier = @"Cell";
    
    if([self.note.contents count] == 0){
        NSLog(@"NoteEditorVC: No note contents available, display standard message");

        UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.text = @"No Content Added";
        cell.detailTextLabel.text = @"Press Buttons Below To Add Some!";
        cell.userInteractionEnabled = NO;
        return  cell;
    }
    
    NoteContent<NoteContentProtocol> *noteC = [self.note.contents objectAtIndex:indexPath.row];
  
        NSLog(@"NoteEditorVC: Cell requested was not an UPLOAD");
        UITableViewCell *tempCell = (NoteContentCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (![tempCell respondsToSelector:@selector(titleLbl)]){
            //[tempCell release];
            tempCell = nil;
        }
        NoteContentCell *cell = (NoteContentCell *)tempCell;
        
        
        if (cell == nil) {
            // Create a temporary UIViewController to instantiate the custom cell.
            UIViewController *temporaryController = [[UIViewController alloc] initWithNibName:@"NoteContentCell" bundle:nil];
            // Grab a pointer to the custom cell.
            cell = (NoteContentCell *)temporaryController.view;
            // Release the temporary UIViewController.
            [temporaryController release];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        cell.index = indexPath.row;
        cell.delegate = self;
        cell.contentId = noteC.getContentId;
        cell.content = noteC;
    cell.indexPath = indexPath;
    cell.parentTableView = self.contentTable;
    
    [cell checkForRetry];
        if([noteC.getTitle length] >24)noteC.title = [noteC.getTitle substringToIndex:24];
        cell.titleLbl.text = noteC.getTitle;
        
        if([[[self.note.contents objectAtIndex:indexPath.row] getType] isEqualToString:kNoteContentTypeText]){
            cell.imageView.image = [UIImage imageWithContentsOfFile: 
                                    [[NSBundle mainBundle] pathForResource:@"noteicon" ofType:@"png"]]; 
            cell.detailLbl.text = noteC.getText;
        }
        else if([[noteC getType] isEqualToString:kNoteContentTypePhoto]){
            NSLog(@"NoteEditorVC: Cell requested is an %@", [noteC getType]);

            AsyncMediaImageView *aView = [[AsyncMediaImageView alloc]initWithFrame:cell.imageView.frame andMedia:noteC.getMedia];
            [cell addSubview:aView];
            [aView release];
        }
        else if([[noteC getType] isEqualToString:kNoteContentTypeAudio] || 
                [[noteC getType] isEqualToString:kNoteContentTypeVideo]){
            
            AsyncMediaImageView *aView = [[AsyncMediaImageView alloc]initWithFrame:cell.imageView.frame andMedia:noteC.getMedia];
            UIImageView *overlay = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"play_button.png"]];
            overlay.frame = CGRectMake(aView.frame.origin.x, aView.frame.origin.y, aView.frame.size.width/2, aView.frame.size.height/2);
            overlay.center = aView.center;

            //overlay.alpha = .6;
            [cell addSubview:aView];
            [cell addSubview:overlay];
            [overlay release];
            [aView release];
        }

        cell.titleLbl.text = noteC.getTitle;
    return cell;
    
    
    //Should never get here
    [reloadArr release];
    return [[UITableViewCell alloc]autorelease];
}
-(void)retryUpload:(id)sender{
    
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //Color the backgrounds
    if (indexPath.row % 2 == 0){  
        cell.backgroundColor = [UIColor colorWithRed:233.0/255.0  
                                               green:233.0/255.0  
                                                blue:233.0/255.0  
                                               alpha:1.0];  
    } else {  
        cell.backgroundColor = [UIColor colorWithRed:200.0/255.0  
                                               green:200.0/255.0  
                                                blue:200.0/255.0  
                                               alpha:1.0];  
    } 
}

-(void)removeObs{
    [self.soundPlayer removeTimeObserver:timeObserver];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NoteContent<NoteContentProtocol> *noteC;
   
    if([self.note.contents count]>indexPath.row){
        noteC = [self.note.contents objectAtIndex:indexPath.row];
    if ([noteC.getType isEqualToString:kNoteContentTypeText]){
        TextViewController *textVC = [[TextViewController alloc] initWithNibName:@"TextViewController" bundle:nil];
        textVC.noteId = self.note.noteId;
        textVC.textToDisplay = noteC.getText;
        textVC.editMode = YES;
        textVC.contentId = noteC.getContentId;
        textVC.editView = self;
        textVC.backView = self;
        textVC.index = indexPath.row;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.5];
        
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
                               forView:self.navigationController.view cache:YES];
        [self.navigationController pushViewController:textVC animated:NO];
        [UIView commitAnimations];
        [textVC release];
   
    }
    else if([noteC.getType isEqualToString:kNoteContentTypePhoto]){
        //view photo
        ImageViewer *controller = [[ImageViewer alloc] initWithNibName:@"ImageViewer" bundle:nil];
               
        controller.media = noteC.getMedia;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.5];
        
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
                               forView:self.navigationController.view cache:YES];
        [self.navigationController pushViewController:controller
                                             animated:NO];
        [UIView commitAnimations];
        [controller release];
    }
    else if([noteC.getType isEqualToString:kNoteContentTypeAudio]){
          //listen to audio      
               [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];	
        
        [[AVAudioSession sharedInstance] setActive: YES error: nil];
        
        
            //NSError *error;
        if(self.soundPlayer.rate == 1.0f){
            [self.soundPlayer pause];
            [tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text = nil;
            
            [tableView cellForRowAtIndexPath:indexPath].selected = NO;
        }
        else{
            [self.soundPlayer initWithURL:noteC.getMedia.url]; 
            [self.soundPlayer play];
        }

        CMTime time = CMTimeMakeWithSeconds(1.0f, 1);
        
    timeObserver = [[self.soundPlayer addPeriodicTimeObserverForInterval:time queue:NULL usingBlock:^(CMTime time){ 
           if((self.soundPlayer.currentTime.value != self.soundPlayer.currentItem.duration.value) && self.soundPlayer.rate !=0.0f){  
               [tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text =[NSString stringWithFormat:@"%d:%d%d", (int)roundf(CMTimeGetSeconds(self.soundPlayer.currentTime))/60,((int)roundf(CMTimeGetSeconds(self.soundPlayer.currentTime))) % 60/10,(int)roundf(CMTimeGetSeconds(self.soundPlayer.currentTime))%10];
           }else {
               [tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text = nil;
               [tableView cellForRowAtIndexPath:indexPath].selected = NO;
               [self removeObs];
                        }
       } ] retain];
        //[tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text =[NSString stringWithFormat:@"%d:%d%d", [self.soundPlayer currentTime].value/60,([self.soundPlayer currentTime ].value%60)/10,[self.soundPlayer currentTime].value%10];
        //[self playTextAnimation:self.soundPlayer withCell:[tableView cellForRowAtIndexPath:indexPath]];
    }
    else if([noteC.getType isEqualToString:kNoteContentTypeVideo]){
        //Create movie player object
        ARISMoviePlayerViewController *mMoviePlayer = [[ARISMoviePlayerViewController alloc] initWithContentURL:noteC.getMedia.url];
        mMoviePlayer.moviePlayer.shouldAutoplay = YES;
        [self presentMoviePlayerViewControllerAnimated:mMoviePlayer];
        [mMoviePlayer release];
    }
    }
    //[noteC release];
}

- (void)tableView:(UITableView *)aTableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
	
}

-(CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60;
}
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    self.soundPlayer = nil;
}
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
	NSLog(@"AudioRecorder: Playback Error");
}
- (void)movieFinishedCallback:(NSNotification*) aNotification
{
	NSLog(@"ItemDetailsViewController: movieFinishedCallback");
	[self dismissMoviePlayerViewControllerAnimated];
}
@end
