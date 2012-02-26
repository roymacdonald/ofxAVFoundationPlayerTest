#pragma once

#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"

#include "ofxAVPlayer.h"

#define VIDEO__INTRO_IN 0
#define VIDEO__INTRO_LOOP 1
#define VIDEO__INTRO_OUT 2
#define VIDEO__JUEGO_LOOP 3
#define VIDEO__JUEGO_REELS_OUT 4
#define VIDEO__JUEGO_REELS 5
#define VIDEO__GANASTE 6
#define VIDEO__CONFIGURACION_IN 7
#define VIDEO__CONFIGURACION_OUT 8

class testApp : public ofxiPhoneApp{
	
public:
	void setup();
	void update();
	void draw();
		
	void touchDown(ofTouchEventArgs &touch);
	void touchMoved(ofTouchEventArgs &touch);
	void touchUp(ofTouchEventArgs &touch);
	void touchDoubleTap(ofTouchEventArgs &touch);
	void touchCancelled(ofTouchEventArgs &touch);
	
	void lostFocus();
	void gotFocus();
	void gotMemoryWarning();
	void deviceOrientationChanged(int newOrientation);
	void movieEndListener(int  movieIndex);
	
	
	ofxAVPlayer videoPlayer;
	

};
