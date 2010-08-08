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
@dynamic preloadedURL;
@synthesize FUHTServices;

@synthesize urlText;
@synthesize connectionStatusMessage, deviceSearchMessage;
@synthesize connectionActive, searchingForDevices;

#pragma mark Instance Management
// Instance Management
-(id) init 
{
	self = [self initWithWindowNibName: @"SendURL_WindowController"];
	
	if (self) {
		self.urlText = @"";
		[self clean];
	}
	
	return self;
}

-(void) loadWindowWithURL: (NSString *) url;
{
	self.preloadedURL = url;
}

-(void) dealloc
{
	[finder release];
	[deviceConnection release];
	[preloadedURL release];
	[FUHTServices release];
	
	[urlText release];
	
	[super dealloc];
}

- (void) clean;
{
	self.connectionStatusMessage = @"";
	self.deviceSearchMessage = @"";
	connectionActive = NO;
	searchingForDevices = NO;
}

#pragma mark Window Management
// Window Management
- (void) windowDidLoad
{
}

- (IBAction)showWindow:(id)sender
{
	[self clean];
	
	// If there is no preloadedURL, set it again to refresh urlText
	if ( preloadedURL == nil ) {
		self.preloadedURL = nil;
	}
	
	// Start up the finder.
	self.finder = [[[ServerBrowser alloc] init] autorelease];
	finder.delegate = self;
	
	[finder startWithServiceType: FUServerBonjourTypeURL];
	
	// Order it front.
	[[self window] makeKeyAndOrderFront: self];
	
	// Activate the app.
	[[NSApplication sharedApplication] activateIgnoringOtherApps: YES];
	
	[super showWindow:sender];
}

- (void)close
{
	// Stop the Finder.
	[finder stop];
	
	[super close];
}


#pragma mark Accessors
- (NSString *)preloadedURL {
    return [[preloadedURL retain] autorelease];
}

- (void)setPreloadedURL:(NSString *)value {
    if (preloadedURL != value) {
        [preloadedURL release];
        preloadedURL = [value copy];
		
		// Set up the url text. We'll use either the preloaded URL, or the last NSString in the Pasteboard.
		if ( preloadedURL != nil ) {
			
			self.urlText = preloadedURL;
			
		} else {
			
			NSString *lastString = [[[NSPasteboard generalPasteboard] readObjectsForClasses: [ARRAY([NSString class]) autorelease] 
																					options: [NSDictionary dictionary]] objectAtIndex: 0];
			
			NSURL *testURL = [NSURL URLWithString: lastString];
			
			if ( testURL != nil )
				self.urlText = lastString;
			
		}
    }
}



#pragma mark User Interaction Management
// User Interaction Mangement
-(IBAction) cancelAction: (id) sender
{
	[self close];
}

-(IBAction) sendAction: (id) sender
{	
	self.connectionActive = YES;
	self.connectionStatusMessage = @"Checking things out...";
	
	// Get the index of the selected device.
	NSInteger selectedIndex = [serviceList indexOfSelectedItem];
	
	NSLog(@"%ld selected index", (long)selectedIndex);
	
	// Check that something is actually selected.
	if ( selectedIndex == -1 ) {
		
		self.connectionActive = NO;
		
		self.connectionStatusMessage = @"Please select a device!";
		
		return;
		
	}
	
	if ( urlText == nil || [self.urlText length] == 0 ) {
		
		self.connectionActive = NO;
		
		self.connectionStatusMessage = @"Please enter a URL!";
		
		return;
		
	}
	
	// Now get the Net Service.
	NSNetService *selectedDevice = [FUHTServices objectAtIndex: selectedIndex];
	
	NSLog(@"Selected device: %@", selectedDevice);
	
	// Create a Connection.
	[deviceConnection release]; // Harmless and necessary. There is no other place we an safely do this.
	self.deviceConnection = [[Connection alloc] initWithNetService: selectedDevice]; // If we were to switch from using the delegate mechanism to using notifications we could autorelease here.
	// The problem is that we have to release the Connection instance when we are done with it. 
	// We can’t do it in the methods called from it here (connectionSucceeded etc.), because control will then return to the (now released) instance thus crashing the app.  
	deviceConnection.delegate = self;
	
	NSLog(@"Connection: %@", deviceConnection);
	
	// Progress report.
	self.connectionStatusMessage = @"Establishing a connection...";
	
	// Connect.
	[deviceConnection connect];
	
	[self close];

}

#pragma mark -
#pragma mark Server Browser Delegation
/* Server Browser Delegation *\
\*****************************/

- (void) updateServerList
{
	self.FUHTServices = finder.servers;
	
	if ( [FUHTServices count] > 0 ) {
		
		self.deviceSearchMessage = STRING_WITH_FORMAT(@"%i device%@ found.", [FUHTServices count], ( [FUHTServices count] == 1 ) ? @"" : @"s");
		self.searchingForDevices = NO;
		
	} else {
		
		self.deviceSearchMessage = @"Looking for devices...";
		self.searchingForDevices = YES;
		
	}
	
	[serviceList reloadData];
	if ([self numberOfItemsInComboBox:serviceList] > 0) {
		[serviceList selectItemAtIndex:0];
		[serviceList setObjectValue:[self comboBox:serviceList objectValueForItemAtIndex:[serviceList indexOfSelectedItem]]];
	}
	
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
		self.connectionStatusMessage = @"Sending site...";
		
		NSDictionary *packet = DICTIONARY(urlText, @"url", DEVICE_NAME, @"sendingDeviceName");
		
		[connection sendNetworkPacket: packet];
		
		self.urlText = @"";
	}
}

-(void) connectionAttemptFailed: (Connection *) connection
{
	if ( connection == deviceConnection ) {
		
		static int failureCount = 0;
		
		if ( failureCount < 5 ) {
		
			// Report progress.
			self.connectionStatusMessage = @"Connection failed! Retrying...";
			
			// Set a timer to retry.
			[connection connect];
			
			failureCount += 1;
			
		} else {
			
			self.connectionStatusMessage = @"Could not connect. :(";
			
			self.connectionActive = NO;
			
		}
		
	}
}

-(void) connectionTerminated: (Connection *) connection
{
	// This is a successful connection, we'll assume.
	self.connectionStatusMessage = @"Success!";
	
	self.connectionActive = NO;
	
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
		
		NSDictionary *packet = DICTIONARY(urlText, @"url", DEVICE_NAME, @"sendingDeviceName");
		
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