//
//  NoteViewController.m
//  ARIS
//
//  Created by Brian Thiel on 8/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NoteViewController.h"
#import "TitleAndDecriptionFormViewController.h"
#import "ARISAppDelegate.h"
#import "AppServices.h"
#import "InventoryListViewController.h"
#import "GPSViewController.h"
#import "CameraViewController.h"
#import "AudioRecorderViewController.h"
#import "TextViewController.h"
#import "AsyncImageView.h"
#import "Media.h"
#import "ImageViewer.h"
#import "ARISMoviePlayerViewController.h"
#import "DropOnMapViewController.h"
#import "NoteCommentViewController.h"
#import "DataCollectionViewController.h"
#import "AppModel.h"
#import "UIImage+Scale.h"

@implementation NoteViewController
@synthesize textBox,textField,note, delegate, hideKeyboardButton,libraryButton,cameraButton,audioButton, typeControl,viewControllers, scrollView,pageControl,publicButton,textButton,mapButton, contentTable,soundPlayer,noteValid,noteChanged, noteDropped, vidThumbs;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Note";
        self.tabBarItem.image = [UIImage imageNamed:@"noteicon.png"];
        viewControllers = [[NSMutableArray alloc] initWithCapacity:10];
        self.note = [[Note alloc]init];
        NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
        [dispatcher addObserver:self selector:@selector(updateTable) name:@"ImageReady" object:nil];
        [dispatcher addObserver:self selector:@selector(movieLoadStateChanged:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
        self.soundPlayer = [[AVPlayer alloc] init];
        self.hidesBottomBarWhenPushed = YES;
        self.noteValid = NO;
        self.vidThumbs = [[NSMutableDictionary alloc] initWithCapacity:5];

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
    [super dealloc];
    
}
-(void)viewWillAppear:(BOOL)animated{
    if(self.note.noteId != 0){
    self.textField.text = self.note.title;
        self.navigationItem.title = self.textField.text;
    }
    if(self.note.shared == YES) self.publicButton.selected = YES;
    else self.publicButton.selected = NO;
    
    if(self.note.dropped)self.mapButton.selected = YES;   
    else self.mapButton.selected = NO;
    
    if(self.noteChanged){
    self.noteChanged = NO;
    [self refresh];
    [contentTable reloadData];
    }
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
        self.note.noteId = [[AppServices sharedAppServices] createNote];
    }
    else self.noteValid = YES;
    //self.contentTable.editing = YES;
    scrollView.delegate = self;
    pageControl.currentPage = 0;
    pageControl.numberOfPages = numPages;
    UIBarButtonItem *previewButton = [[UIBarButtonItem alloc] initWithTitle:@"Preview" style:UIBarButtonItemStylePlain target:self action:@selector(previewButtonTouchAction)];      
	self.navigationItem.rightBarButtonItem = previewButton;
    
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
    self.navigationController.navigationItem.title = @"Note";
        [self.soundPlayer pause];
    
    if([self.delegate isKindOfClass:[GPSViewController class]]){
        [[AppServices sharedAppServices]updateServerDropNoteHere:self.note.noteId atCoordinate:[AppModel sharedAppModel].playerLocation.coordinate];
    }

}
- (IBAction)backButtonTouchAction: (id) sender{
   
    if(!self.noteValid) [[AppServices sharedAppServices]deleteNoteWithNoteId:self.note.noteId];
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (void)movieLoadStateChanged:(NSNotification*) aNotification{
	MPMovieLoadState state = [(MPMoviePlayerController *) aNotification.object loadState];
	MPMoviePlayerController *mMovie = (MPMoviePlayerController *)aNotification.object;
    NSString *url = [mMovie.contentURL absoluteString];
    

	if( state & MPMovieLoadStatePlayable ) {
        
        //Create a thumbnail for the button
        if (![self.vidThumbs valueForKey:url]) {
            UIImage *videoThumb = [mMovie thumbnailImageAtTime:(NSTimeInterval)1.0 timeOption:MPMovieTimeOptionExact];            
            UIImage *videoThumbSized = [videoThumb scaleToSize:CGSizeMake(60, 60)];        
            [self.vidThumbs setValue:videoThumbSized forKey:url];
            [self.contentTable reloadRowsAtIndexPaths:[self.vidThumbs valueForKey:@"indexPath"]  withRowAnimation:UITableViewRowAnimationFade];
        }
	} 

	
}

-(void)previewButtonTouchAction{

    DataCollectionViewController *dataVC = [[[DataCollectionViewController alloc] initWithNibName:@"DataCollectionViewController" bundle:nil]autorelease];
    dataVC.note = self.note;
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
    [[AppServices sharedAppServices] updateNoteWithNoteId:self.note.noteId title:self.textField.text andShared:self.note.shared];
    self.navigationItem.title = self.textField.text;
    self.note.title = self.textField.text;
    [self.delegate refresh];

    return YES;
}

-(void)cameraButtonTouchAction{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    CameraViewController *cameraVC = [[[CameraViewController alloc] initWithNibName:@"Camera" bundle:nil] autorelease];
    cameraVC.delegate = self;
    cameraVC.parentDelegate = self.delegate;
    cameraVC.showVid = YES;
    cameraVC.noteId = self.note.noteId;

    [self.navigationController pushViewController:cameraVC animated:NO];
    //[cameraVC release];
    }
}
-(void)audioButtonTouchAction{
    BOOL audioHWAvailable = [[AVAudioSession sharedInstance] inputIsAvailable];
    if(audioHWAvailable){
    AudioRecorderViewController *audioVC = [[AudioRecorderViewController alloc] initWithNibName:@"AudioRecorderViewController" bundle:nil];
    audioVC.delegate = self;
    audioVC.parentDelegate = self.delegate;
    audioVC.noteId = self.note.noteId;
   
    [self.navigationController pushViewController:audioVC animated:YES];
    [audioVC release];
    } 
}
-(void)libraryButtonTouchAction{
    CameraViewController *cameraVC = [[CameraViewController alloc] initWithNibName:@"Camera" bundle:nil];
    cameraVC.delegate = self;
    cameraVC.showVid = NO;
    cameraVC.parentDelegate = self.delegate;
    cameraVC.noteId = self.note.noteId;
   
    [self.navigationController pushViewController:cameraVC animated:YES];
    [cameraVC release];
}
-(void)textButtonTouchAction{
    TextViewController *textVC = [[TextViewController alloc] initWithNibName:@"TextViewController" bundle:nil];
    textVC.noteId = self.note.noteId;
    textVC.delegate = self;
    [self.navigationController pushViewController:textVC animated:YES];
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

    [self.navigationController pushViewController:mapVC animated:YES];
    [mapVC release];
    }
}
-(void)publicButtonTouchAction{
    self.noteValid = YES;
    if(self.publicButton.selected){
    self.publicButton.selected = NO;
        self.note.shared = NO;
    }
    else {
        self.publicButton.selected = YES;
        self.note.shared = YES;}
    
    [[AppServices sharedAppServices] updateNoteWithNoteId:self.note.noteId title:self.textField.text andShared:self.note.shared];
}

- (void)viewDidAppear:(BOOL)animated {
	NSLog(@"NoteViewController: View Appeared");	
    
}


-(void)refresh {
	NSLog(@"NoteViewController: Refresh Requested");
    
    //register for notifications
    NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
    [dispatcher addObserver:self selector:@selector(refreshViewFromModel) name:@"NewContentListReady" object:nil];
    [dispatcher addObserver:self selector:@selector(removeLoadingIndicator) name:@"NewContentListReady" object:nil];
    self.note =[[AppServices sharedAppServices]fetchNote:self.note.noteId];
    self.publicButton.selected = self.note.shared;
    ///Server Call here
    //[self showLoadingIndicator];
}

#pragma mark custom methods, logic
-(void)showLoadingIndicator{
	UIActivityIndicatorView *activityIndicator = 
	[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	[activityIndicator release];
	[[self navigationItem] setRightBarButtonItem:barButton];
	[barButton release];
	[activityIndicator startAnimating];    
    
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if([self.note.contents count] == 0 && indexPath.row == 0) return UITableViewCellEditingStyleNone;
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    [[AppServices sharedAppServices]deleteNoteContentWithContentId:[(NoteContent *)[self.note.contents objectAtIndex:indexPath.row] contentId]];
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
    self.note =[[AppServices sharedAppServices]fetchNote:self.note.noteId];

    [contentTable reloadData];
    //unregister for notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
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
	//NSLog(@"GamePickerVC: Cell requested for section: %d row: %d",indexPath.section,indexPath.row);
    NSArray *reloadArr = [[NSArray alloc]init];
    NoteContent *noteC = [[NoteContent alloc] init];
    if([self.note.contents count]>indexPath.row)
    noteC = [self.note.contents objectAtIndex:indexPath.row];
	static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    if([self.note.contents count] == 0){
        cell.textLabel.text = @"No Content Added";
        cell.detailTextLabel.text = @"Press Buttons Below To Add Some!";
        cell.userInteractionEnabled = NO;
    }
    else{
        for(int i = 0; i < [self.note.contents count]; i++){
            cell.textLabel.text = [(NoteContent *)[self.note.contents objectAtIndex:indexPath.row] type];
            if([cell.textLabel.text isEqualToString:@"TEXT"]){
             cell.imageView.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"noteicon" ofType:@"png"]]; 
                cell.detailTextLabel.text = noteC.text;
            }
            else if([cell.textLabel.text isEqualToString:@"VIDEO"]){
                reloadArr =[reloadArr arrayByAddingObject:indexPath];
                [self.vidThumbs setValue:reloadArr forKey:@"indexPath"];
                Media *m = [[Media alloc]init];
                m = [[AppModel sharedAppModel] mediaForMediaId:noteC.mediaId]; 
                NSURL* contentURL = [NSURL URLWithString:m.url];
                
                if(![self.vidThumbs valueForKey:m.url]){
                    
                    MPMoviePlayerController  *moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:contentURL];
                    moviePlayerController.shouldAutoplay = NO;
                    [moviePlayerController prepareToPlay];
                    cell.imageView.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaultVideoIcon" ofType:@"png"]];    


                }
                else{
                    cell.imageView.image = [self.vidThumbs valueForKey:m.url];

                }
            }
            else if([cell.textLabel.text isEqualToString:@"PHOTO"]){
                cell.imageView.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaultImageIcon" ofType:@"png"]];    
                Media *m = [[Media alloc]init];
                m = [[AppModel sharedAppModel] mediaForMediaId:noteC.mediaId]; 
                AsyncImageView *aView = [[AsyncImageView alloc]init];
                aView.frame = cell.imageView.frame;
                [aView loadImageFromMedia:m];
                if(m.image)
                [cell.imageView setImage:m.image];
                [cell addSubview:aView];
                [aView release];
                //[m release];
            }
            else if([cell.textLabel.text isEqualToString:@"AUDIO"]){
             cell.imageView.image = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"defaultAudioIcon" ofType:@"png"]];                 
            }
            return cell;
        }
    }
    
    
    [reloadArr release];
    return cell;
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
/*-(void)playTextAnimation:(AVPlayer *) player withCell:(UITableViewCell *)cell{
    if(player.currentTime.value != player.currentItem.duration.value){
    [UIView animateWithDuration:1 delay:1 options:nil animations:^{cell.detailTextLabel.text = @"Playing";} completion:^(BOOL finished){
        [UIView animateWithDuration:1 delay:1 options:nil  animations:^{cell.detailTextLabel.text = @"Playing.";} completion:^(BOOL finished){
            [UIView animateWithDuration:1 delay:1 options:nil  animations:^{cell.detailTextLabel.text = @"Playing..";} completion:^(BOOL finished){
                [UIView animateWithDuration:1 delay:1 options:nil animations:^{cell.detailTextLabel.text = @"Playing...";} completion:^(BOOL finished){
                    [self playTextAnimation:player withCell:cell];
                }];
            }];
        }];
    }];
    }
    else {
        cell.detailTextLabel.text = nil;
    }
}
*/
-(void)removeObs{
    [self.soundPlayer removeTimeObserver:timeObserver];
    

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NoteContent *noteC = [[NoteContent alloc] init];
   
    if([self.note.contents count]>indexPath.row){
        noteC = [self.note.contents objectAtIndex:indexPath.row];
    if ([noteC.type isEqualToString:@"TEXT"]){
        TextViewController *textVC = [[[TextViewController alloc] initWithNibName:@"TextViewController" bundle:nil] autorelease];
        textVC.noteId = self.note.noteId;
        textVC.textToDisplay = noteC.text;
        textVC.editMode = YES;
        textVC.contentId = noteC.contentId;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.5];
        
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
                               forView:self.navigationController.view cache:YES];
        [self.navigationController pushViewController:textVC animated:NO];
        [UIView commitAnimations];
   
    }
    else if([noteC.type isEqualToString:@"PHOTO"]){
        //view photo
        ImageViewer *controller = [[ImageViewer alloc] initWithNibName:@"ImageViewer" bundle:nil];
        Media *m = [[Media alloc]init];
        m = [[AppModel sharedAppModel] mediaForMediaId:noteC.mediaId];
        
        controller.media = m;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.5];
        
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
                               forView:self.navigationController.view cache:YES];
        [self.navigationController pushViewController:controller
                                             animated:NO];
        [UIView commitAnimations];
    }
    else if([noteC.type isEqualToString:@"AUDIO"]){
          //listen to audio      
        Media *media = [[Media alloc] init];
        media = [[AppModel sharedAppModel] mediaForMediaId:noteC.mediaId];
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];	
        
        [[AVAudioSession sharedInstance] setActive: YES error: nil];
        
        
            //NSError *error;
        if(self.soundPlayer.rate == 1.0f){
            [self.soundPlayer pause];
            [tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text = nil;
            
            [tableView cellForRowAtIndexPath:indexPath].selected = NO;
        }
        else{
            NSURL *url =  [NSURL URLWithString:media.url];
            [self.soundPlayer initWithURL:url]; 
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
    else if([noteC.type isEqualToString:@"VIDEO"]){
                //view video
        Media *media = [[Media alloc] init];
        media = [[AppModel sharedAppModel] mediaForMediaId:noteC.mediaId];
        
        //Create movie player object
        ARISMoviePlayerViewController *mMoviePlayer = [[ARISMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:media.url]];
        [mMoviePlayer shouldAutorotateToInterfaceOrientation:YES];
        mMoviePlayer.moviePlayer.shouldAutoplay = NO;
        [mMoviePlayer.moviePlayer prepareToPlay];		
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.5];
        mMoviePlayer.moviePlayer.shouldAutoplay = YES;

        [self presentMoviePlayerViewControllerAnimated:mMoviePlayer];


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
