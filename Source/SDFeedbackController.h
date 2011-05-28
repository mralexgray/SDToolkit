#import <Cocoa/Cocoa.h>

#import "SDOpenFeedbackBridge.h"

#import "SDWindowController.h"

@interface SDFeedbackController : SDWindowController <SDOpenFeedbackBridgeDelegate> {
	IBOutlet NSTabView *tabView;
	
	// Support Tab
	IBOutlet NSTextView *questionTextView;
	
	// Feature Request Tab
	IBOutlet NSTextView *featureTextView;
	IBOutlet NSPopUpButton *importancePopUpButton;
	
	// Bug Report Tab
	IBOutlet NSTextView *bugTextView;
	IBOutlet NSTextView *reproStepsTextView;
	IBOutlet NSButton *isCriticalCheckBox;
	
	IBOutlet NSComboBox *emailComboBox;
	IBOutlet NSButton *includeEmailButton;
	
	BOOL shouldIncludeEmail;
	IBOutlet NSButton *wantReplyCheckBox;
	
	IBOutlet NSProgressIndicator *progressBar;
	IBOutlet NSButton *sendButton;
	
	SDOpenFeedbackBridge *bridge;
}

- (IBAction) presentFeedbackPanelForSupport:(id)sender;
- (IBAction) presentFeedbackPanelForFeature:(id)sender;
- (IBAction) presentFeedbackPanelForBug:(id)sender;

- (IBAction) submitFeedback:(id)sender;

@end
