/****************************************************\
	Abstract UIViewController Singleton Superclass
\****************************************************/

// Dependencies
#import "UIViewControllerSingleton.h"

// Globals
static int gAllocCount;
static id kSharedInstance;
static Class sharingClasses[100];

@implementation UIViewControllerSingleton

#pragma mark Properties
// Properties
@synthesize tag;

#pragma mark Instance Management
// Instance Management
+(id) allocF
{
	extern int gAllocCount;
	++gAllocCount;
	
	return [self alloc];
}

+(int) getAllocCount
{
	extern int gAllocCount;
	
	return gAllocCount;
}

-(id) init
{
	self = [super init];
	
	return self;
}

+(id) sharedInstance
{
	Class actingClass = [self class];
	
	id newInstance = kSharedInstance;
	
	if ( [UIViewControllerSingleton getAllocCount] == 0 || sharingClassesContain(actingClass) ) {
		
		extern int gAllocCount;
		
		sharingClasses[gAllocCount] = actingClass;
		
		newInstance = nil;
		
		newInstance = [[self allocF] init];
		
	}
	
	kSharedInstance = newInstance;
	
	return [kSharedInstance autorelease];
}

-(void) dealloc
{
	extern int gAllocCount;
	--gAllocCount;
	
	Class actingClass = [self class];
	
	for ( int i = 0; i < sizeof(sharingClasses); ++i ) {
		
		if ( sharingClasses[i] == actingClass )
			sharingClasses[i] == NULL;
		
	}
	
	if ( gAllocCount == 0 )	
		[super dealloc];
}

#pragma mark Functions
// Functions
BOOL sharingClassesContain(Class theClass)
{
	for ( int i = 0; i < sizeof(sharingClasses); ++i ) {
		
		if ( sharingClasses[i] == theClass )
			return TRUE;
		
	}
	
	return FALSE;
}

@end
