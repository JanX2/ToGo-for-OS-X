/*****************\
	URL Manager
\*****************/

// Dependencies
#import <Foundation/Foundation.h>

#pragma mark Constants
// Constants
extern NSString * const FUURLManagerNewURLAddedNotification;
extern NSString * const FUURLManagerCurrentURLDidChangeNotification;
extern NSString * const FUURLManagerURLListDidChangeNotification;
extern NSString * const FUURLManagerWillOpenURLNotification;

@interface FUURLManager : NSObject 
{
	// Data
	NSMutableDictionary *currentURL;
	NSMutableArray *urlList;
}

#pragma mark Properties
// Properties
@property (nonatomic, retain) NSMutableDictionary *currentURL;
@property (nonatomic, retain) NSMutableArray *urlList;

#pragma mark Instance Management
// Instance Management
+(id) allocWithZone: (NSZone *) zone;
-(id) init;
+(FUURLManager *) sharedManager;
-(id) retain;
-(id) copyWithZone: (NSZone *) zone;
-(void) dealloc;

#pragma mark Variable Management
// Variable Management
-(void) setCurrentURL: (NSMutableDictionary *) url;
-(NSMutableDictionary *) currentURL;

#pragma mark Opening URLs
// Opening URLs
-(void) openURL: (NSDictionary *) url;

#pragma mark URL Queries
// URL Queries
-(NSDictionary *) URLAtIndex: (NSInteger) index;

#pragma mark Data Control
// Data Control
-(void) checkMetadataForAllURLs;
-(void) _checkMetadataForAllURLs;
-(NSMutableDictionary *) fetchMetadataForURL: (NSString *) theURL;
-(void) updateCurrentURL;
-(void) addURL: (NSString *) url from: (NSString *) nameOfDevice;
-(void) _addURLInBackground: (NSDictionary *) urlDict;
-(void) removeURLAtIndex: (NSInteger) index;
-(void) removeURL: (NSDictionary *) url;
-(BOOL) saveDown;

@end