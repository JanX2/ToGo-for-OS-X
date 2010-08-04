/*********************\
	Pairing Service
\*********************/

// Dependencies
#import <Foundation/Foundation.h>

// Forward Declarations
@class Server;
@class Connection;
@protocol PairingServiceDelegate;

// Pairing Step Constants
extern NSString * const FUPairingServerAuthPIN;
extern NSString * const FUPairingServerAuthPINValid;
extern NSString * const FUPairingServerAuthPINInvalid;
extern NSString * const FUPairingServerAuthReadyToReceivePairingInfo;
extern NSString * const FUPairingServerAuthPairingInfo;
extern NSString * const FUPairingServerAuthPairingDidSucceed;
extern NSString * const FUPairingServerAuthPairingDidFail;

@interface PairingService : Server
{
	// Backend
	Connection *pairingConnection;
	id <PairingServiceDelegate> pairingDelegate;
	
	// Data
	NSInteger pairingPIN;
	
	// Flags
	BOOL hostMode;
}

#pragma mark Properties
// Properties
@property (nonatomic, assign) Connection *pairingConnection;
@property (nonatomic, assign) id <PairingServiceDelegate> pairingDelegate;
@property (nonatomic) NSInteger pairingPIN;
@property (nonatomic) BOOL hostMode;

#pragma mark Setters
// Setters
-(void) setPairingConnection: (Connection *) thePairingConnection;

#pragma mark -
#pragma mark Server Management
/* Server Management *\
\*********************/

#pragma mark Setup
// Setup
-(BOOL) start;
-(void) stop;

#pragma mark PIN Management
// PIN Management
-(NSInteger) generateNewPIN;
-(BOOL) checkPIN: (NSInteger) pin;

#pragma mark -
#pragma mark Pairing Services
/* Pairing Services *\
\********************/

-(void) handlePairingMessage: (NSDictionary *) message;

@end

@protocol PairingServiceDelegate

@optional
-(void) pairingServiceDidPair: (PairingService *) pairingService;
-(void) pairingServiceDidFailToPair: (PairingService *) pairingService;

@end