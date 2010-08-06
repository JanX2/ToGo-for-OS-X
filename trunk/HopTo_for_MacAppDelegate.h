/*******************************\
	Main Application Delegate
\*******************************/

// Dependencies
#import <Cocoa/Cocoa.h>

// Forward Declarations
@class Pairing_WindowController;
@class SendURL_WindowController;
@class Server;
@class Connection;
@protocol ServerDelegate;
@protocol ConnectionDelegate;

@interface HopTo_for_MacAppDelegate : NSObject <NSApplicationDelegate, ServerDelegate, ConnectionDelegate> 
{
	// Backend
	Server *urlServer;
	NSMutableSet *urlClients;
	NSTimer *statusImg1, *statusImg2;
	
	// Data
	NSString *computerName, *modelID, *documentsDirectory, *appBundle;
	
	// Flags
	BOOL loginItem;
	
	// View
	NSStatusItem *statusItem;
	NSMenu *statusItemMenu;
	NSWindow *window;
	NSImage *statusItemBlink1, *statusItemBlink2;
}

#pragma mark Properties
// Properties
@property (nonatomic, retain) Server *urlServer;
@property (nonatomic, retain) NSMutableSet *urlClients;
@property (nonatomic, retain) NSTimer *statusImg1, *statusImg2;
@property (nonatomic, copy) NSString *computerName, *modelID, *appBundle, *documentsDirectory;
@property (nonatomic) BOOL loginItem;
@property (nonatomic, retain) NSStatusItem *statusItem;
@property (nonatomic, retain) IBOutlet NSMenu *statusItemMenu;
@property (nonatomic, retain) IBOutlet NSWindow *window;
@property (nonatomic, retain) NSImage *statusItemBlink1, *statusItemBlink2;

#pragma mark Instance Management
// Instance Management
-(void) dealloc;

#pragma mark View Management
// View Management
-(void) startAnimatingStatusItem;
-(void) stopAnimatingStatusItem;
-(void) setStatusItemImage: (NSTimer *) timer;

#pragma mark Application Lifecycle Management
// Application Lifecycle Management
-(void) applicationDidFinishLaunching: (NSNotification *) aNotification;
-(BOOL) applicationShouldTerminate: (NSApplication *) sender;
-(void) applicationWillTerminate: (NSNotification *) notification;
-(void) handleURLEvent: (NSAppleEventDescriptor *) urlEvent;

#pragma mark Login Startup Management
// Login Startup Management
-(void) addLoginItem;
-(BOOL) determineLoginItemStatus;
-(void) removeLoginItem;

#pragma mark User Interaction Management
// User Interaction Management
-(IBAction) pairingAction: (id) sender;
-(IBAction) sendURLAction: (id) sender;

#pragma mark -
#pragma mark URL Server Delegation
/* URL Server Delegation *\
\*************************/

-(void) serverDidStart: (Server *) server;
-(void) serverFailed: (Server *) server reason: (NSString *) reason;
-(void) serverDidStop: (Server *) server;
-(void) handleNewConnection: (Connection *) connection;

#pragma mark -
#pragma mark URL Connections Delegation
/* URL Connections Delegation *\
\******************************/

#pragma mark Setup
// Setup
-(void) connectionSucceeded: (Connection *) connection;
-(void) connectionAttemptFailed: (Connection *) connection;
-(void) connectionTerminated: (Connection *) connection;

#pragma mark Data Flow
// Data Flow
-(void) receivedNetworkPacket: (NSDictionary *) message viaConnection: (Connection *) connection;

@end