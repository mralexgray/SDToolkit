//
//  SDOpenFeedbackBridge.h
//  DeskLabels
//
//  Created by Steven Degutis on 7/3/09.
//  Copyright 2009 Thoughtful Tree Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define kSDOpenFeedbackBridgeSuccess @"kSDOpenFeedbackBridgeSuccess"
#define kSDOpenFeedbackBridgeFailure @"kSDOpenFeedbackBridgeFailure"

@class SDOpenFeedbackBridge;

@protocol SDOpenFeedbackBridgeDelegate

- (void) openFeedbackBridge:(SDOpenFeedbackBridge*)someBridge sentFeedbackWithSuccess:(BOOL)success;

@end


@interface SDOpenFeedbackBridge : NSObject {
	NSMutableDictionary *dictionary;
	id <SDOpenFeedbackBridgeDelegate> delegate;
	BOOL success;
}

- (id) initWithDelegate:(id<SDOpenFeedbackBridgeDelegate>)newDelegate;

- (void) dispatchWithEmail:(NSString*)email 
				wantsReply:(BOOL)wantsReply
					  type:(NSString*)type
				   message:(NSString*)message
				importance:(NSString*)importance
				isCritical:(BOOL)isCritical;

- (NSAlert*) alertForStatus;
- (NSString*) contextInfoForStatus;

@end
