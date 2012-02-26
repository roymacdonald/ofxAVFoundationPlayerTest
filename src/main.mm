#include "ofMain.h"
#include "testApp.h"

int main(){
	ofSetLogLevel(OF_LOG_VERBOSE);
	ofSetupOpenGL( 1024, 768, OF_FULLSCREEN);		// <-------- setup the GL context
	ofRunApp(new testApp);
}
