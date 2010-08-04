/*****************\
	URL Manager
\*****************/

// Dependencies
#import "FUURLManager.h"

#pragma mark Constants
// Constants
NSString * const FUURLManagerCurrentURLDidChangeNotification = @"FUURLManagerCurrentURLDidChangeNotification";
NSString * const FUURLManagerURLListDidChangeNotification = @"FUURLManagerURLListDidChangeNotification";
NSString * const FUURLManagerWillOpenURLNotification = @"FUURLManagerWillOpenURLNotification";

#pragma mark Globals
// Globals
static FUURLManager *kSharedManager;

@implementation FUURLManager

#pragma mark Properties
// Properties
@synthesize currentURL;
@synthesize urlList;

#pragma mark Instance Management
// Instance Management
+(id) allocWithZone: (NSZone *) zone
{
 	return [[self sharedManager] retain];
}

-(id) init
{
	self = [super init];
	
	if ( self ) {
		
		self.urlList = [NSMutableArray arrayWithContentsOfFile: [DOCUMENTS_DIRECTORY stringByAppendingPathComponent: @"urls.plist"]];
		
		if ( !urlList || [urlList count] == 0 )
			self.urlList = [NSMutableArray array];
		else 
			self.currentURL = [urlList objectAtIndex: 0];
		
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(updateCurrentURL) 
													 name: FUURLManagerCurrentURLDidChangeNotification object: self];
		
	}
	
	return self;
}

+(FUURLManager *) sharedManager
{
	if ( !kSharedManager )
		kSharedManager = [[super allocWithZone: NULL] init];
	
	return [kSharedManager autorelease];
}

-(id) retain
{
	return kSharedManager;
}

-(void) release
{
	return;
}

-(id) copyWithZone: (NSZone *) zone
{
	return kSharedManager;
}

-(void) dealloc
{
	[self performSelector: @selector(saveDown) onThread: [NSThread currentThread] withObject: nil waitUntilDone: YES];
	
	[currentURL release];
	[urlList release];
	
	[super dealloc];
}

#pragma mark Variable Management
// Variable Management
-(void) setCurrentURL: (NSMutableDictionary *) url
{
	[currentURL release];
	currentURL = nil;
	
	currentURL = [url retain];
	
	[[NSNotificationCenter defaultCenter] postNotificationName: FUURLManagerCurrentURLDidChangeNotification object: currentURL];
}

-(NSMutableDictionary *) currentURL
{
	[self updateCurrentURL];
	
	return currentURL;
}

#pragma mark Opening URLs
// Opening URLs
-(void) openURL: (NSDictionary *) url
{
	// Get the url string.
	NSString *urlStr = [url objectForKey: @"url"];
	
	// Put it together for use.
	NSURL *urlObj = [NSURL URLWithString: urlStr];
	
	// Make sure it's not broken. If we're good, tell everyone, if not, abort.
	if ( urlObj ) 
		[[NSNotificationCenter defaultCenter] postNotificationName: FUURLManagerWillOpenURLNotification object: urlObj];
	else
		return;

	// Do it.
	[[NSWorkspace sharedWorkspace] openURL: urlObj];
}

#pragma mark URL Queries
// URL Queries
-(NSDictionary *) URLAtIndex: (NSInteger) index
{
	if ( [urlList count] > index )
		return [urlList objectAtIndex: index];
	
	return nil;
}

#pragma mark Data Control
// Data Control
-(NSMutableDictionary *) fetchMetadataForURL: (NSString *) theURL
{
	// Set up a URL request to the Fappulous app hub.
	NSURL *url = [NSURL URLWithString: STRING_WITH_FORMAT(@"http://fappulo.us/apps_backend/HopTo/websiteMeta.php?url=%@", theURL)];
	
	// Now get the metadata.
	NSMutableDictionary *metaData = [NSMutableDictionary dictionaryWithContentsOfURL: url];
	
	// Set up the base dictionary.
	NSMutableDictionary *urlDict = [NSMutableDictionary dictionary];
	
	if ( [metaData objectForKey: @"title"] == nil ) 
		[urlDict setObject: @"" forKey: @"title"];
	else 
		[urlDict setObject: [metaData objectForKey: @"title"] forKey: @"title"];
	
	if ( [metaData objectForKey: @"description"] == nil )
		[urlDict setObject: @"" forKey: @"description"];
	else 
		[urlDict setObject: [metaData objectForKey: @"description"] forKey: @"description"];
	
	metaData = nil;
	
	return urlDict;
}

-(void) updateCurrentURL
{
	// Make sure there's something there.
	if ( [urlList count] > 0 ) {
		
		if ( [urlList objectAtIndex: 0] != currentURL ) {
			
			self.currentURL = [urlList objectAtIndex: 0];
			
		}
		
	} else if ( currentURL != nil ) {
		
		// If there's nothing there, then the url should be empty.
		self.currentURL = nil;
		
	}
}

-(NSDictionary *) addURL: (NSString *) url from: (NSString *) nameOfDevice
{
	// Get the info set up in a dictionary.
	NSMutableDictionary *urlDict = [self fetchMetadataForURL: url];
	
	[urlDict setObject: url forKey: @"url"];
	[urlDict setObject: nameOfDevice forKey: @"sendingDeviceName"];
	
	// Add it at the beginning of the array.
	if ( [urlList count] > 0 ) 
		[urlList insertObject: urlDict atIndex: 0];
	else 
		[urlList addObject: urlDict];
	
	// We'll only hang on to the last 100.
	if ( [urlList count] > 100 ) 
		[urlList removeLastObject];
	
	[self saveDown];
	
	// Tell everyone what's just happened.
	[[NSNotificationCenter defaultCenter] postNotificationName: FUURLManagerCurrentURLDidChangeNotification object: self];
	[[NSNotificationCenter defaultCenter] postNotificationName: FUURLManagerURLListDidChangeNotification object: self];
	
	// Return the new dictionary.
	return self.currentURL;
}

-(void) removeURLAtIndex: (NSInteger) index
{
	if ( [urlList count] > index ) {
		
		// Delete it.
		[urlList removeObjectAtIndex: index];
		
		// Save.
		[self saveDown];
		
		// Tell everyone what's just happened.
		[[NSNotificationCenter defaultCenter] postNotificationName: FUURLManagerURLListDidChangeNotification object: urlList];
		
	}
}

-(void) removeURL: (NSDictionary *) url
{
	if ( [urlList containsObject: url] ) {
		
		// Delete it.
		[urlList removeObject: url];
		
		// Save.
		[self saveDown];
		
		// Tell everyone what's just happened.
		[[NSNotificationCenter defaultCenter] postNotificationName: FUURLManagerURLListDidChangeNotification object: urlList];
		
	}
}

-(BOOL) saveDown
{
	// Write to file.
	return [urlList writeToFile: [DOCUMENTS_DIRECTORY stringByAppendingPathComponent: @"urls.plist"] atomically: YES];
}

@end