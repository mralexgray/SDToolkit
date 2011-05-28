//
// Created 2008 by Steven Degutis
// http://www.thoughtfultree.com/
// Some rights reserved.
//

#import "SDOpenAtLoginController.h"

@implementation SDOpenAtLoginController

@dynamic opensAtLogin;

- (id) init {
	if (self = [super init]) {
		sharedFileList = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
	}
	return self;
}

- (void) setOpensAtLogin:(BOOL)opensAtLogin {
	if (opensAtLogin) {
		NSString *appPath = [[NSBundle mainBundle] bundlePath];
		CFURLRef appURL = (CFURLRef)[NSURL fileURLWithPath:appPath];
		LSSharedFileListItemRef result = LSSharedFileListInsertItemURL(sharedFileList, kLSSharedFileListItemLast, NULL, NULL, appURL, NULL, NULL);
		CFRelease(result);
	}
	else {
		UInt32 seed;
		NSArray *sharedFileListArray = [(NSArray*)LSSharedFileListCopySnapshot(sharedFileList, &seed) autorelease];
		for (id item in sharedFileListArray) {
			LSSharedFileListItemRef sharedFileItem = (LSSharedFileListItemRef)item;
			CFURLRef url = NULL;
			
			OSStatus result = LSSharedFileListItemResolve(sharedFileItem, 0, &url, NULL);
			if (result == noErr && url != nil) {
				NSString *appPath = [[NSBundle mainBundle] bundlePath];
				NSString *itemPath = [(NSURL*)url path];
				
				if ([appPath isEqualToPath: itemPath])
					LSSharedFileListItemRemove(sharedFileList, sharedFileItem);
				
				CFRelease(url);
			}
		}
	}
}

- (BOOL) opensAtLogin {
	UInt32 seed;
	NSArray *sharedFileListArray = [(NSArray*)LSSharedFileListCopySnapshot(sharedFileList, &seed) autorelease];
	for (id item in sharedFileListArray) {
		CFURLRef url = NULL;
		if (LSSharedFileListItemResolve((LSSharedFileListItemRef)item, 0, &url, NULL) == noErr) {
			NSString *firstPath = [(NSURL*)url path];
			NSString *secondPath = [[NSBundle mainBundle] bundlePath];
			if ([firstPath isEqualToPath: secondPath])
				return YES;
		}
	}
	
	return NO;
}

@end
