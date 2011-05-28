//
//  SDCommonAppDelegate.h
//  DeskLabels
//
//  Created by Steven Degutis on 7/4/09.
//  Copyright 2009 Thoughtful Tree Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SDInstructionsWindowController.h"
#import "SDPreferencesController.h"

@class SUUpdater;
@class SDFeedbackController;
@class SDExceptionController;
@class SDOpenAtLoginController;

@interface SDCommonAppDelegate : NSObject <SDInstructionsDelegate, SDPreferencesDelegate> {
	SUUpdater *updater;
	SDFeedbackController *feedbackController;
	SDExceptionController *exceptionController;
	SDOpenAtLoginController *openAtLoginController;
	SDPreferencesController *preferencesController;
	SDInstructionsWindowController *instructionWindowController;
}

- (IBAction) showInstructionsWindow:(id)sender;

- (IBAction) showPreferencesPanel:(id)sender;

- (IBAction) showAboutPanel:(id)sender;
- (IBAction) toggleOpensAtLogin:(id)sender;

- (IBAction) showFeedbackPanelForBug:(id)sender;
- (IBAction) showFeedbackPanelForFeature:(id)sender;
- (IBAction) showFeedbackPanelForSupport:(id)sender;

- (IBAction) checkForUpdates:(id)sender;

- (IBAction) visitWebsite:(id)sender;
- (IBAction) visitWebsiteStore:(id)sender;

// useful methods

- (void) setOpensAtLogin:(BOOL)opens;

// menu validation (so you know to call super)

- (BOOL) validateMenuItem:(NSMenuItem *)menuItem;

// must implement in subclass!

- (void) appRegisteredSuccessfully;

- (NSArray*) instructionImageNames;

- (BOOL) showsPreferencesToolbar;
- (NSArray*) preferencePaneControllerClasses;

@end
