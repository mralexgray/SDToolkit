#import <Cocoa/Cocoa.h>

#import "SDOpenFeedbackBridge.h"

#import "SDWindowController.h"

@interface SDExceptionController : SDWindowController <SDOpenFeedbackBridgeDelegate> {
	NSMutableString *exceptionInfo;
	
	IBOutlet NSTextView *userInfoTextView;
	IBOutlet NSTextView *exceptionTextView;
	
	IBOutlet NSProgressIndicator *progressBar;
	IBOutlet NSButton *sendButton;
	
	SDOpenFeedbackBridge *bridge;
}

- (IBAction)sendReport:(id)sender;

@end
