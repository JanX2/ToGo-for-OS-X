//
//  Foundation+.m
//  PetMe
//
//  Created by Drew R. Hood on 4.2.10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "Foundation+.h"

#if TARGET_OS_IPHONE
@implementation UIApplication (Extended)

-(void) showNetworkIndicator: (NSNumber *) show
{
	self.networkActivityIndicatorVisible = [show boolValue];
}

@end
#endif

@implementation NSDictionary (MoreStuff)

// Functions
id dictionaryForTableViewCell(NSString *reuseID, int accessoryType, 
							  int editingStyle, int selectionStyle, 
							  NSString *textLabel, NSString *detailTextLabel)
{
	id returnDict = DICTIONARY(reuseID, @"reuseID", 
							   INTOBJ(accessoryType), @"accessoryType", 
							   INTOBJ(editingStyle), @"editingStyle",
							   INTOBJ(selectionStyle), @"selectionStyle",
							   textLabel, @"textLabel",
							   detailTextLabel, @"detailTextLabel"
							   );
	
	return returnDict;
}

id dictionaryForTableViewCellWithData(NSString *reuseID, int accessoryType, 
									  int editingStyle, int selectionStyle, 
									  NSString *textLabel, NSString *detailTextLabel,
									  id data)
{
	id returnDict = dictionaryForTableViewCell(reuseID, accessoryType, 
											   editingStyle, selectionStyle, 
											   textLabel, detailTextLabel);
	
	if ( data != nil )
		[returnDict setObject: data forKey: @"data"];
	
	return returnDict;
}

id dictionaryForTableViewCellWithImage(NSString *reuseID, int accessoryType, 
									   int editingStyle, int selectionStyle, 
									   NSString *textLabel, NSString *detailTextLabel, 
									   id image)
{
	id returnDict = dictionaryForTableViewCell(reuseID, accessoryType, 
											   editingStyle, selectionStyle, 
											   textLabel, detailTextLabel);
	
	if ( image != nil )
		[returnDict setObject: image forKey: @"image"];
	
	return returnDict;
}

id dictionaryForTableViewCellWithImageAndData(NSString *reuseID, int accessoryType, 
											  int editingStyle, int selectionStyle, 
											  NSString *textLabel, NSString *detailTextLabel, 
											  id image, id data)
{
	id returnDict = dictionaryForTableViewCellWithData(reuseID, accessoryType, 
											   editingStyle, selectionStyle, 
											   textLabel, detailTextLabel, data);
	
	if ( image != nil )
		[returnDict setObject: image forKey: @"image"];
	
	return returnDict;
}

// Instance Management
+(id) dictionaryByAddingObjectsAndKeys: (id) object, ...
{
	va_list args;
	va_start(args, object);
	
	// Set up the dictionary.
	id returnDict = [[[self class] alloc] init];
	
	for ( id arg = object; arg != nil; arg = va_arg(args, id) ) {
		
		[returnDict setObject: arg forKey: va_arg(args, id)];
		
	}
	
	va_end(args);
	
	return [returnDict autorelease];
}

@end

#if TARGET_OS_IPHONE
@implementation UIColor (FUE)

+(id) flatBlueColor
{
	return [UIColor colorWithRed: 0.525490196078431 green: 0.572549019607843 blue: 0.8 alpha: 1.0];
}

@end
#else if TARGET_OS_MAC
@implementation NSColor (FUE)

+(id) flatBlueColor
{
	return [NSColor colorWithDeviceRed: 0.525490196078431 green: 0.572549019607843 blue: 0.8 alpha: 1.0];
}

@end
#endif

@implementation NSString (ParseCategory)

- (NSMutableDictionary *)explodeToDictionaryInnerGlue:(NSString *)innerGlue outterGlue:(NSString *)outterGlue {
    // Explode based on outter glue
    NSArray *firstExplode = [self componentsSeparatedByString:outterGlue];
    NSArray *secondExplode;
	
    // Explode based on inner glue
    NSInteger count = [firstExplode count];
    NSMutableDictionary *returnDictionary = [NSMutableDictionary dictionaryWithCapacity:count];
    for (NSInteger i = 0; i < count; i++) {
        secondExplode = [(NSString *)[firstExplode objectAtIndex:i] componentsSeparatedByString:innerGlue];
        if ([secondExplode count] == 2) {
			[returnDictionary setObject:[secondExplode objectAtIndex:1] forKey:[secondExplode objectAtIndex:0]];
        }
    }
	
    return returnDictionary;
}

@end