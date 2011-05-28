#import "SDExceptionController.h"

#import <ExceptionHandling/ExceptionHandling.h>

#include <execinfo.h>

@interface SDExceptionController (Private)

- (void) doneSubmittingFeedbackWithSuccess:(BOOL)success;
- (SDOpenFeedbackBridge*) bridge;

@end


@implementation SDExceptionController

- (id)init {
	if (self = [super initWithWindowNibName:@"ExceptionWindow"]) {
		exceptionInfo = [[NSMutableString string] retain];
		
		[[NSExceptionHandler defaultExceptionHandler] setExceptionHandlingMask:NSHandleTopLevelExceptionMask];
		[[NSExceptionHandler defaultExceptionHandler] setDelegate:self];
	}
	return self;
}

- (void) dealloc {
	[bridge release];
	[exceptionInfo release];
	[super dealloc];
}

- (SDOpenFeedbackBridge*) bridge {
	if (bridge == nil)
		bridge = [[SDOpenFeedbackBridge alloc] initWithDelegate:self];
	
	return bridge;
}

- (BOOL)exceptionHandler:(NSExceptionHandler *)sender shouldHandleException:(NSException *)exception mask:(NSUInteger)aMask {
	[exceptionInfo setString:@""];
	
	[exceptionInfo appendFormat:@"Date: %@\n", [NSDate date]];
	[exceptionInfo appendFormat:@"Exception: %@\n", [exception name]];
	[exceptionInfo appendFormat:@"Reason: %@\n", [exception reason]];
	[exceptionInfo appendString:@"Stack:\n\n"];
	
	NSString *stackString = @"";
	
    NSString *stack = [[exception userInfo] objectForKey:NSStackTraceKey];
    if (stack) {
        NSString *pid = [[NSNumber numberWithInt:[[NSProcessInfo processInfo] processIdentifier]] stringValue];
		
        NSMutableArray *args = [NSMutableArray arrayWithCapacity:20];
        [args addObject:@"-p"];
        [args addObject:pid];
        [args addObjectsFromArray:[stack componentsSeparatedByString:@"  "]];
		
		NSPipe *pipe = [NSPipe pipe];
		
        NSTask *atos = [[[NSTask alloc] init] autorelease];
        [atos setLaunchPath:@"/usr/bin/atos"];
        [atos setArguments:args];
		[atos setStandardOutput:pipe];
        [atos launch];
		[atos waitUntilExit];
		
		NSInteger status = [atos terminationStatus];
		
		if (status == 0) {
			NSFileHandle *fileHandle = [pipe fileHandleForReading];
			NSData *data = [fileHandle availableData];
			stackString = [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
		}
		else {
			stackString = @"Failed to get stack track from NSTask.";
		}
    }
	else {
		stackString = @"No stack trace available.";
    }
	
	[exceptionInfo appendString:stackString];
	//[userInfoTextView setFont:[NSFont systemFontOfSize:11]];
	
	NSDisableScreenUpdates();
	[self showWindow:self];
	[[self window] center];
	NSEnableScreenUpdates();
	
	[[[exceptionTextView textStorage] mutableString] setString:exceptionInfo];
	[exceptionTextView setEditable:NO];
	
	return YES;
}

- (IBAction) sendReport:(id)sender {
	[progressBar startAnimation:self];
	[sendButton setEnabled:NO];
	
	[[self bridge] dispatchWithEmail:NULL
						  wantsReply:NO
								type:@"bug"
							 message:[NSString stringWithFormat:@"User-supplied information:\n%@\n\n%@", [userInfoTextView string], (exceptionInfo)]
						  importance:NULL
						  isCritical:YES];
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

@end
