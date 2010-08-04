/*********************\
	Pairing Service
\*********************/

// Dependencies
#import "PairingService.h"

// Pairing Step Constants
NSString * const FUPairingServerAuthPIN = @"FUPairingServerAuthPIN";
NSString * const FUPairingServerAuthPINValid = @"FUPairingServerAuthPINValid";
NSString * const FUPairingServerAuthPINInvalid = @"FUPairingServerAuthPINInvalid";
NSString * const FUPairingServerAuthReadyToReceivePairingInfo = @"FUPairingServerAuthReadyToReceivePairingInfo";
NSString * const FUPairingServerAuthPairingInfo = @"FUPairingServerAuthPairingInfo";
NSString * const FUPairingServerAuthPairingDidSucceed = @"FUPairingServerAuthPairingDidSucceed";
NSString * const FUPairingServerAuthPairingDidFail = @"FUPairingServerAuthPairingDidFail";

#pragma mark -
#pragma mark Pairing Service Private Interface
/* Pairing Service Private Interface *\
\*************************************/
@interface PairingService ()

#pragma mark Pairing Service Extended

#pragma mark Host Mode
// Pairing Services -- Host Mode
-(void) respondToPairingPINMessage: (NSDictionary *) message;
-(void) respondToPairingInfo: (NSDictionary *) message;

#pragma mark Remote Mode
// Pairing Services -- Remote Mode
-(void) respondToPairingPINValidationMessage: (NSDictionary *) message;

#pragma mark Data Trade
// Pairing Services -- Data Trade
-(void) sendPairingInfo;

@end

#pragma mark -
#pragma mark Pairing Service Implementation
/* Pairing Service Implementation *\
\**********************************/
@implementation PairingService

#pragma mark Properties
// Properties
@synthesize pairingConnection;
@synthesize pairingDelegate;
@synthesize pairingPIN;
@synthesize hostMode;

#pragma mark Setters
// Setters
-(void) setPairingConnection: (Connection *) thePairingConnection
{
	pairingConnection = thePairingConnection;
	
	if ( thePairingConnection != nil )
		self.hostMode = TRUE;
}

#pragma mark -
#pragma mark Server Management
/* Server Management *\
\*********************/

#pragma mark Setup
// Setup
-(BOOL) start
{
	self.pairingPIN = [self generateNewPIN];
	self.serviceType = FUServerBonjourTypePairing;
	
	return [super start];
}

-(void) stop
{
	return [super stop];
}

#pragma mark PIN Management
// PIN Management
-(NSInteger) generateNewPIN
{
	// Be absolutely sure we have a 4 digit number.
	int pin = random() % 10;
	
	if ( pin == 0 ) 
		pin = 1;
	
	for ( int i = 0; i < 3; ++i ) {
		
		pin *= 10;
		pin += random() % 10;
		
	}
	
	NSLog(@"Pairing server generated new pin: %d", pin);
	
	self.pairingPIN = pin;
	
	return pin;
}

-(BOOL) checkPIN: (NSInteger) pin
{
	if ( pin == self.pairingPIN )
		return YES;
	
	return NO;
}

#pragma mark -
#pragma mark Pairing Services
/* Pairing Services *\
\********************/

-(void) handlePairingMessage: (NSDictionary *) message
{
	// First we'll need to get the header of the message. 
	NSString *header = [message objectForKey: @"header"];
	
	if ( hostMode ) {
		
		if ( header == FUPairingServerAuthPIN )
			[self respondToPairingPINMessage: message];
		else if ( header == FUPairingServerAuthPairingInfo )
			[self respondToPairingInfo: message];
		
	} else {
		
		if ( header == FUPairingServerAuthPINValid || header == FUPairingServerAuthPINInvalid )
			[self respondToPairingPINValidationMessage: message];
		
	}
}

#pragma mark Host Mode
// Pairing Services -- Host Mode
-(void) respondToPairingPINMessage: (NSDictionary *) message
{
	// We're supposed to validate this PIN, so get it first.
	int pinForValidation = INTVALUE([message objectForKey: @"message"]);
	
	// Now validate.
	BOOL pinValid = [self checkPIN: (NSInteger) pinForValidation];
	
	// Send the proper message.
	if ( !pinValid ) {
		
		NSDictionary *response = DICTIONARY(FUPairingServerAuthPINInvalid, @"header", NSNULL, @"message", NSNULL, @"user");
		
		[pairingConnection sendNetworkPacket: response];
		
	} else {
		
		NSDictionary *response = DICTIONARY(FUPairingServerAuthPINValid, @"header", NSNULL, @"message", NSNULL, @"user");
		
		[pairingConnection sendNetworkPacket: response];
		
	}
}

-(void) respondToPairingInfo: (NSDictionary *) message
{
	
}

#pragma mark Remote Mode
// Pairing Services -- Remote Mode
-(void) respondToPairingPINValidationMessage: (NSDictionary *) message
{
	
}

#pragma mark Data Trade
// Pairing Services -- Data Trade
-(void) sendPairingInfo
{
	
}

@end