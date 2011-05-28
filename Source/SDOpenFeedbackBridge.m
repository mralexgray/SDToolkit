//
//  SDOpenFeedbackBridge.m
//  DeskLabels
//
//  Created by Steven Degutis on 7/3/09.
//  Copyright 2009 Thoughtful Tree Software. All rights reserved.
//

#import "SDOpenFeedbackBridge.h"

@interface SDOpenFeedbackBridge (Private)

- (void) runTask;
- (NSString*) getPostDataFromDictionary;

@end


@implementation SDOpenFeedbackBridge

- (id) initWithDelegate:(id<SDOpenFeedbackBridgeDelegate>)newDelegate {
	if (self = [super init]) {
		dictionary = [[NSMutableDictionary dictionary] retain];
		delegate = newDelegate;
	}
	return self;
}

- (void) dealloc {
	[dictionary release];
	[super dealloc];
}

- (void) dispatchWithEmail:(NSString*)email 
				wantsReply:(BOOL)wantsReply
					  type:(NSString*)type
				   message:(NSString*)message
				importance:(NSString*)importance
				isCritical:(BOOL)isCritical
{
	[dictionary setObject:NSFullUserName() forKey:@"name"];
	[dictionary setObject:[NSApp appName] forKey:@"appName"];
	[dictionary setObject:[NSApp appVersion] forKey:@"appVersion"];
	[dictionary setObject:[NSWorkspace systemVersion] forKey:@"systemVersion"];
	[dictionary setObject:[[NSDate date] description] forKey:@"dt"];
	
	[dictionary setObject:type forKey:@"type"];
	[dictionary setObject:message forKey:@"message"];
	
	if (email)
		[dictionary setObject:email forKey:@"email"];
	
	if (importance)
		[dictionary	setObject:importance forKey:@"importance"];
	
	[dictionary	setObject:(wantsReply ? @"Yes" : @"No") forKey:@"reply"];
	[dictionary setValue:(isCritical ? @"Yes" : @"No") forKey:@"critical"];
	
	[self runTask];
}

- (NSString*) getPostDataFromDictionary {
	NSMutableArray *info = [NSMutableArray array];
	for (NSString *key in dictionary)
		[info addObject:[NSString stringWithFormat:@"%@=%@", key, [[dictionary objectForKey:key] stringByURLEncodingString]]];
	
	return [info componentsJoinedByString:@"&"];
}

- (void) runTask {
	NSString *post = [self getPostDataFromDictionary];
	NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	NSString *postLength = [NSString stringWithFormat:@"%jd", (intmax_t)[postData length]];
	
	NSString *submitFeedbackURL = SDInfoPlistValueForKey(@"SDSubmitFeedbackURL");
	
	if (submitFeedbackURL == nil) {
		@throw [NSException exceptionWithName:@"Feedback Error"
									   reason:@"You must set SDSubmitFeedbackURL in Info.plist"
									 userInfo:[NSDictionary dictionary]];
		return;
	}
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL:[NSURL URLWithString:submitFeedbackURL]];
	[request setHTTPMethod:@"POST"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:postData];
	
	[NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	success = YES;
	[delegate openFeedbackBridge:self sentFeedbackWithSuccess:success];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	success = NO;
	[delegate openFeedbackBridge:self sentFeedbackWithSuccess:success];
}

- (NSAlert*) alertForStatus {
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert addButtonWithTitle:@"OK"];
	
	if (success) {
		[alert setMessageText:@"Feedback Sent"];
		[alert setInformativeText:@"Your feedback has been sent successfully. Thank you!"];
		[alert setAlertStyle:NSInformationalAlertStyle];
	}
	else {
		[alert setMessageText:@"Can't Send Feedback"];
		[alert setInformativeText:@"We were unable to send your feedback. Please check your internet connection and try again."];
		[alert setAlertStyle:NSWarningAlertStyle];
	}
	
	return alert;
}

- (NSString*) contextInfoForStatus {
	if (success)
		return kSDOpenFeedbackBridgeSuccess;
	else
		return kSDOpenFeedbackBridgeFailure;
}

@end
