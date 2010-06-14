/*******************************\
	Pairing Window Controller
\*******************************/

// Dependencies
#import <Cocoa/Cocoa.h>

// Forward Declarations
@class PairingService;
@class Server;
@class Connection;
@protocol ServerDelegate;
@protocol ConnectionDelegate;

@interface Pairing_WindowController : NSWindowController <ServerDelegate, ConnectionDelegate>
{
	// Backend.
	PairingService *server;
	NSMutableSet *clients;
	
	// Flags
	BOOL hostMode;
	
	// View
	NSView *loadingView, *servingView, *remoteView;
	NSTextField *loadingLabel, *pairingLabel, *pairingInstructions, *pairingCode, *connectionInfo;
	NSProgressIndicator *loadingIndicator, *connectionIndicator;
}

#pragma mark Properties
// Properties
@property (nonatomic, retain) PairingService *server;
@property (nonatomic, retain) NSMutableSet *clients;
@property (nonatomic) BOOL hostMode;
@property (nonatomic, retain) IBOutlet NSView *loadingView, *servingView, *remoteView;
@property (nonatomic, retain) IBOutlet NSTextField *loadingLabel, *pairingLabel, *pairingInstructions, *pairingCode, *connectionInfo;
@property (nonatomic, retain) IBOutlet NSProgressIndicator *loadingIndicator, *connectionIndicator;

#pragma mark Instance Management
// Instance Management
-(id) init;
-(void) dealloc;

#pragma mark Window Management
// Window Management
-(void) windowDidLoad;

#pragma mark User Interaction Management
// User Interaction Mangement
-(IBAction) cancelAction: (id) sender;
-(IBAction) newPINAction: (id) sender;

#pragma mark -
#pragma mark Server Management
/* Server Management *\
\*********************/

#pragma mark Setup
// Setup
-(BOOL) start;
-(void) stop;

#pragma mark Delegation
// Delegation
-(void) serverFailed: (Server *) theServer reason: (NSString *) reason;
-(void) handleNewConnection: (Connection *) connection;

#pragma mark -
#pragma mark Connection Delegation
/* Connection Delegation *\
\*************************/

#pragma mark Setup
// Setup
-(void) connectionAttemptFailed: (Connection *) connection;
-(void) connectionTerminated: (Connection *) connection;

#pragma mark Data Flow
// Data Flow
-(void) receivedNetworkPacket: (NSDictionary *) message viaConnection: (Connection *) connection;

@end