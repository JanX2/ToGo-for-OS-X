/********************************\
	Send URL Window Controller
\********************************/

// Dependencies
#import "SendURL_WindowController.h"

@implementation SendURL_WindowController

#pragma mark Properties
// Properties
@synthesize finder;
@synthesize deviceConnection;
@synthesize preloadedURL;
@synthesize FUHTServices;
@synthesize urlField, connectionStatus, deviceSearch;
@synthesize serviceList;
@synthesize connectionIndicator, deviceIndicator;

#pragma mark Instance Management
// Instance Management
-(id) init 
{
	self = [self initWithWindowNibName: @"SendURL_WindowController"];
	
	return self;
}

-(void) loadWindowWithURL: (NSString *) url
{
	self.preloadedURL = url;
}

-(void) dealloc
{
	[finder release];
	[deviceConnection release];
	[preloadedURL release];
	[FUHTServices release];
	[urlField release];
	[connectionStatus release];
	[deviceSearch release];
	[serviceList release];
	[connectionIndicator release];
	[deviceIndicator release];
	
	[super dealloc];
}

#pragma mark Window Management
// Window Management
-(void) windowDidLoad
{
	// Set up the url field. We'll use either the preloaded URL, or the last NSString in the Pasteboard.
	if ( preloadedURL != nil ) {
		
		[urlField setStringValue: preloadedURL];
		
	} else {
		
		NSString *lastString = [[[NSPasteboard generalPasteboard] readObjectsForClasses: ARRAY([NSString class]) 
																				options: [NSDictionary dictionary]] objectAtIndex: 0];
		
		NSURL *testURL = [NSURL URLWithString: lastString];
		
		if ( testURL != nil )
			[urlField setStringValue: lastString];
		else 
			[urlField setStringValue: @""];
		
	}
	
	// Start up the Finder.
	self.finder = [[ServerBrowser alloc] init];
	finder.delegate = self;
	
	[finder startWithServiceType: FUServerBonjourTypeURL];
}

#pragma mark User Interaction Management
// User Interaction Mangement
-(IBAction) cancelAction: (id) sender
{
	// Stop the Finder.
	[finder stop];
	
	[self close];
	
	[[NSApplication sharedApplication] stopModal];
}

-(IBAction) sendAction: (id) sender
{	
	[connectionIndicator startAnimation: self];
	[connectionStatus setStringValue: @"Checking things out..."];
	
	// Get the index of the selected device.
	NSInteger selectedIndex = [serviceList indexOfSelectedItem];
	
	NSLog(@"%i selected index", selectedIndex);
	
	// Check that something is actually selected.
	if ( selectedIndex == -1 ) {
		
		[connectionIndicator stopAnimation: self];
		
		[connectionStatus setStringValue: @"Please select a device!"];
		
		return;
		
	}
	
	if ( [urlField stringValue] == nil ) {
		
		[connectionIndicator stopAnimation: self];
		
		[connectionStatus setStringValue: @"Please enter a URL!"];
		
		return;
		
	}
	
	// Now get the Net Service.
	NSNetService *selectedDevice = [FUHTServices objectAtIndex: selectedIndex];
	
	NSLog(@"Selected device: %@", selectedDevice);
	
	// Create a Connection.
	self.deviceConnection = [[Connection alloc] initWithNetService: selectedDevice];
	deviceConnection.delegate = self;
	
	NSLog(@"Connection: %@", deviceConnection);
	
	// Progress report.
	[connectionStatus setStringValue: @"Establishing a connection..."];
	[connectionStatus setHidden: NO];
	
	// Connect.
	[deviceConnection connect];
}

#pragma mark -
#pragma mark Server Browser Delegation
/* Server Browser Delegation *\
\*****************************/

-(void) updateServerList
{
	self.FUHTServices = finder.servers;
	
	if ( [FUHTServices count] > 0 ) {
		
		[deviceSearch setStringValue: STRING_WITH_FORMAT(@"%i device%@ found.", [FUHTServices count], ( [FUHTServices count] == 1 ) ? @"" : @"s")];
		[deviceIndicator stopAnimation: self];
		
	} else {
		
		[deviceSearch setStringValue: @"Looking for devices..."];
		[deviceIndicator startAnimation: self];
		
	}

	
	[serviceList reloadData];
}

#pragma mark -
#pragma mark Connection Delegation
/* Connection Delegation *\
\*************************/

#pragma mark Setup
// Setup
-(void) connectionSucceeded: (Connection *) connection
{
	NSLog(@"Connection in delegate: %@", [connection description]);
	
	if ( connection == deviceConnection ) {
		
		// Report progress.
		[connectionStatus setStringValue: @"Sending site..."];
		
		NSDictionary *packet = DICTIONARY([urlField stringValue], @"url", DEVICE_NAME, @"sendingDeviceName");
		
		[connection sendNetworkPacket: packet];
		
	}
}

-(void) connectionAttemptFailed: (Connection *) connection
{
	if ( connection == deviceConnection ) {
		
		static int failureCount = 0;
		
		if ( failureCount < 5 ) {
		
			// Report progress.
			[connectionStatus setStringValue: @"Connection failed! Retrying..."];
			
			// Set a timer to retry.
			[connection connect];
			
			failureCount += 1;
			
		} else {
			
			[connectionStatus setStringValue: @"Could not connect. :("];
			
			[connectionIndicator stopAnimation: self];
			
		}
		
	}
}

-(void) connectionTerminated: (Connection *) connection
{
	// This is a successful connection, we'll assume.
	[connectionStatus setStringValue: @"Success!"];
	
	[connectionIndicator stopAnimation: self];
	
	self.deviceConnection = nil;
	
	[[NSApplication sharedApplication] stopModal];
	
	// Everything went well, so close the window.
	[self close]; // [self performSelector: @selector(close) withObject: nil afterDelay: 2.0];
}

#pragma mark Data Flow
// Data Flow
-(void) receivedNetworkPacket: (NSDictionary *) message viaConnection: (Connection *) connection
{
	NSLog(@"Received Packet: %@", message);
	
	if ( BOOLVALUE([message objectForKey: @"didReceiveURL"]) )
		[deviceConnection close];
	else {
		
		NSDictionary *packet = DICTIONARY([urlField stringValue], @"url", DEVICE_NAME, @"sendingDeviceName");
		
		[connection sendNetworkPacket: packet];
		
	}
		
}

#pragma mark -
#pragma mark Combo Box Management
/* Combo Box Management *\
\************************/

-(NSInteger) numberOfItemsInComboBox: (NSComboBox *) aComboBox
{
	return [FUHTServices count];
}

-(id) comboBox: (NSComboBox *) aComboBox objectValueForItemAtIndex: (NSInteger) index
{
	return [[FUHTServices objectAtIndex: index] name];
}

@end