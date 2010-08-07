/*******************************\
	Main Application Delegate
\*******************************/

// Dependencies
#import "HopTo_for_MacAppDelegate.h"

@implementation HopTo_for_MacAppDelegate

#pragma mark Properties
// Properties
@synthesize urlServer;
@synthesize urlClients;
@synthesize statusImg1, statusImg2;
@synthesize computerName, appBundle, documentsDirectory;
@synthesize loginItem;
@synthesize statusItem;
@synthesize statusItemMenu;
@synthesize statusItemBlink1, statusItemBlink2;
@synthesize window;

#pragma mark Instance Management
// Instance Management
-(void) dealloc
{
	[urlServer release];
	[urlClients release];
	[statusImg1 release];
	[statusImg2 release];
	[computerName release];
	[appBundle release];
	[documentsDirectory release];
	[statusItem release];
	[statusItemMenu release];
	[statusItemBlink1 release];
	[statusItemBlink2 release];
	[window release];
	
	[super dealloc];
}

#pragma mark View Management
// View Management
-(void) startAnimatingStatusItem
{
	// First set up the timers.
	self.statusImg1 = [[NSTimer alloc] initWithFireDate: [NSDate date] interval: 0.5
												 target: self selector: @selector(setStatusItemImage:) 
											   userInfo: statusItemBlink1 repeats: YES];
	self.statusImg2 = [[NSTimer alloc] initWithFireDate: [NSDate dateWithTimeIntervalSinceNow: 0.25] interval: 0.5 
												target: self selector: @selector(setStatusItemImage:) 
											  userInfo: statusItemBlink2 repeats: YES];
	
	// Add them to the run loop.
	[[NSRunLoop currentRunLoop] addTimer: statusImg1 forMode: NSDefaultRunLoopMode];
	[[NSRunLoop currentRunLoop] addTimer: statusImg2 forMode: NSDefaultRunLoopMode];
}

-(void) stopAnimatingStatusItem
{
	// Kill the timers.
	[statusImg1 invalidate];
	[statusImg2 invalidate];
	
	// Clear them.
	self.statusImg1 = nil;
	self.statusImg2 = nil;
	
	[statusItem setImage: [NSImage imageNamed: @"Status Icon.png"]];
}

-(void) setStatusItemImage: (NSTimer *) timer
{
	[statusItem setImage: [timer userInfo]];
}

#pragma mark Application Lifecycle Management
// Application Lifecycle Management
-(void) applicationDidFinishLaunching: (NSNotification *) aNotification
{
	NSLog(@"Welcome to HopTo for Mac!");
	
	// Set up the URL Launch Responder.
	[[NSAppleEventManager sharedAppleEventManager] setEventHandler: self andSelector: @selector(handleURLEvent:) 
													 forEventClass: kInternetEventClass andEventID: kAEGetURL];
	
	// Get the computer name.
	CFStringRef scComputerName = SCDynamicStoreCopyComputerName(NULL, NULL);
	self.computerName = STRING((NSString *)scComputerName);
	CFMakeCollectable(scComputerName);
	CFRelease(scComputerName);
	
	// Set the file directories.
	self.appBundle = [[NSBundle mainBundle] bundlePath];
	self.documentsDirectory = self.appBundle;
	
	// Set up the Status Item.
	self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength: NSVariableStatusItemLength];
	
	//[statusItem setTitle: @"HopTo"];
	[statusItem setImage: [NSImage imageNamed: @"Status Icon.png"]];
	[statusItem setHighlightMode: YES];
	[statusItem setMenu: statusItemMenu];
	
	// Set the images for the blink effect.
	self.statusItemBlink1 = [NSImage imageNamed: @"Status Icon Blink 1.png"];
	self.statusItemBlink2 = [NSImage imageNamed: @"Status Icon Blink 2.png"];
	
	// Start up the URL Server.
	self.urlServer = [[Server alloc] init];
	urlServer.delegate = self;
	urlServer.serviceType = FUServerBonjourTypeURL;
	
	if ( ![urlServer start] ) {
		
		self.urlServer = nil;
		
		NSLog(@"URL Server failed to start!");
		
	}
	
	// Set up the login item.
	//[self addLoginItem];
	//[self determineLoginItemStatus];
	
	//NSLog(@"Login item: %i", (int) self.loginItem);
}

-(BOOL) applicationShouldTerminate: (NSApplication *) sender
{
	return YES;
}

-(void) applicationWillTerminate: (NSNotification *) notification
{
	return;
}

-(void) handleURLEvent: (NSAppleEventDescriptor *) urlEvent
{
	// Get the url.
	NSString *urlStr = [[urlEvent paramDescriptorForKeyword: keyDirectObject] stringValue];
	
	//NSURL *urlObj = [NSURL URLWithString: urlStr];
	
	NSString *urlSource = [urlStr stringByReplacingOccurrencesOfString: @"togo://send/?url=" withString: @""];
	
	//NSMutableDictionary *url = [[urlObj query] explodeToDictionaryInnerGlue: @"=" outterGlue: @"&"];
	
	NSString *explodedURL = [urlSource stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
	
	// Now open it in a send dialogue.
	SendURL_WindowController *sendURL = [[SendURL_WindowController new] autorelease];
	sendURL.preloadedURL = explodedURL;
	
	[[NSApplication sharedApplication] runModalForWindow: [sendURL window]];
}

#pragma mark Login Startup Management
// Login Startup Management
-(void) addLoginItem
{
	// Put together the AppleScript text.
	//NSString *script = STRING_WITH_FORMAT(@"tell application \"System Events\"\
										  make new login item at end \
										  with properties {path:\"%@\", hidden:false}\
										  end tell", appBundle);
	
	// Now execute the script.
	//ExecuteAppleScriptEvent(script, sizeof(script), NULL, NULL);
}

-(BOOL) determineLoginItemStatus
{
	return NO;
}

-(void) removeLoginItem
{
	
}

#pragma mark User Interaction Management
// User Interaction Management
-(IBAction) pairingAction: (id) sender
{
	// Set up a window.
	Pairing_WindowController *pairingWindow = [[[Pairing_WindowController alloc] init] autorelease];
	
	// Order it front.
	[[pairingWindow window] makeKeyAndOrderFront: self];
	
	// Activate the app.
	[[NSApplication sharedApplication] activateIgnoringOtherApps: YES];
}

-(IBAction) sendURLAction: (id) sender
{
	SendURL_WindowController *sendURL = [[SendURL_WindowController new] autorelease];
	
	[[NSApplication sharedApplication] runModalForWindow: [sendURL window]];
}

#pragma mark -
#pragma mark URL Server Delegation
/* URL Server Delegation *\
\*************************/

-(void) serverDidStart: (Server *) server
{
	self.urlClients = [NSMutableSet set];
	
	NSLog(@"Server started!");
}

-(void) serverFailed: (Server *) server reason: (NSString *) reason
{
	self.urlClients = nil;
	
	NSLog(@"Server failed: %@", reason);	
}

-(void) serverDidStop: (Server *) server
{
	self.urlClients = nil;
	
	NSLog(@"Server stopped!");
}

-(void) handleNewConnection: (Connection *) connection
{
	connection.delegate = self;
	
	[urlClients addObject: connection];
}

#pragma mark -
#pragma mark URL Connections Delegation
/* URL Connections Delegation *\
\******************************/

#pragma mark Setup
// Setup
-(void) connectionSucceeded: (Connection *) connection
{
	[self performSelectorOnMainThread: @selector(startAnimatingStatusItem) withObject: nil waitUntilDone: YES];
	
	NSLog(@"Connection established!");
}

-(void) connectionAttemptFailed: (Connection *) connection
{
	[self performSelectorOnMainThread: @selector(stopAnimatingStatusItem) withObject: nil waitUntilDone: YES];
	
	[urlClients removeObject: connection];
	
	NSLog(@"Connection attempt failed!");
}

-(void) connectionTerminated: (Connection *) connection
{
	[self performSelectorOnMainThread: @selector(stopAnimatingStatusItem) withObject: nil waitUntilDone: YES];
	
	[urlClients removeObject: connection];
	
	NSLog(@"Connection terminated!");
}

#pragma mark Data Flow
// Data Flow
-(void) receivedNetworkPacket: (NSDictionary *) message viaConnection: (Connection *) connection
{
	NSLog(@"Received Packet: %@", message);
	
	// First thing we'll do is create a URL object with the string. This will tell us
	// if it's usable or not.
	NSURL *url = [NSURL URLWithString: [message objectForKey: @"url"]];
	
	// If it's messed up, we'll simply return to sender.
	if ( url == nil ) {
		
		[connection performSelectorOnMainThread: @selector(sendNetworkPacket:) 
									 withObject: DICTIONARY(BOOLOBJ(NO), @"didReceiveURL", DEVICE_NAME, @"sendingDeviceName") 
								  waitUntilDone: YES];
		
		return;
		
	}
	
	[connection performSelectorOnMainThread: @selector(sendNetworkPacket:) 
								 withObject: DICTIONARY(BOOLOBJ(YES), @"didReceiveURL", DEVICE_NAME, @"sendingDeviceName") 
							  waitUntilDone: YES];
	
	// Get the strings.
	NSString *urlStr = [message objectForKey: @"url"];
	NSString *from = [message objectForKey: @"sendingDeviceName"];
	
	// Send it off to the URL manager.
	[[FUURLManager sharedManager] addURL: urlStr from: from];
	
	// Prompt the user. 
	NSAlert *urlAlert = [NSAlert alertWithMessageText: STRING_WITH_FORMAT(@"A website has been sent to you by %@. Would you like to open it now?", from) 
										defaultButton: @"Open" alternateButton: @"Cancel" otherButton: nil informativeTextWithFormat: @"%@", urlStr];
	
	[urlAlert setAlertStyle: NSInformationalAlertStyle];
	[urlAlert setIcon: [NSImage imageNamed: @"Icon.icns"]];
	
	[[NSApplication sharedApplication] activateIgnoringOtherApps: YES];
	
	NSInteger response = [urlAlert runModal];
	
	if ( response == 1 ) {
		
		[[FUURLManager sharedManager] openURL: [[FUURLManager sharedManager] currentURL]];
		
	}
}

@end