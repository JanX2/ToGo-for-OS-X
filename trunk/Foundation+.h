/***************************\
	Foundation Extensions
\***************************/

//#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>

@interface UIApplication (Extended)

-(void) showNetworkIndicator: (NSNumber *) show;

@end
#else
#import <Cocoa/Cocoa.h>
#endif

@interface NSDictionary (MoreStuff)

// Functions
id dictionaryForTableViewCell(NSString *reuseID, int accessoryType, 
							  int editingStyle, int selectionStyle, 
							  NSString *textLabel, NSString *detailTextLabel);
id dictionaryForTableViewCellWithData(NSString *reuseID, int accessoryType, 
									  int editingStyle, int selectionStyle, 
									  NSString *textLabel, NSString *detailTextLabel,
									  id data);
id dictionaryForTableViewCellWithImage(NSString *reuseID, int accessoryType, 
									   int editingStyle, int selectionStyle, 
									   NSString *textLabel, NSString *detailTextLabel, 
									   id image);
id dictionaryForTableViewCellWithImageAndData(NSString *reuseID, int accessoryType, 
											  int editingStyle, int selectionStyle, 
											  NSString *textLabel, NSString *detailTextLabel, 
											  id image, id data);

// Instance Management
+(id) dictionaryByAddingObjectsAndKeys: (id) object, ... NS_REQUIRES_NIL_TERMINATION;

@end

#if TARGET_OS_IPHONE
@interface UIColor (FUE)
#else if TARGET_OS_MAC
@interface NSColor (FUE)
#endif

+(id) flatBlueColor;

@end

@interface NSString (ParseCategory)
- (NSMutableDictionary *)explodeToDictionaryInnerGlue:(NSString *)innerGlue outterGlue:(NSString *)outterGlue;
@end