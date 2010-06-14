/*******************************\
	Pairing Window Controller
\*******************************/

// Dependencies
#import "Pairing_WindowController.h"

@implementation Pairing_WindowController

#pragma mark Properties
// Properties
@synthesize server;
@synthesize clients;
@synthesize hostMode;
@synthesize loadingView, servingView, remoteView;
@synthesize loadingLabel, pairingLabel, pairingInstructions, pairingCode, connectionInfo;
@synthesize loadingIndicator, connectionIndicator;

#pragma mark Instance Management
// Instance Management
-(id) init
{
	self = [self initWithWindowNibName: @"Pairing_WindowController"];
	
	return self;
}

-(void) dealloc
{
	NSLog(@"Pairing Window Controller deallocating!");
	
	[pairingLabel release];
	[pairingInstructions release];
	[pairingCode release];
	[connectionInfo release];
	[connectionIndicator release];
	[loadingIndicator release];
	[loadingLabel release];
	[loadingView release];
	[servingView release];
	[remoteView release];
	[server release];
	[clients release];
	
	[super dealloc];
}

#pragma mark Window Management
// Window Management
-(void) windowDidLoad
{
	NSLog(@"Pairing Window loaded!");
	
	// Spin the spinner.
	[connectionIndicator startAnimation: nil];
	
	// Set the font of the text.
	[pairingLabel setFont: [NSFont boldSystemFontOfSize: 18.0]];
	[pairingCode setFont: [NSFont boldSystemFontOfSize: 54.0]];
	
	[loadingView setHidden: TRUE];
	[servingView setHidden: FALSE];
	
	[self start];
	
	[pairingCode setStringValue: STRING_WITH_FORMAT(@"%d", server.pairingPIN)];
}

#pragma mark User Interaction Management
// User Interaction Mangement
-(IBAction) cancelAction: (id) sender
{
	[self stop];
	
	// Right now we'll just close the window.
	[self close];
}

-(IBAction) newPINAction: (id) sender
{
	[server generateNewPIN];
	
	[pairingCode setStringValue: STRING_WITH_FORMAT(@"%d", server.pairingPIN)];
}

#pragma mark -
#pragma mark Server Management
/* Server Management *\
\*********************/

#pragma mark Setup
// Setup
-(BOOL) start
{
	self.server = [[PairingService alloc] init];
	
	// Set the delegate.
	server.delegate = self;
	
	// Try to start.
	if ( ![server start] ) {
		
		self.server = nil;
		
		return NO;
		
	}
	
	self.clients = [NSMutableSet set];
	
	return YES;
}

-(void) stop
{
	[clients makeObjectsPerformSelector: @selector(close)];
	
	[server stop];
	
	self.server = nil;
	
	self.clients = nil;
}

#pragma mark Delegation
// Delegation
-(void) serverFailed: (Server *) theServer reason: (NSString *) reason
{
	NSLog(@"Pairing server failed: %@", reason);
	
	[self stop];
}

-(void) handleNewConnection: (Connection *) connection
{
	connection.delegate = self;
	
	[clients addObject: connection];
	
	server.pairingDelegate = self;
	server.pairingConnection = connection;
}

#pragma mark -
#pragma mark Connection Delegation
/* Connection Delegation *\
\*************************/

#pragma mark Setup
// Setup
-(void) connectionSucceeded: (Connection *) connection
{
	hostMode = TRUE;
}

-(void) connectionAttemptFailed: (Connection *) connection
{
	NSLog(@"Connection attempt failed!");
	
	return; // For now.
}

-(void) connectionTerminated: (Connection *) connection
{
	[clients removeObject: connection];
	
	if ( hostMode )
		hostMode = FALSE;
}

#pragma mark Data Flow
// Data Flow
-(void) receivedNetworkPacket: (NSDictionary *) message viaConnection: (Connection *) connection
{
	NSLog(@"Received packet: %@", message);
	
	[server handlePairingMessage: message];
}

@end