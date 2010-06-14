//
//  Functions.m
//  HopTo for Mac
//
//  Created by Drew R. Hood on 27.5.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Functions.h"


@implementation Functions

/*static OSStatus ExecuteAppleScriptEvent(const void* text,
										long textLength, AppleEvent *theEvent, AEDesc *resultData) {
    ComponentInstance theComponent;
    AEDesc scriptTextDesc;
    OSStatus err;
    OSAID contextID, resultID;
	
	// set up locals to a known state
    theComponent = NULL;
    AECreateDesc(typeNull, NULL, 0, &scriptTextDesc);
    contextID = kOSANullScript;
    resultID = kOSANullScript;
	
	// open the scripting component 
    theComponent = OpenDefaultComponent(kOSAComponentType,
										typeAppleScript);
    if (theComponent == NULL) { err = paramErr; goto bail; }
	
	//put the script text into a Apple event descriptor record
    err = AECreateDesc(typeChar, text, textLength, &scriptTextDesc);
    if (err != noErr) goto bail;
	
	// compile the script into a new context.  The flag
	 'kOSAModeCompileIntoContext' is used when compiling a
	 script containing a handler into a context. 
    err = OSACompile(theComponent, &scriptTextDesc,
					 kOSAModeCompileIntoContext, &contextID);
    if (err != noErr) goto bail;
	
	// run the script
    err = OSAExecuteEvent( theComponent, theEvent,
						  contextID, kOSAModeNull, &resultID);
	
	// collect the results - if any
    if (resultData != NULL) {
        AECreateDesc(typeNull, NULL, 0, resultData);
        if (err == errOSAScriptError) {
            OSAScriptError(theComponent, kOSAErrorMessage,
						   typeChar, resultData);
        } else if (err == noErr && resultID != kOSANullScript) {
            OSADisplay(theComponent, resultID, typeChar,
					   kOSAModeDisplayForHumans, resultData);
        }
    }
bail:
    AEDisposeDesc(&scriptTextDesc);
    if (contextID != kOSANullScript) OSADispose(theComponent, contextID);
    if (resultID != kOSANullScript) OSADispose(theComponent, resultID);
    if (theComponent != NULL) CloseComponent(theComponent);
    return err;
}*/

@end
