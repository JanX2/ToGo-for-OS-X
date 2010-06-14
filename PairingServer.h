/********************\
	Pairing Server
\********************/

// Dependencies
#import <Foundation/Foundation.h>

// Forward Declarations
@class Server;

// Constants
extern NSString * const FUPairingServerAuthPIN;
extern NSString * const FUPairingServerAuthPINValid;
extern NSString * const FUPairingServerAuthPINInvalid;
extern NSString * const FUPairingServerAuthReadyToReceivePairingInfo;
extern NSString * const FUPairingServerAuthPairingInfo;
extern NSString * const FUPairingServerAuthPairingDidSucceed;
extern NSString * const FUPairingServerAuthPairingDidFail;

@interface PairingServer : Server
{
	NSInteger pairingPIN;
}

#pragma mark Properties
// Properties
@property (nonatomic) NSInteger pairingPIN;

#pragma mark Server Management
// Server Management
-(BOOL) start;

#pragma mark PIN Management
// PIN Management
-(NSInteger) generateNewPIN;
-(BOOL) checkPIN: (NSInteger) pin;

@end