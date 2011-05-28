#import "SDFeedbackController.h"

#import <AddressBook/AddressBook.h>

@interface SDFeedbackController (Private)

- (void) conditionallyEnableSendButton;

- (NSString*) deriveSubject;
- (NSString*) deriveBody;

- (void) populateEmailAddresses;

@end

@implementation SDFeedbackController

- (id) init {
	if (self = [super initWithWindowNibName:@"FeedbackWindow"]) {
		shouldIncludeEmail = YES;
	}
    return self;
}

- (SDOpenFeedbackBridge*) bridge {
	if (bridge == nil)
		bridge = [[SDOpenFeedbackBridge alloc] initWithDelegate:self];
	
	return bridge;
}

- (void) dealloc {
	[bridge release];
	[super dealloc];
}

- (void) windowDidLoad {
	[self populateEmailAddresses];
	[[self window] setTitle:[NSString stringWithFormat:@"%@ Feedback", [NSApp appDisplayName]]];
}

- (void) populateEmailAddresses {
	ABPerson *aPerson = [[ABAddressBook sharedAddressBook] me];
	ABMultiValue *emails = [aPerson valueForProperty:kABEmailProperty];
	
	if ([emails count] == 0)
		return;
	
	for (id label in emails)
		[emailComboBox addItemWithObjectValue:[emails valueForIdentifier:label]];
	
	[emailComboBox selectItemAtIndex:0];
}

//MARK: -
//MARK: Showing the Window

- (void) selectTabAtIndex:(int)index {
	id firstResponders[] = {questionTextView, featureTextView, bugTextView};
	
	NSDisableScreenUpdates();
	[NSApp activateIgnoringOtherApps:YES];
	[self showWindow:self];
	[tabView selectTabViewItemAtIndex:index];
	[[self window] makeFirstResponder:firstResponders[index]];
	NSEnableScreenUpdates();
}

- (IBAction) showWindow:(id)sender {
	[wantReplyCheckBox setState:NSOffState];
	[questionTextView setString:@""];
	[featureTextView setString:@""];
	[bugTextView setString:@""];
	[reproStepsTextView setString:@""];
	[isCriticalCheckBox setState:NSOffState];
	
    [super showWindow:self];
	[[self window] center];
}

- (IBAction) presentFeedbackPanelForSupport:(id)sender {
	[self selectTabAtIndex:0];
}

- (IBAction) presentFeedbackPanelForFeature:(id)sender {
	[self selectTabAtIndex:1];
}

- (IBAction) presentFeedbackPanelForBug:(id)sender {
	[self selectTabAtIndex:2];
}

//MARK: -
//MARK: Sending Feedback

- (IBAction) submitFeedback:(id)sender {
	[progressBar startAnimation:self];
	[sendButton setEnabled:NO];
	
	NSString *email = nil;
	if ([includeEmailButton state] == YES)
		email = [emailComboBox stringValue];
	
	NSString *type = nil;
	NSString *message = nil;
	NSString *importance = nil;
	BOOL critical = NO;
	
	switch([tabView indexOfTabViewItem:[tabView selectedTabViewItem]]) {
		case 0: // Support
			type = @"support";
			message = [questionTextView string];
			break;
			
		case 1: // Feature Request
			type = @"feature";
			message = [featureTextView string];
			importance = [importancePopUpButton titleOfSelectedItem];
			break;
			
		case 2: // Bug Report
			type = @"bug";
			message = [NSString stringWithFormat:@"What did you expect to happen?\n%@\n\nWhat steps will reproduce the problem?\n%@",
					   [bugTextView string],
					   [reproStepsTextView string]];
			critical = [isCriticalCheckBox state];
			
			break;
	}
	
	[[self bridge] dispatchWithEmail:email
						  wantsReply:[wantReplyCheckBox state]
								type:type
							 message:message
						  importance:importance
						  isCritical:critical];
}

- (void) openFeedbackBridge:(SDOpenFeedbackBridge*)someBridge sentFeedbackWithSuccess:(BOOL)success {
	[progressBar stopAnimation:self];
	
	NSAlert *alert = [someBridge alertForStatus];
	[alert beginSheetModalForWindow:[self window]
					  modalDelegate:self
					 didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
						contextInfo:[bridge contextInfoForStatus]];
}

- (void) sheetDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	NSString *successString = (id)contextInfo;
	
	[[alert window] orderOut:self];
	
	[sendButton setEnabled:YES];
	
	if ([successString isEqualToString:kSDOpenFeedbackBridgeSuccess])
		[self close];
}

//MARK: -
//MARK: Enabling Send Button

- (void) textDidChange:(NSNotification *)aNotification {
	[self conditionallyEnableSendButton];
}

- (void) comboBoxSelectionDidChange:(NSNotification *)notification {
	[self conditionallyEnableSendButton];
}

- (void) tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem {
	[self conditionallyEnableSendButton];
}

- (void) conditionallyEnableSendButton {
	NSInteger type = [tabView indexOfTabViewItem:[tabView selectedTabViewItem]];
	NSTextView *textViews[] = {questionTextView, featureTextView, bugTextView};
	NSTextView *textView = textViews[type];
	
	BOOL enabled = ([[[textView string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0);
	[sendButton setEnabled:enabled];
}

@end
