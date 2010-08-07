/********************************\
	Send URL Window Controller
\********************************/

// Dependencies
#import <Cocoa/Cocoa.h>

// Forward Declarations
@class ServerBrowser;
@class Connection;
@protocol ServerBrowserDelegate;
@protocol ConnectionDelegate;

@interface SendURL_WindowController : NSWindowController 
<
#ifdef OS_X_6
NSComboBoxDataSource, 
#endif
ServerBrowserDelegate, ConnectionDelegate>
{
	// Backend
	ServerBrowser *finder;
	Connection *deviceConnection;
	
	// Data
	NSString *preloadedURL;
	NSArray *FUHTServices;
	
	// View
	NSTextField *urlField, *connectionStatus, *deviceSearch;
	NSComboBox *serviceList;
	NSProgressIndicator *connectionIndicator, *deviceIndicator;
}

#pragma mark Properties
// Properties
@property (nonatomic, retain) ServerBrowser *finder;
@property (nonatomic, retain) Connection *deviceConnection;
@property (nonatomic, copy) NSString *preloadedURL;
@property (nonatomic, retain) NSArray *FUHTServices;
@property (nonatomic, retain) IBOutlet NSTextField *urlField, *connectionStatus, *deviceSearch;
@property (nonatomic, retain) IBOutlet NSComboBox *serviceList;
@property (nonatomic, retain) IBOutlet NSProgressIndicator *connectionIndicator, *deviceIndicator;

#pragma mark Instance Management
// Instance Management
-(void) loadWindowWithURL: (NSString *) url;
-(void) dealloc;

#pragma mark Window Management
// Window Management
-(void) windowDidLoad;

#pragma mark User Interaction Management
// User Interaction Mangement
-(IBAction) cancelAction: (id) sender;
-(IBAction) sendAction: (id) sender;

#pragma mark -
#pragma mark Server Browser Delegation
/* Server Browser Delegation *\
\*****************************/

-(void) updateServerList;

#pragma mark -
#pragma mark Connection Delegation
/* Connection Delegation *\
\*************************/

#pragma mark Setup
// Setup
-(void) connectionSucceeded: (Connection *) connection;
-(void) connectionAttemptFailed: (Connection *) connection;
-(void) connectionTerminated: (Connection *) connection;

#pragma mark Data Flow
// Data Flow
-(void) receivedNetworkPacket: (NSDictionary *) message viaConnection: (Connection *) connection;

#pragma mark -
#pragma mark Combo Box Management
/* Combo Box Management *\
\************************/

-(NSInteger) numberOfItemsInComboBox: (NSComboBox *) aComboBox;
-(id) comboBox: (NSComboBox *) aComboBox objectValueForItemAtIndex: (NSInteger) index;

@end