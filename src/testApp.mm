#include "testApp.h"

//--------------------------------------------------------------
void testApp::setup(){	
	
	ofxiPhoneAlerts.addListener(this);
	ofxiPhoneSetOrientation(OFXIPHONE_ORIENTATION_LANDSCAPE_LEFT);
	
	videoPlayer.addURL( "movies/fingers.mov", false);
	
	videoPlayer.loadAssets();
			
	ofEnableAlphaBlending();

	ofRegisterTouchEvents(this);
	videoPlayer.show();
	ofxiPhoneSendGLViewToFront();
	
	ofSetBackgroundAuto(false);
	
	ofBackground(0, 0, 0, 0);
	ofxiPhoneGetGLView().layer.opaque=transparentLayer;
}
void testApp::movieEndListener(int movieIndex){
	videoPlayer.playNextMovie();
}
//--------------------------------------------------------------
void testApp::update(){	

}
//--------------------------------------------------------------
void testApp::draw(){	

	ofSetColor(255, 0, 0);
	
	ofFill();
	
	ofRect(100, 200, 400, 400);
	
}
//--------------------------------------------------------------
void testApp::touchDown(ofTouchEventArgs &touch){}
//--------------------------------------------------------------
void testApp::touchMoved(ofTouchEventArgs &touch){}
//--------------------------------------------------------------
void testApp::touchUp(ofTouchEventArgs &touch){}
//--------------------------------------------------------------
void testApp::touchDoubleTap(ofTouchEventArgs &touch){}
//--------------------------------------------------------------
void testApp::lostFocus(){}
//--------------------------------------------------------------
void testApp::gotFocus(){}
//--------------------------------------------------------------
void testApp::gotMemoryWarning(){}
//--------------------------------------------------------------
void testApp::deviceOrientationChanged(int newOrientation){}
//--------------------------------------------------------------
void testApp::touchCancelled(ofTouchEventArgs& args){}