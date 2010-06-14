/****************************************************\
	Abstract UIViewController Singleton Superclass
\****************************************************/

// Dependencies
#import <UIKit/UIKit.h>


@interface UIViewControllerSingleton : UIViewController 
{
	// Data
	
	// Flags
	@protected
	int tag;
}

#pragma mark Properties
// Properties
@property (nonatomic) int tag;

#pragma mark Instance Management
// Instance Management
+(id) allocF;
+(int) getAllocCount;
-(id) init;
+(id) sharedInstance;
-(void) dealloc;

#pragma mark Functions
// Functions
BOOL sharingClassesContain(Class theClass); 

@end
