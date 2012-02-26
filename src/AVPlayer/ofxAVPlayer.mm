
#import "ofxAVPlayer.h"
#import "ofxAVPlayerView.h"

ofxAVPlayer::ofxAVPlayer(){
	mAVPlayerController = [[AVPlayerDemoPlaybackViewController alloc] init];

}
//------------------------------------------------------------------------------------------
ofxAVPlayer::~ofxAVPlayer(){
	[mAVPlayerController release];
}
//------------------------------------------------------------------------------------------
void ofxAVPlayer::addURL(string URL, bool loop){
	
	string moviePath = [[[NSBundle mainBundle] resourcePath] UTF8String];
	moviePath.append("/");
	moviePath.append(URL);
	cout<<"moviePath: "<< moviePath<<endl;
	
	[mAVPlayerController addURL:[NSURL fileURLWithPath:[NSString stringWithUTF8String:moviePath.c_str()]] loopPlayback:YES];
	
}
//------------------------------------------------------------------------------------------
void ofxAVPlayer::playMovie(int movieIndex){
	[mAVPlayerController playMovie:movieIndex];
}
//------------------------------------------------------------------------------------------
void ofxAVPlayer::playMovie(){
	[mAVPlayerController playMovie];
}
//------------------------------------------------------------------------------------------
void ofxAVPlayer::playNextMovie(){
	[mAVPlayerController playNextMovie];
}
//------------------------------------------------------------------------------------------
void ofxAVPlayer::loadAssets(){
	[mAVPlayerController loadAssets];
}
//------------------------------------------------------------------------------------------
void ofxAVPlayer::show(){
	NSLog(@"addSubview");
	[[[UIApplication sharedApplication] keyWindow] addSubview:mAVPlayerController.view];
}
//------------------------------------------------------------------------------------------
void ofxAVPlayer::hide(){
	NSLog(@"removeFrmosSuperview");
	[mAVPlayerController.view removeFromSuperview];
}
//------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------

/* Asset keys */
NSString * const kTracksKey         = @"tracks";
NSString * const kPlayableKey		= @"playable";

/* PlayerItem keys */
NSString * const kStatusKey         = @"status";

/* AVPlayer keys */
NSString * const kRateKey			= @"rate";
NSString * const kCurrentItemKey	= @"currentItem";

@interface AVPlayerDemoPlaybackViewController ()
- (void)play;
- (void)pause;
- (id)init;
- (void)dealloc;
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (void)viewDidLoad;
- (void)viewWillDisappear:(BOOL)animated;

@end

@interface AVPlayerDemoPlaybackViewController (Player)
//- (CMTime)playerItemDuration;
- (BOOL)isPlaying;
- (void)playerItemDidReachEnd:(NSNotification *)notification ;
- (void)observeValueForKeyPath:(NSString*) path ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys;
@end

static void *AVPlayerDemoPlaybackViewControllerRateObservationContext = &AVPlayerDemoPlaybackViewControllerRateObservationContext;
static void *AVPlayerDemoPlaybackViewControllerStatusObservationContext = &AVPlayerDemoPlaybackViewControllerStatusObservationContext;
static void *AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext = &AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext;


@implementation AVPlayerDemoPlaybackViewController

@synthesize mPlayer, mPlaybackView, mPlayerItems, mPlayerItemsDidFinish, URLs, doLoop, doLoopURLs;

//------------------------------------------------------------------------------------------
- (void)addURL:(NSURL*)URL loopPlayback:(BOOL)loop{
	NSLog(@"addURL");        
	[doLoopURLs addObject:[NSNumber numberWithBool:loop]];
	[URLs addObject:URL];
}
//------------------------------------------------------------------------------------------
- (void)loadAssets{
	if (loadedAssetIndex<[URLs count]) {
		NSLog(@"loadAssets");
		AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[URLs objectAtIndex:loadedAssetIndex] options:nil];
        
        NSArray *requestedKeys = [NSArray arrayWithObjects:kTracksKey, kPlayableKey, nil];
        
        [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:
         ^{	NSLog(@"Values loaded completion handler");
             dispatch_async( dispatch_get_main_queue(), 
                            ^{
								NSLog(@"dispatch prepareToPlayAssets");
                                /* IMPORTANT: Must dispatch to main queue in order to operate on the AVPlayer and AVPlayerItem. */
								
                                [self prepareToPlayAsset:asset withKeys:requestedKeys];
							
								//[asset release];
								//[requestedKeys release];
                            });
         }];
	}else if ([mPlayerItems count]>0) {
		[self play];
	}
}
//------------------------------------------------------------------------------------------
- (void)play{
	NSLog(@"play");
	/* If we are at the end of the movie, we must seek to the beginning first 
		before starting playback. */
	if (YES == seekToZeroBeforePlay) 
	{
		//seekToZeroBeforePlay = NO;
		[mPlayer seekToTime:kCMTimeZero];
	}

	[mPlayer play];
	if (![[doLoop objectAtIndex:currentMovieIndex] boolValue]) {
		if (currentMovieIndex < [self.mPlayerItemsDidFinish count]) {
			[self.mPlayerItemsDidFinish replaceObjectAtIndex:currentMovieIndex withObject:[NSNumber numberWithBool:NO]];
		}
	}
}
//------------------------------------------------------------------------------------------
- (void)pause{
	[mPlayer pause];
}
//------------------------------------------------------------------------------------------
- (id)init{
	if (self = [super init]){
		mPlayer = nil;
	//	[self setWantsFullScreenLayout:YES];
		self.mPlayerItems = [[NSMutableArray alloc]init];
		self.mPlayerItemsDidFinish= [[NSMutableArray alloc]init];
		self.URLs = [[NSMutableArray alloc]init];
		self.doLoop = [[NSMutableArray alloc]init];
		self.doLoopURLs = [[NSMutableArray alloc]init];
	}
	firstPlay=YES;
	loadedAssetIndex=0;
	currentMovieIndex=0;
	return self;
}
//------------------------------------------------------------------------------------------
- (void)loadView {
	CGRect myFrame = [[UIScreen mainScreen]bounds];
	//self.view = [[UIView alloc] initWithFrame:myFrame];
	NSLog(@"Playback view controler %@", NSStringFromCGRect(myFrame));
	mPlaybackView = [[ofxAVPlayerView alloc]initWithFrame:myFrame];
	[mPlaybackView setAutoresizingMask:UIViewAutoresizingFlexibleWidth ];
	mPlaybackView.autoresizesSubviews =YES; 
    self.view=mPlaybackView;
	self.view.userInteractionEnabled=NO;
}	
//------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------
- (void)viewDidUnload{
    self.mPlaybackView = nil;
    [super viewDidUnload];
}
//------------------------------------------------------------------------------------------
- (void)viewDidLoad{ 
//	mPlayer = nil;
}
//------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated{
	[mPlayer pause];
	[super viewWillDisappear:animated];
}
//------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
	if (interfaceOrientation== UIInterfaceOrientationLandscapeLeft || interfaceOrientation ==UIInterfaceOrientationLandscapeRight) {
		return YES;
	}else {
		return NO; 
	}
}
//------------------------------------------------------------------------------------------
- (void)dealloc{
	
	
	
	[mPlayer removeObserver:self forKeyPath:@"rate"];
	[mPlayer removeObserver:self forKeyPath:kCurrentItemKey];
	[mPlayer.currentItem removeObserver:self forKeyPath:@"status"];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:AVPlayerItemDidPlayToEndTimeNotification
												  object:[self.mPlayerItems objectAtIndex:currentMovieIndex]];
	
	[mPlayer pause];
	[mPlayer release];
	
	[mPlayerItems release];
	[mPlayerItemsDidFinish release];
	[URLs release];
	[doLoopURLs release];
	[mPlaybackView release];
	[doLoop release];
	
	
		
	[super dealloc];
	
}
//------------------------------------------------------------------------------------------
- (void)playNextMovie{
	NSLog(@"PlayNextMovie");
	
	NSUInteger next;
	if (currentMovieIndex < [self.mPlayerItems count]-1){
		next = currentMovieIndex+1;
	}else {
		next =0;
	}
	[self playMovie:next];

}
//------------------------------------------------------------------------------------------
- (void)playMovie{
	NSLog(@"Play Movie ");
	
	if ([self.mPlayerItems count]>0) {
		NSLog(@"Play Movie at index");
		
		[self playMovie:[self.mPlayerItems count]-1];
	}
}
//------------------------------------------------------------------------------------------
- (void)playMovie:(NSUInteger) movieIndex{
	NSLog(@"Play Movie at index: %d", movieIndex);
	
	if (movieIndex < [self.mPlayerItems count]){
		/* Make our new AVPlayerItem the AVPlayer's current item. */
		if (self.player.currentItem != [self.mPlayerItems objectAtIndex:movieIndex]){
			
			if (!firstPlay) {
			if ([self.mPlayerItems objectAtIndex:currentMovieIndex]){
				// Remove existing player item key value observers and notifications. 
				
				[[self.mPlayerItems objectAtIndex:currentMovieIndex] removeObserver:self forKeyPath:kStatusKey];            
				
				[[NSNotificationCenter defaultCenter] removeObserver:self
																name:AVPlayerItemDidPlayToEndTimeNotification
															  object:[self.mPlayerItems objectAtIndex:currentMovieIndex]];
				}	
			}
			
			
			/* Observe the player item "status" key to determine when it is ready to play. */
			[[self.mPlayerItems objectAtIndex:movieIndex] addObserver:self 
														   forKeyPath:kStatusKey 
															  options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
															  context:AVPlayerDemoPlaybackViewControllerStatusObservationContext];
			
			/* When the player item has played to its end time we'll toggle
			 the movie controller Pause button to be the Play button */
			[[NSNotificationCenter defaultCenter] addObserver:self
													 selector:@selector(playerItemDidReachEnd:)
														 name:AVPlayerItemDidPlayToEndTimeNotification
													   object:[self.mPlayerItems objectAtIndex:movieIndex]];
			
			firstPlay=NO;
			/* Replace the player item with a new player item. The item replacement occurs 
			 asynchronously; observe the currentItem property to find out when the 
			 replacement will/did occur*/
			[[self player] replaceCurrentItemWithPlayerItem:[self.mPlayerItems objectAtIndex:movieIndex]];
			currentMovieIndex = movieIndex;
		}
		[self play];
	}
}

//------------------------------------------------------------------------------------------
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	NSUInteger numTaps = [[touches anyObject] tapCount];
	if (numTaps>0) {
		NSLog(@"touches Began ");
		[self playNextMovie];					
	}
}
//------------------------------------------------------------------------------------------
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{}
//------------------------------------------------------------------------------------------
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{}
//------------------------------------------------------------------------------------------
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{}

@end
//------------------------------------------------------------------------------------------
@implementation AVPlayerDemoPlaybackViewController (Player)

//------------------------------------------------------------------------------------------
- (BOOL)isPlaying{
	return [mPlayer rate] != 0.f;
}
//------------------------------------------------------------------------------------------
- (void)playerItemDidReachEnd:(NSNotification *)notification {
	if ([[doLoop objectAtIndex:currentMovieIndex] boolValue]) {
		seekToZeroBeforePlay = YES;
		[self play];
	}else if (currentMovieIndex < [self.mPlayerItemsDidFinish count]) {
		[self.mPlayerItemsDidFinish replaceObjectAtIndex:currentMovieIndex withObject:[NSNumber numberWithBool:YES]];
		//if (myApp) {
		//	myApp->movieEndListener(currentMovieIndex);
		//}
	}
}
//------------------------------------------------------------------------------------------
-(BOOL)didMovieEnd{
	if (currentMovieIndex < [self.mPlayerItemsDidFinish count]) {
		return[[self.mPlayerItemsDidFinish objectAtIndex:currentMovieIndex] boolValue ];
    }else {
		return YES;
	}
}
//------------------------------------------------------------------------------------------
/*
- (CMTime)playerItemDuration{
	AVPlayerItem *playerItem = [mPlayer currentItem];
	if (playerItem.status == AVPlayerItemStatusReadyToPlay){
		return([playerItem duration]);
	}
	return(kCMTimeInvalid);
}//*/
//------------------------------------------------------------------------------------------
-(void)assetFailedToPrepareForPlayback:(NSError *)error{
   
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
														message:[error localizedFailureReason]
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}
//------------------------------------------------------------------------------------------
- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys{
    /* Make sure that the value of each key has loaded successfully. */
	NSLog(@"Prepare to play assets");
	for (NSString *thisKey in requestedKeys)
	{
		NSError *error = nil;
		AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
		if (keyStatus == AVKeyValueStatusFailed)
		{
			[self assetFailedToPrepareForPlayback:error];
			return;
		}
	}
    
	NSLog(@"mPlayerItems count (pre add): %d", [self.mPlayerItems count]);
	[self.mPlayerItems addObject:[AVPlayerItem playerItemWithAsset:asset]];
    [self.mPlayerItemsDidFinish addObject:[NSNumber numberWithBool:NO]];
	NSLog(@"Loaded asset Index: %d", loadedAssetIndex);
	[self.doLoop addObject:[self.doLoopURLs objectAtIndex:loadedAssetIndex]];
	NSLog(@"mPlayerItems count (post add): %d", [self.mPlayerItems count]);
	NSLog(@"Movie asset added");
	
	//seekToZeroBeforePlay = NO;
	
    if (![self player])
    {
        [self setPlayer:[AVPlayer playerWithPlayerItem:[self.mPlayerItems lastObject]]];	
		
        [self.player addObserver:self 
                      forKeyPath:kCurrentItemKey 
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext];
        [self.player addObserver:self 
                      forKeyPath:kRateKey 
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:AVPlayerDemoPlaybackViewControllerRateObservationContext];
    }
	loadedAssetIndex++;
    [self loadAssets];
}
//------------------------------------------------------------------------------------------
- (void)observeValueForKeyPath:(NSString*) path ofObject:(id)object change:(NSDictionary*)change context:(void*)context{
	if (context == AVPlayerDemoPlaybackViewControllerStatusObservationContext)
	{
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status)
        {
            case AVPlayerStatusUnknown:
            {
        
            }
            break;
                
            case AVPlayerStatusReadyToPlay:
            {
                
            }
            break;
                
            case AVPlayerStatusFailed:
            {
                AVPlayerItem *playerItem = (AVPlayerItem *)object;
                [self assetFailedToPrepareForPlayback:playerItem.error];
            }
            break;
        }
	}
	else if (context == AVPlayerDemoPlaybackViewControllerRateObservationContext)
	{
	
	}
	else if (context == AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext)
	{
        AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
        
        if (newPlayerItem == (id)[NSNull null])
        {
        }
        else
        {
			NSLog(@"player item Changed");
            [mPlaybackView setPlayer:mPlayer];
            [mPlaybackView setVideoFillMode:AVLayerVideoGravityResizeAspect];
			[self play];
        }
	}
	else
	{
		[super observeValueForKeyPath:path ofObject:object change:change context:context];
	}
}


@end

