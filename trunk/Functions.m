/***********************\
	General Functions
\***********************/

#import "Functions.h"

// Object Allocation Management
void destroy(id object)
{
	[object release];
	object = nil;
}

// Time Calculations
NSTimeInterval intervalSinceMidnightForDate(NSDate *date)
{
	// First, get midnight.
	NSDateFormatter *mdf = [[NSDateFormatter alloc] init];
	[mdf setDateFormat: @"yyyy-MM-dd"];
	
	NSDate *midnight = [mdf dateFromString: [mdf stringFromDate: date]];
	
	[mdf release];
	
	// Then, get the interval.
	NSTimeInterval interval = [date timeIntervalSinceDate: midnight];
	
	// Get the absolute value.
	interval = ABS_VALUE(interval);
	
	return interval;
}

NSDate * convertDateToMidnight(NSDate *date)
{
	NSDateFormatter *mdf = [[NSDateFormatter alloc] init];
	[mdf setDateFormat: @"yyyy-MM-dd"];
	
	NSDate *midnight = [mdf dateFromString: [mdf stringFromDate: date]];
	
	[mdf release];
	
	return midnight;
}

#if TARGET_OS_IPHONE
// Table View Shortcuts
id generateTableViewCell(UITableView *tableView, NSDictionary *cellData, NSString *reuseID)
{
	[cellData retain];
	
	id cell = [tableView dequeueReusableCellWithIdentifier: reuseID];
	
	if ( !cell ) {
		
		if ( reuseID == UITableViewCellReuseIDDefault )
			cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: reuseID] autorelease];
		else if ( reuseID == UITableViewCellReuseIDValue2 )
			cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue2 reuseIdentifier: reuseID] autorelease];
		else if ( reuseID == UITableViewCellReuseIDValue1 )
			cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier: reuseID] autorelease];
		else if ( reuseID == UITableViewCellReuseIDSubtitle )
			cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier: reuseID] autorelease];
	}
	
	// Blank everything out.
	[cell setAccessoryView: nil];
	[cell setEditingAccessoryView: nil];
	[[cell imageView] setImage: nil];
	
	// Set the basic properties of the cell and clear out text.
	[cell setAccessoryType: INTVALUE([cellData objectForKey: @"accessoryType"])];
	[cell setEditingAccessoryType: INTVALUE([cellData objectForKey: @"accessoryType"])];
	[cell setSelectionStyle: INTVALUE([cellData objectForKey: @"selectionStyle"])];
	[[cell textLabel] setText: nil];
	[[cell detailTextLabel] setText: nil];
	
	// Make sure we've removed the custom note label.
	for ( id eachSubview in [cell subviews] ) {
		
		if ( [eachSubview tag] == 1901 )
			[eachSubview removeFromSuperview];
		
	}
	
	// Add any images.
	if ( [cell respondsToSelector: @selector(imageView)] )
		[[cell imageView] setImage: [cellData objectForKey: @"image"]];
	
	// Set the text.
	[[cell textLabel] setText: [cellData objectForKey: @"textLabel"]];
	
	if ( [cell respondsToSelector: @selector(detailTextLabel)] )
		[[cell detailTextLabel] setText: [cellData objectForKey: @"detailTextLabel"]];
	
	[cellData release];
	return cell;
}
#endif

// Math
CGFloat radians(CGFloat degrees)
{
	return (degrees * M_PI) / 180.0;
}

#if TARGET_OS_IPHONE
NSString * FUStringSha1(NSString *input)
{
	const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
	NSData *data = [NSData dataWithBytes:cstr length:input.length];
	
	uint8_t digest[CC_SHA256_DIGEST_LENGTH];
	
	CC_SHA256(data.bytes, data.length, digest);
	
	NSMutableString* output = [NSMutableString stringWithCapacity: CC_SHA256_DIGEST_LENGTH * 2];
	
	for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
		[output appendFormat:@"%02x", digest[i]];
	
	return output; 
	
}
#endif

// Localization
NSString * FULocalizedString(NSString *source, NSString *flags)
{
	if ( flags == nil || source == nil || [flags isEqualToString: @""] || [source isEqualToString: @""] )
		goto noFlags;
	
	NSString *localized;
	NSString *appendage;
	NSMutableString *digest = [source mutableCopy];
	
	// Digest the flags.
	NSMutableString *flagDigest = [flags mutableCopy];
	
	BOOL allCaps = (BOOL) [flagDigest replaceOccurrencesOfString: @"-cc" withString: @"" 
														 options: NSLiteralSearch range: NSMakeRange(0, [flagDigest length])];
	BOOL wordCap = (BOOL) [flagDigest replaceOccurrencesOfString: @"-c" withString: @"" 
														 options: NSLiteralSearch range: NSMakeRange(0, [flagDigest length])];
	BOOL noCaps = (BOOL) [flagDigest replaceOccurrencesOfString: @"-l" withString: @"" 
														options: NSLiteralSearch range: NSMakeRange(0, [flagDigest length])];
	BOOL plural = (BOOL) [flagDigest replaceOccurrencesOfString: @"-pl" withString: @"" 
														options: NSLiteralSearch range: NSMakeRange(0, [flagDigest length])];
	BOOL pastTense = (BOOL) [flagDigest replaceOccurrencesOfString: @"-pa" withString: @"" 
														   options: NSLiteralSearch range: NSMakeRange(0, [flagDigest length])];
	BOOL presentTense = (BOOL) [flagDigest replaceOccurrencesOfString: @"-pr" withString: @"" 
															  options: NSLiteralSearch range: NSMakeRange(0, [flagDigest length])];
	BOOL futureTense = (BOOL) [flagDigest replaceOccurrencesOfString: @"-fu" withString: @"" 
															 options: NSLiteralSearch range: NSMakeRange(0, [flagDigest length])];
	BOOL abbreviated = (BOOL) [flagDigest replaceOccurrencesOfString: @"-sh" withString: @"" 
															 options: NSLiteralSearch range: NSMakeRange(0, [flagDigest length])];
	BOOL append = FALSE;
	NSRange appendageRange = [flagDigest rangeOfString: @"-a"];
	
	// If there's an appendage, get that and save it for later.
	if ( appendageRange.location != NSNotFound ) {
		
		appendage = [flagDigest substringFromIndex: (appendageRange.location + appendageRange.length)];
		
		appendage = [appendage stringByReplacingOccurrencesOfString: @" \"" withString: @""];
		appendage = [appendage stringByReplacingOccurrencesOfString: @"\"" withString: @""];
		
		if ( appendage != nil ) 
			append = TRUE;
		
	}
	
	// Now we're done with the flag string.
	[flagDigest release];
	flagDigest = nil;
	
	// If it's plural, add an S.
	if ( plural )
		[digest appendString: @"s"];
	
	// Add any tense appendages.
	if ( pastTense )
		[digest appendString: @" FUPast"];
	else if ( presentTense )
		[digest appendString: @" FUPresent"];
	else if ( futureTense )
		[digest appendString: @" FUFuture"];
	
	// If we need the abbreviation, append the keyword.
	if ( abbreviated )
		[digest appendString: @" FUAbbreviated"];
	
	// Now get the localized version of that.
	localized = NSLocalizedString(digest, @"");
	
	// Now make sure we have an abbreviated version and,
	// if not, just get the unabbreviated one.
	if ( [localized rangeOfString: @" FUAbbreviated"].location != NSNotFound ) {
		
		[digest replaceOccurrencesOfString: @" FUAbbreviated" withString: @"" 
								   options: NSLiteralSearch 
									 range: NSMakeRange(0, [digest length])];
		
		localized = NSLocalizedString(digest, @"");
		
		if ( [localized length] > 3 )
			localized = [localized stringByReplacingCharactersInRange: NSMakeRange(3, ([localized length] - 3)) withString: @"."];
		
	}
	
	if ( [localized rangeOfString: @" FUPast"].location != NSNotFound || 
		[localized rangeOfString: @" FUPresent"].location != NSNotFound ||
		[localized rangeOfString: @" FUFuture"].location != NSNotFound ) 
	{
		
		[digest replaceOccurrencesOfString: @" FUPast" withString: @"" 
								   options: NSLiteralSearch 
									 range: NSMakeRange(0, [digest length])];
		
		[digest replaceOccurrencesOfString: @" FUPresent" withString: @"" 
								   options: NSLiteralSearch 
									 range: NSMakeRange(0, [digest length])];
		
		[digest replaceOccurrencesOfString: @" FUFuture" withString: @"" 
								   options: NSLiteralSearch 
									 range: NSMakeRange(0, [digest length])];
		
		localized = NSLocalizedString(digest, @"");
		
	}
	
	// Capitalize, by order of precedence.
	if ( allCaps ) {
		
		localized = [localized uppercaseString];
		
	} else if ( wordCap ) {
		
		localized = [localized capitalizedString];
		
	} else if ( noCaps ) {
		
		localized = [localized lowercaseString];
		
	}
	
	// Tack on the appendage.
	if ( append ) {
		
		localized = [localized stringByAppendingString: appendage];
		
	}
	
	// And we're done.
	[digest release];
	digest = nil;

	return localized;

noFlags: ;

	return NSLocalizedString(source, @"");
}