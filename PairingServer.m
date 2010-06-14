/********************\
	Pairing Server
\********************/

// Dependencies
#import "PairingService.h"

@implementation PairingService

#pragma mark Properties
// Properties
@synthesize pairingPIN;

#pragma mark Server Management
// Server Management
-(BOOL) start
{
	self.pairingPIN = [self generateNewPIN];
	
	return [super start];
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

@end