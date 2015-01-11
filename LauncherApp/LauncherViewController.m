//
//  LauncherViewController.m
//  LauncherApp
//
//  Created by Philip Schneider on 1/10/15.
//  Copyright (c) 2015 Code From Above, LLC. All rights reserved.
//

#import "LauncherViewController.h"
#include "LaunchWithSystemCall.h"

#include <Carbon/Carbon.h>

@interface LauncherViewController ()
@property (weak) IBOutlet NSTextField *appOutlet;

@end

@implementation LauncherViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do view setup here.
}

//
// Select an app to launch with the scripts.
//
- (IBAction)browseAction:(id)sender
{
    NSOpenPanel *openDialog = [NSOpenPanel openPanel];

    [openDialog setCanChooseFiles:YES];
    [openDialog setCanChooseDirectories:NO];
    [openDialog setAllowsMultipleSelection:NO];
    [openDialog setDirectoryURL:[NSURL URLWithString:@"/Applications"]];
    [openDialog setAllowedFileTypes:[NSArray arrayWithObjects:@"app", nil]];

    if ([openDialog runModal] == NSOKButton)
    {
        NSArray  *urls           = [openDialog URLs];
        NSString *path           = [urls objectAtIndex:0];
        NSArray  *pathComponents = [path pathComponents];
        NSString *appName        = [pathComponents lastObject];

        [[self appOutlet] setStringValue:[appName stringByDeletingPathExtension]];
    }
}

//
// This goes through a purely C-language interface...no Objective-C at all.
// The script is created on the fly from a C string, then executed with
// the "system" call, which calls osascript to execute the script text.
//
- (IBAction)launchWithOnTheFlyScriptUsingSystemCallAction:(id)sender
{
    launchWithSystemCall([[[self appOutlet] stringValue] UTF8String]);
}


//
// This creates an NSAppleScript on the fly from an NSString. The
// NSAppleScript object executes itself directly.
//
- (void)launchWithOnTheFlyScriptUsingNSAppleScript:(NSString *)app
{
    if (!app)
        return;

    // https://developer.apple.com/library/mac/technotes/tn2084/_index.html
    NSString *scriptCode  = [NSString stringWithFormat:@"tell application \"%@\" to run\n\
                                                         tell application \"%@\" to activate",
                                                         app, app];

    NSDictionary           *errorDict;
    NSAppleEventDescriptor *returnDescriptor = NULL;
    NSAppleScript          *scriptObject     = [[NSAppleScript alloc] initWithSource:scriptCode];

    returnDescriptor = [scriptObject executeAndReturnError:&errorDict];

    if (returnDescriptor != NULL)
    {
        // successful execution
        if (kAENullEvent != [returnDescriptor descriptorType])
        {
            // script returned an AppleScript result
            if (cAEList == [returnDescriptor descriptorType])
            {
                // result is a list of other descriptors
            }
            else
            {
                // coerce the result to the appropriate ObjC type
            }
        }
    }
    else
    {
        // no script result, handle error here
    }
}

- (IBAction)launchWithOnTheFlyScriptUsingNSAppleScriptAction:(id)sender
{
    [self launchWithOnTheFlyScriptUsingNSAppleScript:[[self appOutlet] stringValue]];
}


//
// This creates an NSAppleScript from a bundled applescript (text) file,
// which contains a parameterized function. An argument (the app name) is
// constructed and passed to the script, which self-executes.
//
- (void)launchWithBundledScriptWithParameters:(NSString *)app
{
    if (!app)
        return;

    // load the script from a resource by fetching its URL from within our bundle
    NSString* path = [[NSBundle mainBundle] pathForResource:@"LaunchParameterizedScript"
                                                     ofType:@"scpt"];

    if (path != nil)
    {
        NSURL* url = [NSURL fileURLWithPath:path];
        if (url != nil)
        {
            NSDictionary  *errorDict     = [NSDictionary dictionary];
            NSAppleScript *scriptObject = [[NSAppleScript alloc] initWithContentsOfURL:url
                                                                                 error:&errorDict];

            if (scriptObject != nil)
            {
                // create the first parameter
                NSAppleEventDescriptor *firstParameter = [NSAppleEventDescriptor descriptorWithString:app];

                // create and populate the list of parameters (in our case just one)
                NSAppleEventDescriptor *parameters = [NSAppleEventDescriptor listDescriptor];
                [parameters insertDescriptor:firstParameter atIndex:1];

                // create the AppleEvent target
                ProcessSerialNumber     psn    = { 0, kCurrentProcess };
                NSAppleEventDescriptor *target = [NSAppleEventDescriptor descriptorWithDescriptorType:typeProcessSerialNumber
                                                                                                bytes:&psn
                                                                                               length:sizeof(ProcessSerialNumber)];

                // create an NSAppleEventDescriptor with the script's method name to call,
                // this is used for the script statement: "on launch_app(user_message)"
                // Note that the routine name must be in lower case.
                NSAppleEventDescriptor *handler = [NSAppleEventDescriptor descriptorWithString: [@"launch_app" lowercaseString]];

                // create the event for an AppleScript subroutine,
                // set the method name and the list of parameters
                NSAppleEventDescriptor *event = [NSAppleEventDescriptor appleEventWithEventClass:kASAppleScriptSuite
                                                                                         eventID:kASSubroutineEvent
                                                                                targetDescriptor:target
                                                                                        returnID:kAutoGenerateReturnID
                                                                                   transactionID:kAnyTransactionID];
                [event setParamDescriptor:handler forKeyword:keyASSubroutineName];
                [event setParamDescriptor:parameters forKeyword:keyDirectObject];

                // call the event in AppleScript
                if (![scriptObject executeAppleEvent:event error:&errorDict])
                {
                    // report any errors from 'errors'
                }
            }
            else
            {
                // report any errors from 'errors'
            }
        }
    }
}

- (IBAction)launchWithBundledScriptWithParametersAction:(id)sender
{
    [self launchWithBundledScriptWithParameters:[[self appOutlet] stringValue]];
}


//
// This creates an NSAppleScript from a bundled applescript (text) file. The
// script hard-codes the application to be launched.
//
- (void)launchWithHardCodedScript
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"LaunchHardCodedScript"
                                                     ofType:@"scpt"];

    if (path != nil)
    {
        NSURL *url = [NSURL fileURLWithPath:path];
        if (url != nil)
        {
            NSDictionary           *errorDict        = [NSDictionary dictionary];
            NSAppleScript          *scriptObject     = [[NSAppleScript alloc] initWithContentsOfURL:url
                                                                                              error:&errorDict];
            NSAppleEventDescriptor *returnDescriptor = NULL;

            if (scriptObject != nil)
            {
                returnDescriptor = [scriptObject executeAndReturnError:&errorDict];

                if (returnDescriptor != NULL)
                {
                    // successful execution
                    if (kAENullEvent != [returnDescriptor descriptorType])
                    {
                        // script returned an AppleScript result
                        if (cAEList == [returnDescriptor descriptorType])
                        {
                            // result is a list of other descriptors
                        }
                        else
                        {
                            // coerce the result to the appropriate ObjC type
                        }
                    }
                }
                else
                {
                    // no script result, handle error here
                }
            }
        }
    }
}

- (IBAction)launchWithHardCodedScriptAction:(id)sender
{
    [self launchWithHardCodedScript];
}
@end
