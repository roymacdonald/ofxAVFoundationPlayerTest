
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ofMain.h"
#import "ofxiPhoneExtras.h"

#pragma once

@class AVPlayer;
@class ofxAVPlayerView;
 

@interface AVPlayerDemoPlaybackViewController : UIViewController
{
	
	ofxAVPlayerView *mPlaybackView;	
	BOOL seekToZeroBeforePlay;
	AVPlayer* mPlayer;
	NSUInteger currentMovieIndex;
	NSUInteger loadedAssetIndex;
	BOOL firstPlay;
	
}

@property (readwrite, retain, setter=setPlayer:, getter=player) AVPlayer* mPlayer;
@property (nonatomic, retain) NSMutableArray * mPlayerItems;
@property (nonatomic, retain) NSMutableArray * mPlayerItemsDidFinish;
@property (nonatomic, retain) NSMutableArray * URLs;
@property (nonatomic, retain) NSMutableArray * doLoopURLs;
@property (nonatomic, retain) ofxAVPlayerView *mPlaybackView;
@property (nonatomic, retain) NSMutableArray * doLoop;

- (void)addURL:(NSURL*)URL loopPlayback:(BOOL)loop;
- (void)playMovie:(NSUInteger) movieIndex;
- (void)playMovie;
- (void)playNextMovie;
- (void)loadAssets;
@end


class ofxAVPlayer{

public:	
	ofxAVPlayer();
	~ofxAVPlayer();
	
	void addURL(string URL, bool loop);
	void playMovie(int movieIndex);
	void playMovie();
	void playNextMovie();
	void loadAssets();
	void show();
	void hide();
	
private:	
	AVPlayerDemoPlaybackViewController * mAVPlayerController; 
};

