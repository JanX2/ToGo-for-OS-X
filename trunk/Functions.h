/***********************\
	General Functions
\***********************/

#import <Foundation/Foundation.h>

// Object Allocation Management
void destroy(id object);

// Time Calculations
NSTimeInterval intervalSinceMidnightForDate(NSDate *date);
NSDate * convertDateToMidnight(NSDate *date);

#if TARGET_OS_IPHONE
// Table View Shortcuts
extern id generateTableViewCell(UITableView *tableView, NSDictionary *cellData, NSString *reuseID);
#endif

// Math
CGFloat radians(CGFloat degrees);
#if TARGET_OS_IPHONE
NSString * FUStringSha1(NSString *input);
#endif

// Localization
NSString * FULocalizedString(NSString *source, NSString *flags);